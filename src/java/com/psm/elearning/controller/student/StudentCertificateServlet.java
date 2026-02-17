package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CertificateDAO;
import com.psm.elearning.dao.CertificateDAOImpl;
import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.dao.StudentDAO;
import com.psm.elearning.dao.StudentDAOImpl;
import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.model.Certificate;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Payment;
import com.psm.elearning.model.Student;
import com.psm.elearning.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

public class StudentCertificateServlet extends HttpServlet {

    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final CertificateDAO certificateDAO = new CertificateDAOImpl();
    private final UserDAO userDAO = new UserDAOImpl();
    private final StudentDAO studentDAO = new StudentDAOImpl();
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isStudent(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        Integer enrollmentId = parseInt(request.getParameter("enrollmentId"));
        if (enrollmentId == null) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
            return;
        }

        Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
        if (enrollment == null || enrollment.getUserId() == null || !enrollment.getUserId().equals(userId)) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=permission");
            return;
        }

        Course course = courseDAO.findById(enrollment.getCourseId());
        User studentUser = userDAO.findById(userId);
        Student studentProfile = studentDAO.findByUserId(userId);
        boolean eligible = isEligible(enrollment);

        Certificate certificate = certificateDAO.findByEnrollment(enrollmentId);
        if (certificate == null && eligible) {
            certificate = issueCertificate(request, enrollmentId);
        }

        request.setAttribute("eligible", eligible);
        request.setAttribute("enrollment", enrollment);
        request.setAttribute("course", course);
        request.setAttribute("studentUser", studentUser);
        request.setAttribute("studentProfile", studentProfile);
        request.setAttribute("certificate", certificate);
        request.getRequestDispatcher("/WEB-INF/views/student/certificate.jsp").forward(request, response);
    }

    private boolean isEligible(Enrollment enrollment) {
        boolean paid = false;
        if (enrollment.getPaymentStatus() != null) {
            paid = "Paid".equalsIgnoreCase(enrollment.getPaymentStatus());
        }
        if (!paid && enrollment.getEnrollmentId() != null) {
            Payment payment = paymentDAO.getPaymentByEnrollmentId(enrollment.getEnrollmentId());
            paid = payment != null && "Paid".equalsIgnoreCase(payment.getStatus());
        }

        boolean completed = "Completed".equalsIgnoreCase(enrollment.getCompletionStatus())
                || "Completed".equalsIgnoreCase(enrollment.getStatus());

        return paid && completed;
    }

    private Certificate issueCertificate(HttpServletRequest request, int enrollmentId) {
        String certificateNo = buildUniqueCertificateNo();
        String verifyUrl = buildBaseUrl(request) + request.getContextPath() + "/certificate/verify?code=" + certificateNo;

        Certificate certificate = new Certificate();
        certificate.setEnrollmentId(enrollmentId);
        certificate.setCertificateNo(certificateNo);
        certificate.setGeneratedBy("System Auto");
        certificate.setVerificationURL(verifyUrl);
        certificate.setQrCodePath(verifyUrl);

        return certificateDAO.create(certificate);
    }

    private String buildUniqueCertificateNo() {
        DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyyMMdd");
        String baseDate = LocalDateTime.now().format(f);
        for (int i = 0; i < 8; i++) {
            String suffix = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
            String no = "PSM-CERT-" + baseDate + "-" + suffix;
            if (certificateDAO.findByCertificateNo(no) == null) {
                return no;
            }
        }
        return "PSM-CERT-" + baseDate + "-" + System.currentTimeMillis();
    }

    private String buildBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String server = request.getServerName();
        int port = request.getServerPort();
        if (("http".equalsIgnoreCase(scheme) && port == 80) || ("https".equalsIgnoreCase(scheme) && port == 443)) {
            return scheme + "://" + server;
        }
        return scheme + "://" + server + ":" + port;
    }

    private Integer parseInt(String value) {
        try {
            if (value == null || value.trim().isEmpty()) return null;
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean isStudent(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        return "Student".equals(role);
    }
}
