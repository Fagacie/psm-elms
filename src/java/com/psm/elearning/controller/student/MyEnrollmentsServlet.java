package com.psm.elearning.controller.student;

import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
import com.psm.elearning.service.StudentAccessService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet to display student's enrollments.
 */
public class MyEnrollmentsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MyEnrollmentsServlet.class.getName());

    private EnrollmentDAO enrollmentDAO;
    private MaterialDAO materialDAO;
    private AssessmentDAO assessmentDAO;
    private StudentAccessService studentAccessService;

    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        materialDAO = new MaterialDAOImpl();
        assessmentDAO = new AssessmentDAOImpl();
        studentAccessService = new StudentAccessService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = SessionUtil.resolveUserId(session);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!studentAccessService.isStudentSession(session)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        try {
            List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
            if (enrollments == null) enrollments = new ArrayList<>();
            int inProgressCount = 0;
            int completedCount = 0;
            int paidCount = 0;
            Map<Integer, Integer> materialCountByCourse = new HashMap<>();
            Map<Integer, Integer> assessmentCountByCourse = new HashMap<>();

            for (Enrollment e : enrollments) {
                if (studentAccessService.isPaymentComplete(e.getPaymentStatus())) {
                    paidCount++;
                }
                if ("Completed".equalsIgnoreCase(e.getCompletionStatus()) || "Completed".equalsIgnoreCase(e.getStatus())) {
                    completedCount++;
                } else if ("In Progress".equalsIgnoreCase(e.getCompletionStatus())
                        || "Active".equalsIgnoreCase(e.getStatus())
                        || "Enrolled".equalsIgnoreCase(e.getStatus())) {
                    inProgressCount++;
                }

                if (e.getCourseId() != null && !materialCountByCourse.containsKey(e.getCourseId())) {
                    List<Material> materials = materialDAO.findByCourse(e.getCourseId());
                    List<Assessment> assessments = assessmentDAO.findByCourse(e.getCourseId());
                    materialCountByCourse.put(e.getCourseId(), materials != null ? materials.size() : 0);
                    assessmentCountByCourse.put(e.getCourseId(), assessments != null ? assessments.size() : 0);
                }
            }

            request.setAttribute("enrollments", enrollments);
            request.setAttribute("inProgressCount", inProgressCount);
            request.setAttribute("completedCount", completedCount);
            request.setAttribute("paidCount", paidCount);
            request.setAttribute("materialCountByCourse", materialCountByCourse);
            request.setAttribute("assessmentCountByCourse", assessmentCountByCourse);
            request.getRequestDispatcher("/WEB-INF/views/student/my-enrollments.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("=== MYENROLLMENTS SERVLET EXCEPTION DIAGNOSTICS ===");
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, "MyEnrollmentsServlet failed to load enrollments", e);
            response.sendRedirect(request.getContextPath() + "/dashboard?error=exception");
        }
    }

}
