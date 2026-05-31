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
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    
    <!-- CSS Modules Isolated Stylesheets -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/PaymentHistory.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ReceiptModal.module.css">
    
    <!-- React, Animation & html2pdf CDNs -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
</head>
<body class="sv-page">
<c:set var="topbarTitle" value="Payment History"/>
<c:set var="topbarSubtitle" value="Review successful, pending, and failed payments"/>
<c:set var="topbarShowSearch" value="false"/>
<jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>

<div class="sv-layout">
    <c:set var="activePage" value="payments"/>
    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>

    <main class="sv-main ef-main">
        <div class="sv-breadcrumb">
            <a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-house"></i> Dashboard</a>
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
        const [filteredPayments, setFilteredPayments] = React.useState(payments);
        
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

        // Live text and status filtering
        React.useEffect(() => {
            setIsFiltering(true);
            const timer = setTimeout(() => {
                const result = payments.filter(p => {
                    const courseMatch = p.courseName.toLowerCase().includes(searchTerm.toLowerCase());
                    const statusMatch = activeStatus === 'all' || p.status.toLowerCase() === activeStatus;
                    return courseMatch && statusMatch;
                });
                setFilteredPayments(result);
                setIsFiltering(false);
            }, 200);

            return () => clearTimeout(timer);
        }, [searchTerm, activeStatus, payments]);

        // Re-draw Lucide icons on view changes
        React.useEffect(() => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        }, [filteredPayments, selectedPayment, isFiltering]);

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

                {/* Task 1: Clean, Borderless Ledger List */}
                {isFiltering ? (
                    <div className="history_ph_ledgerList">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="history_ph_skeletonRow">
                                <div className="history_ph_rowLeft">
                                    <div className="history_ph_skeletonText medium"></div>
                                    <div className="history_ph_skeletonText short" style={{ marginTop: 8 }}></div>
                                </div>
                                <div className="history_ph_rowRight">
                                    <div className="history_ph_skeletonText short"></div>
                                    <div className="history_ph_skeletonBtn"></div>
                                </div>
                            </div>
                        ))}
                    </div>
                ) : filteredPayments.length === 0 ? (
                    <div className="history_ph_ledgerList" style={{ background: '#ffffff', borderRadius: 8, border: '1px solid #f1f5f9' }}>
                        <div className="history_ph_emptyState">
                            <i data-lucide="receipt" style={{ width: 48, height: 48, color: '#94a3b8', strokeWidth: 1.5 }}></i>
                            <h3>No payments found</h3>
                            <p>Try adjusting your search criteria or filter options.</p>
                        </div>
                    </div>
                ) : (
                    <div className="history_ph_ledgerList">
                        {filteredPayments.map((payment) => (
                            <div key={payment.paymentId} className="history_ph_ledgerRow">
                                <div className="history_ph_rowLeft">
                                    <h4 className="history_ph_courseTitle">{payment.courseName}</h4>
                                    <span className="history_ph_rowDate">{payment.paymentDate}</span>
                                </div>
                                <div className="history_ph_rowRight">
                                    <span className="history_ph_amount">{formatCurrency(payment.amount)}</span>
                                    <button 
                                        type="button" 
                                        className="history_ph_viewBtn"
                                        onClick={() => setSelectedPayment(payment)}
                                    >
                                        View Receipt
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                )}

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
                                    className="history_rm_paper"
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
                                        <i data-lucide="x" style={{ width: 16, height: 16, strokeWidth: 2.5 }}></i>
                                    </button>

                                    {/* Inner Thermal printable document targeted by React Ref */}
                                    <div ref={receiptRef} className="history_rm_printableArea">
                                        
                                        {/* Thermal Header Platform Name */}
                                        <div className="history_rm_header">
                                            <i data-lucide="qr-code" className="history_rm_thermalIcon" style={{ width: 44, height: 44, strokeWidth: 1.5 }}></i>
                                            <h3 className="history_rm_platformName">PSM E-LEARNING</h3>
                                            <span className="history_rm_subtitle">CASHIER: AUTOMATED SYSTEM</span>
                                            <span className="history_rm_subtitle">*** TRANSACTION RECORD ***</span>
                                        </div>

                                        {/* Massive Bold Total Boxed with dashed borders */}
                                        <div className="history_rm_totalBox">
                                            <span className="history_rm_totalLabel">TOTAL AMOUNT</span>
                                            <div className="history_rm_totalAmount">
                                                {formatCurrency(selectedPayment.amount)}
                                            </div>
                                        </div>

                                        {/* Monospace Metadata Detail Fields */}
                                        <div className="history_rm_lineItem">
                                            <span className="history_rm_label">DATE PAID</span>
                                            <span className="history_rm_monospace">{selectedPayment.paymentDate}</span>
                                        </div>

                                        <div className="history_rm_lineItem">
                                            <span className="history_rm_label">TRANSACTION ID</span>
                                            <span className="history_rm_monospace">{selectedPayment.paymentRef}</span>
                                        </div>

                                        <div className="history_rm_lineItem">
                                            <span className="history_rm_label">GATEWAY REF</span>
                                            <span className="history_rm_monospace">{selectedPayment.paystackReference}</span>
                                        </div>

                                        <div className="history_rm_lineItem">
                                            <span className="history_rm_label">METHOD</span>
                                            <span className="history_rm_monospace">{selectedPayment.method.toUpperCase()}</span>
                                        </div>

                                        <div className="history_rm_dashedDivider"></div>

                                        <div className="history_rm_lineItem">
                                            <span className="history_rm_label">ITEM</span>
                                            <span className="history_rm_monospace" style={{ textAlign: 'right', display: 'block' }}>
                                                {selectedPayment.courseName.toUpperCase()}
                                            </span>
                                        </div>

                                        {/* Stylized Mock Barcode */}
                                        <div className="history_rm_barcodeContainer">
                                            <div className="history_rm_barcodeStripes"></div>
                                            <span className="history_rm_barcodeText">*{selectedPayment.paymentId}*</span>
                                        </div>

                                        {/* Receipt Footer Message */}
                                        <div className="history_rm_footer">
                                            *** THANK YOU FOR ENROLLING ***<br />
                                            SUPPORT: SUPPORT@USYYTECH.COM
                                        </div>
                                    </div>

                                    {/* Action Download Button: Bottom (OUTSIDE printable target ref) */}
                                    <button 
                                        type="button" 
                                        className="history_rm_downloadBtn"
                                        onClick={handleDownload}
                                    >
                                        <i data-lucide="download" style={{ width: 18, height: 18, strokeWidth: 2.5 }}></i>
                                        <span>Download PDF</span>
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