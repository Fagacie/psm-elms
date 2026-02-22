package com.psm.elearning.controller;

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

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class CertificateVerifyServlet extends HttpServlet {

    private final CertificateDAO certificateDAO = new CertificateDAOImpl();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final UserDAO userDAO = new UserDAOImpl();
    private final StudentDAO studentDAO = new StudentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            request.setAttribute("valid", false);
            request.setAttribute("message", "Certificate code is required.");
            request.getRequestDispatcher("/WEB-INF/views/certificate-verify.jsp").forward(request, response);
            return;
        }

        Certificate certificate = certificateDAO.findByCertificateNo(code.trim());
        if (certificate == null) {
            request.setAttribute("valid", false);
            request.setAttribute("message", "Certificate not found.");
            request.getRequestDispatcher("/WEB-INF/views/certificate-verify.jsp").forward(request, response);
            return;
        }
        if ("Revoked".equalsIgnoreCase(certificate.getStatus())) {
            request.setAttribute("valid", false);
            request.setAttribute("message", "Certificate has been revoked.");
            request.getRequestDispatcher("/WEB-INF/views/certificate-verify.jsp").forward(request, response);
            return;
        }

        Enrollment enrollment = enrollmentDAO.getEnrollment(certificate.getEnrollmentId());
        Course course = enrollment != null ? courseDAO.findById(enrollment.getCourseId()) : null;
        User studentUser = enrollment != null ? userDAO.findById(enrollment.getUserId()) : null;
        Student student = enrollment != null ? studentDAO.findByUserId(enrollment.getUserId()) : null;

        request.setAttribute("valid", true);
        request.setAttribute("certificate", certificate);
        request.setAttribute("enrollment", enrollment);
        request.setAttribute("course", course);
        request.setAttribute("studentUser", studentUser);
        request.setAttribute("studentProfile", student);
        request.getRequestDispatcher("/WEB-INF/views/certificate-verify.jsp").forward(request, response);
    }
}
