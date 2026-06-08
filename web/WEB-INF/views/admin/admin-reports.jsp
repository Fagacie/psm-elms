<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Visual Analytics Hub - PSM E-Learning</title>
    <meta name="description" content="Admin analytics dashboard for PSM E-Learning platform insights, revenue charts, and enrollment metrics">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminReports.module.css">
    <!-- Lucide Icons UMD -->
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>

    <!-- React & ReactDOM UMD -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>

    <!-- Babel Standalone for JSX -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>

    <!-- TanStack Table UMD -->
    <script src="https://unpkg.com/@tanstack/react-table@8.17.3/build/umd/index.production.js"></script>

    <!-- Chart.js UMD -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Reports"/>
    <jsp:param name="pageSubtitle" value="Visual analytics hub for platform-level insights and data-driven decisions"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <c:if test="${not empty error}">
        <div style="max-width: 1400px; margin: 1.5rem auto 0; padding: 0 2rem;">
            <div class="alert-error-gf">
                <i class="fas fa-exclamation-circle"></i> ${error}
            </div>
        </div>
    </c:if>

    <div id="analytics-root"></div>
</main>

<%
    // ── Serialize report summary ──
    java.util.Map<String, Object> summary = (java.util.Map<String, Object>) request.getAttribute("reportSummary");
    org.json.JSONObject summaryJson = new org.json.JSONObject();
    if (summary != null) {
        for (java.util.Map.Entry<String, Object> e : summary.entrySet()) {
            summaryJson.put(e.getKey(), e.getValue() != null ? e.getValue() : 0);
        }
    }

    // ── Serialize top courses ──
    java.util.List<java.util.Map<String, Object>> topCourses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("topCourses");
    org.json.JSONArray topCoursesJson = new org.json.JSONArray();
    if (topCourses != null) {
        for (java.util.Map<String, Object> row : topCourses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("courseId", row.get("courseId"));
            obj.put("title", row.get("title") != null ? row.get("title") : "");
            obj.put("enrollments", row.get("enrollments") != null ? row.get("enrollments") : 0);
            obj.put("completions", row.get("completions") != null ? row.get("completions") : 0);
            obj.put("avgProgress", row.get("avgProgress") != null ? row.get("avgProgress") : 0);
            obj.put("completionRate", row.get("completionRate") != null ? row.get("completionRate") : 0);
            topCoursesJson.put(obj);
        }
    }

    // ── Serialize revenue rows ──
    java.util.List<java.util.Map<String, Object>> revenueRows = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("revenueRows");
    org.json.JSONArray revenueJson = new org.json.JSONArray();
    if (revenueRows != null) {
        for (java.util.Map<String, Object> row : revenueRows) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("courseId", row.get("courseId"));
            obj.put("title", row.get("title") != null ? row.get("title") : "");
            obj.put("enrollments", row.get("enrollments") != null ? row.get("enrollments") : 0);
            obj.put("revenue", row.get("revenue") != null ? row.get("revenue") : 0);
            revenueJson.put(obj);
        }
    }

    // ── Serialize recent exports ──
    java.util.List<java.util.Map<String, Object>> recentExports = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("recentExports");
    org.json.JSONArray exportsJson = new org.json.JSONArray();
    if (recentExports != null) {
        for (java.util.Map<String, Object> row : recentExports) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("exportId", row.get("exportId"));
            obj.put("reportType", row.get("reportType") != null ? row.get("reportType") : "");
            obj.put("exportFormat", row.get("exportFormat") != null ? row.get("exportFormat") : "");
            obj.put("filtersJson", row.get("filtersJson") != null ? row.get("filtersJson") : "{}");
            obj.put("createdAt", row.get("createdAt") != null ? row.get("createdAt").toString() : "");
            exportsJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> userRoles = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("userRoles");
    org.json.JSONArray userRolesJson = new org.json.JSONArray();
    if (userRoles != null) {
        for (java.util.Map<String, Object> row : userRoles) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            userRolesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> userStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("userStatuses");
    org.json.JSONArray userStatusesJson = new org.json.JSONArray();
    if (userStatuses != null) {
        for (java.util.Map<String, Object> row : userStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            userStatusesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> courseStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("courseStatuses");
    org.json.JSONArray courseStatusesJson = new org.json.JSONArray();
    if (courseStatuses != null) {
        for (java.util.Map<String, Object> row : courseStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            courseStatusesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> enrollmentStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("enrollmentStatuses");
    org.json.JSONArray enrollmentStatusesJson = new org.json.JSONArray();
    if (enrollmentStatuses != null) {
        for (java.util.Map<String, Object> row : enrollmentStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            enrollmentStatusesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> paymentStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("paymentStatuses");
    org.json.JSONArray paymentStatusesJson = new org.json.JSONArray();
    if (paymentStatuses != null) {
        for (java.util.Map<String, Object> row : paymentStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            paymentStatusesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> certificateStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("certificateStatuses");
    org.json.JSONArray certificateStatusesJson = new org.json.JSONArray();
    if (certificateStatuses != null) {
        for (java.util.Map<String, Object> row : certificateStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            certificateStatusesJson.put(obj);
        }
    }

    java.util.Map<String, Object> assessmentSummary = (java.util.Map<String, Object>) request.getAttribute("assessmentSummary");
    org.json.JSONObject assessmentSummaryJson = new org.json.JSONObject();
    if (assessmentSummary != null) {
        for (java.util.Map.Entry<String, Object> e : assessmentSummary.entrySet()) {
            assessmentSummaryJson.put(e.getKey(), e.getValue() != null ? e.getValue() : 0);
        }
    }

    java.util.List<java.util.Map<String, Object>> gradingModes = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("gradingModes");
    org.json.JSONArray gradingModesJson = new org.json.JSONArray();
    if (gradingModes != null) {
        for (java.util.Map<String, Object> row : gradingModes) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            gradingModesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> submissionModes = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("submissionModes");
    org.json.JSONArray submissionModesJson = new org.json.JSONArray();
    if (submissionModes != null) {
        for (java.util.Map<String, Object> row : submissionModes) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            submissionModesJson.put(obj);
        }
    }

    java.util.List<java.util.Map<String, Object>> reportAccessStatuses = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("reportAccessStatuses");
    org.json.JSONArray reportAccessStatusesJson = new org.json.JSONArray();
    if (reportAccessStatuses != null) {
        for (java.util.Map<String, Object> row : reportAccessStatuses) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("label", row.get("label") != null ? row.get("label") : "");
            obj.put("count", row.get("count") != null ? row.get("count") : 0);
            reportAccessStatusesJson.put(obj);
        }
    }

    pageContext.setAttribute("summaryJsonStr", summaryJson.toString());
    pageContext.setAttribute("topCoursesJsonStr", topCoursesJson.toString());
    pageContext.setAttribute("revenueJsonStr", revenueJson.toString());
    pageContext.setAttribute("exportsJsonStr", exportsJson.toString());
    pageContext.setAttribute("userRolesJsonStr", userRolesJson.toString());
    pageContext.setAttribute("userStatusesJsonStr", userStatusesJson.toString());
    pageContext.setAttribute("courseStatusesJsonStr", courseStatusesJson.toString());
    pageContext.setAttribute("enrollmentStatusesJsonStr", enrollmentStatusesJson.toString());
    pageContext.setAttribute("paymentStatusesJsonStr", paymentStatusesJson.toString());
    pageContext.setAttribute("certificateStatusesJsonStr", certificateStatusesJson.toString());
    pageContext.setAttribute("assessmentSummaryJsonStr", assessmentSummaryJson.toString());
    pageContext.setAttribute("gradingModesJsonStr", gradingModesJson.toString());
    pageContext.setAttribute("submissionModesJsonStr", submissionModesJson.toString());
    pageContext.setAttribute("reportAccessStatusesJsonStr", reportAccessStatusesJson.toString());
%>

<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__REPORT_SUMMARY__ = ${summaryJsonStr};
    window.__TOP_COURSES__ = ${topCoursesJsonStr};
    window.__REVENUE_ROWS__ = ${revenueJsonStr};
    window.__RECENT_EXPORTS__ = ${exportsJsonStr};
    window.__USER_ROLE_BREAKDOWN__ = ${userRolesJsonStr};
    window.__USER_STATUS_BREAKDOWN__ = ${userStatusesJsonStr};
    window.__COURSE_STATUS_BREAKDOWN__ = ${courseStatusesJsonStr};
    window.__ENROLLMENT_STATUS_BREAKDOWN__ = ${enrollmentStatusesJsonStr};
    window.__PAYMENT_STATUS_BREAKDOWN__ = ${paymentStatusesJsonStr};
    window.__CERTIFICATE_STATUS_BREAKDOWN__ = ${certificateStatusesJsonStr};
    window.__ASSESSMENT_SUMMARY__ = ${assessmentSummaryJsonStr};
    window.__ASSESSMENT_GRADING_BREAKDOWN__ = ${gradingModesJsonStr};
    window.__ASSESSMENT_SUBMISSION_BREAKDOWN__ = ${submissionModesJsonStr};
    window.__REPORT_ACCESS_BREAKDOWN__ = ${reportAccessStatusesJsonStr};
    window.__SELECTED_START_DATE__ = "${selectedStartDate}";
    window.__SELECTED_END_DATE__ = "${selectedEndDate}";
</script>

<script type="text/babel">
    const { useState, useEffect, useMemo, useRef } = React;
    const {
        useReactTable, getCoreRowModel, getPaginationRowModel, getSortedRowModel, flexRender
    } = window.ReactTable || {};

    function AnalyticsHub() {
        // ── Data from server ──
        const summary = window.__REPORT_SUMMARY__ || {};
        const [topCourses] = useState(window.__TOP_COURSES__ || []);
        const [revenueRows] = useState(window.__REVENUE_ROWS__ || []);
        const [recentExports] = useState(window.__RECENT_EXPORTS__ || []);
        const [userRoles] = useState(window.__USER_ROLE_BREAKDOWN__ || []);
        const [userStatuses] = useState(window.__USER_STATUS_BREAKDOWN__ || []);
        const [courseStatuses] = useState(window.__COURSE_STATUS_BREAKDOWN__ || []);
        const [enrollmentStatuses] = useState(window.__ENROLLMENT_STATUS_BREAKDOWN__ || []);
        const [paymentStatuses] = useState(window.__PAYMENT_STATUS_BREAKDOWN__ || []);
        const [certificateStatuses] = useState(window.__CERTIFICATE_STATUS_BREAKDOWN__ || []);
        const [gradingModes] = useState(window.__ASSESSMENT_GRADING_BREAKDOWN__ || []);
        const [submissionModes] = useState(window.__ASSESSMENT_SUBMISSION_BREAKDOWN__ || []);
        const [reportAccessStatuses] = useState(window.__REPORT_ACCESS_BREAKDOWN__ || []);
        const assessmentSummary = window.__ASSESSMENT_SUMMARY__ || {};
        const ctxPath = window.__CONTEXT_PATH__;

        // ── Filter state ──
        const [startDate, setStartDate] = useState(window.__SELECTED_START_DATE__ || '');
        const [endDate, setEndDate] = useState(window.__SELECTED_END_DATE__ || '');
        const hasFilter = startDate && endDate;

        // ── Selection states for custom exports ──
        const [incSummary, setIncSummary] = useState(true);
        const [incBreakdowns, setIncBreakdowns] = useState(true);
        const [incAssessments, setIncAssessments] = useState(true);
        const [incTopCourses, setIncTopCourses] = useState(true);
        const [incRevenue, setIncRevenue] = useState(true);
        const [incHistory, setIncHistory] = useState(true);

        // ── Table search state ──
        const [courseSearch, setCourseSearch] = useState('');
        const [revenueSearch, setRevenueSearch] = useState('');

        // ── Table pagination & sorting ──
        const [coursePagination, setCoursePagination] = useState({ pageIndex: 0, pageSize: 10 });
        const [courseSorting, setCourseSorting] = useState([{ id: 'enrollments', desc: true }]);
        const [revPagination, setRevPagination] = useState({ pageIndex: 0, pageSize: 10 });
        const [revSorting, setRevSorting] = useState([{ id: 'revenue', desc: true }]);

        // ── Chart refs ──
        const revenueChartRef = useRef(null);
        const enrollChartRef = useRef(null);
        const revenueCanvasRef = useRef(null);
        const enrollCanvasRef = useRef(null);
        const userRolesChartRef = useRef(null);
        const courseStatusChartRef = useRef(null);
        const enrollmentStatusChartRef = useRef(null);
        const paymentStatusChartRef = useRef(null);
        const certificateStatusChartRef = useRef(null);
        const gradingModesChartRef = useRef(null);
        const submissionModesChartRef = useRef(null);
        const userRolesCanvasRef = useRef(null);
        const courseStatusCanvasRef = useRef(null);
        const enrollmentStatusCanvasRef = useRef(null);
        const paymentStatusCanvasRef = useRef(null);
        const certificateStatusCanvasRef = useRef(null);
        const gradingModesCanvasRef = useRef(null);
        const submissionModesCanvasRef = useRef(null);

        // ── Computed summary values ──
        const totalRevenue = summary.totalRevenue || summary.filteredRevenue || 0;
        const totalEnrollments = summary.filteredEnrollments || summary.totalEnrollments || 0;
        const completedEnrollments = summary.filteredCompletedEnrollments || summary.completedEnrollments || 0;
        const completionRate = totalEnrollments > 0 ? Math.round((completedEnrollments * 100) / totalEnrollments) : 0;
        const newUsers = summary.newUsersInRange || 0;

        // ── Quick date presets ──
        const setQuickRange = (days) => {
            const end = new Date();
            const start = new Date();
            start.setDate(end.getDate() - (days - 1));
            setStartDate(toIso(start));
            setEndDate(toIso(end));
        };

        const setYtd = () => {
            const now = new Date();
            setStartDate(now.getFullYear() + '-01-01');
            setEndDate(toIso(now));
        };

        function toIso(d) {
            return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
        }

        // ── Apply filter (form submit) ──
        const applyFilter = () => {
            if (startDate && endDate) {
                window.location.href = ctxPath + '/reports?startDate=' + startDate + '&endDate=' + endDate;
            }
        };

        const resetFilter = () => {
            window.location.href = ctxPath + '/reports';
        };

        const exportCsv = () => {
            window.location.href = ctxPath + '/reports?startDate=' + (startDate || '') + '&endDate=' + (endDate || '') + '&export=csv' +
                '&incSummary=' + incSummary +
                '&incBreakdowns=' + incBreakdowns +
                '&incAssessments=' + incAssessments +
                '&incTopCourses=' + incTopCourses +
                '&incRevenue=' + incRevenue +
                '&incHistory=' + incHistory;
        };

        const exportPdf = () => {
            window.location.href = ctxPath + '/reports?startDate=' + (startDate || '') + '&endDate=' + (endDate || '') + '&export=pdf' +
                '&incSummary=' + incSummary +
                '&incBreakdowns=' + incBreakdowns +
                '&incAssessments=' + incAssessments +
                '&incTopCourses=' + incTopCourses +
                '&incRevenue=' + incRevenue +
                '&incHistory=' + incHistory;
        };

        // ── Chart.js: Revenue Bar Chart ──
        useEffect(() => {
            if (!revenueCanvasRef.current || revenueRows.length === 0) return;
            if (revenueChartRef.current) revenueChartRef.current.destroy();

            const labels = revenueRows.map(r => r.title.length > 20 ? r.title.substring(0, 20) + '...' : r.title);
            const data = revenueRows.map(r => r.revenue);

            revenueChartRef.current = new Chart(revenueCanvasRef.current, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Revenue (NGN)',
                        data: data,
                        backgroundColor: 'rgba(22, 101, 52, 0.75)',
                        borderColor: 'rgba(22, 101, 52, 1)',
                        borderWidth: 1,
                        borderRadius: 6,
                        borderSkipped: false,
                        barPercentage: 0.7,
                        categoryPercentage: 0.8
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: '#0f172a',
                            titleFont: { family: 'Inter', size: 12, weight: '600' },
                            bodyFont: { family: 'Inter', size: 11 },
                            padding: 10,
                            cornerRadius: 8,
                            callbacks: {
                                label: function(ctx) {
                                    return 'NGN ' + ctx.parsed.x.toLocaleString('en-NG');
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: { color: 'rgba(0,0,0,0.04)', drawBorder: false },
                            ticks: {
                                font: { family: 'Inter', size: 11 },
                                color: '#94a3b8',
                                callback: function(v) { return 'NGN ' + (v >= 1000 ? (v/1000).toFixed(0) + 'k' : v); }
                            }
                        },
                        y: {
                            grid: { display: false },
                            ticks: {
                                font: { family: 'Inter', size: 11 },
                                color: '#475569'
                            }
                        }
                    }
                }
            });

            return () => { if (revenueChartRef.current) revenueChartRef.current.destroy(); };
        }, [revenueRows]);

        // ── Chart.js: Enrollment Doughnut ──
        useEffect(() => {
            if (!enrollCanvasRef.current || topCourses.length === 0) return;
            if (enrollChartRef.current) enrollChartRef.current.destroy();

            const labels = topCourses.slice(0, 6).map(c => c.title.length > 18 ? c.title.substring(0, 18) + '...' : c.title);
            const data = topCourses.slice(0, 6).map(c => c.enrollments);
            const colors = ['#166534', '#10b981', '#34d399', '#6ee7b7', '#a7f3d0', '#d1fae5'];

            enrollChartRef.current = new Chart(enrollCanvasRef.current, {
                type: 'doughnut',
                data: {
                    labels: labels,
                    datasets: [{
                        data: data,
                        backgroundColor: colors,
                        borderWidth: 2,
                        borderColor: '#ffffff',
                        hoverOffset: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '62%',
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                font: { family: 'Inter', size: 11 },
                                color: '#475569',
                                padding: 12,
                                usePointStyle: true,
                                pointStyleWidth: 8
                            }
                        },
                        tooltip: {
                            backgroundColor: '#0f172a',
                            titleFont: { family: 'Inter', size: 12, weight: '600' },
                            bodyFont: { family: 'Inter', size: 11 },
                            padding: 10,
                            cornerRadius: 8,
                            callbacks: {
                                label: function(ctx) {
                                    const total = ctx.dataset.data.reduce((a, b) => a + b, 0);
                                    const pct = total > 0 ? Math.round((ctx.parsed / total) * 100) : 0;
                                    return ctx.label + ': ' + ctx.parsed + ' (' + pct + '%)';
                                }
                            }
                        }
                    }
                }
            });

            return () => { if (enrollChartRef.current) enrollChartRef.current.destroy(); };
        }, [topCourses]);

        // ── Chart.js: User Roles breakdown ──
        useEffect(() => {
            if (!userRolesCanvasRef.current) return;
            if (userRolesChartRef.current) userRolesChartRef.current.destroy();
            const labels = userRoles.map(r => r.label);
            const data = userRoles.map(r => r.count);
            userRolesChartRef.current = new Chart(userRolesCanvasRef.current, {
                type: 'pie',
                data: { labels, datasets: [{ data, backgroundColor: ['#166534','#10b981','#34d399','#60a5fa','#a78bfa'], hoverOffset:8 }] },
                options: { plugins: { legend: { position: 'bottom' }, tooltip: { callbacks: { label: ctx => ctx.label + ': ' + ctx.parsed } } }, responsive:true, maintainAspectRatio:false }
            });
            return () => { if (userRolesChartRef.current) userRolesChartRef.current.destroy(); };
        }, [userRoles]);

        // ── Chart.js: Course Statuses breakdown ──
        useEffect(() => {
            if (!courseStatusCanvasRef.current) return;
            if (courseStatusChartRef.current) courseStatusChartRef.current.destroy();
            const labels = courseStatuses.map(r => r.label);
            const data = courseStatuses.map(r => r.count);
            courseStatusChartRef.current = new Chart(courseStatusCanvasRef.current, {
                type: 'bar',
                data: { labels, datasets: [{ data, backgroundColor: 'rgba(59,130,246,0.85)' }] },
                options: { indexAxis: 'y', responsive:true, maintainAspectRatio:false, plugins:{legend:{display:false}} }
            });
            return () => { if (courseStatusChartRef.current) courseStatusChartRef.current.destroy(); };
        }, [courseStatuses]);

        // ── Chart.js: Enrollment Statuses breakdown ──
        useEffect(() => {
            if (!enrollmentStatusCanvasRef.current) return;
            if (enrollmentStatusChartRef.current) enrollmentStatusChartRef.current.destroy();
            const labels = enrollmentStatuses.map(r => r.label);
            const data = enrollmentStatuses.map(r => r.count);
            enrollmentStatusChartRef.current = new Chart(enrollmentStatusCanvasRef.current, {
                type: 'doughnut',
                data: { labels, datasets: [{ data, backgroundColor: ['#34d399','#60a5fa','#f59e0b','#ef4444'] }] },
                options: { responsive:true, maintainAspectRatio:false, plugins:{legend:{position:'bottom'}} }
            });
            return () => { if (enrollmentStatusChartRef.current) enrollmentStatusChartRef.current.destroy(); };
        }, [enrollmentStatuses]);

        // ── Chart.js: Payment Statuses breakdown ──
        useEffect(() => {
            if (!paymentStatusCanvasRef.current) return;
            if (paymentStatusChartRef.current) paymentStatusChartRef.current.destroy();
            const labels = paymentStatuses.map(r => r.label);
            const data = paymentStatuses.map(r => r.count);
            paymentStatusChartRef.current = new Chart(paymentStatusCanvasRef.current, {
                type: 'pie',
                data: { labels, datasets: [{ data, backgroundColor: ['#14b8a6','#06b6d4','#4f46e5','#f97316'] }] },
                options: { responsive:true, maintainAspectRatio:false, plugins:{legend:{position:'bottom'}} }
            });
            return () => { if (paymentStatusChartRef.current) paymentStatusChartRef.current.destroy(); };
        }, [paymentStatuses]);

        // ── Chart.js: Certificate Statuses breakdown ──
        useEffect(() => {
            if (!certificateStatusCanvasRef.current) return;
            if (certificateStatusChartRef.current) certificateStatusChartRef.current.destroy();
            const labels = certificateStatuses.map(r => r.label);
            const data = certificateStatuses.map(r => r.count);
            certificateStatusChartRef.current = new Chart(certificateStatusCanvasRef.current, {
                type: 'bar',
                data: { labels, datasets: [{ data, backgroundColor: 'rgba(16,185,129,0.85)' }] },
                options: { indexAxis: 'y', responsive:true, maintainAspectRatio:false, plugins:{legend:{display:false}} }
            });
            return () => { if (certificateStatusChartRef.current) certificateStatusChartRef.current.destroy(); };
        }, [certificateStatuses]);

        // ── Chart.js: Grading / Submission modes ──
        useEffect(() => {
            if (!gradingModesCanvasRef.current || !submissionModesCanvasRef.current) return;
            if (gradingModesChartRef.current) gradingModesChartRef.current.destroy();
            if (submissionModesChartRef.current) submissionModesChartRef.current.destroy();
            const gLabels = gradingModes.map(r => r.label);
            const gData = gradingModes.map(r => r.count);
            gradingModesChartRef.current = new Chart(gradingModesCanvasRef.current, {
                type: 'pie', data: { labels: gLabels, datasets: [{ data: gData, backgroundColor:['#60a5fa','#7c3aed','#06b6d4'] }] }, options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{position:'bottom'}}}
            });
            const sLabels = submissionModes.map(r => r.label);
            const sData = submissionModes.map(r => r.count);
            submissionModesChartRef.current = new Chart(submissionModesCanvasRef.current, {
                type: 'doughnut', data: { labels: sLabels, datasets: [{ data: sData, backgroundColor:['#34d399','#a78bfa','#f59e0b'] }] }, options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{position:'bottom'}}}
            });
            return () => { if (gradingModesChartRef.current) gradingModesChartRef.current.destroy(); if (submissionModesChartRef.current) submissionModesChartRef.current.destroy(); };
        }, [gradingModes, submissionModes]);

        useEffect(() => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        });

        // ── TanStack: Top Courses filtered data ──
        const filteredCourses = useMemo(() => {
            if (!courseSearch.trim()) return topCourses;
            const q = courseSearch.toLowerCase();
            return topCourses.filter(c => (c.title || '').toLowerCase().includes(q));
        }, [topCourses, courseSearch]);

        // ── TanStack: Top Courses columns ──
        const courseColumns = useMemo(() => [
            {
                accessorKey: 'title',
                header: 'Course',
                cell: info => <span style={{ fontWeight: 600 }}>{info.getValue()}</span>
            },
            {
                accessorKey: 'enrollments',
                header: 'Enrollments',
                cell: info => <strong>{info.getValue()}</strong>
            },
            {
                accessorKey: 'completions',
                header: 'Completions',
                cell: info => info.getValue()
            },
            {
                accessorKey: 'avgProgress',
                header: 'Avg Progress',
                cell: info => {
                    const val = info.getValue() || 0;
                    return (
                        <div className="ar_progress_row">
                            <span className="ar_progress_label">{val}%</span>
                            <div className="ar_progress_bar">
                                <div className="ar_progress_fill" style={{ width: val + '%' }}></div>
                            </div>
                        </div>
                    );
                }
            },
            {
                accessorKey: 'completionRate',
                header: 'Completion Rate',
                cell: info => {
                    const val = info.getValue() || 0;
                    return (
                        <div className="ar_progress_row">
                            <span className="ar_progress_label">{val}%</span>
                            <div className="ar_progress_bar">
                                <div className="ar_progress_fill" style={{ width: val + '%' }}></div>
                            </div>
                        </div>
                    );
                }
            }
        ], []);

        const courseTable = useReactTable({
            data: filteredCourses,
            columns: courseColumns,
            state: { pagination: coursePagination, sorting: courseSorting },
            onPaginationChange: setCoursePagination,
            onSortingChange: setCourseSorting,
            getCoreRowModel: getCoreRowModel ? getCoreRowModel() : null,
            getPaginationRowModel: getPaginationRowModel ? getPaginationRowModel() : null,
            getSortedRowModel: getSortedRowModel ? getSortedRowModel() : null
        });

        // ── TanStack: Revenue filtered data ──
        const filteredRevenue = useMemo(() => {
            if (!revenueSearch.trim()) return revenueRows;
            const q = revenueSearch.toLowerCase();
            return revenueRows.filter(r => (r.title || '').toLowerCase().includes(q));
        }, [revenueRows, revenueSearch]);

        // ── TanStack: Revenue columns ──
        const revenueColumns = useMemo(() => [
            {
                accessorKey: 'title',
                header: 'Course',
                cell: info => <span style={{ fontWeight: 600 }}>{info.getValue()}</span>
            },
            {
                accessorKey: 'enrollments',
                header: 'Enrollments',
                cell: info => info.getValue()
            },
            {
                accessorKey: 'revenue',
                header: 'Revenue',
                cell: info => {
                    const v = info.getValue() || 0;
                    return <strong style={{ color: 'var(--ar-primary)' }}>{'NGN ' + Number(v).toLocaleString('en-NG')}</strong>;
                }
            }
        ], []);

        const revenueTable = useReactTable({
            data: filteredRevenue,
            columns: revenueColumns,
            state: { pagination: revPagination, sorting: revSorting },
            onPaginationChange: setRevPagination,
            onSortingChange: setRevSorting,
            getCoreRowModel: getCoreRowModel ? getCoreRowModel() : null,
            getPaginationRowModel: getPaginationRowModel ? getPaginationRowModel() : null,
            getSortedRowModel: getSortedRowModel ? getSortedRowModel() : null
        });

        // ── Render helper for TanStack tables ──
        const renderTable = (table, emptyMsg) => {
            const rows = table.getRowModel().rows;
            if (rows.length === 0) {
                return (
                    <div className="ar_empty_state">
                        <i data-lucide="bar-chart-3" style={{ fontSize: '2rem', color: 'var(--ar-text-muted)' }}></i>
                        <p>{emptyMsg}</p>
                    </div>
                );
            }
            return (
                <div className="ar_data_table_wrapper">
                    <table className="ar_data_table">
                        <thead>
                            {table.getHeaderGroups().map(hg => (
                                <tr key={hg.id}>
                                    {hg.headers.map(header => (
                                        <th key={header.id} onClick={header.column.getToggleSortingHandler()} style={{ cursor: 'pointer' }}>
                                            <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                                                {flexRender(header.column.columnDef.header, header.getContext())}
                                                {header.column.getCanSort() && (
                                                    <span style={{ opacity: header.column.getIsSorted() ? 1 : 0.3, fontSize: '0.7rem' }}>
                                                        {header.column.getIsSorted() === 'asc' ? <i data-lucide="chevron-up" style={{ width: '12px', height: '12px' }}></i> :
                                                         header.column.getIsSorted() === 'desc' ? <i data-lucide="chevron-down" style={{ width: '12px', height: '12px' }}></i> :
                                                         <i data-lucide="chevrons-up-down" style={{ width: '12px', height: '12px' }}></i>}
                                                    </span>
                                                )}
                                            </div>
                                        </th>
                                    ))}
                                </tr>
                            ))}
                        </thead>
                        <tbody>
                            {rows.map(row => (
                                <tr key={row.id}>
                                    {row.getVisibleCells().map(cell => (
                                        <td key={cell.id}>
                                            {flexRender(cell.column.columnDef.cell, cell.getContext())}
                                        </td>
                                    ))}
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            );
        };

        const renderPagination = (table) => {
            if (!table.getPageCount || table.getPageCount() <= 1) return null;
            return (
                <div className="ar_pagination">
                    <span>Page <strong>{table.getState().pagination.pageIndex + 1}</strong> of <strong>{table.getPageCount()}</strong></span>
                    <div className="ar_page_controls">
                        <button className="ar_page_btn" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>Previous</button>
                        <button className="ar_page_btn" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>Next</button>
                    </div>
                </div>
            );
        };

        return (
            <div className="ar_container">
                {/* Breadcrumb */}
                <div className="admin-breadcrumb" style={{ margin: 0 }}>
                    <a href={ctxPath + '/dashboard'}>Dashboard</a>
                    <span>&gt;</span>
                    <span>Analytics Hub</span>
                </div>

                {/* Page Header */}
                <div className="ar_header">
                    <h1>Visual Analytics Hub</h1>
                    <p>Explore enrollment trends, revenue performance, and platform health indicators with interactive charts and filterable data tables.</p>
                </div>

                {/* ═══ Command Bar ═══ */}
                <div className="ar_controls">
                    <div className="ar_controls_top">
                        <h2><i data-lucide="sliders" style={{ color: 'var(--ar-primary)' }}></i> Report Controls</h2>
                        <span className="ar_table_badge">Admin Only</span>
                    </div>
                    <div className="ar_controls_form">
                        <div className="ar_filter_group">
                            <label>From</label>
                            <input type="date" value={startDate} onChange={e => setStartDate(e.target.value)} />
                        </div>
                        <div className="ar_filter_group">
                            <label>To</label>
                            <input type="date" value={endDate} onChange={e => setEndDate(e.target.value)} />
                        </div>
                        <div className="ar_controls_actions">
                            <button className="ar_btn ar_btn_primary" onClick={applyFilter}>
                                <i data-lucide="filter"></i> Apply Filter
                            </button>
                            <button className="ar_btn" onClick={resetFilter}>
                                <i data-lucide="rotate-ccw"></i> Reset
                            </button>
                            <button className="ar_btn" onClick={exportCsv}>
                                <i data-lucide="file-spreadsheet"></i> Export CSV
                            </button>
                            <button className="ar_btn" onClick={exportPdf}>
                                <i data-lucide="file-down"></i> Download PDF
                            </button>
                        </div>
                    </div>
                    <div className="ar_presets">
                        <button className="ar_preset_btn" onClick={() => setQuickRange(7)}>Last 7 Days</button>
                        <button className="ar_preset_btn" onClick={() => setQuickRange(30)}>Last 30 Days</button>
                        <button className="ar_preset_btn" onClick={() => setQuickRange(90)}>Last 90 Days</button>
                        <button className="ar_preset_btn" onClick={setYtd}>Year to Date</button>
                    </div>
                    <div className="ar_export_selections">
                        <span className="ar_export_selections_label">
                            <i data-lucide="check-square" style={{ width: '14px', height: '14px', color: 'var(--ar-primary)' }}></i> Include in Export:
                        </span>
                        <div className="ar_checkbox_grid">
                            <label className="ar_checkbox_label">
                                <input type="checkbox" checked={incSummary} onChange={e => setIncSummary(e.target.checked)} />
                                <span>Platform Summary</span>
                            </label>
                            <label className="ar_checkbox_label">
                                <input type="checkbox" checked={incBreakdowns} onChange={e => setIncBreakdowns(e.target.checked)} />
                                <span>System Breakdowns</span>
                            </label>
                            <label className="ar_checkbox_label">
                                <input type="checkbox" checked={incAssessments} onChange={e => setIncAssessments(e.target.checked)} />
                                <span>Assessment Analytics</span>
                            </label>
                            <label className="ar_checkbox_label">
                                <input type="checkbox" checked={incTopCourses} onChange={e => setIncTopCourses(e.target.checked)} />
                                <span>Top Courses</span>
                            </label>
                            <label className="ar_checkbox_label">
                                <input type="checkbox" checked={incRevenue} onChange={e => setIncRevenue(e.target.checked)} />
                                <span>Revenue Data</span>
                            </label>
                            <label className="ar_checkbox_label">
                                <input type="checkbox" checked={incHistory} onChange={e => setIncHistory(e.target.checked)} />
                                <span>Export History</span>
                            </label>
                        </div>
                    </div>
                    {(startDate || endDate) && (
                        <div className="ar_chips">
                            {hasFilter ? (
                                <span className="ar_chip ar_chip_active">
                                    <i data-lucide="calendar"></i> {startDate} → {endDate}
                                </span>
                            ) : null}
                            <span className="ar_chip">
                                {hasFilter ? 'Filtered view' : 'Full history'}
                            </span>
                        </div>
                    )}
                </div>

                {/* ═══ Master KPIs ═══ */}
                <section className="ar_kpi_grid">
                    <div className="ar_kpi_card">
                        <span className="ar_kpi_label"><i data-lucide="coins"></i> Total Revenue</span>
                        <span className="ar_kpi_value">{'NGN ' + Number(totalRevenue).toLocaleString('en-NG')}</span>
                        <span className="ar_kpi_sub">{hasFilter ? 'Filtered period' : 'All time'}</span>
                    </div>
                    <div className="ar_kpi_card">
                        <span className="ar_kpi_label"><i data-lucide="graduation-cap"></i> Enrollments</span>
                        <span className="ar_kpi_value">{totalEnrollments}</span>
                        <span className="ar_kpi_sub">{completedEnrollments} completed</span>
                    </div>
                    <div className="ar_kpi_card">
                        <span className="ar_kpi_label"><i data-lucide="trending-up"></i> Completion Rate</span>
                        <span className="ar_kpi_value">{completionRate}%</span>
                        <span className="ar_kpi_sub">Based on filtered data</span>
                    </div>
                    <div className="ar_kpi_card">
                        <span className="ar_kpi_label"><i data-lucide="user-plus"></i> New Users</span>
                        <span className="ar_kpi_value">{newUsers}</span>
                        <span className="ar_kpi_sub">{hasFilter ? 'In selected range' : 'Use date filter'}</span>
                    </div>
                </section>

                {/* ═══ Platform Health (Consolidated Modules) ═══ */}
                <section className="ar_health_section">
                    <h3 className="ar_health_title">
                        <i data-lucide="activity"></i> Platform Health
                    </h3>
                    <div className="ar_health_grid">
                        <div className="ar_health_item">
                            <div className="ar_health_header">
                                <i data-lucide="users"></i>
                                <span className="ar_health_label">Total Users</span>
                            </div>
                            <span className="ar_health_value">{summary.totalUsers || 0}</span>
                        </div>
                        <div className="ar_health_item">
                            <div className="ar_health_header">
                                <i data-lucide="book-open"></i>
                                <span className="ar_health_label">Active Courses</span>
                            </div>
                            <span className="ar_health_value">{summary.totalCourses || 0}</span>
                        </div>
                        <div className="ar_health_item">
                            <div className="ar_health_header">
                                <i data-lucide="graduation-cap"></i>
                                <span className="ar_health_label">Enrollments</span>
                            </div>
                            <span className="ar_health_value">{summary.totalEnrollments || 0}</span>
                        </div>
                        <div className="ar_health_item">
                            <div className="ar_health_header">
                                <i data-lucide="award"></i>
                                <span className="ar_health_label">Active Certs</span>
                            </div>
                            <span className="ar_health_value">{summary.activeCertificates || 0}</span>
                        </div>
                        <div className="ar_health_item">
                            <div className="ar_health_header">
                                <i data-lucide="clipboard-list"></i>
                                <span className="ar_health_label">Assessments</span>
                            </div>
                            <span className="ar_health_value">{assessmentSummary.totalAssessments || 0}</span>
                        </div>
                        <div className="ar_health_item">
                            <div className="ar_health_header">
                                <i data-lucide="inbox"></i>
                                <span className="ar_health_label">Submissions</span>
                            </div>
                            <span className="ar_health_value">{assessmentSummary.totalSubmissions || 0}</span>
                        </div>
                    </div>
                </section>

                {/* ═══ Charts Grid ═══ */}
                <div className="ar_charts_grid">
                    {/* Revenue Bar Chart */}
                    <div className="ar_chart_card">
                        <div className="ar_chart_header">
                            <h3><i data-lucide="bar-chart-3" style={{ color: 'var(--ar-primary)' }}></i> Revenue by Course</h3>
                            <span className="ar_chart_sub">{revenueRows.length} courses</span>
                        </div>
                        <div className="ar_chart_wrap" style={{ height: Math.max(200, revenueRows.length * 36) + 'px' }}>
                            {revenueRows.length > 0 ? (
                                <canvas ref={revenueCanvasRef}></canvas>
                            ) : (
                                <div className="ar_empty_state">
                                    <i data-lucide="bar-chart-3" style={{ fontSize: '2rem', color: 'var(--ar-text-muted)' }}></i>
                                    <p>No revenue data available for charting.</p>
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Enrollment Doughnut */}
                    <div className="ar_chart_card">
                        <div className="ar_chart_header">
                            <h3><i data-lucide="pie-chart" style={{ color: 'var(--ar-primary)' }}></i> Enrollment Share</h3>
                            <span className="ar_chart_sub">Top {Math.min(6, topCourses.length)}</span>
                        </div>
                        <div className="ar_chart_wrap" style={{ height: '320px' }}>
                            {topCourses.length > 0 ? (
                                <canvas ref={enrollCanvasRef}></canvas>
                            ) : (
                                <div className="ar_empty_state">
                                    <i data-lucide="pie-chart" style={{ fontSize: '2rem', color: 'var(--ar-text-muted)' }}></i>
                                    <p>No enrollment data available.</p>
                                </div>
                            )}
                        </div>
                    </div>
                </div>

                {/* ═══ Top Courses Table ═══ */}
                <div className="ar_table_card">
                    <div className="ar_table_header">
                        <h3><i data-lucide="award" style={{ color: 'var(--ar-primary)' }}></i> Top Courses by Enrollment</h3>
                        <span className="ar_table_badge">{filteredCourses.length} {filteredCourses.length === 1 ? 'record' : 'records'}</span>
                    </div>
                    <div className="ar_table_controls">
                        <div className="ar_search_box">
                            <i data-lucide="search"></i>
                            <input type="text" placeholder="Search courses..." value={courseSearch} onChange={e => setCourseSearch(e.target.value)} />
                        </div>
                    </div>
                    {renderTable(courseTable, 'No course enrollment data matches your search.')}
                    {renderPagination(courseTable)}
                </div>

                {/* ═══ Revenue Table ═══ */}
                <div className="ar_table_card">
                    <div className="ar_table_header">
                        <h3><i data-lucide="banknote" style={{ color: 'var(--ar-primary)' }}></i> Revenue Breakdown by Course</h3>
                        <span className="ar_table_badge">{filteredRevenue.length} {filteredRevenue.length === 1 ? 'record' : 'records'}</span>
                    </div>
                    <div className="ar_table_controls">
                        <div className="ar_search_box">
                            <i data-lucide="search"></i>
                            <input type="text" placeholder="Search revenue..." value={revenueSearch} onChange={e => setRevenueSearch(e.target.value)} />
                        </div>
                    </div>
                    {renderTable(revenueTable, 'No revenue data matches your search.')}
                    {renderPagination(revenueTable)}
                </div>

                {/* ═══ Recent Exports Log ═══ */}
                {recentExports.length > 0 && (
                    <div className="ar_table_card">
                        <div className="ar_table_header">
                            <h3><i data-lucide="history" style={{ color: 'var(--ar-text-muted)' }}></i> Recent Export History</h3>
                            <span className="ar_table_badge">{recentExports.length} exports</span>
                        </div>
                        <div className="ar_data_table_wrapper">
                            <table className="ar_exports_table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Type</th>
                                        <th>Format</th>
                                        <th>Filters</th>
                                        <th>Created</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {recentExports.map(exp => (
                                        <tr key={exp.exportId}>
                                            <td><strong>{exp.exportId}</strong></td>
                                            <td>{exp.reportType}</td>
                                            <td>
                                                <span className={'ar_format_badge ' + (exp.exportFormat === 'CSV' ? 'ar_format_csv' : 'ar_format_pdf')}>
                                                    {exp.exportFormat}
                                                </span>
                                            </td>
                                            <td style={{ maxWidth: '200px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{exp.filtersJson}</td>
                                            <td>{exp.createdAt ? new Date(exp.createdAt.replace(' ', 'T')).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : '-'}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                )}
            </div>
        );
    }

    const container = document.getElementById('analytics-root');
    const root = ReactDOM.createRoot(container);
    root.render(<AnalyticsHub />);
</script>
</body>
</html>
