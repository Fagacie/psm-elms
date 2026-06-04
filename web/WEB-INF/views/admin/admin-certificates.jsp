<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Credentials Registry - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400;1,600&family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-certificates-gf.css?v=1.0">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- React & ReactDOM UMD production versions -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for live JSX translation -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    
    <!-- TanStack Table UMD -->
    <script src="https://unpkg.com/@tanstack/react-table@8.17.3/build/umd/index.production.js"></script>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Certificates"/>
    <jsp:param name="pageSubtitle" value="Validate issued credentials, search registry records, and review revocations"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- Success/Error Banners in Greenfield Styling -->
    <div style="max-width: 1400px; margin: 2rem auto 0 auto; padding: 0 2rem;">
        <c:if test="${param.success == 'revoked'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Certificate revoked successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'backfill'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Enrollment eligibility backfill completed. Updated: <c:out value="${param.updated}"/>, Errors: <c:out value="${param.errors}"/>.
            </div>
        </c:if>
        <c:if test="${param.error == 'revoke'}">
            <div class="alert-gf alert-error-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-exclamation-circle"></i> Unable to revoke certificate.
            </div>
        </c:if>
        <c:if test="${param.error == 'invalid'}">
            <div class="alert-gf alert-error-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-exclamation-circle"></i> Invalid certificate action request.
            </div>
        </c:if>
    </div>

    <!-- React Mounting Entry Node -->
    <div id="admin-react-root"></div>
</main>

<%
    List<com.psm.elearning.model.CertificateView> certificatesList = (List<com.psm.elearning.model.CertificateView>) request.getAttribute("certificates");
    org.json.JSONArray certsJsonArray = new org.json.JSONArray();
    if (certificatesList != null) {
        for (com.psm.elearning.model.CertificateView c : certificatesList) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("certificateId", c.getCertificateId());
            obj.put("enrollmentId", c.getEnrollmentId());
            obj.put("courseId", c.getCourseId());
            obj.put("certificateNo", c.getCertificateNo() != null ? c.getCertificateNo() : "");
            obj.put("issueDate", c.getIssueDate() != null ? c.getIssueDate().toString() : "");
            obj.put("generatedBy", c.getGeneratedBy() != null ? c.getGeneratedBy() : "");
            obj.put("verificationURL", c.getVerificationURL() != null ? c.getVerificationURL() : "");
            obj.put("qrCodePath", c.getQrCodePath() != null ? c.getQrCodePath() : "");
            obj.put("status", c.getStatus() != null ? c.getStatus() : "Active");
            obj.put("revokedAt", c.getRevokedAt() != null ? c.getRevokedAt().toString() : "");
            obj.put("revokedBy", c.getRevokedBy() != null ? c.getRevokedBy() : 0);
            obj.put("studentName", c.getStudentName() != null ? c.getStudentName() : "");
            obj.put("studentEmail", c.getStudentEmail() != null ? c.getStudentEmail() : "");
            obj.put("regNumber", c.getRegNumber() != null ? c.getRegNumber() : "");
            obj.put("courseName", c.getCourseName() != null ? c.getCourseName() : "");
            obj.put("instructorName", c.getInstructorName() != null ? c.getInstructorName() : "");
            certsJsonArray.put(obj);
        }
    }
    pageContext.setAttribute("serializedCertsJson", certsJsonArray.toString());
%>

<!-- Context Serialization securely into window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__CERTIFICATES__ = ${serializedCertsJson};
</script>

<!-- Interactive React Command Center Application -->
<script type="text/babel">
    const { useState, useEffect, useMemo } = React;
    const { 
        useReactTable, getCoreRowModel, getPaginationRowModel, getSortedRowModel, flexRender 
    } = window.ReactTable || {};

    function CertificatesRegistry() {
        const [certificates, setCertificates] = useState(window.__CERTIFICATES__ || []);
        const [globalFilter, setGlobalFilter] = useState('');
        const [courseFilter, setCourseFilter] = useState('All');
        
        // Pagination state
        const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
        
        // Sorting state
        const [sorting, setSorting] = useState([{ id: 'issueDate', desc: true }]);

        // Dropdown menu tracking
        const [activeDropdownId, setActiveDropdownId] = useState(null);

        // Drawer and Modal states
        const [drawerOpen, setDrawerOpen] = useState(false);
        const [selectedCert, setSelectedCert] = useState(null);
        
        // Search verification modal states
        const [verifyModalOpen, setVerifyModalOpen] = useState(false);
        const [verifySearchCode, setVerifySearchCode] = useState('');
        const [verifyResult, setVerifyResult] = useState(null); // 'not-found', 'revoked', or certificate object

        // Revocation modal state
        const [revokeModalOpen, setRevokeModalOpen] = useState(false);
        const [certToRevoke, setCertToRevoke] = useState(null);

        // Toast copied notification
        const [toastVisible, setToastVisible] = useState(false);
        const [toastMessage, setToastMessage] = useState('');

        // Unique Course Catalog for dropdown options
        const uniqueCourses = useMemo(() => ['All', ...new Set(certificates.map(c => c.courseName).filter(Boolean))], [certificates]);

        // Calculated registry metrics
        const totalCount = certificates.length;
        const activeCount = certificates.filter(c => c.status && c.status.toLowerCase() !== 'revoked').length;
        const revokedCount = totalCount - activeCount;

        // Copy verification link to clipboard
        const copyToClipboard = (text, message = 'Link copied to clipboard!') => {
            const el = document.createElement('textarea');
            el.value = text;
            document.body.appendChild(el);
            el.select();
            document.execCommand('copy');
            document.body.removeChild(el);

            setToastMessage(message);
            setToastVisible(true);
            setTimeout(() => setToastVisible(false), 2500);
        };

        // Instant lookup verify search logic
        const handleVerifyLookup = () => {
            if (!verifySearchCode.trim()) {
                setVerifyResult(null);
                return;
            }
            const normalized = verifySearchCode.trim().toUpperCase();
            const found = certificates.find(c => c.certificateNo && c.certificateNo.toUpperCase() === normalized);
            if (!found) {
                setVerifyResult({ status: 'not-found' });
            } else if (found.status && found.status.toLowerCase() === 'revoked') {
                setVerifyResult({ status: 'revoked', data: found });
            } else {
                setVerifyResult({ status: 'active', data: found });
            }
        };

        // Filter and Search logic
        const filteredData = useMemo(() => certificates.filter(c => {
            const matchesCourse = courseFilter === 'All' || c.courseName === courseFilter;
            
            const certNo = c.certificateNo ? c.certificateNo.toLowerCase() : '';
            const student = c.studentName ? c.studentName.toLowerCase() : '';
            const email = c.studentEmail ? c.studentEmail.toLowerCase() : '';
            const search = globalFilter.toLowerCase();
            const matchesSearch = certNo.includes(search) || student.includes(search) || email.includes(search);

            return matchesCourse && matchesSearch;
        }), [certificates, courseFilter, globalFilter]);

        // Close dropdown when clicking outside
        useEffect(() => {
            const handleOutsideClick = (e) => {
                if (activeDropdownId && !e.target.closest('.actions-cell-gf')) {
                    setActiveDropdownId(null);
                }
            };
            window.addEventListener('click', handleOutsideClick);
            return () => window.removeEventListener('click', handleOutsideClick);
        }, [activeDropdownId]);

        // Define TanStack columns
        const columns = useMemo(() => [
            {
                accessorKey: 'certificateNo',
                header: 'Certificate ID',
                cell: info => {
                    const val = info.getValue() || '';
                    return (
                        <div 
                            className="cert-badge-gf" 
                            onClick={(e) => {
                                e.stopPropagation();
                                copyToClipboard(val, 'Certificate ID copied!');
                            }}
                            title="Click to copy Certificate ID"
                        >
                            <i className="fas fa-hashtag text-muted" style={{ marginRight: '0.4rem' }}></i>
                            <span>{val}</span>
                        </div>
                    );
                }
            },
            {
                accessorKey: 'studentName',
                header: 'Recipient',
                cell: info => {
                    const row = info.row.original;
                    const name = row.studentName || 'Unknown Student';
                    const email = row.studentEmail || '';
                    const initials = name.split(' ').map(n => n[0]).join('').substring(0, 2);
                    return (
                        <div className="student-cell-gf">
                            <div className="student-avatar-gf">{initials}</div>
                            <div className="student-meta-gf">
                                <span className="student-name-gf">{name}</span>
                                <span className="student-email-gf">{email}</span>
                            </div>
                        </div>
                    );
                }
            },
            {
                accessorKey: 'courseName',
                header: 'Course',
                cell: info => <span style={{ fontWeight: 600 }}>{info.getValue() || ''}</span>
            },
            {
                accessorKey: 'issueDate',
                header: 'Issue Date',
                cell: info => {
                    const rawDate = info.getValue();
                    if (!rawDate) return '-';
                    const d = new Date(rawDate.replace(' ', 'T'));
                    return (
                        <div>
                            <strong>{d.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}</strong>
                            <div style={{ fontSize: '0.8rem', color: 'var(--gf-text-muted)', marginTop: '2px' }}>
                                {d.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' })}
                            </div>
                        </div>
                    );
                }
            },
            {
                accessorKey: 'status',
                header: 'Status',
                cell: info => {
                    const statusVal = info.getValue() || 'Active';
                    const isRevoked = statusVal.toLowerCase() === 'revoked';
                    const row = info.row.original;
                    return (
                        <div>
                            <span className={isRevoked ? 'badge-gf badge-revoked-gf' : 'badge-gf badge-active-gf'}>
                                {isRevoked ? 'Revoked' : 'Active'}
                            </span>
                            {isRevoked && row.revokedAt && (
                                <div style={{ fontSize: '0.75rem', color: 'var(--gf-red)', marginTop: '4px', fontWeight: 500 }}>
                                    on {new Date(row.revokedAt.replace(' ', 'T')).toLocaleDateString()}
                                </div>
                            )}
                        </div>
                    );
                }
            },
            {
                id: 'actions',
                header: () => <div style={{ textAlign: 'right' }}>Actions</div>,
                cell: info => {
                    const row = info.row.original;
                    const isRevoked = row.status && row.status.toLowerCase() === 'revoked';
                    
                    return (
                        <div className="actions-cell-gf" onClick={e => e.stopPropagation()}>
                            <button 
                                className="actions-btn-gf"
                                onClick={(e) => {
                                    e.stopPropagation();
                                    setActiveDropdownId(activeDropdownId === row.certificateId ? null : row.certificateId);
                                }}
                            >
                                <i className="fas fa-ellipsis-v"></i>
                            </button>
                            {activeDropdownId === row.certificateId && (
                                <div className="actions-dropdown-gf">
                                    <button 
                                        className="dropdown-item-gf"
                                        onClick={() => {
                                            setSelectedCert(row);
                                            setDrawerOpen(true);
                                            setActiveDropdownId(null);
                                        }}
                                    >
                                        <i className="fas fa-eye" style={{ marginRight: '0.4rem' }}></i> View Certificate
                                    </button>
                                    
                                    {!isRevoked && (
                                        <button 
                                            className="dropdown-item-gf danger"
                                            onClick={() => {
                                                setCertToRevoke(row);
                                                setRevokeModalOpen(true);
                                                setActiveDropdownId(null);
                                            }}
                                        >
                                            <i className="fas fa-exclamation-triangle" style={{ marginRight: '0.4rem' }}></i> Revoke
                                        </button>
                                    )}
                                </div>
                            )}
                        </div>
                    );
                }
            }
        ], [activeDropdownId]);

        // Configure TanStack React Table
        const table = useReactTable({
            data: filteredData,
            columns,
            state: {
                pagination,
                sorting
            },
            onPaginationChange: setPagination,
            onSortingChange: setSorting,
            getCoreRowModel: getCoreRowModel ? getCoreRowModel() : null,
            getPaginationRowModel: getPaginationRowModel ? getPaginationRowModel() : null,
            getSortedRowModel: getSortedRowModel ? getSortedRowModel() : null,
        });

        return (
            <div className="admin-container-gf">
                {/* Dashboard Breadcrumbs */}
                <div className="admin-breadcrumb" style={{ margin: 0 }}>
                    <a href={window.__CONTEXT_PATH__ + "/dashboard"}>Dashboard</a>
                    <span>&gt;</span>
                    <span>Certificates Registry</span>
                </div>

                {/* Dashboard Headers */}
                <div className="dashboard-header-gf">
                    <h1>Credentials Verification Registry</h1>
                    <p>Audit and manage institutional certificate templates, perform visual validation lookups, and cancel course completion credentials.</p>
                </div>

                {/* Registry Overview Summary Metrics */}
                <section className="metrics-grid-gf">
                    <div className="metric-card-gf">
                        <span className="label">Total Issued</span>
                        <span className="value">{totalCount}</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Active Verified</span>
                        <span className="value" style={{ color: 'var(--gf-primary-dark)' }}>{activeCount}</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Revoked Credentials</span>
                        <span className="value" style={{ color: 'var(--gf-red)' }}>{revokedCount}</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Registry Status</span>
                        <span className="value" style={{ fontSize: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.4rem', color: 'var(--gf-primary-dark)' }}>
                            <i className="fas fa-shield-alt" style={{ width: '22px' }}></i> Operational
                        </span>
                    </div>
                </section>

                {/* Command Control Action Panel */}
                <div className="section-card" style={{ padding: '1.5rem 2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '1.5rem', backgroundColor: '#ffffff', border: '1px solid var(--gf-border)', borderRadius: '12px', boxShadow: 'var(--gf-card-shadow)' }}>
                    <div>
                        <strong style={{ display: 'block', fontSize: '1rem', color: 'var(--gf-text-primary)' }}>Registry Tooling Controls</strong>
                        <span style={{ fontSize: '0.85rem', color: 'var(--gf-text-secondary)' }}>Backfill new certificate eligibility criteria or preview templates.</span>
                    </div>
                    <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
                        <a className="btn-secondary-gf" style={{ textDecoration: 'none', display: 'inline-flex', alignItems: 'center', gap: '0.5rem' }} href={window.__CONTEXT_PATH__ + "/certificate/template?back=" + window.__CONTEXT_PATH__ + "/admin/certificates"}>
                            <i className="fas fa-file-alt" style={{ marginRight: '0.4rem' }}></i> Preview Template
                        </a>
                        <form method="post" action={window.__CONTEXT_PATH__ + "/admin/certificates"} style={{ margin: 0 }}>
                            <input type="hidden" name="action" value="backfill" />
                            <button 
                                className="btn-primary-gf" 
                                type="submit"
                                onClick={(e) => {
                                    if (!confirm('Run enrollment backfill now? This recalculates completion checkpoints for all users.')) {
                                        e.preventDefault();
                                    }
                                }}
                            >
                                <i className="fas fa-sync-alt" style={{ marginRight: '0.4rem' }}></i> Backfill Eligible State
                            </button>
                        </form>
                    </div>
                </div>

                {/* Headless Table Shell */}
                <section className="table-card-gf">
                    <div className="table-controls-gf">
                        <div className="controls-left-gf">
                            {/* Global Monospace Code or Student Name Search */}
                            <div className="search-box-gf">
                                <i className="fas fa-search"></i>
                                <input 
                                    type="text" 
                                    placeholder="Search student, email, or Certificate ID..."
                                    value={globalFilter}
                                    onChange={e => setGlobalFilter(e.target.value)}
                                />
                            </div>

                            {/* Dropdown Course Category Filter */}
                            <select 
                                className="select-filter-gf"
                                value={courseFilter}
                                onChange={e => setCourseFilter(e.target.value)}
                            >
                                {uniqueCourses.map(course => (
                                    <option key={course} value={course}>
                                        {course === 'All' ? 'All Certified Courses' : course}
                                    </option>
                                ))}
                            </select>
                        </div>

                        {/* Verify modal launcher button */}
                        <button 
                            className="btn-primary-gf"
                            onClick={() => {
                                setVerifySearchCode('');
                                setVerifyResult(null);
                                setVerifyModalOpen(true);
                            }}
                        >
                            <i className="fas fa-shield-alt" style={{ marginRight: '0.4rem' }}></i> Verify Certificate
                        </button>
                    </div>

                    {filteredData.length === 0 ? (
                        <div className="empty-state-gf">
                            <i className="fas fa-award" style={{ fontSize: '2.5rem', color: 'var(--gf-text-muted)' }}></i>
                            <p>No verified certificate records found matching the current query criteria.</p>
                        </div>
                    ) : (
                        <div style={{ overflowX: 'auto' }}>
                            <table className="certs-table-gf">
                                <thead>
                                    {table.getHeaderGroups().map(headerGroup => (
                                        <tr key={headerGroup.id}>
                                            {headerGroup.headers.map(header => (
                                                <th key={header.id} style={{ cursor: header.column.getCanSort() ? 'pointer' : 'default' }} onClick={header.column.getToggleSortingHandler()}>
                                                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', justifyContent: header.id === 'actions' ? 'flex-end' : 'flex-start' }}>
                                                        {flexRender(header.column.columnDef.header, header.getContext())}
                                                        {header.column.getCanSort() && (
                                                            <span style={{ marginLeft: '0.4rem', opacity: header.column.getIsSorted() ? 1 : 0.3 }}>
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
                                    {table.getRowModel().rows.map(row => (
                                        <tr key={row.id}>
                                            {row.getVisibleCells().map(cell => (
                                                <td key={cell.id} style={{ textAlign: cell.column.id === 'actions' ? 'right' : 'left' }}>
                                                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                                                </td>
                                            ))}
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}

                    {/* Headless Table Pagination Footer */}
                    {table && table.getPageCount && table.getPageCount() > 1 && (
                        <div className="pagination-bar-gf">
                            <span>
                                Page <strong>{table.getState().pagination.pageIndex + 1}</strong> of <strong>{table.getPageCount()}</strong>
                            </span>
                            <div className="pagination-controls-gf">
                                <button 
                                    className="btn-page-gf"
                                    onClick={() => table.previousPage()}
                                    disabled={!table.getCanPreviousPage()}
                                >
                                    Previous
                                </button>
                                <button 
                                    className="btn-page-gf"
                                    onClick={() => table.nextPage()}
                                    disabled={!table.getCanNextPage()}
                                >
                                    Next
                                </button>
                            </div>
                        </div>
                    )}
                </section>

                {/* Right Slide-out Drawer: Certificate Visual Preview */}
                {drawerOpen && selectedCert && (
                    <div className="drawer-overlay-gf" onClick={() => setDrawerOpen(false)}>
                        <div className="drawer-container-gf" onClick={e => e.stopPropagation()}>
                            <header className="drawer-header-gf">
                                <h2>
                                    <i className="fas fa-award" style={{ marginRight: '0.4rem' }}></i> Credential Live Preview
                                </h2>
                                <button className="drawer-close-gf" onClick={() => setDrawerOpen(false)}>
                                    <i className="fas fa-times"></i>
                                </button>
                            </header>

                            <div className="drawer-body-gf">
                                {/* visual certificate scaled for preview */}
                                <section className="cert-sheet-gf">
                                    <div className="cert-inner-border-gf"></div>

                                    {/* Crest */}
                                    <div className="cert-crest-gf">
                                        <svg className="cert-crest-svg-gf" viewBox="0 0 100 100">
                                            <path d="M50 15 L80 25 V55 C80 72 68 83 50 88 C32 83 20 72 20 55 V25 Z" fill="none" stroke="#1e293b" strokeWidth="2.5"></path>
                                            <path d="M50 19 L76 28 V54 C76 69 65 79 50 84 C35 79 24 69 24 54 V28 Z" fill="#2b5a8e" opacity="0.08"></path>
                                            <line x1="50" y1="15" x2="50" y2="88" stroke="#1e293b" strokeWidth="1.5"></line>
                                            <line x1="20" y1="46" x2="80" y2="46" stroke="#1e293b" strokeWidth="1.5"></line>
                                            <circle cx="35" cy="33" r="3.5" fill="#1e293b"></circle>
                                            <circle cx="65" cy="33" r="3.5" fill="#1e293b"></circle>
                                            <path d="M38 64 C42 60 48 60 50 63 C52 60 58 60 62 64 V52 C58 49 52 49 50 51 C48 49 42 49 38 52 Z" fill="none" stroke="#1e293b" strokeWidth="1.5"></path>
                                        </svg>
                                        <h4 className="cert-platform-gf">PSM E-Learning Academy</h4>
                                        <h1 className="cert-title-gf">Certificate of Completion</h1>
                                    </div>

                                    {/* Content */}
                                    <div className="cert-body-gf">
                                        <p className="cert-recipient-lbl-gf">This programmatically verified credential is proudly presented to</p>
                                        <h2 className="cert-recipient-name-gf">{selectedCert.studentName}</h2>
                                        <p className="cert-statement-gf">
                                            who has successfully fulfilled all academic requirements and completed the certified program of study in
                                        </p>
                                        <h3 className="cert-course-gf">{selectedCert.courseName}</h3>
                                    </div>

                                    {/* Footer */}
                                    <div className="cert-footer-row-gf">
                                        <div className="cert-sec-info-gf">
                                            <strong>Credential Details</strong><br />
                                            Reg: {selectedCert.regNumber || 'N/A'}<br />
                                            No: {selectedCert.certificateNo}<br />
                                            Issued: {selectedCert.issueDate ? new Date(selectedCert.issueDate.replace(' ', 'T')).toLocaleDateString() : '-'}
                                        </div>

                                        <div className="cert-qr-stamp-gf">
                                            <div className="cert-verify-text-gf">Scan to verify<br /><strong>Official Stamp</strong></div>
                                            {selectedCert.qrCodePath && (
                                                <img 
                                                    className="cert-qr-image-gf" 
                                                    src={selectedCert.qrCodePath.startsWith('http') ? selectedCert.qrCodePath : window.__CONTEXT_PATH__ + "/" + selectedCert.qrCodePath} 
                                                    alt="QR" 
                                                />
                                            )}
                                        </div>

                                        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end' }}>
                                            <img className="cert-sig-image-gf" src={window.__CONTEXT_PATH__ + "/img/registrar-sig.png"} alt="Signature" />
                                            <div className="cert-sig-line-gf" style={{ width: '100%', textAlign: 'right' }}>
                                                <h4 className="cert-sig-title-gf">Sulaiman Sani</h4>
                                                <span className="cert-sig-sub-gf">Registrar Office</span>
                                            </div>
                                        </div>
                                    </div>
                                </section>

                                {/* Diagnostic metadata view card */}
                                <div className="cert-drawer-card-gf">
                                    <h3>Registry Audit Log</h3>
                                    <div className="cert-detail-grid-gf">
                                        <div className="cert-detail-item-gf">
                                            <span>Authority Issuer</span>
                                            <strong>{selectedCert.generatedBy || 'System Auto'}</strong>
                                        </div>
                                        <div className="cert-detail-item-gf">
                                            <span>Instructor Assigned</span>
                                            <strong>{selectedCert.instructorName || 'Academy Registrar'}</strong>
                                        </div>
                                        <div className="cert-detail-item-gf" style={{ gridColumn: 'span 2' }}>
                                            <span>Secure Verification URL</span>
                                            <strong 
                                                style={{ fontSize: '0.8rem', wordBreak: 'break-all', color: 'var(--gf-primary)', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '0.4rem' }}
                                                onClick={() => copyToClipboard(selectedCert.verificationURL || (window.location.origin + window.__CONTEXT_PATH__ + "/certificate/verify?code=" + selectedCert.certificateNo))}
                                            >
                                                <i className="fas fa-copy" style={{ marginRight: '0.4rem' }}></i> {selectedCert.verificationURL || (window.location.origin + window.__CONTEXT_PATH__ + "/certificate/verify?code=" + selectedCert.certificateNo)}
                                            </strong>
                                        </div>
                                    </div>
                                    
                                    <div style={{ display: 'flex', gap: '1rem', marginTop: '0.5rem' }}>
                                        <a 
                                            className="btn-primary-gf" 
                                            style={{ textDecoration: 'none', width: '100%', justifyContent: 'center' }} 
                                            href={window.__CONTEXT_PATH__ + "/certificate/verify?code=" + selectedCert.certificateNo}
                                            target="_blank"
                                        >
                                            <i className="fas fa-external-link-alt" style={{ marginRight: '0.4rem' }}></i> Open Public Verification URL
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                )}

                {/* Primary header dialog validation console modal */}
                {verifyModalOpen && (
                    <div className="modal-overlay-gf" onClick={() => setVerifyModalOpen(false)}>
                        <div className="modal-box-gf" onClick={e => e.stopPropagation()}>
                            <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--gf-border)', paddingBottom: '1rem' }}>
                                <div className="modal-title-gf">
                                    <i className="fas fa-shield-alt" style={{ marginRight: '0.4rem', color: 'var(--gf-primary)' }}></i> Verify Certificate Registry
                                </div>
                                <button className="drawer-close-gf" onClick={() => setVerifyModalOpen(false)} style={{ padding: '0.25rem' }}>
                                    <i className="fas fa-times"></i>
                                </button>
                            </header>

                            <div className="modal-body-gf">
                                <p>Input the unique certificate identification code (e.g. <code>PSM-CERT-20260404-ABC123</code>) to retrieve immediate credential validity records.</p>
                                
                                <div className="verify-input-group-gf">
                                    <input 
                                        type="text" 
                                        placeholder="Enter Certificate No..."
                                        value={verifySearchCode}
                                        onChange={e => setVerifySearchCode(e.target.value)}
                                        onKeyPress={e => e.key === 'Enter' && handleVerifyLookup()}
                                    />
                                    <button className="btn-primary-gf" onClick={handleVerifyLookup}>
                                        Verify
                                    </button>
                                </div>

                                {verifyResult && verifyResult.status === 'not-found' && (
                                    <div className="verify-alert-gf verify-alert-error-gf">
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontWeight: 700 }}>
                                            <i className="fas fa-exclamation-triangle" style={{ marginRight: '0.4rem' }}></i> Invalid Credential Record
                                        </div>
                                        <span>No matching certificate entry could be discovered in the PSM E-Learning Academic Registry. Double check the code and try again.</span>
                                    </div>
                                )}

                                {verifyResult && verifyResult.status === 'revoked' && (
                                    <div className="verify-alert-gf verify-alert-error-gf">
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontWeight: 700 }}>
                                            <i className="fas fa-times-circle" style={{ marginRight: '0.4rem' }}></i> Revoked Credential
                                        </div>
                                        <span>This certificate was officially issued but has since been revoked by academic administration:</span>
                                        <div className="verify-result-grid-gf" style={{ borderTopColor: 'rgba(185, 28, 28, 0.2)' }}>
                                            <div className="verify-result-item-gf">Recipient: <span>{verifyResult.data.studentName}</span></div>
                                            <div className="verify-result-item-gf">Course: <span>{verifyResult.data.courseName}</span></div>
                                            <div className="verify-result-item-gf" style={{ gridColumn: 'span 2' }}>Reason: <span style={{ color: 'var(--gf-red)' }}>Administrative Revocation</span></div>
                                        </div>
                                    </div>
                                )}

                                {verifyResult && verifyResult.status === 'active' && (
                                    <div className="verify-alert-gf verify-alert-success-gf">
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontWeight: 700 }}>
                                            <i className="fas fa-check-circle" style={{ marginRight: '0.4rem' }}></i> Legitimate Institutional Certificate
                                        </div>
                                        <span>This certificate is legitimate and verified active. Issued details:</span>
                                        
                                        <div className="verify-result-grid-gf">
                                            <div className="verify-result-item-gf">Recipient: <span>{verifyResult.data.studentName}</span></div>
                                            <div className="verify-result-item-gf">Reg No: <span>{verifyResult.data.regNumber || 'N/A'}</span></div>
                                            <div className="verify-result-item-gf" style={{ gridColumn: 'span 2' }}>Program: <span>{verifyResult.data.courseName}</span></div>
                                            <div className="verify-result-item-gf">Issued on: <span>{verifyResult.data.issueDate ? new Date(verifyResult.data.issueDate.replace(' ', 'T')).toLocaleDateString() : '-'}</span></div>
                                            <div className="verify-result-item-gf">Status: <span style={{ color: 'var(--gf-primary-dark)', fontWeight: 800 }}>ACTIVE</span></div>
                                        </div>

                                        <button 
                                            className="btn-secondary-gf" 
                                            style={{ marginTop: '0.75rem', width: '100%', fontSize: '0.8rem', padding: '0.5rem', justifyContent: 'center' }}
                                            onClick={() => {
                                                setSelectedCert(verifyResult.data);
                                                setVerifyModalOpen(false);
                                                setDrawerOpen(true);
                                            }}
                                        >
                                            <i className="fas fa-eye" style={{ marginRight: '0.4rem' }}></i> Live Preview Visual Sheet
                                        </button>
                                    </div>
                                )}
                            </div>

                            <div className="modal-footer-gf">
                                <button className="btn-secondary-gf" onClick={() => setVerifyModalOpen(false)}>
                                    Close
                                </button>
                            </div>
                        </div>
                    </div>
                )}

                {/* Revoke center confirmation modal overlay */}
                {revokeModalOpen && certToRevoke && (
                    <div className="modal-overlay-gf" onClick={() => setRevokeModalOpen(false)}>
                        <div className="modal-box-gf" onClick={e => e.stopPropagation()} style={{ maxWidth: '440px' }}>
                            <header style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', color: 'var(--gf-red)', borderBottom: '1px solid var(--gf-border)', paddingBottom: '1rem' }}>
                                <i className="fas fa-exclamation-triangle" style={{ width: '24px', height: '24px' }}></i>
                                <span style={{ fontSize: '1.15rem', fontWeight: 800 }}>Confirm Revocation</span>
                            </header>

                            <div className="modal-body-gf" style={{ padding: '0.5rem 0' }}>
                                <p>Are you sure you want to permanently revoke certificate <strong>{certToRevoke.certificateNo}</strong> issued to <strong>{certToRevoke.studentName}</strong>?</p>
                                <p style={{ color: 'var(--gf-red)', fontSize: '0.85rem', fontWeight: 500 }}>
                                    Warning: This destructive operation prevents future validation queries and voids the credential permanently.
                                </p>
                            </div>

                            <div className="modal-footer-gf">
                                <button className="btn-secondary-gf" onClick={() => setRevokeModalOpen(false)}>
                                    Cancel
                                </button>
                                
                                <form method="post" action={window.__CONTEXT_PATH__ + "/admin/certificates"} style={{ margin: 0 }}>
                                    <input type="hidden" name="action" value="revoke" />
                                    <input type="hidden" name="certificateId" value={certToRevoke.certificateId} />
                                    <button className="btn-danger-gf" type="submit">
                                        Permanently Revoke
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                )}

                {/* Copy helper Toast */}
                {toastVisible && (
                    <div className="toast-gf toast-success-gf">
                        <i className="fas fa-check-circle" style={{ marginRight: '0.4rem' }}></i> {toastMessage}
                    </div>
                )}
            </div>
        );
    }

    const container = document.getElementById('admin-react-root');
    const root = ReactDOM.createRoot(container);
    root.render(<CertificatesRegistry />);
</script>
</body>
</html>
