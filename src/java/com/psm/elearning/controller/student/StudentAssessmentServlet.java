package com.psm.elearning.controller.student;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Standalone student assessments page has been retired.
 * Keep this route as a compatibility redirect so old links still resolve.
 */
public class StudentAssessmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        redirectToLearningHub(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        redirectToLearningHub(request, response);
    }

    private void redirectToLearningHub(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (!isStudent(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String enrollmentId = request.getParameter("enrollmentId");
        if (enrollmentId != null && !enrollmentId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/student/my-enrollments");
    }

    private boolean isStudent(HttpSession session) {
        return session != null && session.getAttribute("student") != null;
    }
}
