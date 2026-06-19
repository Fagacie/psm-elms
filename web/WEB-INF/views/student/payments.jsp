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
                    `n    
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
                    
    <script type="module" src="${pageContext.request.contextPath}/js/dist/payments.js"></script>
                </body>

                </html>
