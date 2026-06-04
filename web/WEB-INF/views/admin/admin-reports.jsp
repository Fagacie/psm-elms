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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-reports-gf.css?v=1.0">
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
            window.location.href = ctxPath + '/reports?startDate=' + (startDate || '') + '&endDate=' + (endDate || '') + '&export=csv';
        };

        const exportPdf = () => {
            window.location.href = ctxPath + '/reports?startDate=' + (startDate || '') + '&endDate=' + (endDate || '') + '&export=pdf';
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
                        <div className="progress-inline-gf">
                            <span className="progress-label-gf">{val}%</span>
                            <div className="progress-bar-gf">
                                <div className="progress-fill-gf" style={{ width: val + '%' }}></div>
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
                        <div className="progress-inline-gf">
                            <span className="progress-label-gf">{val}%</span>
                            <div className="progress-bar-gf">
                                <div className="progress-fill-gf" style={{ width: val + '%' }}></div>
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
                    return <strong style={{ color: 'var(--gf-primary-dark)' }}>{'NGN ' + Number(v).toLocaleString('en-NG')}</strong>;
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
                    <div className="empty-state-gf">
                        <i className="fas fa-chart-bar" style={{ fontSize: '2rem', color: 'var(--gf-text-muted)' }}></i>
                        <p>{emptyMsg}</p>
                    </div>
                );
            }
            return (
                <div style={{ overflowX: 'auto' }}>
                    <table className="data-table-gf">
                        <thead>
                            {table.getHeaderGroups().map(hg => (
                                <tr key={hg.id}>
                                    {hg.headers.map(header => (
                                        <th key={header.id} onClick={header.column.getToggleSortingHandler()} style={{ cursor: 'pointer' }}>
                                            <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                                                {flexRender(header.column.columnDef.header, header.getContext())}
                                                {header.column.getCanSort() && (
                                                    <span style={{ opacity: header.column.getIsSorted() ? 1 : 0.3, fontSize: '0.7rem' }}>
                                                        {header.column.getIsSorted() === 'asc' ? <i className="fas fa-chevron-up"></i> :
                                                         header.column.getIsSorted() === 'desc' ? <i className="fas fa-chevron-down"></i> :
                                                         <i className="fas fa-sort"></i>}
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
                <div className="pagination-bar-gf">
                    <span>Page <strong>{table.getState().pagination.pageIndex + 1}</strong> of <strong>{table.getPageCount()}</strong></span>
                    <div className="pagination-controls-gf">
                        <button className="btn-page-gf" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>Previous</button>
                        <button className="btn-page-gf" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>Next</button>
                    </div>
                </div>
            );
        };

        const renderBreakdownList = (items, emptyMessage) => {
            if (!items || items.length === 0) {
                return (
                    <div className="empty-state-gf module-empty-gf">
                        <i className="fas fa-chart-bar" style={{ fontSize: '1.5rem', color: 'var(--gf-text-muted)' }}></i>
                        <p>{emptyMessage}</p>
                    </div>
                );
            }

            return (
                <div className="module-breakdown-list-gf">
                    {items.map((item) => (
                        <div className="module-breakdown-row-gf" key={(item.label || 'item') + '-' + item.count}>
                            <span className="module-breakdown-label-gf">{item.label}</span>
                            <strong className="module-breakdown-value-gf">{item.count}</strong>
                        </div>
                    ))}
                </div>
            );
        };

        return (
            <div className="analytics-container-gf">
                {/* Breadcrumb */}
                <div className="admin-breadcrumb" style={{ margin: 0 }}>
                    <a href={ctxPath + '/dashboard'}>Dashboard</a>
                    <span>&gt;</span>
                    <span>Analytics Hub</span>
                </div>

                {/* Page Header */}
                <div className="analytics-header-gf">
                    <h1>Visual Analytics Hub</h1>
                    <p>Explore enrollment trends, revenue performance, and platform health indicators with interactive charts and filterable data tables.</p>
                </div>

                {/* ═══ Command Bar ═══ */}
                <div className="command-bar-gf">
                    <div className="bar-title-gf">
                        <h2><i className="fas fa-sliders-h" style={{ color: 'var(--gf-primary)' }}></i> Report Controls</h2>
                        <span className="admin-badge-gf">Admin Only</span>
                    </div>
                    <div className="command-form-gf">
                        <div className="filter-group-gf">
                            <label>From</label>
                            <input type="date" value={startDate} onChange={e => setStartDate(e.target.value)} />
                        </div>
                        <div className="filter-group-gf">
                            <label>To</label>
                            <input type="date" value={endDate} onChange={e => setEndDate(e.target.value)} />
                        </div>
                        <div className="command-actions-gf">
                            <button className="btn-primary-gf" onClick={applyFilter}>
                                <i className="fas fa-filter"></i> Apply Filter
                            </button>
                            <button className="btn-secondary-gf" onClick={resetFilter}>
                                <i className="fas fa-undo"></i> Reset
                            </button>
                            <button className="btn-primary-gf" onClick={exportCsv} style={{ background: '#0f172a' }}>
                                <i className="fas fa-file-csv"></i> Export CSV
                            </button>
                            <button className="btn-primary-gf" onClick={exportPdf} style={{ background: 'var(--gf-primary-dark)' }}>
                                <i className="fas fa-file-pdf"></i> Download PDF
                            </button>
                        </div>
                    </div>
                    <div className="presets-row-gf">
                        <button className="preset-btn-gf" onClick={() => setQuickRange(7)}>Last 7 Days</button>
                        <button className="preset-btn-gf" onClick={() => setQuickRange(30)}>Last 30 Days</button>
                        <button className="preset-btn-gf" onClick={() => setQuickRange(90)}>Last 90 Days</button>
                        <button className="preset-btn-gf" onClick={setYtd}>Year to Date</button>
                    </div>
                    {(startDate || endDate) && (
                        <div className="filter-chips-gf">
                            {hasFilter ? (
                                <span className="chip-gf chip-primary-gf">
                                    <i className="fas fa-calendar-alt"></i> {startDate} → {endDate}
                                </span>
                            ) : null}
                            <span className="chip-gf chip-muted-gf">
                                {hasFilter ? 'Filtered view' : 'Full history'}
                            </span>
                        </div>
                    )}
                </div>

                {/* ═══ KPI Metrics Strip ═══ */}
                <section className="metrics-grid-gf">
                    <div className="metric-card-gf">
                        <span className="label"><i className="fas fa-coins" style={{ marginRight: '0.3rem' }}></i> Total Revenue</span>
                        <span className="value" style={{ color: 'var(--gf-primary-dark)' }}>{'NGN ' + Number(totalRevenue).toLocaleString('en-NG')}</span>
                        <span className="sub-label">{hasFilter ? 'Filtered period' : 'All time'}</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label"><i className="fas fa-user-graduate" style={{ marginRight: '0.3rem' }}></i> Enrollments</span>
                        <span className="value">{totalEnrollments}</span>
                        <span className="sub-label">{completedEnrollments} completed</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label"><i className="fas fa-chart-line" style={{ marginRight: '0.3rem' }}></i> Completion Rate</span>
                        <span className="value" style={{ color: completionRate >= 50 ? 'var(--gf-primary-dark)' : 'var(--gf-amber)' }}>{completionRate}%</span>
                        <span className="sub-label">Based on filtered data</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label"><i className="fas fa-user-plus" style={{ marginRight: '0.3rem' }}></i> New Users</span>
                        <span className="value">{newUsers}</span>
                        <span className="sub-label">{hasFilter ? 'In selected range' : 'Use date filter'}</span>
                    </div>
                </section>

                {/* ═══ Platform Snapshot ═══ */}
                <div className="snapshot-card-gf">
                    <div className="snapshot-header-gf">
                        <h3><i className="fas fa-th-large" style={{ color: 'var(--gf-primary)', marginRight: '0.4rem' }}></i> Platform Snapshot</h3>
                        <span className="chip-gf chip-muted-gf" style={{ fontSize: '0.7rem' }}>All-Time Totals</span>
                    </div>
                    <div className="snapshot-grid-inner-gf">
                        <div className="snapshot-tile-gf">
                            <span className="tile-label">Users</span>
                            <span className="tile-value">{summary.totalUsers || 0}</span>
                        </div>
                        <div className="snapshot-tile-gf">
                            <span className="tile-label">Students</span>
                            <span className="tile-value">{summary.totalStudents || 0}</span>
                        </div>
                        <div className="snapshot-tile-gf">
                            <span className="tile-label">Instructors</span>
                            <span className="tile-value">{summary.totalInstructors || 0}</span>
                        </div>
                        <div className="snapshot-tile-gf">
                            <span className="tile-label">Courses</span>
                            <span className="tile-value">{summary.totalCourses || 0}</span>
                        </div>
                        <div className="snapshot-tile-gf">
                            <span className="tile-label">Enrollments</span>
                            <span className="tile-value">{summary.totalEnrollments || 0}</span>
                        </div>
                        <div className="snapshot-tile-gf">
                            <span className="tile-label">Completed</span>
                            <span className="tile-value">{summary.completedEnrollments || 0}</span>
                        </div>
                        <div className="snapshot-tile-gf">
                            <span className="tile-label">Certificates</span>
                            <span className="tile-value">{summary.activeCertificates || 0}</span>
                        </div>
                        <div className="snapshot-tile-gf">
                            <span className="tile-label">Revenue</span>
                            <span className="tile-value" style={{ fontSize: '1.1rem' }}>{'NGN ' + Number(summary.totalRevenue || 0).toLocaleString('en-NG')}</span>
                        </div>
                    </div>
                </div>

                {/* ═══ Module Reports ═══ */}
                <section className="module-grid-gf">
                    <div className="module-card-gf">
                        <div className="module-card-head-gf">
                            <h3><i className="fas fa-users"></i> User Module</h3>
                            <span>Accounts and roles</span>
                        </div>
                        <div className="module-summary-grid-gf">
                            <div className="module-summary-item-gf"><span>Total</span><strong>{summary.totalUsers || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Students</span><strong>{summary.totalStudents || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Instructors</span><strong>{summary.totalInstructors || 0}</strong></div>
                        </div>
                        {renderBreakdownList(userRoles, 'No role breakdown available.')}
                        {renderBreakdownList(userStatuses, 'No status breakdown available.')}
                    </div>

                    <div className="module-card-gf">
                        <div className="module-card-head-gf">
                            <h3><i className="fas fa-book-open"></i> Course Module</h3>
                            <span>Catalog health</span>
                        </div>
                        <div className="module-summary-grid-gf">
                            <div className="module-summary-item-gf"><span>Total</span><strong>{summary.totalCourses || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Enrollments</span><strong>{summary.totalEnrollments || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Revenue</span><strong>{'NGN ' + Number(summary.totalRevenue || 0).toLocaleString('en-NG')}</strong></div>
                        </div>
                        {renderBreakdownList(courseStatuses, 'No course status breakdown available.')}
                    </div>

                    <div className="module-card-gf">
                        <div className="module-card-head-gf">
                            <h3><i className="fas fa-graduation-cap"></i> Enrollment Module</h3>
                            <span>Progress and completion</span>
                        </div>
                        <div className="module-summary-grid-gf">
                            <div className="module-summary-item-gf"><span>Active</span><strong>{summary.totalEnrollments || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Completed</span><strong>{summary.completedEnrollments || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Filtered</span><strong>{summary.filteredEnrollments || summary.totalEnrollments || 0}</strong></div>
                        </div>
                        {renderBreakdownList(enrollmentStatuses, 'No enrollment status breakdown available.')}
                    </div>

                    <div className="module-card-gf">
                        <div className="module-card-head-gf">
                            <h3><i className="fas fa-coins"></i> Payment Module</h3>
                            <span>Collections and gateway states</span>
                        </div>
                        <div className="module-summary-grid-gf">
                            <div className="module-summary-item-gf"><span>Total</span><strong>{'NGN ' + Number(summary.totalRevenue || 0).toLocaleString('en-NG')}</strong></div>
                            <div className="module-summary-item-gf"><span>Filtered</span><strong>{'NGN ' + Number(summary.filteredRevenue || summary.totalRevenue || 0).toLocaleString('en-NG')}</strong></div>
                        </div>
                        {renderBreakdownList(paymentStatuses, 'No payment status breakdown available.')}
                    </div>

                    <div className="module-card-gf">
                        <div className="module-card-head-gf">
                            <h3><i className="fas fa-certificate"></i> Certificate Module</h3>
                            <span>Issued credentials</span>
                        </div>
                        <div className="module-summary-grid-gf">
                            <div className="module-summary-item-gf"><span>Active</span><strong>{summary.activeCertificates || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Issued</span><strong>{summary.activeCertificates || 0}</strong></div>
                        </div>
                        {renderBreakdownList(certificateStatuses, 'No certificate status breakdown available.')}
                    </div>

                    <div className="module-card-gf">
                        <div className="module-card-head-gf">
                            <h3><i className="fas fa-clipboard-check"></i> Assessment Module</h3>
                            <span>Testing and grading</span>
                        </div>
                        <div className="module-summary-grid-gf">
                            <div className="module-summary-item-gf"><span>Total</span><strong>{assessmentSummary.totalAssessments || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Questions</span><strong>{assessmentSummary.totalQuestions || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Submissions</span><strong>{assessmentSummary.totalSubmissions || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Graded</span><strong>{assessmentSummary.gradedSubmissions || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Pending</span><strong>{assessmentSummary.pendingSubmissions || 0}</strong></div>
                            <div className="module-summary-item-gf"><span>Retakes</span><strong>{assessmentSummary.pendingRetakeRequests || 0}</strong></div>
                        </div>
                        {renderBreakdownList(gradingModes, 'No grading mode breakdown available.')}
                        {renderBreakdownList(submissionModes, 'No submission mode breakdown available.')}
                        {renderBreakdownList(reportAccessStatuses, 'No report access breakdown available.')}
                    </div>
                </section>

                {/* ═══ Charts Grid ═══ */}
                <div className="charts-grid-gf">
                    {/* Revenue Bar Chart */}
                    <div className="chart-card-gf">
                        <div className="chart-header-gf">
                            <h3><i className="fas fa-chart-bar" style={{ color: 'var(--gf-primary)' }}></i> Revenue by Course</h3>
                            <span className="chart-sub">{revenueRows.length} courses</span>
                        </div>
                        <div className="chart-canvas-wrap-gf" style={{ height: Math.max(200, revenueRows.length * 36) + 'px' }}>
                            {revenueRows.length > 0 ? (
                                <canvas ref={revenueCanvasRef}></canvas>
                            ) : (
                                <div className="empty-state-gf">
                                    <i className="fas fa-chart-bar" style={{ fontSize: '2rem', color: 'var(--gf-text-muted)' }}></i>
                                    <p>No revenue data available for charting.</p>
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Enrollment Doughnut */}
                    <div className="chart-card-gf">
                        <div className="chart-header-gf">
                            <h3><i className="fas fa-chart-pie" style={{ color: 'var(--gf-accent)' }}></i> Enrollment Share</h3>
                            <span className="chart-sub">Top {Math.min(6, topCourses.length)}</span>
                        </div>
                        <div className="chart-canvas-wrap-gf chart-doughnut-wrap-gf" style={{ height: '320px' }}>
                            {topCourses.length > 0 ? (
                                <canvas ref={enrollCanvasRef}></canvas>
                            ) : (
                                <div className="empty-state-gf">
                                    <i className="fas fa-chart-pie" style={{ fontSize: '2rem', color: 'var(--gf-text-muted)' }}></i>
                                    <p>No enrollment data available.</p>
                                </div>
                            )}
                        </div>
                    </div>
                </div>

                {/* ═══ Top Courses Table ═══ */}
                <div className="table-card-gf">
                    <div className="table-header-gf">
                        <h3><i className="fas fa-trophy" style={{ color: 'var(--gf-amber)' }}></i> Top Courses by Enrollment</h3>
                        <span className="record-count-gf">{filteredCourses.length} {filteredCourses.length === 1 ? 'record' : 'records'}</span>
                    </div>
                    <div className="table-controls-gf">
                        <div className="search-box-gf">
                            <i className="fas fa-search"></i>
                            <input type="text" placeholder="Search courses..." value={courseSearch} onChange={e => setCourseSearch(e.target.value)} />
                        </div>
                    </div>
                    {renderTable(courseTable, 'No course enrollment data matches your search.')}
                    {renderPagination(courseTable)}
                </div>

                {/* ═══ Revenue Table ═══ */}
                <div className="table-card-gf">
                    <div className="table-header-gf">
                        <h3><i className="fas fa-money-bill-wave" style={{ color: 'var(--gf-primary)' }}></i> Revenue Breakdown by Course</h3>
                        <span className="record-count-gf">{filteredRevenue.length} {filteredRevenue.length === 1 ? 'record' : 'records'}</span>
                    </div>
                    <div className="table-controls-gf">
                        <div className="search-box-gf">
                            <i className="fas fa-search"></i>
                            <input type="text" placeholder="Search revenue..." value={revenueSearch} onChange={e => setRevenueSearch(e.target.value)} />
                        </div>
                    </div>
                    {renderTable(revenueTable, 'No revenue data matches your search.')}
                    {renderPagination(revenueTable)}
                </div>

                {/* ═══ Recent Exports Log ═══ */}
                {recentExports.length > 0 && (
                    <div className="table-card-gf">
                        <div className="table-header-gf">
                            <h3><i className="fas fa-history" style={{ color: 'var(--gf-text-muted)' }}></i> Recent Export History</h3>
                            <span className="record-count-gf">{recentExports.length} exports</span>
                        </div>
                        <div style={{ overflowX: 'auto' }}>
                            <table className="exports-table-gf">
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
                                                <span className={'format-badge-gf ' + (exp.exportFormat === 'CSV' ? 'format-csv-gf' : 'format-pdf-gf')}>
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
