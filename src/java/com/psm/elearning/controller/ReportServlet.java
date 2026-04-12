package com.psm.elearning.controller;

import com.psm.elearning.dao.ReportDAO;
import com.psm.elearning.dao.ReportDAOImpl;
import com.psm.elearning.model.User;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

public class ReportServlet extends HttpServlet {

    private ReportDAO reportDAO;
    private static final Pattern DATE_PATTERN = Pattern.compile("^\\d{4}-\\d{2}-\\d{2}$");

    @Override
    public void init() throws ServletException {
        super.init();
        reportDAO = new ReportDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String role = SessionUtil.resolveRole(session);
        if (role == null) role = user.getRole();

        String ip = request.getRemoteAddr();
        Integer userId = user.getUserId();
        String startDate = sanitizeDate(request.getParameter("startDate"));
        String endDate = sanitizeDate(request.getParameter("endDate"));
        String export = sanitize(request.getParameter("export"), "");
        String filtersJson = buildFiltersJson(startDate, endDate);

        try {
            if (!"Admin".equals(role)) {
                reportDAO.logReportAccess(userId, role, "admin-only-report", filtersJson, "Denied", ip);
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }

            Map<String, Object> summary = reportDAO.getAdminSummary(startDate, endDate);
            List<Map<String, Object>> topCourses = reportDAO.getTopCoursesByEnrollment(10, startDate, endDate);
            List<Map<String, Object>> revenueRows = reportDAO.getRevenueByCourse(10, startDate, endDate);
            List<Map<String, Object>> recentExports = reportDAO.getRecentExports(12);

            if ("csv".equalsIgnoreCase(export)) {
                reportDAO.saveGeneratedReport(userId, role, "admin-overview", filtersJson, "CSV", null);
                reportDAO.logReportAccess(userId, role, "admin-overview-export-csv", filtersJson, "Success", ip);
                writeAdminCsv(response, summary, topCourses, revenueRows, startDate, endDate);
                return;
            }

            request.setAttribute("reportSummary", summary);
            request.setAttribute("topCourses", topCourses);
            request.setAttribute("revenueRows", revenueRows);
            request.setAttribute("recentExports", recentExports);
            request.setAttribute("selectedStartDate", startDate);
            request.setAttribute("selectedEndDate", endDate);

            if ("pdf".equalsIgnoreCase(export)) {
                reportDAO.saveGeneratedReport(userId, role, "admin-overview", filtersJson, "PDF_PRINT", null);
                reportDAO.logReportAccess(userId, role, "admin-overview-export-pdf", filtersJson, "Success", ip);
                request.getRequestDispatcher("/WEB-INF/views/admin/admin-reports-print.jsp").forward(request, response);
                return;
            }

            reportDAO.logReportAccess(userId, role, "admin-overview", filtersJson, "Success", ip);
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-reports.jsp").forward(request, response);
        } catch (Exception e) {
            reportDAO.logReportAccess(userId, role, "report-error", filtersJson, "Failed", ip);
            request.setAttribute("error", "Unable to load report module right now.");
            request.setAttribute("reportSummary", java.util.Collections.emptyMap());
            request.setAttribute("topCourses", java.util.Collections.emptyList());
            request.setAttribute("revenueRows", java.util.Collections.emptyList());
            request.setAttribute("recentExports", java.util.Collections.emptyList());
            request.setAttribute("selectedStartDate", startDate);
            request.setAttribute("selectedEndDate", endDate);
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-reports.jsp").forward(request, response);
        }
    }

    private void writeAdminCsv(HttpServletResponse response,
                               Map<String, Object> summary,
                               List<Map<String, Object>> topCourses,
                               List<Map<String, Object>> revenueRows,
                               String startDate,
                               String endDate) throws IOException {
        response.setContentType("text/csv");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=admin-report.csv");

        PrintWriter writer = response.getWriter();
        writer.println("PSME Admin Report");
        writer.println("Date Range," + csv(startDate) + " to " + csv(endDate));
        writer.println();

        writer.println("Summary Metric,Value");
        writer.println("Total Users," + value(summary.get("totalUsers")));
        writer.println("Total Students," + value(summary.get("totalStudents")));
        writer.println("Total Instructors," + value(summary.get("totalInstructors")));
        writer.println("Total Courses," + value(summary.get("totalCourses")));
        writer.println("Total Enrollments," + value(summary.get("totalEnrollments")));
        writer.println("Completed Enrollments," + value(summary.get("completedEnrollments")));
        writer.println("Active Certificates," + value(summary.get("activeCertificates")));
        writer.println("Total Revenue," + value(summary.get("totalRevenue")));
        writer.println("Filtered Enrollments," + value(summary.get("filteredEnrollments")));
        writer.println("Filtered Completed Enrollments," + value(summary.get("filteredCompletedEnrollments")));
        writer.println("Filtered Revenue," + value(summary.get("filteredRevenue")));
        writer.println("New Users In Range," + value(summary.get("newUsersInRange")));
        writer.println();

        writer.println("Top Courses by Enrollment");
        writer.println("Course,Enrollments,Completions,Completion Rate,Average Progress");
        for (Map<String, Object> row : topCourses) {
            writer.println(csv(value(row.get("title"))) + "," +
                    value(row.get("enrollments")) + "," +
                    value(row.get("completions")) + "," +
                    value(row.get("completionRate")) + "," +
                    value(row.get("avgProgress")));
        }
        writer.println();

        writer.println("Revenue by Course");
        writer.println("Course,Enrollments,Revenue");
        for (Map<String, Object> row : revenueRows) {
            writer.println(csv(value(row.get("title"))) + "," +
                    value(row.get("enrollments")) + "," +
                    value(row.get("revenue")));
        }
        writer.flush();
    }

    private String value(Object value) {
        return value == null ? "0" : String.valueOf(value);
    }

    private String csv(String value) {
        if (value == null) {
            return "";
        }
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }

    private String sanitize(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }

    private String sanitizeDate(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "";
        }
        String candidate = value.trim();
        return DATE_PATTERN.matcher(candidate).matches() ? candidate : "";
    }

    private String buildFiltersJson(String startDate, String endDate) {
        List<String> entries = new ArrayList<>();
        if (startDate != null && !startDate.isEmpty()) {
            entries.add("\"startDate\":\"" + startDate + "\"");
        }
        if (endDate != null && !endDate.isEmpty()) {
            entries.add("\"endDate\":\"" + endDate + "\"");
        }
        if (entries.isEmpty()) {
            return "{}";
        }
        return "{" + String.join(",", entries) + "}";
    }
}
