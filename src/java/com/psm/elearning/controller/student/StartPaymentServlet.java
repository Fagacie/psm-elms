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
import com.psm.elearning.service.PaystackService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Servlet to initialize a Paystack payment transaction.
 * Creates a Payment record and redirects to Paystack's authorization URL.
 */
public class StartPaymentServlet extends HttpServlet {

    private EnrollmentDAO enrollmentDAO;
    private CourseDAO courseDAO;
    private PaymentDAO paymentDAO;
    private PaystackService paystackService;

    @Override
    public void init() {
        System.out.println("StartPaymentServlet.init: initializing");
        enrollmentDAO = new EnrollmentDAOImpl();
        courseDAO = new CourseDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        paystackService = new PaystackService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("StartPaymentServlet.doPost: start");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("StartPaymentServlet: no session; redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (role == null) {
            role = (String) session.getAttribute("userRole");
        }
        if (!"Student".equals(role)) {
            System.out.println("StartPaymentServlet: unauthorized role=" + role);
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        try {
            Integer userId = (Integer) session.getAttribute("userId");
            String userEmail = (String) session.getAttribute("email");
            if (userEmail == null || userEmail.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + request.getParameter("enrollmentId") + "&error=noemail");
                return;
            }
            Integer enrollmentId = Integer.parseInt(request.getParameter("enrollmentId"));

            System.out.println("StartPaymentServlet: userId=" + userId + ", enrollmentId=" + enrollmentId);

            // Get enrollment to verify ownership and get course fee
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            if (enrollment == null) {
                System.err.println("StartPaymentServlet: enrollment not found id=" + enrollmentId);
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=notfound");
                return;
            }

            // Verify ownership
            if (!enrollment.getUserId().equals(userId)) {
                System.err.println("StartPaymentServlet: unauthorized access to enrollment=" + enrollmentId);
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }

            // Fetch course to get fee
            Course course = courseDAO.findById(enrollment.getCourseId());
            if (course == null) {
                System.err.println("StartPaymentServlet: course not found id=" + enrollment.getCourseId());
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=coursenotfound");
                return;
            }

            // Check if already paid
            Payment existingPayment = paymentDAO.getPaymentByEnrollmentId(enrollmentId);
            if (existingPayment != null && "Paid".equalsIgnoreCase(existingPayment.getStatus())) {
                System.out.println("StartPaymentServlet: enrollment already paid id=" + enrollmentId);
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?message=alreadypaid");
                return;
            }

            BigDecimal amount = course.getCourseFee();
            System.out.println("StartPaymentServlet: amount=" + amount + ", email=" + userEmail);

            // Generate external reference
            String externalReference = "PSME_" + enrollmentId + "_" + UUID.randomUUID().toString();
            System.out.println("StartPaymentServlet: generated externalReference=" + externalReference);

            // Initialize Paystack transaction with external reference
                System.out.println("StartPaymentServlet: calling PaystackService.initializeTransaction...");
                Payment initResult = paystackService.initializeTransaction(
                    userEmail,
                    amount.doubleValue(),
                    enrollmentId,
                    externalReference
                );

                if (initResult != null) {
                System.out.println("StartPaymentServlet: Paystack initialization successful");

                String authorizationUrl = initResult.getAuthorizationUrl();
                String accessCode = initResult.getAccessCode();
                String paystackReference = initResult.getPaystackReference();
                if (paystackReference == null || paystackReference.trim().isEmpty()) {
                    paystackReference = externalReference;
                }

                System.out.println("StartPaymentServlet: authorizationUrl=" + authorizationUrl);
                System.out.println("StartPaymentServlet: accessCode=" + accessCode);
                System.out.println("StartPaymentServlet: paystackReference=" + paystackReference);

                // Create or update Payment record
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

                System.out.println("StartPaymentServlet: creating/updating Payment record...");
                Payment createdPayment = paymentDAO.createPayment(payment);
                if (createdPayment == null) {
                    System.err.println("StartPaymentServlet: failed to persist payment record");
                    response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + enrollmentId + "&error=initstore");
                    return;
                }
                System.out.println("StartPaymentServlet: Payment record created/updated");

                // Redirect to Paystack authorization URL
                System.out.println("StartPaymentServlet: redirecting to Paystack authorizationUrl");
                response.sendRedirect(authorizationUrl);

            } else {
                System.err.println("StartPaymentServlet: Paystack initialization failed");
                String errorMsg = "Unknown error";
                System.err.println("StartPaymentServlet: error message=" + errorMsg);
                response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + enrollmentId + "&error=paystack");
            }

        } catch (NumberFormatException e) {
            System.err.println("StartPaymentServlet: invalid enrollmentId");
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
        } catch (Exception e) {
            System.err.println("StartPaymentServlet: Exception: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=exception");
        }
    }
}
