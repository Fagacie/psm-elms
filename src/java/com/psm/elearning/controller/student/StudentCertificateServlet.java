package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CertificateDAO;
import com.psm.elearning.dao.CertificateDAOImpl;
import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.StudentDAO;
import com.psm.elearning.dao.StudentDAOImpl;
import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.model.Certificate;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Student;
import com.psm.elearning.model.User;
import com.psm.elearning.service.EnrollmentStateSyncService;
import com.psm.elearning.util.CloudinaryUtil;
import com.psm.elearning.util.QRUtil;
import com.psm.elearning.util.SessionUtil;

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
    private final EnrollmentStateSyncService enrollmentStateSyncService = new EnrollmentStateSyncService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isStudent(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = SessionUtil.resolveUserId(session);
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
        EnrollmentStateSyncService.SyncResult syncResult = enrollmentStateSyncService.syncEnrollmentState(enrollment);
        boolean freeCourse = course != null && course.getCourseFee() != null && course.getCourseFee().doubleValue() <= 0d;

        Certificate certificate = certificateDAO.findByEnrollment(enrollmentId);

        request.setAttribute("eligible", !freeCourse && syncResult.isEligibleForCertificate());
        request.setAttribute("diagPaid", syncResult.isPaid());
        request.setAttribute("diagCompleted", syncResult.isCompleted());
        request.setAttribute("diagPassedAllAssessments", syncResult.isPassedAllAssessments());
        request.setAttribute("diagProgress", syncResult.getProgressPercent());
        request.setAttribute("diagViewedMaterials", syncResult.getViewedMaterials());
        request.setAttribute("diagTotalMaterials", syncResult.getTotalMaterials());
        request.setAttribute("diagPassedAssessments", syncResult.getPassedAssessments());
        request.setAttribute("diagTotalAssessments", syncResult.getTotalAssessments());
        request.setAttribute("diagViewedAllMaterials", syncResult.hasViewedAllMaterials());
        request.setAttribute("diagPassedRequiredAssessments", syncResult.hasPassedRequiredAssessments());
        request.setAttribute("eligibilitySummary", freeCourse
            ? "Free courses do not issue completion certificates."
            : syncResult.getBlockingReasonSummary());
        request.setAttribute("missingRequirements", syncResult.getMissingRequirements());
        request.setAttribute("enrollment", enrollment);
        request.setAttribute("course", course);
        request.setAttribute("studentUser", studentUser);
        request.setAttribute("studentProfile", studentProfile);
        request.setAttribute("certificate", certificate);
        request.setAttribute("canGenerate", !freeCourse && syncResult.isEligibleForCertificate() && certificate == null);
        request.getRequestDispatcher("/WEB-INF/views/student/certificate.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isStudent(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = SessionUtil.resolveUserId(session);
        String redirectTo = request.getParameter("redirectTo");
        boolean backToCertificates = "certificates".equalsIgnoreCase(redirectTo);
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
        boolean freeCourse = course != null && course.getCourseFee() != null && course.getCourseFee().doubleValue() <= 0d;
        if (freeCourse) {
            if (backToCertificates) {
                response.sendRedirect(request.getContextPath() + "/student/certificates?error=nocertificatefree");
            } else {
                response.sendRedirect(request.getContextPath() + "/student/certificate?enrollmentId=" + enrollmentId + "&error=nocertificatefree");
            }
            return;
        }

        EnrollmentStateSyncService.SyncResult syncResult = enrollmentStateSyncService.syncEnrollmentState(enrollment);
        if (!syncResult.isEligibleForCertificate()) {
            String reasonQuery = buildEligibilityReasonQuery(syncResult);
            if (backToCertificates) {
                response.sendRedirect(request.getContextPath() + "/student/certificates?error=noteligible&enrollmentId=" + enrollmentId + reasonQuery);
            } else {
                response.sendRedirect(request.getContextPath() + "/student/certificate?enrollmentId=" + enrollmentId + "&error=noteligible" + reasonQuery);
            }
            return;
        }

        Certificate certificate = certificateDAO.findByEnrollment(enrollmentId);
        if (certificate == null) {
            certificate = issueCertificate(request, enrollmentId);
            if (certificate == null) {
                if (backToCertificates) {
                    response.sendRedirect(request.getContextPath() + "/student/certificates?error=generatefail&enrollmentId=" + enrollmentId);
                } else {
                    response.sendRedirect(request.getContextPath() + "/student/certificate?enrollmentId=" + enrollmentId + "&error=generatefail");
                }
                return;
            }
        }

        if (backToCertificates) {
            response.sendRedirect(request.getContextPath() + "/student/certificates?success=generated");
        } else {
            response.sendRedirect(request.getContextPath() + "/student/certificate?enrollmentId=" + enrollmentId);
        }
    }

    private Certificate issueCertificate(HttpServletRequest request, int enrollmentId) {
        String certificateNo = buildUniqueCertificateNo();
        String verifyUrl = buildBaseUrl(request) + request.getContextPath() + "/certificate/verify?code=" + certificateNo;

        Certificate certificate = new Certificate();
        certificate.setEnrollmentId(enrollmentId);
        certificate.setCertificateNo(certificateNo);
        certificate.setGeneratedBy("System Auto");
        certificate.setVerificationURL(verifyUrl);
        String qrUrl = uploadQrCode(verifyUrl, certificateNo);
        certificate.setQrCodePath(qrUrl);

        Certificate created = certificateDAO.create(certificate);
        if (created == null) {
            return certificateDAO.findByEnrollment(enrollmentId);
        }
        return created;
    }

    private String uploadQrCode(String verifyUrl, String certificateNo) {
        byte[] qrBytes = QRUtil.generateQRCodeBytes(verifyUrl);
        if (qrBytes == null) return null;
        String fileName = "certificate_qr_" + certificateNo + ".png";
        return CloudinaryUtil.uploadFile(qrBytes, fileName, CloudinaryUtil.getCertificatesFolder(), "image");
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

    private String buildEligibilityReasonQuery(EnrollmentStateSyncService.SyncResult syncResult) {
        StringBuilder reasons = new StringBuilder();
        if (!syncResult.isPaid()) {
            reasons.append("payment");
        }
        if (!syncResult.hasViewedAllMaterials()) {
            if (reasons.length() > 0) reasons.append(',');
            reasons.append("materials");
        }
        if (!syncResult.hasPassedRequiredAssessments()) {
            if (reasons.length() > 0) reasons.append(',');
            reasons.append("assessments");
        }
        return reasons.length() > 0 ? "&reason=" + reasons : "";
    }

    private Integer parseInt(String value) {
        try {
            if (value == null) return null;
            String cleaned = value.trim();
            if (cleaned.isEmpty()) return null;
            return Integer.parseInt(cleaned);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean isStudent(HttpSession session) {
        return SessionUtil.resolveUserId(session) != null && "Student".equals(SessionUtil.resolveRole(session));
    }
}

