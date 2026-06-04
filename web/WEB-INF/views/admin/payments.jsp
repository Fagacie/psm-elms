<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Financial Transaction Ledger - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-payments-gf.css?v=1.0">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- React & ReactDOM (UMD production versions) -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for JSX rendering -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    
    <!-- Lucide Icons UMD -->
    <script src="https://unpkg.com/lucide@0.395.0/dist/umd/lucide.min.js"></script>
    
    <!-- TanStack Table UMD -->
    <script src="https://unpkg.com/@tanstack/react-table@8.17.3/build/umd/index.production.js"></script>
    
    <style media="print">
        body * {
            visibility: hidden;
        }
        #print-receipt-area, #print-receipt-area * {
            visibility: visible;
        }
        #print-receipt-area {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
        }
    </style>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Payments"/>
    <jsp:param name="pageSubtitle" value="Track tuition collections, gateway processing states, and payment verifications"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- Success/Error JSTL Notification Banners -->
    <div style="max-width: 1400px; margin: 2rem auto 0 auto; padding: 0 2rem;">
        <c:if test="${not empty successMessage}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> <c:out value="${successMessage}"/>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert-gf alert-error-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-exclamation-circle"></i> <c:out value="${errorMessage}"/>
            </div>
        </c:if>
    </div>

    <!-- React Greenfield Mounting Entry Node -->
    <div id="admin-react-root"></div>
</main>

<%
    List<Payment> paymentsList = (List<Payment>) request.getAttribute("payments");
    org.json.JSONArray paymentsJsonArray = new org.json.JSONArray();
    if (paymentsList != null) {
        for (Payment p : paymentsList) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("paymentId", p.getPaymentId());
            obj.put("enrollmentId", p.getEnrollmentId());
            obj.put("amount", p.getAmount() != null ? p.getAmount() : 0.0);
            obj.put("paymentRef", p.getPaymentRef() != null ? p.getPaymentRef() : "");
            obj.put("paystackReference", p.getPaystackReference() != null ? p.getPaystackReference() : "");
            obj.put("accessCode", p.getAccessCode() != null ? p.getAccessCode() : "");
            obj.put("authorizationUrl", p.getAuthorizationUrl() != null ? p.getAuthorizationUrl() : "");
            obj.put("paystackStatus", p.getPaystackStatus() != null ? p.getPaystackStatus() : "N/A");
            obj.put("status", p.getStatus() != null ? p.getStatus() : "Pending");
            obj.put("method", p.getMethod() != null ? p.getMethod() : "N/A");
            obj.put("paymentDate", p.getPaymentDate() != null ? p.getPaymentDate().toString() : "");
            obj.put("studentName", p.getStudentName() != null ? p.getStudentName() : "");
            obj.put("studentEmail", p.getStudentEmail() != null ? p.getStudentEmail() : "");
            obj.put("courseName", p.getCourseName() != null ? p.getCourseName() : "");
            paymentsJsonArray.put(obj);
        }
    }
    pageContext.setAttribute("serializedPaymentsJson", paymentsJsonArray.toString());
%>

<!-- Serialize JSTL variables securely to window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__PAYMENTS__ = ${serializedPaymentsJson};
</script>

<!-- Interactive React Command Center Application -->
<script type="text/babel">
    const { useState, useEffect } = React;
    const { 
        useReactTable, getCoreRowModel, getPaginationRowModel, getSortedRowModel, flexRender 
    } = window.ReactTable || {};

    function PaymentsLedger() {
        const [payments, setPayments] = useState(window.__PAYMENTS__ || []);
        const [globalFilter, setGlobalFilter] = useState('');
        const [statusFilter, setStatusFilter] = useState('All');
        const [gatewayFilter, setGatewayFilter] = useState('All');
        
        // Pagination state
        const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
        
        // Sorting state
        const [sorting, setSorting] = useState([{ id: 'paymentDate', desc: true }]);

        // Dropdown tracking
        const [activeDropdownId, setActiveDropdownId] = useState(null);

        // Drawer states
        const [drawerOpen, setDrawerOpen] = useState(false);
        const [selectedPayment, setSelectedPayment] = useState(null);

        // In-place real-time verification loaders
        const [verifyingPaymentIds, setVerifyingPaymentIds] = useState([]);

        // Custom toast message status
        const [toast, setToast] = useState(null);

        useEffect(() => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        }, [payments, pagination, globalFilter, statusFilter, gatewayFilter, sorting, drawerOpen, verifyingPaymentIds]);

        // Close dropdown on click outside
        useEffect(() => {
            const handleOutsideClick = (e) => {
                if (activeDropdownId && !e.target.closest('.actions-cell-gf')) {
                    setActiveDropdownId(null);
                }
            };
            window.addEventListener('click', handleOutsideClick);
            return () => window.removeEventListener('click', handleOutsideClick);
        }, [activeDropdownId]);

        // Auto clear toast helper
        useEffect(() => {
            if (toast) {
                const t = setTimeout(() => setToast(null), 5000);
                return () => clearTimeout(t);
            }
        }, [toast]);

        // Metrics calculations
        const totalCount = payments.length;
        const paidCount = payments.filter(p => p.status === 'Paid' || p.status === 'Paid').length;
        const pendingCount = payments.filter(p => p.status === 'Pending').length;
        const failedCount = payments.filter(p => p.status === 'Failed' || p.status === 'Abandoned').length;
        const totalTuition = payments
            .filter(p => p.status === 'Paid')
            .reduce((sum, p) => sum + Number(p.amount || 0), 0);

        // Custom filtering based on status filters, gateway filters, and search queries
        const filteredData = React.useMemo(() => {
            return payments.filter(item => {
                // Status filter
                if (statusFilter !== 'All') {
                    if (statusFilter === 'Paid' && item.status !== 'Paid') return false;
                    if (statusFilter === 'Pending' && item.status !== 'Pending') return false;
                    if (statusFilter === 'Failed' && item.status !== 'Failed' && item.status !== 'Abandoned') return false;
                }
                
                // Gateway / Method filter
                if (gatewayFilter !== 'All') {
                    const methodStr = (item.method || '').toLowerCase();
                    if (gatewayFilter === 'Paystack' && !methodStr.includes('paystack') && item.paystackReference) {
                        // Include standard paystack integrations
                    } else if (gatewayFilter === 'Bank' && !methodStr.includes('bank') && !methodStr.includes('transfer')) {
                        return false;
                    }
                }
                
                // Search query filter
                if (globalFilter.trim()) {
                    const query = globalFilter.toLowerCase();
                    return (
                        item.studentName.toLowerCase().includes(query) ||
                        item.studentEmail.toLowerCase().includes(query) ||
                        item.courseName.toLowerCase().includes(query) ||
                        item.paymentRef.toLowerCase().includes(query) ||
                        item.paystackReference.toLowerCase().includes(query)
                    );
                }
                return true;
            });
        }, [payments, globalFilter, statusFilter, gatewayFilter]);

        // Click to copy reference code helper
        const handleCopyText = (text) => {
            navigator.clipboard.writeText(text);
            setToast({ type: 'success', message: 'Transaction reference copied to clipboard!' });
        };

        // Open invoice drawer in details mode
        const handleOpenReceipt = (payment) => {
            setSelectedPayment(payment);
            setDrawerOpen(true);
        };

        // Trigger real-time Paystack Verification via backend
        const handleVerifyPayment = (paymentId) => {
            setVerifyingPaymentIds(prev => [...prev, paymentId]);
            setActiveDropdownId(null);
            
            fetch(window.__CONTEXT_PATH__ + '/admin/payments?action=verify&id=' + paymentId)
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        // Dynamically update the row in React state immediately!
                        setPayments(prev => prev.map(p => {
                            if (p.paymentId === paymentId) {
                                return { 
                                    ...p, 
                                    status: data.status, 
                                    paystackStatus: data.gatewayStatus,
                                    method: data.method 
                                };
                            }
                            return p;
                        }));
                        setToast({ type: 'success', message: data.message });
                    } else {
                        setToast({ type: 'error', message: data.message || 'Verification could not be confirmed.' });
                    }
                })
                .catch(err => {
                    console.error("Verification error:", err);
                    setToast({ type: 'error', message: 'Network error while attempting gateway verification.' });
                })
                .finally(() => {
                    setVerifyingPaymentIds(prev => prev.filter(id => id !== paymentId));
                });
        };

        // Setup headless React Table column cells
        const columns = React.useMemo(() => [
            {
                accessorKey: 'paymentId',
                header: 'ID',
                cell: info => <span style={{ fontWeight: '600' }}>{"#" + info.getValue()}</span>
            },
            {
                accessorKey: 'paystackReference',
                header: 'Transaction Ref',
                cell: info => {
                    const row = info.row.original;
                    const ref = info.getValue() || row.paymentRef || 'N/A';
                    return (
                        <div className="reference-badge-gf" onClick={() => handleCopyText(ref)} title="Click to Copy">
                            <span>{ref.substring(0, 12)}...</span>
                            <i className="far fa-copy"></i>
                        </div>
                    );
                }
            },
            {
                accessorKey: 'studentName',
                header: 'Customer',
                cell: info => {
                    const row = info.row.original;
                    return (
                        <div className="stacked-cell-gf">
                            <span className="stacked-primary-gf">{row.studentName}</span>
                            <span className="stacked-secondary-gf">{row.studentEmail}</span>
                        </div>
                    );
                }
            },
            {
                accessorKey: 'amount',
                header: 'Amount & Course',
                cell: info => {
                    const row = info.row.original;
                    const val = Number(info.getValue() || 0);
                    return (
                        <div className="stacked-cell-gf">
                            <span className="stacked-primary-gf" style={{ fontWeight: '700' }}>
                                ₦{val.toLocaleString('en-NG', { minimumFractionDigits: 2 })}
                            </span>
                            <span className="stacked-secondary-gf">{row.courseName}</span>
                        </div>
                    );
                }
            },
            {
                accessorKey: 'method',
                header: 'Gateway',
                cell: info => {
                    const val = info.getValue() || 'Paystack';
                    let channelClass = 'gateway-paystack-gf';
                    if (val.toLowerCase().includes('bank') || val.toLowerCase().includes('transfer')) {
                        channelClass = 'gateway-bank-gf';
                    }
                    return <span className={"gateway-badge-gf " + channelClass}>{val}</span>;
                }
            },
            {
                accessorKey: 'status',
                header: 'Status',
                cell: info => {
                    const val = info.getValue() || 'Pending';
                    let statusClass = 'badge-pending-gf';
                    if (val === 'Paid' || val === 'success' || val === 'SUCCESS') {
                        statusClass = 'badge-paid-gf';
                    } else if (val === 'Failed') {
                        statusClass = 'badge-failed-gf';
                    } else if (val === 'Abandoned') {
                        statusClass = 'badge-abandoned-gf';
                    }
                    return <span className={"badge-gf " + statusClass}>{val}</span>;
                }
            },
            {
                accessorKey: 'paymentDate',
                header: 'Paid At',
                cell: info => {
                    const val = info.getValue();
                    if (!val) return 'N/A';
                    const d = new Date(val);
                    return <span>{d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' })}</span>;
                }
            },
            {
                id: 'actions',
                header: '',
                cell: info => {
                    const row = info.row.original;
                    const isOpen = activeDropdownId === row.paymentId;
                    return (
                        <div className="actions-cell-gf">
                            <button 
                                className="actions-btn-gf"
                                onClick={(e) => {
                                    e.stopPropagation();
                                    setActiveDropdownId(isOpen ? null : row.paymentId);
                                }}
                            >
                                <i className="fas fa-ellipsis-v"></i>
                            </button>
                            {isOpen && (
                                <div className="actions-dropdown-gf">
                                    <button className="dropdown-item-gf" onClick={() => handleOpenReceipt(row)}>
                                        <i className="fas fa-file-invoice-dollar"></i> View Receipt
                                    </button>
                                    <button className="dropdown-item-gf" onClick={() => handleVerifyPayment(row.paymentId)}>
                                        <i className="fas fa-sync-alt"></i> Verify Status
                                    </button>
                                </div>
                            )}
                        </div>
                    );
                }
            }
        ], [activeDropdownId]);

        // Mount TanStack React Table
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
            getSortedRowModel: getSortedRowModel ? getSortedRowModel() : null
        });

        return (
            <div className="admin-container-gf">
                {/* Header Section */}
                <header className="dashboard-header-gf">
                    <h1>TUITION TRANSACTIONS</h1>
                    <p>Track student enrollment invoices, verify processing states with external payment processor APIs, and audit general ledger entries.</p>
                </header>

                {/* Metrics Cards row */}
                <section className="metrics-grid-gf">
                    <div className="metric-card-gf">
                        <span className="label">Tuition collections</span>
                        <span className="value" style={{ color: '#10b981' }}>₦{totalTuition.toLocaleString('en-NG', { minimumFractionDigits: 2 })}</span>
                        <span className="meta">Successful paid entries</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Transactions</span>
                        <span className="value">{totalCount}</span>
                        <span className="meta">Total database payment records</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Pending</span>
                        <span className="value" style={{ color: '#b45309' }}>{pendingCount}</span>
                        <span className="meta">Awaiting callback confirmations</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Failed / Abandoned</span>
                        <span className="value" style={{ color: '#ef4444' }}>{failedCount}</span>
                        <span className="meta">Declined checkout attempts</span>
                    </div>
                </section>

                {/* Data Table Shell */}
                <section className="table-card-gf">
                    <div className="table-controls-gf">
                        <div className="controls-left-gf">
                            {/* Search Box */}
                            <div className="search-box-gf">
                                <i className="fas fa-search"></i>
                                <input 
                                    type="text" 
                                    placeholder="Search reference, email or student..." 
                                    value={globalFilter}
                                    onChange={e => setGlobalFilter(e.target.value)}
                                />
                            </div>

                            {/* Gateway / Processor dropdown filter */}
                            <select 
                                className="select-filter-gf" 
                                value={gatewayFilter}
                                onChange={e => setGatewayFilter(e.target.value)}
                            >
                                <option value="All">All Gateways</option>
                                <option value="Paystack">Paystack</option>
                                <option value="Bank">Bank Transfer</option>
                            </select>

                            {/* Status Tabs toggles */}
                            <div className="filter-tabs-gf">
                                <button className={"tab-btn-gf " + (statusFilter === 'All' ? 'active' : '')} onClick={() => setStatusFilter('All')}>All</button>
                                <button className={"tab-btn-gf " + (statusFilter === 'Paid' ? 'active' : '')} onClick={() => setStatusFilter('Paid')}>Successful</button>
                                <button className={"tab-btn-gf " + (statusFilter === 'Pending' ? 'active' : '')} onClick={() => setStatusFilter('Pending')}>Pending</button>
                                <button className={"tab-btn-gf " + (statusFilter === 'Failed' ? 'active' : '')} onClick={() => setStatusFilter('Failed')}>Failed</button>
                            </div>
                        </div>
                    </div>

                    {/* Table Render */}
                    {table && table.getRowModel && table.getRowModel().rows.length === 0 ? (
                        <div className="empty-state-gf">
                            <i className="fas fa-credit-card"></i>
                            <p>No transaction logs matched your query criteria.</p>
                        </div>
                    ) : (
                        <div style={{ overflowX: 'auto' }}>
                            <table className="payments-table-gf">
                                <thead>
                                    {table && table.getHeaderGroups().map(headerGroup => (
                                        <tr key={headerGroup.id}>
                                            {headerGroup.headers.map(header => (
                                                <th 
                                                    key={header.id}
                                                    onClick={header.column.getCanSort() ? header.column.getToggleSortingHandler() : undefined}
                                                    style={{ cursor: header.column.getCanSort() ? 'pointer' : 'default' }}
                                                >
                                                    {flexRender(header.column.columnDef.header, header.getContext())}
                                                    {header.column.getIsSorted() === 'asc' && ' 🔼'}
                                                    {header.column.getIsSorted() === 'desc' && ' 🔽'}
                                                </th>
                                            ))}
                                        </tr>
                                    ))}
                                </thead>
                                <tbody>
                                    {table && table.getRowModel().rows.map(row => {
                                        const isVerifying = verifyingPaymentIds.includes(row.original.paymentId);
                                        return (
                                            <tr key={row.id} className={isVerifying ? 'row-verifying-gf' : ''}>
                                                {row.getVisibleCells().map(cell => (
                                                    <td key={cell.id} style={{ position: 'relative' }}>
                                                        {isVerifying && cell.column.id === 'paystackReference' && (
                                                            <div className="row-verifying-overlay-gf">
                                                                <i className="fas fa-spinner fa-spin" style={{ marginRight: '0.4rem' }}></i> Verifying...
                                                            </div>
                                                        )}
                                                        {flexRender(cell.column.columnDef.cell, cell.getContext())}
                                                    </td>
                                                ))}
                                            </tr>
                                        );
                                    })}
                                </tbody>
                            </table>
                        </div>
                    )}

                    {/* Pagination controls */}
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

                {/* Right Slide-out Drawer Receipt */}
                {drawerOpen && selectedPayment && (
                    <div className="drawer-overlay-gf" onClick={() => setDrawerOpen(false)}>
                        <div className="drawer-container-gf" onClick={e => e.stopPropagation()}>
                            <header className="drawer-header-gf">
                                <h2>Transaction Billing Invoice</h2>
                                <button className="drawer-close-gf" onClick={() => setDrawerOpen(false)}>×</button>
                            </header>

                            <div className="drawer-body-gf">
                                <div id="print-receipt-area" className="invoice-receipt-gf">
                                    <div className="invoice-brand-gf">
                                        <div className="invoice-logo-gf">PSM E-LEARNING</div>
                                        <div className="invoice-number-gf">
                                            <span>Transaction Receipt</span>
                                            <strong>#TXN-{selectedPayment.paymentId}</strong>
                                        </div>
                                    </div>

                                    <div className="invoice-details-gf">
                                        <div className="invoice-row-gf">
                                            <span>Billing Date</span>
                                            <strong>{selectedPayment.paymentDate || 'N/A'}</strong>
                                        </div>
                                        <div className="invoice-row-gf">
                                            <span>Billed To</span>
                                            <strong>{selectedPayment.studentName}</strong>
                                        </div>
                                        <div className="invoice-row-gf">
                                            <span>Email Address</span>
                                            <strong>{selectedPayment.studentEmail}</strong>
                                        </div>
                                        <div className="invoice-row-gf">
                                            <span>Course Item</span>
                                            <strong>{selectedPayment.courseName}</strong>
                                        </div>
                                        <div className="invoice-row-gf">
                                            <span>Payment Channel</span>
                                            <strong>{selectedPayment.method}</strong>
                                        </div>
                                        <div className="invoice-row-gf">
                                            <span>Gateway reference</span>
                                            <strong style={{ fontFamily: 'monospace', fontSize: '0.85rem' }}>
                                                {selectedPayment.paystackReference || selectedPayment.paymentRef || 'N/A'}
                                            </strong>
                                        </div>
                                        <div className="invoice-row-gf" style={{ marginTop: '1rem', borderTop: '2px solid var(--gf-border)', paddingTop: '1rem', borderBottom: 'none' }}>
                                            <span style={{ fontWeight: '700', fontSize: '1rem', color: 'var(--gf-text-primary)' }}>Total Amount</span>
                                            <strong className="price">
                                                ₦{Number(selectedPayment.amount).toLocaleString('en-NG', { minimumFractionDigits: 2 })}
                                            </strong>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <footer className="drawer-footer-gf">
                                <button className="btn-secondary-gf" onClick={() => setDrawerOpen(false)}>
                                    Close
                                </button>
                                <button 
                                    className="btn-primary-gf" 
                                    onClick={() => window.print()}
                                >
                                    <i className="fas fa-print"></i> Print Invoice
                                </button>
                            </footer>
                        </div>
                    </div>
                )}

                {/* Floating dynamic Toast Notifications */}
                {toast && (
                    <div className={"toast-gf " + (toast.type === 'success' ? 'toast-success-gf' : 'toast-error-gf')}>
                        <i className={toast.type === 'success' ? "fas fa-check-circle" : "fas fa-exclamation-circle"}></i>
                        <span>{toast.message}</span>
                    </div>
                )}
            </div>
        );
    }

    const container = document.getElementById('admin-react-root');
    const root = ReactDOM.createRoot(container);
    root.render(<PaymentsLedger />);
</script>
</body>
</html>
