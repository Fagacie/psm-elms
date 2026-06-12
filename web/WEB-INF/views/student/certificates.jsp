<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificates | PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    
    <!-- CSS Module & Global Certificate Styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Certificates.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student-certificate-v2.css">
    
    <!-- React, Animation & Lucide CDNs -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    
    <!-- Dynamic A4 Background Compiler Libraries -->
    <script src="https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</head>
<body class="sv-page">
<c:set var="revokedCount" value="0" />
<c:forEach var="issued" items="${issuedCertificates}">
    <c:if test="${issued.status == 'Revoked'}">
        <c:set var="revokedCount" value="${revokedCount + 1}" />
    </c:if>
</c:forEach>
<c:set var="activeCount" value="${fn:length(issuedCertificates) - revokedCount}" />

<c:set var="topbarTitle" value="Certificates"/>
<c:set var="topbarSubtitle" value="Generate, manage, and share credentials"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="certificates"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main cert-page trophy_pageWrapper">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <span>/</span>
            <span>Certificates</span>
        </div>

        <c:if test="${param.success == 'generated'}">
            <div class="alert alert-success" style="margin-bottom: 24px; border-radius: 8px;">
                <i class="fas fa-check-circle"></i> Certificate generated successfully and added to your issued list.
            </div>
        </c:if>
        <c:if test="${param.error == 'noteligible'}">
            <div class="alert alert-error" style="margin-bottom: 24px; border-radius: 8px;">
                <i class="fas fa-exclamation-triangle"></i>
                This enrollment is not yet eligible for certificate generation.
                <c:if test="${fn:contains(param.reason, 'payment')}"> Payment is pending.</c:if>
                <c:if test="${fn:contains(param.reason, 'materials')}"> Some materials are still not viewed.</c:if>
                <c:if test="${fn:contains(param.reason, 'assessments')}"> Required assessments are not fully passed.</c:if>
            </div>
        </c:if>
        <c:if test="${param.error == 'generatefail'}">
            <div class="alert alert-error" style="margin-bottom: 24px; border-radius: 8px;">
                <i class="fas fa-triangle-exclamation"></i> Certificate generation failed. Please retry.
            </div>
        </c:if>

        <!-- React Trophy Room Root Target -->
        <div id="trophy-room-react-root"></div>
    </main>
</div>

<div id="svOverlay" class="sv-overlay"></div>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>

<!-- Server JSTL Data Bridge to Browser-side React Context -->
<script>
    window.issuedCertificatesData = [
        <c:forEach var="cert" items="${issuedCertificates}" varStatus="status">
            {
                certificateNo: "${cert.certificateNo}",
                courseName: `${fn:escapeXml(cert.courseName)}`,
                issueDate: "<c:choose><c:when test="${not empty cert.issueDate}">${cert.issueDate.toLocalDate()}</c:when><c:otherwise>-</c:otherwise></c:choose>",
                status: "${cert.status}",
                enrollmentId: "${cert.enrollmentId}",
                qrCodePath: "${cert.qrCodePath}",
                regNumber: "<c:out value="${cert.regNumber}" default="N/A"/>"
            }${not status.last ? ',' : ''}
        </c:forEach>
    ];

    window.readyToGenerateData = [
        <c:forEach var="enrollment" items="${readyToGenerate}" varStatus="status">
            {
                enrollmentId: "${enrollment.enrollmentId}",
                courseName: `${fn:escapeXml(enrollment.courseName)}`
            }${not status.last ? ',' : ''}
        </c:forEach>
    ];

    window.blockedEnrollmentsData = [
        <c:forEach var="item" items="${blockedEnrollments}" varStatus="status">
            {
                courseName: `${fn:escapeXml(item.enrollment.courseName)}`,
                paid: ${item.syncResult.paid},
                viewedMaterials: ${item.syncResult.viewedMaterials},
                totalMaterials: ${item.syncResult.totalMaterials},
                passedAssessments: ${item.syncResult.passedAssessments},
                totalAssessments: ${item.syncResult.totalAssessments},
                viewedAllMaterials: ${item.syncResult.viewedAllMaterials},
                passedRequiredAssessments: ${item.syncResult.passedRequiredAssessments}
            }${not status.last ? ',' : ''}
        </c:forEach>
    ];

    window.studentName = "${fn:escapeXml(sessionScope.userName)}";
    window.contextPath = "${pageContext.request.contextPath}";
</script>

<!-- React Frontend Script compiled with Babel in Browser -->
<script type="text/babel">
    // Scoped CSS Module class bridge mapping to mimic webpack/bundler css isolation
    const styles = {
        viewport: 'trophy_viewport',
        container: 'trophy_container',
        header: 'trophy_header',
        title: 'trophy_title',
        subtitle: 'trophy_subtitle',
        emptyState: 'trophy_emptyState',
        emptyIcon: 'trophy_emptyIcon',
        emptyTitle: 'trophy_emptyTitle',
        emptyText: 'trophy_emptyText',
        primaryBtn: 'trophy_primaryBtn',
        grid: 'trophy_grid',
        card: 'trophy_card',
        thumbnailArea: 'trophy_thumbnailArea',
        thumbnailFrame: 'trophy_thumbnailFrame',
        mockHeader: 'trophy_mockHeader',
        mockGoldSeal: 'trophy_mockGoldSeal',
        mockCertTitle: 'trophy_mockCertTitle',
        mockBody: 'trophy_mockBody',
        mockStudentName: 'trophy_mockStudentName',
        mockText: 'trophy_mockText',
        mockFooter: 'trophy_mockFooter',
        mockSignature: 'trophy_mockSignature',
        mockCode: 'trophy_mockCode',
        cardBody: 'trophy_cardBody',
        courseTitle: 'trophy_courseTitle',
        detailsRow: 'trophy_detailsRow',
        issuedDate: 'trophy_issuedDate',
        credentialId: 'trophy_credentialId',
        actionFooter: 'trophy_actionFooter',
        actionBtn: 'trophy_actionBtn',
        actionBtnPrimary: 'trophy_actionBtnPrimary',
        sectionsGrid: 'trophy_sectionsGrid',
        sectionCard: 'trophy_sectionCard',
        sectionTitle: 'trophy_sectionTitle',
        sectionDesc: 'trophy_sectionDesc',
        tableWrap: 'trophy_tableWrap',
        table: 'trophy_table',
        tableCourse: 'trophy_tableCourse',
        generateBtn: 'trophy_generateBtn',
        chipGroup: 'trophy_chipGroup',
        chip: 'trophy_chip',
        chipSuccess: 'trophy_chipSuccess',
        chipPending: 'trophy_chipPending',
        toast: 'trophy_toast',
        
        // Task 1 additions (Ready to Generate Section)
        readySection: 'trophy_readySection',
        readyCard: 'trophy_readyCard',
        readyLeft: 'trophy_readyLeft',
        readyBadge: 'trophy_readyBadge',
        readyCourseTitle: 'trophy_readyCourseTitle',
        readyRight: 'trophy_readyRight',
        
        // Button Actions Redesign
        primaryViewBtn: 'trophy_primaryViewBtn',
        iconBtn: 'trophy_iconBtn',

        // Filter bar isolated styles
        filterBar: 'trophy_filterBar',
        searchContainer: 'trophy_searchContainer',
        searchInput: 'trophy_searchInput',
        searchIcon: 'trophy_searchIcon',
        filterGroup: 'trophy_filterGroup',
        filterBtn: 'trophy_filterBtn',
        filterBtnActive: 'trophy_filterBtnActive'
    };

    const CertificatesTrophyRoom = () => {
        const [issued, setIssued] = React.useState(window.issuedCertificatesData || []);
        const [ready, setReady] = React.useState(window.readyToGenerateData || []);
        const [blocked, setBlocked] = React.useState(window.blockedEnrollmentsData || []);

        const [searchTerm, setSearchTerm] = React.useState('');
        const [activeFilter, setActiveFilter] = React.useState('all');
        const [filteredIssued, setFilteredIssued] = React.useState(issued);

        const [showToast, setShowToast] = React.useState(false);
        const [toastMessage, setToastMessage] = React.useState('');
        const [generatingId, setGeneratingId] = React.useState(null);
        
        // Compilation state for background compiling without routing
        const [compilingCert, setCompilingCert] = React.useState(null);

        // Live text and status filtering
        React.useEffect(() => {
            const result = issued.filter(cert => {
                const courseMatch = cert.courseName.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    cert.certificateNo.toLowerCase().includes(searchTerm.toLowerCase());
                
                const filterMatch = activeFilter === 'all' || 
                                    (activeFilter === 'active' && cert.status !== 'Revoked') || 
                                    (activeFilter === 'revoked' && cert.status === 'Revoked');
                
                return courseMatch && filterMatch;
            });
            setFilteredIssued(result);
        }, [searchTerm, activeFilter, issued]);

        // Redraw Lucide Icons
        React.useEffect(() => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        }, [filteredIssued, ready, blocked, showToast, generatingId, compilingCert]);

        const handleCopy = (code) => {
            navigator.clipboard.writeText(code).then(() => {
                setToastMessage("Certificate ID copied to clipboard!");
                setShowToast(true);
                setTimeout(() => setShowToast(false), 3000);
            }).catch(err => console.error("Copy failed", err));
        };

        const handleShare = (certificateNo) => {
            const publicUrl = window.location.origin + window.contextPath + "/certificate/verify?code=" + certificateNo;
            navigator.clipboard.writeText(publicUrl).then(() => {
                setToastMessage("Verification link copied to clipboard!");
                setShowToast(true);
                setTimeout(() => setShowToast(false), 3000);
            }).catch(err => console.error("Share failed", err));
        };

        const handleGenerateSubmit = (e, enrollmentId) => {
            e.preventDefault();
            setGeneratingId(enrollmentId);
            const form = e.currentTarget;
            
            // Allow 600ms loader animation before submitting the POST transaction
            setTimeout(() => {
                form.submit();
            }, 600);
        };

        // Client-side landscape A4 compiler executed entirely in the background
        const triggerDownload = (cert) => {
            setCompilingCert(cert.certificateNo);
            
            // Allow 200ms for React to mount the hidden off-screen target
            setTimeout(() => {
                const targetNode = document.getElementById('hidden-pdf-target');
                if (!targetNode) {
                    console.error("Compilation target node not found in DOM.");
                    setCompilingCert(null);
                    return;
                }

                const sheetNode = targetNode.querySelector('.sc-sheet');
                if (!sheetNode) {
                    console.error("Certificate sheet node not found.");
                    setCompilingCert(null);
                    return;
                }

                // Force high-res locked printing dimensions
                sheetNode.style.setProperty('width', '1123px', 'important');
                sheetNode.style.setProperty('height', '794px', 'important');
                sheetNode.style.setProperty('max-width', 'none', 'important');
                sheetNode.style.setProperty('aspect-ratio', '1123 / 794', 'important');

                document.fonts.ready.then(() => {
                    return html2canvas(sheetNode, {
                        scale: 2, // Double scaling for high-resolution vector and text quality
                        useCORS: true,
                        allowTaint: false,
                        backgroundColor: '#ffffff'
                    });
                }).then((canvas) => {
                    const imgData = canvas.toDataURL('image/png');
                    const { jsPDF } = window.jspdf;
                    const pdf = new jsPDF({
                        orientation: 'landscape',
                        unit: 'mm',
                        format: 'a4',
                        compress: true
                    });

                    pdf.addImage(imgData, 'PNG', 0, 0, 297, 210, undefined, 'FAST');
                    const filename = cert.certificateNo.replace(/[^a-z0-9_-]+/gi, '_') + '.pdf';
                    pdf.save(filename);
                }).catch((err) => {
                    console.error('Dynamic high-fidelity compilation failed:', err);
                    alert('Background PDF compilation failed. Please view the certificate page directly to print.');
                }).finally(() => {
                    setCompilingCert(null);
                });
            }, 200);
        };

        const { motion } = window.Motion || {};

        const containerVariants = {
            hidden: { opacity: 0 },
            show: {
                opacity: 1,
                transition: { staggerChildren: 0.08 }
            }
        };

        const cardVariants = {
            hidden: { opacity: 0, scale: 0.95, y: 15 },
            show: { 
                opacity: 1, 
                scale: 1, 
                y: 0, 
                transition: { type: "spring", stiffness: 260, damping: 20 } 
            }
        };

        return (
            <div className={styles.viewport}>
                <div className={styles.container}>
                    
                    {/* Header */}
                    <div className={styles.header}>
                        <h2 className={styles.title}>My Certificates</h2>
                        <p className={styles.subtitle}>Manage, download, and share your achievements.</p>
                    </div>

                    {/* Task 1: Minimal Borderless "Ready to Generate" Section (Top of Page) */}
                    {ready.length > 0 && (
                        <div className={styles.readySection}>
                            {ready.map((enrollment) => (
                                <div key={enrollment.enrollmentId} className={styles.readyCard}>
                                    <div className={styles.readyLeft}>
                                        <h4 className={styles.readyCourseTitle}>{enrollment.courseName}</h4>
                                        <div className={styles.readyBadge}>
                                            <i data-lucide="award" style={{ width: 14, height: 14, marginRight: 6 }}></i>
                                            <span>100% Completed</span>
                                        </div>
                                    </div>
                                    <div className={styles.readyRight}>
                                        <form 
                                            method="post" 
                                            action={window.contextPath + "/student/certificate"}
                                            onSubmit={(e) => handleGenerateSubmit(e, enrollment.enrollmentId)}
                                            style={{ margin: 0 }}
                                        >
                                            <input type="hidden" name="enrollmentId" value={enrollment.enrollmentId} />
                                            <input type="hidden" name="redirectTo" value="certificates" />
                                            <button 
                                                className={styles.generateBtn} 
                                                type="submit"
                                                disabled={generatingId === enrollment.enrollmentId}
                                                style={{ border: 'none' }}
                                            >
                                                {generatingId === enrollment.enrollmentId ? (
                                                    <i className="fas fa-spinner fa-spin" style={{ marginRight: 8, fontSize: 14 }}></i>
                                                ) : (
                                                    <i data-lucide="file-signature" style={{ width: 16, height: 16 }}></i>
                                                )}
                                                <span>{generatingId === enrollment.enrollmentId ? 'Generating...' : 'Generate Certificate'}</span>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}

                    {/* Quick Search & Status Filters */}
                    {issued.length > 0 && (
                        <div className={styles.filterBar}>
                            <div className={styles.searchContainer}>
                                <input 
                                    type="search" 
                                    className={styles.searchInput} 
                                    placeholder="Search by course name or code..." 
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                    aria-label="Search certificates"
                                />
                                <div className={styles.searchIcon}>
                                    <i data-lucide="search" style={{ width: 16, height: 16 }}></i>
                                </div>
                            </div>

                            <div className={styles.filterGroup} role="group" aria-label="Filter certificates by status">
                                {['all', 'active', 'revoked'].map((filter) => (
                                    <button
                                        key={filter}
                                        type="button"
                                        className={styles.filterBtn + " " + (activeFilter === filter ? styles.filterBtnActive : "")}
                                        onClick={() => setActiveFilter(filter)}
                                    >
                                        {filter.charAt(0).toUpperCase() + filter.slice(1)}
                                    </button>
                                ))}
                            </div>
                        </div>
                    )}

                    {/* Task 2: Rewarding Gold/Slate Empty State */}
                    {issued.length === 0 ? (
                        <div className={styles.emptyState}>
                            <i data-lucide="award" className={styles.emptyIcon} style={{ width: 64, height: 64, color: '#eab308', strokeWidth: 1.5 }}></i>
                            <h3 className={styles.emptyTitle}>You haven't earned any certificates yet</h3>
                            <p className={styles.emptyText}>Complete your course materials and pass all required assessments to generate credentials!</p>
                            <a href={window.contextPath + "/student/courses"} className={styles.primaryBtn}>
                                <i data-lucide="compass" style={{ width: 18, height: 18, strokeWidth: 2 }}></i>
                                <span>Browse Courses</span>
                            </a>
                        </div>
                    ) : filteredIssued.length === 0 ? (
                        <div className={styles.emptyState} style={{ padding: '40px 24px' }}>
                            <i data-lucide="search" className={styles.emptyIcon} style={{ width: 48, height: 48, color: '#94a3b8', strokeWidth: 1.5 }}></i>
                            <h3 className={styles.emptyTitle}>No certificates match your search</h3>
                            <p className={styles.emptyText}>Try adjusting your keywords or filtering by status.</p>
                        </div>
                    ) : (
                        /* Task 3 & 4: CSS Grid & Staggered Trophy Cards */
                        motion ? (
                            <motion.div 
                                className={styles.grid}
                                variants={containerVariants}
                                initial="hidden"
                                animate="show"
                            >
                                {filteredIssued.map((cert) => {
                                    const isCompiling = compilingCert === cert.certificateNo;
                                    return (
                                        <motion.div 
                                            key={cert.certificateNo} 
                                            className="sv-premium-card"
                                            variants={cardVariants}
                                        >
                                            {/* Premium Background / Thumbnail Cover */}
                                            <div className="sv-premium-cover">
                                                <div className={styles.thumbnailArea} style={{ height: '100%' }}>
                                                    <div className={styles.thumbnailFrame}>
                                                        <div className={styles.mockHeader}>
                                                            <div className={styles.mockGoldSeal}></div>
                                                            <span className={styles.mockCertTitle}>Completion Certificate</span>
                                                        </div>
                                                        <div className={styles.mockBody}>
                                                            <div className={styles.mockStudentName}>{window.studentName || 'Certified Student'}</div>
                                                            <div className={styles.mockText}>OFFICIAL ACADEMIC COMPLETION</div>
                                                        </div>
                                                        <div className={styles.mockFooter}>
                                                            <div className={styles.mockSignature}></div>
                                                            <span className={styles.mockCode}>{"#" + cert.certificateNo.substring(0, 7)}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div className="sv-premium-gradient"></div>
                                            
                                            {/* Basic Info that shows normally */}
                                            <div className="sv-premium-basic-info">
                                                <div className="sv-premium-category" style={{ color: '#eab308' }}>Verified Credential</div>
                                                <h3 title={cert.courseName}>{cert.courseName}</h3>
                                                <div className="sv-premium-instructor">Issued: {cert.issueDate}</div>
                                            </div>

                                            {/* Premium Hover Reveal panel */}
                                            <div className="sv-premium-reveal">
                                                <div className="sv-premium-reveal-price"><i data-lucide="award" style={{ width: 48, height: 48, color: '#eab308' }}></i></div>
                                                <div className="sv-premium-reveal-meta" style={{ marginBottom: 16 }}>
                                                    <span style={{ fontSize: '0.85rem' }}>ID: {cert.certificateNo}</span>
                                                </div>
                                                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', width: '100%' }}>
                                                    <a 
                                                        href={window.contextPath + "/student/certificate?enrollmentId=" + cert.enrollmentId} 
                                                        className="sv-btn sv-btn-primary"
                                                        style={{ width: '100%', padding: '10px 0', minHeight: '38px', fontSize: '0.85rem' }}
                                                    >
                                                        View Certificate
                                                    </a>
                                                    <div style={{ display: 'flex', gap: '8px', width: '100%' }}>
                                                        <button 
                                                            type="button" 
                                                            className="sv-btn"
                                                            style={{ flex: 1, padding: '8px 0', minHeight: '36px', fontSize: '0.8rem', background: 'rgba(255,255,255,0.1)', color: '#fff', border: '1px solid rgba(255,255,255,0.2)' }}
                                                            onClick={(e) => { e.preventDefault(); triggerDownload(cert); }}
                                                            disabled={isCompiling}
                                                        >
                                                            {isCompiling ? <i className="fas fa-spinner fa-spin"></i> : <i data-lucide="download"></i>} PDF
                                                        </button>
                                                        <button 
                                                            type="button" 
                                                            className="sv-btn"
                                                            style={{ flex: 1, padding: '8px 0', minHeight: '36px', fontSize: '0.8rem', background: 'rgba(255,255,255,0.1)', color: '#fff', border: '1px solid rgba(255,255,255,0.2)' }}
                                                            onClick={(e) => { e.preventDefault(); handleShare(cert.certificateNo); }}
                                                        >
                                                            <i data-lucide="share-2"></i> Share
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </motion.div>
                                    );
                                })}
                            </motion.div>
                        ) : (
                            <div className={styles.grid}>
                                {filteredIssued.map((cert) => {
                                    const isCompiling = compilingCert === cert.certificateNo;
                                    return (
                                        <div key={cert.certificateNo} className="sv-premium-card">
                                            {/* Premium Background / Thumbnail Cover */}
                                            <div className="sv-premium-cover">
                                                <div className={styles.thumbnailArea} style={{ height: '100%' }}>
                                                    <div className={styles.thumbnailFrame}>
                                                        <div className={styles.mockHeader}>
                                                            <div className={styles.mockGoldSeal}></div>
                                                            <span className={styles.mockCertTitle}>Completion Certificate</span>
                                                        </div>
                                                        <div className={styles.mockBody}>
                                                            <div className={styles.mockStudentName}>{window.studentName || 'Certified Student'}</div>
                                                            <div className={styles.mockText}>OFFICIAL ACADEMIC COMPLETION</div>
                                                        </div>
                                                        <div className={styles.mockFooter}>
                                                            <div className={styles.mockSignature}></div>
                                                            <span className={styles.mockCode}>{"#" + cert.certificateNo.substring(0, 7)}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div className="sv-premium-gradient"></div>
                                            
                                            {/* Basic Info that shows normally */}
                                            <div className="sv-premium-basic-info">
                                                <div className="sv-premium-category" style={{ color: '#eab308' }}>Verified Credential</div>
                                                <h3 title={cert.courseName}>{cert.courseName}</h3>
                                                <div className="sv-premium-instructor">Issued: {cert.issueDate}</div>
                                            </div>

                                            {/* Premium Hover Reveal panel */}
                                            <div className="sv-premium-reveal">
                                                <div className="sv-premium-reveal-price"><i data-lucide="award" style={{ width: 48, height: 48, color: '#eab308' }}></i></div>
                                                <div className="sv-premium-reveal-meta" style={{ marginBottom: 16 }}>
                                                    <span style={{ fontSize: '0.85rem' }}>ID: {cert.certificateNo}</span>
                                                </div>
                                                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', width: '100%' }}>
                                                    <a 
                                                        href={window.contextPath + "/student/certificate?enrollmentId=" + cert.enrollmentId} 
                                                        className="sv-btn sv-btn-primary"
                                                        style={{ width: '100%', padding: '10px 0', minHeight: '38px', fontSize: '0.85rem' }}
                                                    >
                                                        View Certificate
                                                    </a>
                                                    <div style={{ display: 'flex', gap: '8px', width: '100%' }}>
                                                        <button 
                                                            type="button" 
                                                            className="sv-btn"
                                                            style={{ flex: 1, padding: '8px 0', minHeight: '36px', fontSize: '0.8rem', background: 'rgba(255,255,255,0.1)', color: '#fff', border: '1px solid rgba(255,255,255,0.2)' }}
                                                            onClick={(e) => { e.preventDefault(); triggerDownload(cert); }}
                                                            disabled={isCompiling}
                                                        >
                                                            {isCompiling ? <i className="fas fa-spinner fa-spin"></i> : <i data-lucide="download"></i>} PDF
                                                        </button>
                                                        <button 
                                                            type="button" 
                                                            className="sv-btn"
                                                            style={{ flex: 1, padding: '8px 0', minHeight: '36px', fontSize: '0.8rem', background: 'rgba(255,255,255,0.1)', color: '#fff', border: '1px solid rgba(255,255,255,0.2)' }}
                                                            onClick={(e) => { e.preventDefault(); handleShare(cert.certificateNo); }}
                                                        >
                                                            <i data-lucide="share-2"></i> Share
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        )
                    )}

                    {/* Secondary Sections Blocked Courses (Ready Section is moved to top) */}
                    <div className={styles.sectionsGrid} style={{ gridTemplateColumns: '1fr' }}>
                        {/* Blocked Enrollments / Requirements checklist */}
                        <div className={styles.sectionCard}>
                            <div>
                                <h3 className={styles.sectionTitle}>Not Yet Eligible</h3>
                                <p className={styles.sectionDesc}>Active courses requiring one or more criteria to be completed.</p>
                            </div>
                            <div className={styles.tableWrap}>
                                {blocked.length === 0 ? (
                                    <div className="history_ph_emptyState" style={{ padding: '24px 0', border: 'none', boxShadow: 'none' }}>
                                        <i data-lucide="check-circle" style={{ width: 36, height: 36, color: '#cbd5e1' }}></i>
                                        <p style={{ fontSize: '0.88rem', margin: '8px 0 0 0' }}>All active enrollments are complete.</p>
                                    </div>
                                ) : (
                                    <table className={styles.table}>
                                        <thead>
                                            <tr>
                                                <th>Course</th>
                                                <th>Requirements</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {blocked.map((item, index) => (
                                                <tr key={index}>
                                                    <td className={styles.tableCourse}>{item.courseName}</td>
                                                    <td>
                                                        <div className={styles.chipGroup}>
                                                            <span className={styles.chip + " " + (item.paid ? styles.chipSuccess : styles.chipPending)}>
                                                                <i data-lucide="wallet" style={{ width: 10, height: 10 }}></i>
                                                                Paid: {item.paid ? 'Yes' : 'No'}
                                                            </span>
                                                            <span className={styles.chip + " " + (item.viewedAllMaterials ? styles.chipSuccess : styles.chipPending)}>
                                                                <i data-lucide="book-open" style={{ width: 10, height: 10 }}></i>
                                                                Materials: {item.viewedMaterials}/{item.totalMaterials}
                                                            </span>
                                                            <span className={styles.chip + " " + (item.passedRequiredAssessments ? styles.chipSuccess : styles.chipPending)}>
                                                                <i data-lucide="check-square" style={{ width: 10, height: 10 }}></i>
                                                                Quiz: {item.passedAssessments}/{item.totalAssessments}
                                                            </span>
                                                        </div>
                                                    </td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Toast Alert popup */}
                    {showToast && (
                        <div className={styles.toast}>
                            <i data-lucide="check" style={{ width: 16, height: 16 }}></i>
                            <span>{toastMessage}</span>
                        </div>
                    )}
                </div>

                {/* Hidden Physical Landscape A4 Document Template for background compiling */}
                {compilingCert && (() => {
                    const activeCert = issued.find(c => c.certificateNo === compilingCert);
                    if (!activeCert) return null;
                    return (
                        <div 
                            id="hidden-pdf-target" 
                            style={{
                                position: 'fixed',
                                left: '-9999px',
                                top: '-9999px',
                                width: '1123px',
                                height: '794px',
                                zIndex: -9999,
                                backgroundColor: '#ffffff'
                            }}
                        >
                            <section className="sc-sheet" style={{ width: '1123px', height: '794px', maxWidth: 'none', aspectRatio: '1123 / 794', boxSizing: 'border-box' }}>
                                {/* Top Platform Crest */}
                                <div className="sc-crest">
                                    <svg className="sc-crest-svg" viewBox="0 0 100 100" width="48" height="48">
                                        <path d="M50 15 L80 25 V55 C80 72 68 83 50 88 C32 83 20 72 20 55 V25 Z" fill="none" stroke="#0f172a" strokeWidth="2.5"></path>
                                        <line x1="50" y1="15" x2="50" y2="88" stroke="#0f172a" strokeWidth="1.5"></line>
                                        <line x1="20" y1="46" x2="80" y2="46" stroke="#0f172a" strokeWidth="1.5"></line>
                                        <circle cx="35" cy="33" r="3.5" fill="#0f172a"></circle>
                                        <circle cx="65" cy="33" r="3.5" fill="#0f172a"></circle>
                                        <path d="M38 64 C42 60 48 60 50 63 C52 60 58 60 62 64 V52 C58 49 52 49 50 51 C48 49 42 49 38 52 Z" fill="none" stroke="#0f172a" strokeWidth="1.5"></path>
                                    </svg>
                                    <h4 className="sc-platform-name">PSM E-Learning Academy</h4>
                                    <h1 className="sc-title">Certificate of Completion</h1>
                                </div>

                                {/* Recipient Details */}
                                <div className="sc-body-content">
                                    <p className="sc-recipient-lbl">This programmatically verified credential is proudly presented to</p>
                                    <h2 className="sc-recipient-name">{window.studentName}</h2>
                                    <p className="sc-award-statement">
                                        who has successfully fulfilled all academic requirements and completed the certified program of study in
                                    </p>
                                    <h3 className="sc-course-name">{activeCert.courseName}</h3>
                                </div>

                                {/* Footer Area */}
                                <div className="sc-footer-row">
                                    <div className="sc-footer-left">
                                        <div className="sc-sec-info">
                                            <strong>Credential Details</strong>
                                            <span>Student Reg: {activeCert.regNumber || 'N/A'}</span>
                                            <span>Certificate No: {activeCert.certificateNo}</span>
                                            <span>Date Issued: {activeCert.issueDate}</span>
                                        </div>
                                    </div>

                                    <div className="sc-footer-right">
                                        {/* Verification Ink Stamp */}
                                        <div className="sc-verify-stamp-wrapper">
                                            <svg viewBox="0 0 100 100" width="56" height="56">
                                                <circle cx="50" cy="50" r="40" fill="none" stroke="#0f172a" strokeWidth="1.5" strokeDasharray="3 1.5" />
                                                <circle cx="50" cy="50" r="34" fill="none" stroke="#0f172a" strokeWidth="0.5" />
                                                <path id="stampTextPathComp" d="M18 50 A32 32 0 1 1 82 50" fill="none" stroke="none" />
                                                <text fill="#0f172a" fontSize="5.5" fontWeight="bold" letterSpacing="0.8">
                                                    <textPath href="#stampTextPathComp" startOffset="50%" textAnchor="middle">OFFICIAL VERIFICATION</textPath>
                                                </text>
                                                <text x="50" y="46" fill="#0f172a" fontSize="9" fontWeight="900" textAnchor="middle">PSM</text>
                                                <text x="50" y="58" fill="#0f172a" fontSize="7" fontWeight="bold" text-anchor="middle">APPROVED</text>
                                                <text x="50" y="66" fill="#0f172a" fontSize="4" fontWeight="bold" text-anchor="middle">ACADEMY</text>
                                            </svg>
                                        </div>
                                        {/* QR Code */}
                                        <div className="sc-qr-stamp">
                                            {activeCert.qrCodePath && (
                                                <img 
                                                    className="sc-qr-image" 
                                                    src={activeCert.qrCodePath.startsWith('http') ? activeCert.qrCodePath : (window.contextPath + '/' + activeCert.qrCodePath)} 
                                                    alt="Verification QR Code" 
                                                />
                                            )}
                                        </div>
                                    </div>
                                </div>
                            </section>
                        </div>
                    );
                })()}
            </div>
        );
    };

    const container = document.getElementById('trophy-room-react-root');
    const root = ReactDOM.createRoot(container);
    root.render(<CertificatesTrophyRoom />);
</script>
</body>
</html>
