package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.service.StudentAccessService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet to display payment success page.
 */
public class PaymentSuccessServlet extends HttpServlet {
    
    private EnrollmentDAO enrollmentDAO;
    private StudentAccessService studentAccessService;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        studentAccessService = new StudentAccessService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (!studentAccessService.isStudentSession(session) || userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            Integer enrollmentId = parseEnrollmentId(request.getParameter("enrollmentId"));
            if (enrollmentId == null) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
                return;
            }
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            if (enrollment == null) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=notfound");
                return;
            }
            if (!studentAccessService.belongsToStudent(enrollment, userId)) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }
            
            request.setAttribute("enrollment", enrollment);
            request.getRequestDispatcher("/WEB-INF/views/student/payment-success.jsp").forward(request, response);
            
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments");
        }
    }

    private Integer parseEnrollmentId(String value) {
        if (value == null) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

}
