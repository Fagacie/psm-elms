package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Payment;
import com.psm.elearning.service.StudentAccessService;
import com.psm.elearning.service.PaystackService;
import com.psm.elearning.service.AppSettingsService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet to process course enrollment and route the student to payment (or auto-complete free enrollments).
 */
public class ProcessEnrollmentServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(ProcessEnrollmentServlet.class.getName());
    
    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private PaymentDAO paymentDAO;
    private PaystackService paystackService;
    private StudentAccessService studentAccessService;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        courseDAO = new CourseDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        paystackService = new PaystackService();
        studentAccessService = new StudentAccessService();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (!studentAccessService.isStudentSession(session) || userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            String userEmail = (String) session.getAttribute("email");
            Integer courseId = parseCourseId(request.getParameter("courseId"));
            if (courseId == null) {
                response.sendRedirect(request.getContextPath() + "/student/courses?error=invalid");
                return;
            }

            if (userEmail == null || userEmail.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/login?error=session");
                return;
            }
            
            Enrollment existingEnrollment = enrollmentDAO.findLatestEnrollmentByUserAndCourse(userId, courseId);
            if (existingEnrollment != null) {
                Payment existingPayment = paymentDAO.getPaymentByEnrollmentId(existingEnrollment.getEnrollmentId());
                String paymentStatus = existingPayment != null ? existingPayment.getStatus() : existingEnrollment.getPaymentStatus();
                if (studentAccessService.isPaymentComplete(paymentStatus)) {
                    response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=already");
                } else {
                    Course existingCourse = courseDAO.findById(courseId);
                    if (existingCourse != null && isFreeCourse(existingCourse.getCourseFee())) {
                        String freeReference = "FREE-" + existingEnrollment.getEnrollmentId() + "-" + UUID.randomUUID().toString().substring(0, 8);
                        enrollmentDAO.updatePaymentStatus(existingEnrollment.getEnrollmentId(), "Paid", freeReference);
                        enrollmentDAO.updateStatus(existingEnrollment.getEnrollmentId(), "Enrolled");

                        Payment freePayment = new Payment();
                        freePayment.setEnrollmentId(existingEnrollment.getEnrollmentId());
                        freePayment.setAmount(0.0);
                        freePayment.setMethod("Free");
                        freePayment.setStatus("Paid");
                        freePayment.setPaymentRef(freeReference);
                        freePayment.setPaystackReference(freeReference);
                        freePayment.setPaystackStatus("success");
                        paymentDAO.createPayment(freePayment);

                        response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + existingEnrollment.getEnrollmentId() + "&message=freeenrolled");
                    } else {
                        triggerDirectPayment(request, response, existingEnrollment, existingCourse, userEmail);
                    }
                }
                return;
            }
            
            // Get course details
            Course course = courseDAO.findById(courseId);
            if (course == null) {
                response.sendRedirect(request.getContextPath() + "/student/courses?error=notfound");
                return;
            }
            
            // Create enrollment first; payment gating is resolved below.
            Enrollment enrollment = new Enrollment(userId, courseId, "Enrolled", "Pending");
            enrollment = enrollmentDAO.createEnrollment(enrollment);

            if (enrollment != null) {
                boolean freeCourse = isFreeCourse(course.getCourseFee());
                if (freeCourse) {
                    String freeReference = "FREE-" + enrollment.getEnrollmentId() + "-" + UUID.randomUUID().toString().substring(0, 8);
                    enrollmentDAO.updatePaymentStatus(enrollment.getEnrollmentId(), "Paid", freeReference);
                    enrollmentDAO.updateStatus(enrollment.getEnrollmentId(), "Enrolled");

                    Payment freePayment = new Payment();
                    freePayment.setEnrollmentId(enrollment.getEnrollmentId());
                    freePayment.setAmount(0.0);
                    freePayment.setMethod("Free");
                    freePayment.setStatus("Paid");
                    freePayment.setPaymentRef(freeReference);
                    freePayment.setPaystackReference(freeReference);
                    freePayment.setPaystackStatus("success");
                    paymentDAO.createPayment(freePayment);

                    response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollment.getEnrollmentId() + "&message=freeenrolled");
                    return;
                }

                triggerDirectPayment(request, response, enrollment, course, userEmail);
            } else {
                response.sendRedirect(request.getContextPath() + "/student/courses?error=failed");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/student/courses?error=invalid");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/student/courses?error=exception");
        }
    }

    private void triggerDirectPayment(HttpServletRequest request, HttpServletResponse response, 
                                     Enrollment enrollment, Course course, String userEmail) 
            throws IOException {
        int enrollmentId = enrollment.getEnrollmentId();
        try {
            if (!paystackService.isConfiguredForPayments()) {
                LOGGER.severe("Payment start blocked in ProcessEnrollmentServlet: Paystack keys are not configured");
                response.sendRedirect(request.getContextPath() + "/student/enrollment-summary?courseId=" + course.getCourseId() + "&error=paystackconfig");
                return;
            }
            
            BigDecimal amount = course.getCourseFee();
            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&message=freeenrolled");
                return;
            }
            
            // Generate external reference
            String externalReference = "PSME_" + enrollmentId + "_" + UUID.randomUUID().toString();
            LOGGER.info("Generated payment reference=" + maskReference(externalReference));
            
            String callbackUrl = buildCallbackUrl(request);
            Payment initResult = paystackService.initializeTransaction(
                    userEmail,
                    amount.doubleValue(),
                    enrollmentId,
                    externalReference,
                    callbackUrl
            );
            
            if (initResult != null) {
                String authorizationUrl = initResult.getAuthorizationUrl();
                String accessCode = initResult.getAccessCode();
                String paystackReference = initResult.getPaystackReference();
                if (paystackReference == null || paystackReference.trim().isEmpty()) {
                    paystackReference = externalReference;
                }
                
                Payment existingPayment = paymentDAO.getPaymentByEnrollmentId(enrollmentId);
                boolean paymentStored;
                if (existingPayment != null && !studentAccessService.isPaymentComplete(existingPayment.getStatus())) {
                    paymentStored = paymentDAO.refreshPaymentInitialization(
                            existingPayment.getPaymentId(),
                            amount.doubleValue(),
                            "Paystack",
                            paystackReference,
                            accessCode,
                            authorizationUrl,
                            "pending"
                    );
                } else {
                    Payment payment = new Payment();
                    payment.setEnrollmentId(enrollmentId);
                    payment.setAmount(amount.doubleValue());
                    payment.setStatus("Pending");
                    payment.setMethod("Paystack");
                    payment.setPaymentRef(paystackReference);
                    payment.setPaystackReference(paystackReference);
                    payment.setAccessCode(accessCode);
                    payment.setAuthorizationUrl(authorizationUrl);
                    payment.setPaystackStatus("pending");
                    payment.setPaymentDate(LocalDateTime.now());
                    paymentStored = paymentDAO.createPayment(payment) != null;
                }
                
                if (!paymentStored) {
                    LOGGER.severe("Failed to persist payment record in ProcessEnrollmentServlet for enrollmentId=" + enrollmentId);
                    response.sendRedirect(request.getContextPath() + "/student/enrollment-summary?courseId=" + course.getCourseId() + "&error=initstore");
                    return;
                }
                
                enrollmentDAO.updatePaymentStatus(enrollmentId, "Pending", paystackReference);
                LOGGER.info("Redirecting directly to Paystack authorization URL: " + authorizationUrl);
                response.sendRedirect(authorizationUrl);
            } else {
                LOGGER.severe("Paystack initialization returned null in ProcessEnrollmentServlet");
                response.sendRedirect(request.getContextPath() + "/student/enrollment-summary?courseId=" + course.getCourseId() + "&error=paystack");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error initiating direct payment in ProcessEnrollmentServlet", e);
            response.sendRedirect(request.getContextPath() + "/student/enrollment-summary?courseId=" + course.getCourseId() + "&error=exception");
        }
    }

    private String buildCallbackUrl(HttpServletRequest request) {
        String configured = AppSettingsService.getString(AppSettingsService.KEY_PAYMENT_CALLBACK_URL, "");
        if (!configured.isEmpty()) {
            return configured;
        }
        
        String scheme = request.getHeader("X-Forwarded-Proto");
        if (scheme == null || scheme.trim().isEmpty()) {
            scheme = request.getScheme();
        }
        
        String server = request.getHeader("X-Forwarded-Host");
        if (server == null || server.trim().isEmpty()) {
            server = request.getServerName();
        } else {
            if (server.contains(":")) {
                server = server.split(":")[0];
            }
        }
        
        String forwardedPort = request.getHeader("X-Forwarded-Port");
        int port = -1;
        if (forwardedPort != null && !forwardedPort.trim().isEmpty()) {
            try {
                port = Integer.parseInt(forwardedPort.trim());
            } catch (NumberFormatException ignored) {}
        }
        if (port == -1) {
            port = request.getServerPort();
        }
        
        boolean defaultPort = ("http".equalsIgnoreCase(scheme) && (port == 80 || port == 8080))
                || ("https".equalsIgnoreCase(scheme) && (port == 443 || port == 8443));
                
        String host;
        if (request.getHeader("X-Forwarded-Host") != null) {
            host = scheme + "://" + server;
        } else {
            host = defaultPort ? (scheme + "://" + server) : (scheme + "://" + server + ":" + port);
        }
        
        return host + request.getContextPath() + "/student/payment-callback";
    }

    private String maskReference(String reference) {
        if (reference == null || reference.isEmpty()) {
            return "-";
        }
        if (reference.length() <= 8) {
            return "****";
        }
        return reference.substring(0, 4) + "..." + reference.substring(reference.length() - 4);
    }

    private Integer parseCourseId(String value) {
        if (value == null) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private boolean isFreeCourse(BigDecimal fee) {
        return fee == null || fee.compareTo(BigDecimal.ZERO) <= 0;
    }

}
