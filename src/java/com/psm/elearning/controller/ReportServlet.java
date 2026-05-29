package com.psm.elearning.controller;

import com.psm.elearning.dao.ReportDAO;
import com.psm.elearning.dao.ReportDAOImpl;
import com.psm.elearning.model.User;
import com.psm.elearning.util.SessionUtil;
import com.psm.elearning.util.ReflectionPdfBoxGenerator;
import com.psm.elearning.util.SimplePdfWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
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
            List<Map<String, Object>> userRoles = reportDAO.getUserRoleBreakdown();
            List<Map<String, Object>> userStatuses = reportDAO.getUserStatusBreakdown();
            List<Map<String, Object>> courseStatuses = reportDAO.getCourseStatusBreakdown();
            List<Map<String, Object>> enrollmentStatuses = reportDAO.getEnrollmentStatusBreakdown();
            List<Map<String, Object>> paymentStatuses = reportDAO.getPaymentStatusBreakdown();
            List<Map<String, Object>> certificateStatuses = reportDAO.getCertificateStatusBreakdown();
            Map<String, Object> assessmentSummary = reportDAO.getAssessmentSummary();
            List<Map<String, Object>> gradingModes = reportDAO.getAssessmentGradingModeBreakdown();
            List<Map<String, Object>> submissionModes = reportDAO.getAssessmentSubmissionModeBreakdown();
            List<Map<String, Object>> reportAccessStatuses = reportDAO.getReportAccessStatusBreakdown();

            if ("csv".equalsIgnoreCase(export)) {
                reportDAO.saveGeneratedReport(userId, role, "admin-overview", filtersJson, "CSV", null);
                reportDAO.logReportAccess(userId, role, "admin-overview-export-csv", filtersJson, "Success", ip);
                writeAdminCsv(response, summary, topCourses, revenueRows, startDate, endDate);
                return;
            }

            if ("pdf".equalsIgnoreCase(export)) {
                reportDAO.saveGeneratedReport(userId, role, "admin-overview", filtersJson, "PDF", null);
                reportDAO.logReportAccess(userId, role, "admin-overview-export-pdf", filtersJson, "Success", ip);
                writeAdminPdf(response,
                        summary,
                        topCourses,
                        revenueRows,
                        recentExports,
                        userRoles,
                        userStatuses,
                        courseStatuses,
                        enrollmentStatuses,
                        paymentStatuses,
                        certificateStatuses,
                        assessmentSummary,
                        gradingModes,
                        submissionModes,
                        reportAccessStatuses,
                        startDate,
                        endDate);
                return;
            }

            request.setAttribute("reportSummary", summary);
            request.setAttribute("topCourses", topCourses);
            request.setAttribute("revenueRows", revenueRows);
            request.setAttribute("recentExports", recentExports);
            request.setAttribute("userRoles", userRoles);
            request.setAttribute("userStatuses", userStatuses);
            request.setAttribute("courseStatuses", courseStatuses);
            request.setAttribute("enrollmentStatuses", enrollmentStatuses);
            request.setAttribute("paymentStatuses", paymentStatuses);
            request.setAttribute("certificateStatuses", certificateStatuses);
            request.setAttribute("assessmentSummary", assessmentSummary);
            request.setAttribute("gradingModes", gradingModes);
            request.setAttribute("submissionModes", submissionModes);
            request.setAttribute("reportAccessStatuses", reportAccessStatuses);
            request.setAttribute("selectedStartDate", startDate);
            request.setAttribute("selectedEndDate", endDate);

            reportDAO.logReportAccess(userId, role, "admin-overview", filtersJson, "Success", ip);
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-reports.jsp").forward(request, response);
        } catch (Exception e) {
            reportDAO.logReportAccess(userId, role, "report-error", filtersJson, "Failed", ip);
            request.setAttribute("error", "Unable to load report module right now.");
            request.setAttribute("reportSummary", java.util.Collections.emptyMap());
            request.setAttribute("topCourses", java.util.Collections.emptyList());
            request.setAttribute("revenueRows", java.util.Collections.emptyList());
            request.setAttribute("recentExports", java.util.Collections.emptyList());
            request.setAttribute("userRoles", java.util.Collections.emptyList());
            request.setAttribute("userStatuses", java.util.Collections.emptyList());
            request.setAttribute("courseStatuses", java.util.Collections.emptyList());
            request.setAttribute("enrollmentStatuses", java.util.Collections.emptyList());
            request.setAttribute("paymentStatuses", java.util.Collections.emptyList());
            request.setAttribute("certificateStatuses", java.util.Collections.emptyList());
            request.setAttribute("assessmentSummary", java.util.Collections.emptyMap());
            request.setAttribute("gradingModes", java.util.Collections.emptyList());
            request.setAttribute("submissionModes", java.util.Collections.emptyList());
            request.setAttribute("reportAccessStatuses", java.util.Collections.emptyList());
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

    private void writeAdminPdf(HttpServletResponse response,
                              Map<String, Object> summary,
                              List<Map<String, Object>> topCourses,
                              List<Map<String, Object>> revenueRows,
                              List<Map<String, Object>> recentExports,
                              List<Map<String, Object>> userRoles,
                              List<Map<String, Object>> userStatuses,
                              List<Map<String, Object>> courseStatuses,
                              List<Map<String, Object>> enrollmentStatuses,
                              List<Map<String, Object>> paymentStatuses,
                              List<Map<String, Object>> certificateStatuses,
                              Map<String, Object> assessmentSummary,
                              List<Map<String, Object>> gradingModes,
                              List<Map<String, Object>> submissionModes,
                              List<Map<String, Object>> reportAccessStatuses,
                              String startDate,
                              String endDate) throws IOException {
        response.setContentType("application/pdf");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=admin-report-" + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + ".pdf");

        List<String> lines = buildPdfLines(summary,
                topCourses,
                revenueRows,
                recentExports,
                userRoles,
                userStatuses,
                courseStatuses,
                enrollmentStatuses,
                paymentStatuses,
                certificateStatuses,
                assessmentSummary,
                gradingModes,
                submissionModes,
                reportAccessStatuses,
                startDate,
                endDate);

        String subtitle = displayRange(startDate, endDate);
        byte[] pdfBytes;
        try {
            if (ReflectionPdfBoxGenerator.isAvailable()) {
                pdfBytes = ReflectionPdfBoxGenerator.generatePdf(summary, topCourses, revenueRows, "PSME Admin Report", subtitle);
            } else {
                pdfBytes = SimplePdfWriter.writeBrandedPdf("PSME Admin Report", subtitle, lines);
            }
        } catch (Exception pdfEx) {
            pdfBytes = SimplePdfWriter.writeBrandedPdf("PSME Admin Report", subtitle, lines);
        }
        response.setContentLength(pdfBytes.length);
        try (OutputStream output = response.getOutputStream()) {
            output.write(pdfBytes);
        }
    }

    private List<String> buildPdfLines(Map<String, Object> summary,
                                       List<Map<String, Object>> topCourses,
                                       List<Map<String, Object>> revenueRows,
                                       List<Map<String, Object>> recentExports,
                                       List<Map<String, Object>> userRoles,
                                       List<Map<String, Object>> userStatuses,
                                       List<Map<String, Object>> courseStatuses,
                                       List<Map<String, Object>> enrollmentStatuses,
                                       List<Map<String, Object>> paymentStatuses,
                                       List<Map<String, Object>> certificateStatuses,
                                       Map<String, Object> assessmentSummary,
                                       List<Map<String, Object>> gradingModes,
                                       List<Map<String, Object>> submissionModes,
                                       List<Map<String, Object>> reportAccessStatuses,
                                       String startDate,
                                       String endDate) {
        List<String> lines = new ArrayList<>();

        addKeyValueSection(lines, "Platform Summary", summary,
                new String[]{"totalUsers", "totalStudents", "totalInstructors", "totalCourses", "totalEnrollments", "completedEnrollments", "activeCertificates", "totalRevenue", "filteredEnrollments", "filteredCompletedEnrollments", "filteredRevenue", "newUsersInRange"});

        addBreakdownSection(lines, "User Roles", userRoles);
        addBreakdownSection(lines, "User Statuses", userStatuses);
        addBreakdownSection(lines, "Course Statuses", courseStatuses);
        addBreakdownSection(lines, "Enrollment Statuses", enrollmentStatuses);
        addBreakdownSection(lines, "Payment Statuses", paymentStatuses);
        addBreakdownSection(lines, "Certificate Statuses", certificateStatuses);

        addKeyValueSection(lines, "Assessment Module", assessmentSummary,
                new String[]{"totalAssessments", "activeAssessments", "deletedAssessments", "totalQuestions", "totalSubmissions", "gradedSubmissions", "pendingSubmissions", "pendingRetakeRequests"});
        addBreakdownSection(lines, "Assessment Grading Modes", gradingModes);
        addBreakdownSection(lines, "Assessment Submission Modes", submissionModes);
        addBreakdownSection(lines, "Report Access Statuses", reportAccessStatuses);

        addTopRowsSection(lines, "Top Courses by Enrollment", topCourses, 5);
        addTopRevenueSection(lines, "Revenue by Course", revenueRows, 5);
        addRecentExportsSection(lines, "Recent Report Exports", recentExports, 5);
        return lines;
    }

    private void addKeyValueSection(List<String> lines, String title, Map<String, Object> values, String[] keys) {
        lines.add(title);
        if (values == null || values.isEmpty()) {
            lines.add("  No data available.");
            lines.add("");
            return;
        }
        for (String key : keys) {
            if (values.containsKey(key)) {
                lines.add("  " + labelForKey(key) + ": " + safeText(values.get(key)));
            }
        }
        lines.add("");
    }

    private void addBreakdownSection(List<String> lines, String title, List<Map<String, Object>> rows) {
        lines.add(title);
        if (rows == null || rows.isEmpty()) {
            lines.add("  No data available.");
            lines.add("");
            return;
        }
        for (Map<String, Object> row : rows) {
            lines.add("  " + safeText(row.get("label")) + ": " + safeText(row.get("count")));
        }
        lines.add("");
    }

    private void addTopRowsSection(List<String> lines, String title, List<Map<String, Object>> rows, int limit) {
        lines.add(title);
        if (rows == null || rows.isEmpty()) {
            lines.add("  No data available.");
            lines.add("");
            return;
        }
        int index = 1;
        for (Map<String, Object> row : rows) {
            if (index > limit) {
                break;
            }
            lines.add("  " + index + ". " + safeText(row.get("title")) + " | Enrollments: " + safeText(row.get("enrollments")) + " | Completions: " + safeText(row.get("completions")) + " | Avg Progress: " + safeText(row.get("avgProgress")) + "% | Completion Rate: " + safeText(row.get("completionRate")) + "%");
            index++;
        }
        lines.add("");
    }

    private void addTopRevenueSection(List<String> lines, String title, List<Map<String, Object>> rows, int limit) {
        lines.add(title);
        if (rows == null || rows.isEmpty()) {
            lines.add("  No data available.");
            lines.add("");
            return;
        }
        int index = 1;
        for (Map<String, Object> row : rows) {
            if (index > limit) {
                break;
            }
            lines.add("  " + index + ". " + safeText(row.get("title")) + " | Enrollments: " + safeText(row.get("enrollments")) + " | Revenue: NGN " + safeText(row.get("revenue")));
            index++;
        }
        lines.add("");
    }

    private void addRecentExportsSection(List<String> lines, String title, List<Map<String, Object>> rows, int limit) {
        lines.add(title);
        if (rows == null || rows.isEmpty()) {
            lines.add("  No data available.");
            lines.add("");
            return;
        }
        int index = 1;
        for (Map<String, Object> row : rows) {
            if (index > limit) {
                break;
            }
            lines.add("  " + index + ". " + safeText(row.get("reportType")) + " | Format: " + safeText(row.get("exportFormat")) + " | Created: " + safeText(row.get("createdAt")));
            index++;
        }
        lines.add("");
    }

    private String labelForKey(String key) {
        switch (key) {
            case "totalUsers": return "Total Users";
            case "totalStudents": return "Total Students";
            case "totalInstructors": return "Total Instructors";
            case "totalCourses": return "Total Courses";
            case "totalEnrollments": return "Total Enrollments";
            case "completedEnrollments": return "Completed Enrollments";
            case "activeCertificates": return "Active Certificates";
            case "totalRevenue": return "Total Revenue";
            case "filteredEnrollments": return "Filtered Enrollments";
            case "filteredCompletedEnrollments": return "Filtered Completed Enrollments";
            case "filteredRevenue": return "Filtered Revenue";
            case "newUsersInRange": return "New Users In Range";
            case "totalAssessments": return "Total Assessments";
            case "activeAssessments": return "Active Assessments";
            case "deletedAssessments": return "Deleted Assessments";
            case "totalQuestions": return "Total Questions";
            case "totalSubmissions": return "Total Submissions";
            case "gradedSubmissions": return "Graded Submissions";
            case "pendingSubmissions": return "Pending Submissions";
            case "pendingRetakeRequests": return "Pending Retake Requests";
            default: return key;
        }
    }

    private String displayRange(String startDate, String endDate) {
        if ((startDate == null || startDate.isEmpty()) && (endDate == null || endDate.isEmpty())) {
            return "All time";
        }
        return (startDate == null || startDate.isEmpty() ? "..." : startDate) + " to " + (endDate == null || endDate.isEmpty() ? "..." : endDate);
    }

    private String safeText(Object value) {
        if (value == null) {
            return "0";
        }
        return String.valueOf(value);
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
