<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Payment History - PSM E-Learning</title>
                    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp" />

                    <!-- CSS Modules Isolated Stylesheets -->
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/PaymentHistory.module.css">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ReceiptModal.module.css">

                    <!-- React, Animation & html2pdf CDNs -->
                    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
                    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
                    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
                    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
                    <script src="https://unpkg.com/lucide@latest"></script>
                    <script
                        src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
                </head>

                <body class="sv-page">
                    <c:set var="topbarTitle" value="Payment History" />
                    <c:set var="topbarSubtitle" value="Review successful, pending, and failed payments" />
                    <c:set var="topbarShowSearch" value="false" />
                    <jsp:include page="/WEB-INF/views/common/student-topbar.jsp" />

                    <div class="sv-layout">
                        <c:set var="activePage" value="payments" />
                        <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp" />

                        <main class="sv-main ef-main">
                            <div class="sv-breadcrumb">
                                <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i>
                                    Dashboard</a>
                                <span>/</span>
                                <a href="${pageContext.request.contextPath}/student/my-enrollments">My Courses</a>
                                <span>/</span>
                                <span>Payments</span>
                            </div>

                            <!-- React Root Mounting Target -->
                            <div id="payment-history-react-root"></div>
                        </main>
                    </div>

                    <div class="sv-overlay" id="svOverlay"></div>
                    <script src="${pageContext.request.contextPath}/js/student-v2.js"></script>

                    <!-- Server-to-Client JSTL Data Bridge -->
                    <script>
                        window.paymentsData = [
                            <c:forEach var="payment" items="${payments}" varStatus="status">
                                {
                                    paymentId: "${payment.paymentId}",
                                courseName: `${fn:escapeXml(payment.courseName)}`,
                                studentName: `${fn:escapeXml(payment.studentName)}`,
                                amount: ${payment.amount},
                                status: "${payment.status}",
                                paymentDate: "${not empty payment.paymentDate ? fn:replace(payment.paymentDate, 'T', ' ') : '-'}",
                                paymentRef: "${fn:escapeXml(not empty payment.paymentRef ? payment.paymentRef : '-')}",
                                paystackReference: "${fn:escapeXml(not empty payment.paystackReference ? payment.paystackReference : '-')}",
                                method: "${fn:escapeXml(not empty payment.method ? payment.method : 'Gateway')}",
                                enrollmentId: "${payment.enrollmentId}"
            }${not status.last ? ',' : ''}
                            </c:forEach>
                        ];
                    </script>

                    <!-- React Application Script Compiling with Babel in Browser -->
                    <script type="text/babel">
                        const PaymentHistoryApp = () => {
                            const [payments, setPayments] = React.useState(window.paymentsData || []);
                            const [searchTerm, setSearchTerm] = React.useState('');
                            const [activeStatus, setActiveStatus] = React.useState('all');
                            const [selectedPayment, setSelectedPayment] = React.useState(null);
                            const [isFiltering, setIsFiltering] = React.useState(false);

                            // Sorting states
                            const [sortField, setSortField] = React.useState('paymentDate');
                            const [sortDirection, setSortDirection] = React.useState('desc');

                            // Target Ref for clean PDF generation
                            const receiptRef = React.useRef(null);

                            // Parse query params for receipt ID or status filter
                            React.useEffect(() => {
                                const urlParams = new URLSearchParams(window.location.search);
                                const statusParam = urlParams.get('status');
                                if (statusParam) {
                                    setActiveStatus(statusParam.toLowerCase());
                                }

                                const receiptParam = urlParams.get('receiptPaymentId');
                                if (receiptParam) {
                                    const found = payments.find(p => p.paymentId === receiptParam);
                                    if (found) {
                                        setSelectedPayment(found);
                                    }
                                }
                            }, [payments]);

                            // Sorting trigger
                            const handleSort = (field) => {
                                if (sortField === field) {
                                    setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
                                } else {
                                    setSortField(field);
                                    setSortDirection('asc');
                                }
                            };

                            // Compute sorted and filtered payments dynamically
                            const sortedAndFiltered = React.useMemo(() => {
                                const filtered = payments.filter(p => {
                                    const courseMatch = p.courseName.toLowerCase().includes(searchTerm.toLowerCase());
                                    const statusMatch = activeStatus === 'all' || p.status.toLowerCase() === activeStatus;
                                    return courseMatch && statusMatch;
                                });

                                return [...filtered].sort((a, b) => {
                                    let valA = a[sortField] || '';
                                    let valB = b[sortField] || '';

                                    if (sortField === 'amount') {
                                        return sortDirection === 'asc' ? Number(valA) - Number(valB) : Number(valB) - Number(valA);
                                    }

                                    valA = String(valA).toLowerCase();
                                    valB = String(valB).toLowerCase();

                                    if (valA < valB) return sortDirection === 'asc' ? -1 : 1;
                                    if (valA > valB) return sortDirection === 'asc' ? 1 : -1;
                                    return 0;
                                });
                            }, [payments, searchTerm, activeStatus, sortField, sortDirection]);

                            // Re-draw Lucide icons on view changes
                            React.useEffect(() => {
                                if (window.lucide) {
                                    window.lucide.createIcons();
                                }
                            }, [sortedAndFiltered, selectedPayment]);

                            // Simulated skeleton transition on text input
                            React.useEffect(() => {
                                setIsFiltering(true);
                                const timer = setTimeout(() => {
                                    setIsFiltering(false);
                                }, 150);
                                return () => clearTimeout(timer);
                            }, [searchTerm, activeStatus]);

                            const formatCurrency = (amount) => {
                                return '₦' + Number(amount).toLocaleString('en-NG', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                            };

                            // Single-Page PDF Download Handler
                            const handleDownload = () => {
                                const element = receiptRef.current;
                                if (!element) return;

                                const opt = {
                                    margin: 0.5,
                                    filename: 'transaction-receipt.pdf',
                                    image: { type: 'jpeg', quality: 0.98 },
                                    html2canvas: { scale: 2, useCORS: true },
                                    jsPDF: { unit: 'in', format: 'a4', orientation: 'portrait' }
                                };

                                // Execute HTML to PDF rendering
                                html2pdf().set(opt).from(element).save();
                            };

                            const { motion, AnimatePresence } = window.Motion || {};

                            return (
                                <div className="history_ph_ledgerContainer">
                                    <h2 className="history_ph_ledgerTitle">Payment History</h2>

                                    {/* Task 1: Filter & Search Controls */}
                                    <div className="history_ph_filterBar">
                                        <div className="history_ph_searchContainer">
                                            <input
                                                type="search"
                                                className="history_ph_searchInput"
                                                placeholder="Search by course name..."
                                                value={searchTerm}
                                                onChange={(e) => setSearchTerm(e.target.value)}
                                                aria-label="Search transactions"
                                            />
                                            <div className="history_ph_searchIcon">
                                                <i data-lucide="search" style={{ width: 16, height: 16 }}></i>
                                            </div>
                                        </div>

                                        <div className="history_ph_filterGroup" role="group" aria-label="Filter transactions by status">
                                            <div className="history_ph_sortWrap">
                                                <select
                                                    className="history_ph_searchInput"
                                                    style={{ paddingLeft: '16px', paddingRight: '36px', appearance: 'none', cursor: 'pointer', background: 'var(--sv-surface-secondary)' }}
                                                    value={sortField + '-' + sortDirection}
                                                    onChange={(e) => {
                                                        const [f, d] = e.target.value.split('-');
                                                        setSortField(f);
                                                        setSortDirection(d);
                                                    }}
                                                >
                                                    <option value="paymentDate-desc">Newest First</option>
                                                    <option value="paymentDate-asc">Oldest First</option>
                                                    <option value="amount-desc">Highest Amount</option>
                                                    <option value="amount-asc">Lowest Amount</option>
                                                    <option value="courseName-asc">Course A-Z</option>
                                                </select>
                                                <i data-lucide="chevron-down" style={{ position: 'absolute', right: '12px', top: '11px', width: 16, height: 16, pointerEvents: 'none', color: 'var(--sv-muted)' }}></i>
                                            </div>

                                            <div className="history_ph_statusGroup">
                                                {['all', 'paid', 'pending', 'failed'].map((status) => (
                                                    <button
                                                        key={status}
                                                        type="button"
                                                        className={"history_ph_filterBtn " + (activeStatus === status ? "history_ph_filterBtnActive" : "")}
                                                        onClick={() => setActiveStatus(status)}
                                                    >
                                                        {status.charAt(0).toUpperCase() + status.slice(1)}
                                                    </button>
                                                ))}
                                            </div>
                                        </div>
                                    </div>

                                    {/* Responsive Floating Ledger Rows */}
                                    <div className="history_ph_ledgerList">
                                        {isFiltering ? (
                                            [1, 2, 3].map(i => (
                                                <article key={i} className="history_ph_ledgerRow">
                                                    <div className="history_ph_rowLeft">
                                                        <div className="history_ph_skeletonText medium"></div>
                                                        <div className="history_ph_skeletonText short" style={{ height: '12px', marginTop: '4px' }}></div>
                                                    </div>
                                                    <div className="history_ph_rowRight">
                                                        <div className="history_ph_skeletonText short" style={{ width: '60px' }}></div>
                                                        <div className="history_ph_skeletonBadge"></div>
                                                        <div className="history_ph_skeletonBtn"></div>
                                                    </div>
                                                </article>
                                            ))
                                        ) : sortedAndFiltered.length === 0 ? (
                                            <div className="history_ph_emptyState">
                                                <i data-lucide="receipt" style={{ width: 48, height: 48, color: '#94a3b8', strokeWidth: 1.5 }}></i>
                                                <h3>No payments found</h3>
                                                <p>Try adjusting your search criteria or filter options.</p>
                                            </div>
                                        ) : (
                                            sortedAndFiltered.map((payment) => (
                                                <article key={payment.paymentId} className="history_ph_ledgerRow">
                                                    <div className="history_ph_rowLeft">
                                                        <h3 className="history_ph_courseTitle">{payment.courseName}</h3>
                                                        <div className="history_ph_rowDate">
                                                            <span>{payment.paymentRef}</span> &nbsp;&bull;&nbsp; {payment.paymentDate}
                                                        </div>
                                                    </div>
                                                    <div className="history_ph_rowRight">
                                                        <div className="history_ph_amount">{formatCurrency(payment.amount)}</div>
                                                        <span className={"history_ph_badge history_ph_badge_" + payment.status.toLowerCase()}>
                                                            <span style={{
                                                                width: 6,
                                                                height: 6,
                                                                borderRadius: '50%',
                                                                backgroundColor: payment.status.toLowerCase() === 'paid' ? '#198754' : (payment.status.toLowerCase() === 'pending' ? '#ffc107' : '#dc3545')
                                                            }}></span>
                                                            {payment.status}
                                                        </span>
                                                        <button
                                                            type="button"
                                                            className="history_ph_viewBtn"
                                                            onClick={() => setSelectedPayment(payment)}
                                                        >
                                                            <i data-lucide="file-text" style={{ width: 16, height: 16 }}></i>
                                                            View Receipt
                                                        </button>
                                                    </div>
                                                </article>
                                            ))
                                        )}
                                    </div>

                                    {/* Task 2 & 3: iOS-style Elastic Receipt Modal */}
                                    {AnimatePresence && (
                                        <AnimatePresence>
                                            {selectedPayment && (
                                                <motion.div
                                                    className="history_rm_backdrop"
                                                    initial={{ opacity: 0 }}
                                                    animate={{ opacity: 1 }}
                                                    exit={{ opacity: 0 }}
                                                    onClick={() => setSelectedPayment(null)}
                                                >
                                                    <motion.section
                                                        className="history_rm_passWrapper"
                                                        initial={{ scale: 0.9, y: 15, opacity: 0 }}
                                                        animate={{ scale: 1, y: 0, opacity: 1 }}
                                                        exit={{ scale: 0.92, y: 10, opacity: 0 }}
                                                        transition={{ type: "spring", damping: 25, stiffness: 350 }}
                                                        onClick={(e) => e.stopPropagation()}
                                                    >
                                                        {/* Close Button: Positioned absolute (OUTSIDE printable target ref) */}
                                                        <button
                                                            type="button"
                                                            className="history_rm_closeBtn"
                                                            onClick={() => setSelectedPayment(null)}
                                                            aria-label="Close modal"
                                                        >
                                                            <i data-lucide="x" style={{ width: 20, height: 20, strokeWidth: 2.5 }}></i>
                                                        </button>

                                                        {/* Inner printable Digital Pass targeted by React Ref */}
                                                        <div ref={receiptRef} className="history_rm_digitalPass" style={{ position: 'relative' }}>
                                                            
                                                            {/* Official Document Watermark Stamp */}
                                                            <div className={"history_rm_stamp history_rm_stamp_" + selectedPayment.status.toLowerCase()}>
                                                                {selectedPayment.status}
                                                            </div>

                                                            {/* Pass Top: Title & Price */}
                                                            <div className="history_rm_passTop" style={{ zIndex: 2, position: 'relative' }}>
                                                                <div className="history_rm_platformIcon">
                                                                    <i data-lucide="wallet" style={{ width: 24, height: 24, strokeWidth: 2 }}></i>
                                                                </div>
                                                                <h3 className="history_rm_courseTitle">{selectedPayment.courseName}</h3>
                                                                <span className={"history_rm_statusBadge history_rm_status_" + selectedPayment.status.toLowerCase()}>
                                                                    <span style={{
                                                                        width: 6, height: 6, borderRadius: '50%',
                                                                        backgroundColor: selectedPayment.status.toLowerCase() === 'paid' ? '#166534' : (selectedPayment.status.toLowerCase() === 'pending' ? '#664d03' : '#842029')
                                                                    }}></span>
                                                                    {selectedPayment.status}
                                                                </span>
                                                                <div className="history_rm_totalAmount">
                                                                    {formatCurrency(selectedPayment.amount)}
                                                                </div>
                                                            </div>

                                                            {/* Dashed Tear Line */}
                                                            <div className="history_rm_passDivider" style={{ zIndex: 2, position: 'relative' }}></div>

                                                            {/* Pass Bottom: Metadata & Barcode */}
                                                            <div className="history_rm_passBottom" style={{ zIndex: 2, position: 'relative' }}>
                                                                <div className="history_rm_metaGrid">
                                                                    <div className="history_rm_metaItem">
                                                                        <span className="history_rm_metaLabel">Student Name</span>
                                                                        <span className="history_rm_metaValue">{selectedPayment.studentName}</span>
                                                                    </div>
                                                                    <div className="history_rm_metaItem">
                                                                        <span className="history_rm_metaLabel">Enrollment ID</span>
                                                                        <span className="history_rm_metaValue mono">{selectedPayment.enrollmentId}</span>
                                                                    </div>
                                                                    <div className="history_rm_metaItem">
                                                                        <span className="history_rm_metaLabel">Date & Time</span>
                                                                        <span className="history_rm_metaValue">{selectedPayment.paymentDate}</span>
                                                                    </div>
                                                                    <div className="history_rm_metaItem">
                                                                        <span className="history_rm_metaLabel">Method</span>
                                                                        <span className="history_rm_metaValue" style={{ textTransform: 'capitalize' }}>{selectedPayment.method}</span>
                                                                    </div>
                                                                    <div className="history_rm_metaItem" style={{ gridColumn: 'span 2' }}>
                                                                        <span className="history_rm_metaLabel">Transaction Reference</span>
                                                                        <span className="history_rm_metaValue mono" style={{ fontSize: '0.8rem' }}>
                                                                            {selectedPayment.paymentRef}
                                                                            {selectedPayment.paystackReference !== '-' && ` / ${selectedPayment.paystackReference}`}
                                                                        </span>
                                                                    </div>
                                                                </div>

                                                                <div className="history_rm_barcodeWrapper">
                                                                    <div className="history_rm_barcodeStripes"></div>
                                                                    <span className="history_rm_barcodeText">*{selectedPayment.paymentId}*</span>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        {/* Action Download Button: Bottom (OUTSIDE printable target ref) */}
                                                        <button
                                                            type="button"
                                                            className="history_rm_downloadBtn"
                                                            onClick={handleDownload}
                                                        >
                                                            <i data-lucide="download" style={{ width: 18, height: 18, strokeWidth: 2.5 }}></i>
                                                            <span>Download Pass PDF</span>
                                                        </button>
                                                    </motion.section>
                                                </motion.div>
                                            )}
                                        </AnimatePresence>
                                    )}
                                </div>
                            );
                        };

                        const container = document.getElementById('payment-history-react-root');
                        const root = ReactDOM.createRoot(container);
                        root.render(<PaymentHistoryApp />);
                    </script>
                </body>

                </html>