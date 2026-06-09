package com.psm.elearning.controller;

import com.psm.elearning.dao.ReportDAO;
import com.psm.elearning.dao.ReportDAOImpl;
import com.psm.elearning.model.User;
import com.psm.elearning.util.SessionUtil;
import com.psm.elearning.util.ReflectionPdfBoxGenerator;
import com.psm.elearning.util.SimplePdfWriter;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import java.awt.Color;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
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
        if (role == null)
            role = user.getRole();

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

            boolean incSummary = !"false".equalsIgnoreCase(request.getParameter("incSummary"));
            boolean incBreakdowns = !"false".equalsIgnoreCase(request.getParameter("incBreakdowns"));
            boolean incAssessments = !"false".equalsIgnoreCase(request.getParameter("incAssessments"));
            boolean incTopCourses = !"false".equalsIgnoreCase(request.getParameter("incTopCourses"));
            boolean incRevenue = !"false".equalsIgnoreCase(request.getParameter("incRevenue"));
            boolean incHistory = !"false".equalsIgnoreCase(request.getParameter("incHistory"));

            if ("csv".equalsIgnoreCase(export)) {
                reportDAO.saveGeneratedReport(userId, role, "admin-overview", filtersJson, "CSV", null);
                reportDAO.logReportAccess(userId, role, "admin-overview-export-csv", filtersJson, "Success", ip);
                writeAdminCsv(response, summary, topCourses, revenueRows, startDate, endDate, incSummary, incTopCourses,
                        incRevenue);
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
                        endDate,
                        incSummary,
                        incBreakdowns,
                        incAssessments,
                        incTopCourses,
                        incRevenue,
                        incHistory);
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
            String endDate,
            boolean incSummary,
            boolean incTopCourses,
            boolean incRevenue) throws IOException {
        response.setContentType("text/csv");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=admin-report.csv");

        PrintWriter writer = response.getWriter();
        writer.println("PSME Admin Report");
        writer.println("Date Range," + csv(startDate) + " to " + csv(endDate));
        writer.println();

        if (incSummary) {
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
        }

        if (incTopCourses) {
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
        }

        if (incRevenue) {
            writer.println("Revenue by Course");
            writer.println("Course,Enrollments,Revenue");
            for (Map<String, Object> row : revenueRows) {
                writer.println(csv(value(row.get("title"))) + "," +
                        value(row.get("enrollments")) + "," +
                        value(row.get("revenue")));
            }
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
            String endDate,
            boolean incSummary,
            boolean incBreakdowns,
            boolean incAssessments,
            boolean incTopCourses,
            boolean incRevenue,
            boolean incHistory) throws IOException {
        response.setContentType("application/pdf");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=admin-report-"
                + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + ".pdf");

        Document document = new Document();
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try {
            PdfWriter.getInstance(document, baos);
            document.open();

            // Task 1: Centered Document Title and Generated Date
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, Color.BLACK);
            Paragraph title = new Paragraph("PSM Platform Analytics Report", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(6f);
            document.add(title);

            Font subFont = FontFactory.getFont(FontFactory.HELVETICA, 10, Color.GRAY);
            String rangeStr = displayRange(startDate, endDate);
            Paragraph subtitle = new Paragraph(
                    "Date Range: " + rangeStr + " | Generated: " + LocalDate.now().toString(), subFont);
            subtitle.setAlignment(Element.ALIGN_CENTER);
            subtitle.setSpacingAfter(20f);
            document.add(subtitle);

            // Fonts and color tokens for tables
            Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, Color.BLACK);
            Font cellFont = FontFactory.getFont(FontFactory.HELVETICA, 9, Color.BLACK);
            Color headerBg = new Color(241, 245, 249); // light gray slate background

            // Task 2: Platform Summary Table (2 columns)
            if (incSummary) {
                addKeyValueTable(document, "Platform Summary", summary,
                        new String[] { "totalUsers", "totalStudents", "totalInstructors", "totalCourses",
                                "totalEnrollments", "completedEnrollments", "activeCertificates", "totalRevenue",
                                "filteredEnrollments", "filteredCompletedEnrollments", "filteredRevenue",
                                "newUsersInRange" },
                        headerFont, cellFont, headerBg);
            }

            // System Breakdown Tables
            if (incBreakdowns) {
                addBreakdownTable(document, "User Roles Breakdown", userRoles, headerFont, cellFont, headerBg);
                addBreakdownTable(document, "User Statuses Breakdown", userStatuses, headerFont, cellFont, headerBg);
                addBreakdownTable(document, "Course Statuses Breakdown", courseStatuses, headerFont, cellFont,
                        headerBg);
                addBreakdownTable(document, "Enrollment Statuses Breakdown", enrollmentStatuses, headerFont, cellFont,
                        headerBg);
                addBreakdownTable(document, "Payment Statuses Breakdown", paymentStatuses, headerFont, cellFont,
                        headerBg);
                addBreakdownTable(document, "Certificate Statuses Breakdown", certificateStatuses, headerFont, cellFont,
                        headerBg);
            }

            // Assessments Key-Value & breakdown
            if (incAssessments) {
                addKeyValueTable(document, "Assessment Summary", assessmentSummary,
                        new String[] { "totalAssessments", "activeAssessments", "deletedAssessments", "totalQuestions",
                                "totalSubmissions", "gradedSubmissions", "pendingSubmissions",
                                "pendingRetakeRequests" },
                        headerFont, cellFont, headerBg);
                addBreakdownTable(document, "Assessment Grading Modes", gradingModes, headerFont, cellFont, headerBg);
                addBreakdownTable(document, "Assessment Submission Modes", submissionModes, headerFont, cellFont,
                        headerBg);
                addBreakdownTable(document, "Report Access Statuses", reportAccessStatuses, headerFont, cellFont,
                        headerBg);
            }

            // Task 3: Top Courses Table (4 columns)
            if (incTopCourses) {
                Paragraph coursesTitle = new Paragraph("Top Courses by Enrollment",
                        FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12));
                coursesTitle.setSpacingBefore(12f);
                coursesTitle.setSpacingAfter(8f);
                document.add(coursesTitle);

                if (topCourses == null || topCourses.isEmpty()) {
                    document.add(new Paragraph("No course data available.", cellFont));
                } else {
                    PdfPTable coursesTable = new PdfPTable(4);
                    coursesTable.setWidthPercentage(100f);
                    coursesTable.setSpacingAfter(15f);
                    coursesTable.setWidths(new float[] { 4f, 2f, 2f, 2f });

                    String[] coursesHeaders = { "Course Name", "Enrollments", "Completions", "Completion Rate" };
                    for (String ch : coursesHeaders) {
                        PdfPCell cell = new PdfPCell(new Phrase(ch, headerFont));
                        cell.setBackgroundColor(headerBg);
                        cell.setPadding(5f);
                        coursesTable.addCell(cell);
                    }

                    for (Map<String, Object> row : topCourses) {
                        PdfPCell nameCell = new PdfPCell(new Phrase(safeText(row.get("title")), cellFont));
                        nameCell.setPadding(5f);
                        coursesTable.addCell(nameCell);

                        PdfPCell enrollCell = new PdfPCell(new Phrase(safeText(row.get("enrollments")), cellFont));
                        enrollCell.setPadding(5f);
                        coursesTable.addCell(enrollCell);

                        PdfPCell compCell = new PdfPCell(new Phrase(safeText(row.get("completions")), cellFont));
                        compCell.setPadding(5f);
                        coursesTable.addCell(compCell);

                        PdfPCell rateCell = new PdfPCell(
                                new Phrase(safeText(row.get("completionRate")) + "%", cellFont));
                        rateCell.setPadding(5f);
                        coursesTable.addCell(rateCell);
                    }
                    document.add(coursesTable);
                }
            }

            // Task 3: Revenue by Course Table (3 columns)
            if (incRevenue) {
                Paragraph revTitle = new Paragraph("Revenue by Course",
                        FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12));
                revTitle.setSpacingBefore(12f);
                revTitle.setSpacingAfter(8f);
                document.add(revTitle);

                if (revenueRows == null || revenueRows.isEmpty()) {
                    document.add(new Paragraph("No revenue data available.", cellFont));
                } else {
                    PdfPTable revTable = new PdfPTable(3);
                    revTable.setWidthPercentage(100f);
                    revTable.setSpacingAfter(15f);
                    revTable.setWidths(new float[] { 5f, 2f, 3f });

                    String[] revHeaders = { "Course Name", "Enrollments", "Revenue" };
                    for (String rh : revHeaders) {
                        PdfPCell cell = new PdfPCell(new Phrase(rh, headerFont));
                        cell.setBackgroundColor(headerBg);
                        cell.setPadding(5f);
                        revTable.addCell(cell);
                    }

                    for (Map<String, Object> row : revenueRows) {
                        PdfPCell nameCell = new PdfPCell(new Phrase(safeText(row.get("title")), cellFont));
                        nameCell.setPadding(5f);
                        revTable.addCell(nameCell);

                        PdfPCell enrollCell = new PdfPCell(new Phrase(safeText(row.get("enrollments")), cellFont));
                        enrollCell.setPadding(5f);
                        revTable.addCell(enrollCell);

                        PdfPCell revenueCell = new PdfPCell(
                                new Phrase("NGN " + safeText(row.get("revenue")), cellFont));
                        revenueCell.setPadding(5f);
                        revTable.addCell(revenueCell);
                    }
                    document.add(revTable);
                }
            }

            // Recent Exports
            if (incHistory) {
                addRecentExportsTable(document, "Recent Report Exports History", recentExports, 5, headerFont, cellFont,
                        headerBg);
            }

        } catch (DocumentException e) {
            throw new IOException(e);
        } finally {
            document.close();
        }

        byte[] pdfBytes = baos.toByteArray();
        response.setContentLength(pdfBytes.length);
        try (OutputStream output = response.getOutputStream()) {
            output.write(pdfBytes);
        }
    }

    private void addKeyValueTable(Document document, String title, Map<String, Object> values, String[] keys,
            Font headerFont, Font cellFont, Color headerBg) throws DocumentException {
        Paragraph tableTitle = new Paragraph(title, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12));
        tableTitle.setSpacingBefore(12f);
        tableTitle.setSpacingAfter(8f);
        document.add(tableTitle);

        if (values == null || values.isEmpty()) {
            document.add(new Paragraph("No data available.", cellFont));
            return;
        }

        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100f);
        table.setSpacingAfter(15f);
        table.setWidths(new float[] { 1f, 1f });

        PdfPCell h1 = new PdfPCell(new Phrase("Metric Name", headerFont));
        h1.setBackgroundColor(headerBg);
        h1.setPadding(5f);
        table.addCell(h1);

        PdfPCell h2 = new PdfPCell(new Phrase("Value", headerFont));
        h2.setBackgroundColor(headerBg);
        h2.setPadding(5f);
        table.addCell(h2);

        for (String key : keys) {
            if (values.containsKey(key)) {
                PdfPCell c1 = new PdfPCell(new Phrase(labelForKey(key), cellFont));
                c1.setPadding(5f);
                table.addCell(c1);

                Object val = values.get(key);
                String valStr = (key.toLowerCase().contains("revenue")) ? "NGN " + safeText(val) : safeText(val);
                PdfPCell c2 = new PdfPCell(new Phrase(valStr, cellFont));
                c2.setPadding(5f);
                table.addCell(c2);
            }
        }
        document.add(table);
    }

    private void addBreakdownTable(Document document, String title, List<Map<String, Object>> rows, Font headerFont,
            Font cellFont, Color headerBg) throws DocumentException {
        Paragraph tableTitle = new Paragraph(title, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12));
        tableTitle.setSpacingBefore(12f);
        tableTitle.setSpacingAfter(8f);
        document.add(tableTitle);

        if (rows == null || rows.isEmpty()) {
            document.add(new Paragraph("No data available.", cellFont));
            return;
        }

        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100f);
        table.setSpacingAfter(15f);
        table.setWidths(new float[] { 1f, 1f });

        PdfPCell h1 = new PdfPCell(new Phrase("Label", headerFont));
        h1.setBackgroundColor(headerBg);
        h1.setPadding(5f);
        table.addCell(h1);

        PdfPCell h2 = new PdfPCell(new Phrase("Count", headerFont));
        h2.setBackgroundColor(headerBg);
        h2.setPadding(5f);
        table.addCell(h2);

        for (Map<String, Object> row : rows) {
            PdfPCell c1 = new PdfPCell(new Phrase(safeText(row.get("label")), cellFont));
            c1.setPadding(5f);
            table.addCell(c1);

            PdfPCell c2 = new PdfPCell(new Phrase(safeText(row.get("count")), cellFont));
            c2.setPadding(5f);
            table.addCell(c2);
        }
        document.add(table);
    }

    private void addRecentExportsTable(Document document, String title, List<Map<String, Object>> rows, int limit,
            Font headerFont, Font cellFont, Color headerBg) throws DocumentException {
        Paragraph tableTitle = new Paragraph(title, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12));
        tableTitle.setSpacingBefore(12f);
        tableTitle.setSpacingAfter(8f);
        document.add(tableTitle);

        if (rows == null || rows.isEmpty()) {
            document.add(new Paragraph("No export history recorded.", cellFont));
            return;
        }

        PdfPTable table = new PdfPTable(4);
        table.setWidthPercentage(100f);
        table.setSpacingAfter(15f);
        table.setWidths(new float[] { 1f, 3f, 2f, 4f });

        String[] headers = { "#", "Type", "Format", "Created At" };
        for (String h : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(h, headerFont));
            cell.setBackgroundColor(headerBg);
            cell.setPadding(5f);
            table.addCell(cell);
        }

        int index = 1;
        for (Map<String, Object> row : rows) {
            if (index > limit)
                break;

            PdfPCell c0 = new PdfPCell(new Phrase(String.valueOf(index), cellFont));
            c0.setPadding(5f);
            table.addCell(c0);

            PdfPCell c1 = new PdfPCell(new Phrase(safeText(row.get("reportType")), cellFont));
            c1.setPadding(5f);
            table.addCell(c1);

            PdfPCell c2 = new PdfPCell(new Phrase(safeText(row.get("exportFormat")), cellFont));
            c2.setPadding(5f);
            table.addCell(c2);

            PdfPCell c3 = new PdfPCell(new Phrase(safeText(row.get("createdAt")), cellFont));
            c3.setPadding(5f);
            table.addCell(c3);

            index++;
        }
        document.add(table);
    }

    private String labelForKey(String key) {
        switch (key) {
            case "totalUsers":
                return "Total Users";
            case "totalStudents":
                return "Total Students";
            case "totalInstructors":
                return "Total Instructors";
            case "totalCourses":
                return "Total Courses";
            case "totalEnrollments":
                return "Total Enrollments";
            case "completedEnrollments":
                return "Completed Enrollments";
            case "activeCertificates":
                return "Active Certificates";
            case "totalRevenue":
                return "Total Revenue";
            case "filteredEnrollments":
                return "Filtered Enrollments";
            case "filteredCompletedEnrollments":
                return "Filtered Completed Enrollments";
            case "filteredRevenue":
                return "Filtered Revenue";
            case "newUsersInRange":
                return "New Users In Range";
            case "totalAssessments":
                return "Total Assessments";
            case "activeAssessments":
                return "Active Assessments";
            case "deletedAssessments":
                return "Deleted Assessments";
            case "totalQuestions":
                return "Total Questions";
            case "totalSubmissions":
                return "Total Submissions";
            case "gradedSubmissions":
                return "Graded Submissions";
            case "pendingSubmissions":
                return "Pending Submissions";
            case "pendingRetakeRequests":
                return "Pending Retake Requests";
            default:
                return key;
        }
    }

    private String displayRange(String startDate, String endDate) {
        if ((startDate == null || startDate.isEmpty()) && (endDate == null || endDate.isEmpty())) {
            return "All time";
        }
        return (startDate == null || startDate.isEmpty() ? "..." : startDate) + " to "
                + (endDate == null || endDate.isEmpty() ? "..." : endDate);
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
