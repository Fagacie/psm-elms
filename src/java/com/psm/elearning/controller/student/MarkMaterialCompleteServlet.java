package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.dao.MaterialProgressDAO;
import com.psm.elearning.dao.MaterialProgressDAOImpl;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.logging.Logger;

/**
 * AJAX endpoint to mark a material as completed/viewed.
 * Used by Learning Hub to update progress without full page reload.
 */
public class MarkMaterialCompleteServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MarkMaterialCompleteServlet.class.getName());

    private MaterialProgressDAO materialProgressDAO;
    private EnrollmentDAO enrollmentDAO;
    private MaterialDAO materialDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        materialProgressDAO = new MaterialProgressDAOImpl();
        enrollmentDAO = new EnrollmentDAOImpl();
        materialDAO = new MaterialDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // Get user from session
            HttpSession session = request.getSession();
            Integer userId = SessionUtil.resolveUserId(session);
            
            if (userId == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\": false, \"message\": \"Not authenticated\"}");
                return;
            }

            // Get parameters
            String materialIdParam = request.getParameter("materialId");
            String enrollmentIdParam = request.getParameter("enrollmentId");

            if (materialIdParam == null || enrollmentIdParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Missing parameters\"}");
                return;
            }

            try {
                int materialId = Integer.parseInt(materialIdParam);
                int enrollmentId = Integer.parseInt(enrollmentIdParam);

                // Verify enrollment ownership
                Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
                if (enrollment == null || !enrollment.getUserId().equals(userId)) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"success\": false, \"message\": \"Unauthorized enrollment access\"}");
                    return;
                }

                Material material = materialDAO.findById(materialId);
                if (material == null || material.getCourseId() == null
                        || enrollment.getCourseId() == null
                        || !enrollment.getCourseId().equals(material.getCourseId())) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\": false, \"message\": \"Material does not belong to this enrollment\"}");
                    return;
                }

                boolean success = materialProgressDAO.markCompleted(userId, materialId, material.getCourseId());

                if (success) {
                    out.print("{\"success\": true, \"message\": \"Material marked as completed\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Failed to update material progress\"}");
                }

            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Invalid parameters\"}");
            }

        } catch (Exception e) {
            LOGGER.severe("Error marking material complete: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Server error\"}");
        } finally {
            out.flush();
            out.close();
        }
    }
}
