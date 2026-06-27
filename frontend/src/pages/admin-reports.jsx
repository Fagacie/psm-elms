const { useState, useEffect, useMemo, useCallback, useRef } = window.React || React;
const ReactDOM = window.ReactDOM;

    
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
            if (!window.html2canvas || !window.jspdf) {
                window.location.href = ctxPath + '/reports?startDate=' + (startDate || '') + '&endDate=' + (endDate || '') + '&export=pdf' +
                    '&incSummary=' + incSummary +
                    '&incBreakdowns=' + incBreakdowns +
                    '&incAssessments=' + incAssessments +
                    '&incTopCourses=' + incTopCourses +
                    '&incRevenue=' + incRevenue +
                    '&incHistory=' + incHistory;
                return;
            }

            // Capture chart canvas images if available
            const getCanvasImg = (ref) => (ref && ref.current) ? ref.current.toDataURL('image/png') : null;
            const revImg = getCanvasImg(revenueCanvasRef);
            const enrollImg = getCanvasImg(enrollCanvasRef);

            // Build clean printable document
            const reportDoc = document.createElement('div');
            reportDoc.id = 'printableReportDoc';
            reportDoc.style.cssText = 'position: fixed; left: -9999px; top: 0; width: 794px; background: #ffffff; color: #0f172a; font-family: "Inter", sans-serif; padding: 40px; box-sizing: border-box; z-index: -9999;';

            let html = `
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #166534; padding-bottom: 20px; margin-bottom: 28px;">
                    <div>
                        <h1 style="font-size: 26px; font-weight: 800; color: #0f172a; margin: 0; letter-spacing: -0.5px;">PSM E-Learning Academy</h1>
                        <h2 style="font-size: 15px; font-weight: 600; color: #166534; margin: 6px 0 0 0; text-transform: uppercase; letter-spacing: 0.5px;">Executive Analytics & KPI Report</h2>
                    </div>
                    <div style="text-align: right; font-size: 12px; color: #475569; line-height: 1.5;">
                        <div><strong>Report Period:</strong> ${startDate ? startDate : 'Full History'} → ${endDate ? endDate : 'Present'}</div>
                        <div><strong>Generated Date:</strong> ${new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })}</div>
                    </div>
                </div>
            `;

            if (incSummary) {
                html += `
                    <div style="margin-bottom: 30px;">
                        <h3 style="font-size: 16px; font-weight: 700; color: #0f172a; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px; margin: 0 0 16px 0;">Key Performance Indicators</h3>
                        <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px;">
                            <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; text-align: center;">
                                <div style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Total Revenue</div>
                                <div style="font-size: 18px; font-weight: 800; color: #166534; margin-top: 6px;">NGN ${Number(totalRevenue).toLocaleString('en-NG')}</div>
                            </div>
                            <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; text-align: center;">
                                <div style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Enrollments</div>
                                <div style="font-size: 18px; font-weight: 800; color: #0f172a; margin-top: 6px;">${totalEnrollments}</div>
                                <div style="font-size: 10px; color: #64748b; margin-top: 2px;">${completedEnrollments} Completed</div>
                            </div>
                            <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; text-align: center;">
                                <div style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Completion Rate</div>
                                <div style="font-size: 18px; font-weight: 800; color: #2563eb; margin-top: 6px;">${completionRate}%</div>
                            </div>
                            <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; text-align: center;">
                                <div style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">New Users</div>
                                <div style="font-size: 18px; font-weight: 800; color: #9333ea; margin-top: 6px;">${newUsers}</div>
                            </div>
                        </div>
                    </div>
                `;
            }

            if (revImg || enrollImg) {
                html += `
                    <div style="margin-bottom: 30px;">
                        <h3 style="font-size: 16px; font-weight: 700; color: #0f172a; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px; margin: 0 0 16px 0;">Visual Analytics & Charts</h3>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                            ${revImg ? `<div><div style="font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 8px;">Revenue by Course</div><div style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; background: #ffffff;"><img src="${revImg}" style="width: 100%; height: auto; display: block;" /></div></div>` : ''}
                            ${enrollImg ? `<div><div style="font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 8px;">Enrollment Share</div><div style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; background: #ffffff;"><img src="${enrollImg}" style="width: 100%; height: auto; display: block;" /></div></div>` : ''}
                        </div>
                    </div>
                `;
            }

            if (incTopCourses && topCourses && topCourses.length > 0) {
                html += `
                    <div style="margin-bottom: 30px;">
                        <h3 style="font-size: 16px; font-weight: 700; color: #0f172a; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px; margin: 0 0 12px 0;">Top Courses by Enrollment</h3>
                        <table style="width: 100%; border-collapse: collapse; font-size: 12px; text-align: left;">
                            <thead>
                                <tr style="background: #f1f5f9; color: #334155; font-weight: 600;">
                                    <th style="padding: 8px 10px; border: 1px solid #cbd5e1;">Course Title</th>
                                    <th style="padding: 8px 10px; border: 1px solid #cbd5e1; text-align: center;">Enrollments</th>
                                    <th style="padding: 8px 10px; border: 1px solid #cbd5e1; text-align: center;">Completions</th>
                                    <th style="padding: 8px 10px; border: 1px solid #cbd5e1; text-align: center;">Completion Rate</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${topCourses.slice(0, 10).map((c, i) => `
                                    <tr style="background: ${i % 2 === 0 ? '#ffffff' : '#f8fafc'};">
                                        <td style="padding: 8px 10px; border: 1px solid #e2e8f0; font-weight: 500;">${c.title}</td>
                                        <td style="padding: 8px 10px; border: 1px solid #e2e8f0; text-align: center;">${c.enrollments}</td>
                                        <td style="padding: 8px 10px; border: 1px solid #e2e8f0; text-align: center;">${c.completions}</td>
                                        <td style="padding: 8px 10px; border: 1px solid #e2e8f0; text-align: center;">${c.completionRate}%</td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                `;
            }

            if (incRevenue && revenueRows && revenueRows.length > 0) {
                html += `
                    <div style="margin-bottom: 30px;">
                        <h3 style="font-size: 16px; font-weight: 700; color: #0f172a; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px; margin: 0 0 12px 0;">Revenue Breakdown by Course</h3>
                        <table style="width: 100%; border-collapse: collapse; font-size: 12px; text-align: left;">
                            <thead>
                                <tr style="background: #f1f5f9; color: #334155; font-weight: 600;">
                                    <th style="padding: 8px 10px; border: 1px solid #cbd5e1;">Course Title</th>
                                    <th style="padding: 8px 10px; border: 1px solid #cbd5e1; text-align: center;">Enrollments</th>
                                    <th style="padding: 8px 10px; border: 1px solid #cbd5e1; text-align: right;">Revenue (NGN)</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${revenueRows.slice(0, 10).map((r, i) => `
                                    <tr style="background: ${i % 2 === 0 ? '#ffffff' : '#f8fafc'};">
                                        <td style="padding: 8px 10px; border: 1px solid #e2e8f0; font-weight: 500;">${r.title}</td>
                                        <td style="padding: 8px 10px; border: 1px solid #e2e8f0; text-align: center;">${r.enrollments}</td>
                                        <td style="padding: 8px 10px; border: 1px solid #e2e8f0; text-align: right; font-weight: 600; color: #166534;">NGN ${Number(r.revenue).toLocaleString('en-NG')}</td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                `;
            }

            html += `
                <div style="border-top: 1px solid #cbd5e1; padding-top: 16px; text-align: center; font-size: 11px; color: #64748b; margin-top: 40px;">
                    Confidential Executive Report • PSM E-Learning Platform • Generated via Admin Portal
                </div>
            `;

            reportDoc.innerHTML = html;
            document.body.appendChild(reportDoc);

            window.html2canvas(reportDoc, { scale: 2, useCORS: true, logging: false, backgroundColor: '#ffffff' }).then(canvas => {
                const imgData = canvas.toDataURL('image/png');
                const { jsPDF } = window.jspdf;
                const pdf = new jsPDF('p', 'mm', 'a4');
                const imgWidth = 210;
                const pageHeight = 297;
                const imgHeight = (canvas.height * imgWidth) / canvas.width;
                let heightLeft = imgHeight;
                let position = 0;
                pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
                heightLeft -= pageHeight;
                while (heightLeft > 2) {
                    position = heightLeft - imgHeight;
                    pdf.addPage();
                    pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
                    heightLeft -= pageHeight;
                }
                pdf.save('PSME_Executive_Report_' + new Date().toISOString().slice(0,10) + '.pdf');
            }).catch(err => {
                console.error("PDF Report generation failed:", err);
                alert("Could not generate PDF report. Please try again.");
            }).finally(() => {
                if (reportDoc.parentNode) {
                    reportDoc.parentNode.removeChild(reportDoc);
                }
            });
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
