const { useState, useEffect, useMemo, useCallback } = window.React || React;
const ReactDOM = window.ReactDOM;
const {
    useReactTable,
    getCoreRowModel,
    getSortedRowModel,
    getPaginationRowModel,
    getFilteredRowModel,
    flexRender
} = window.ReactTable || {};

const AdminPaymentsApp = () => {
    // Shared state
    const [payments, setPayments] = useState(window.__PAYMENTS__ || []);
    const [globalFilter, setGlobalFilter] = useState('');
    const [activeTab, setActiveTab] = useState('All');
    const [activeDropdownId, setActiveDropdownId] = useState(null);

    // Filter logic
    const filteredData = useMemo(() => {
        if (activeTab === 'All') return payments;
        return payments.filter(p => p.status && p.status.toLowerCase() === activeTab.toLowerCase());
    }, [payments, activeTab]);

    // Close dropdowns when clicking outside
    useEffect(() => {
        const handleClickOutside = () => setActiveDropdownId(null);
        document.addEventListener('click', handleClickOutside);
        return () => document.removeEventListener('click', handleClickOutside);
    }, []);

    // Action Handlers
    const handleViewInvoice = (payment) => {
        // Fallback view: redirect to detail page or alert
        window.location.href = window.__CONTEXT_PATH__ + '/admin/payments?action=view&id=' + payment.paymentId;
    };

    // Table Column Definitions
    const columns = useMemo(() => [
        {
            accessorKey: 'paymentId',
            header: 'ID',
            cell: info => <span style={{ fontWeight: '500' }}>{"#" + info.getValue()}</span>
        },
        {
            accessorKey: 'studentName',
            header: 'Student',
            cell: info => {
                const row = info.row.original;
                return (
                    <div className="stacked-cell-gf">
                        <span className="stacked-primary-gf">{row.studentName || 'Unknown Student'}</span>
                        <span className="stacked-secondary-gf">{row.studentEmail || 'N/A'}</span>
                    </div>
                );
            }
        },
        {
            accessorKey: 'courseName',
            header: 'Course',
            cell: info => {
                const row = info.row.original;
                return (
                    <div className="stacked-cell-gf">
                        <span className="stacked-primary-gf">{row.courseName}</span>
                        <span className="stacked-secondary-gf">Ref: {row.paymentRef}</span>
                    </div>
                );
            }
        },
        {
            accessorKey: 'amount',
            header: 'Amount',
            cell: info => {
                const val = info.getValue();
                return <span style={{ fontWeight: '600' }}>₦{Number(val).toLocaleString('en-NG', { minimumFractionDigits: 2 })}</span>;
            }
        },
        {
            accessorKey: 'paymentDate',
            header: 'Date',
            cell: info => {
                const val = info.getValue();
                if (!val) return 'N/A';
                const d = new Date(val);
                return <span>{d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>;
            }
        },
        {
            accessorKey: 'status',
            header: 'Status',
            cell: info => {
                const status = info.getValue() || 'Pending';
                let badgeClass = 'badge-pending-gf';
                if (status.toLowerCase() === 'paid' || status.toLowerCase() === 'success') {
                    badgeClass = 'badge-paid-gf';
                } else if (status.toLowerCase() === 'failed') {
                    badgeClass = 'badge-failed-gf';
                } else if (status.toLowerCase() === 'abandoned') {
                    badgeClass = 'badge-abandoned-gf';
                }

                return <span className={"badge-gf " + badgeClass}>{status}</span>;
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
                                <button className="dropdown-item-gf" onClick={() => handleViewInvoice(row)}>
                                    <i className="fas fa-file-invoice"></i> View Invoice
                                </button>
                                {row.status && row.status.toLowerCase() === 'pending' && (
                                    <button className="dropdown-item-gf" onClick={() => {}}>
                                        <i className="fas fa-sync"></i> Re-Verify
                                    </button>
                                )}
                            </div>
                        )}
                    </div>
                );
            }
        }
    ], [activeDropdownId]);

    const table = useReactTable({
        data: filteredData,
        columns,
        state: { globalFilter },
        onGlobalFilterChange: setGlobalFilter,
        getCoreRowModel: getCoreRowModel(),
        getSortedRowModel: getSortedRowModel(),
        getFilteredRowModel: getFilteredRowModel(),
        getPaginationRowModel: getPaginationRowModel(),
        initialState: {
            pagination: { pageSize: 15 },
            sorting: [{ id: 'paymentDate', desc: true }]
        }
    });

    return (
        <div className="admin-container-gf">
            <section className="table-card-gf">
                <div className="table-controls-gf">
                    <h2 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '700', color: 'var(--gf-text-primary)' }}>Payments</h2>
                    <div className="controls-left-gf">
                        <div className="search-box-gf">
                            <i className="fas fa-search"></i>
                            <input
                                type="text"
                                placeholder="Search by student, course, or reference..."
                                value={globalFilter ?? ''}
                                onChange={e => setGlobalFilter(e.target.value)}
                            />
                        </div>
                        <div className="filter-tabs-gf">
                            {['All', 'Paid', 'Pending', 'Failed'].map(tab => (
                                <button
                                    key={tab}
                                    className={"tab-btn-gf " + (activeTab === tab ? 'active' : '')}
                                    onClick={() => setActiveTab(tab)}
                                >
                                    {tab}
                                </button>
                            ))}
                        </div>
                    </div>
                    <div className="controls-right-gf">
                        <button className="btn-secondary-gf" onClick={() => window.print()}>
                            <i className="fas fa-download"></i> Export
                        </button>
                    </div>
                </div>

                <div style={{ overflowX: 'auto' }}>
                    <table className="payments-table-gf">
                        <thead>
                            {table.getHeaderGroups().map(headerGroup => (
                                <tr key={headerGroup.id}>
                                    {headerGroup.headers.map(header => (
                                        <th key={header.id} onClick={header.column.getToggleSortingHandler()} style={{ cursor: header.column.getCanSort() ? 'pointer' : 'default' }}>
                                            {flexRender(header.column.columnDef.header, header.getContext())}
                                            {header.column.getIsSorted() ? (header.column.getIsSorted() === 'asc' ? ' ↑' : ' ↓') : ''}
                                        </th>
                                    ))}
                                </tr>
                            ))}
                        </thead>
                        <tbody>
                            {table.getRowModel().rows.length > 0 ? (
                                table.getRowModel().rows.map(row => (
                                    <tr key={row.id}>
                                        {row.getVisibleCells().map(cell => (
                                            <td key={cell.id}>
                                                {flexRender(cell.column.columnDef.cell, cell.getContext())}
                                            </td>
                                        ))}
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan={columns.length}>
                                        <div className="empty-state-gf">
                                            <i className="fas fa-wallet"></i>
                                            <p>No payments found matching your criteria.</p>
                                        </div>
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>

                <div className="pagination-bar-gf">
                    <span className="pagination-info">
                        Showing page {table.getState().pagination.pageIndex + 1} of {table.getPageCount() || 1}
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
            </section>
        </div>
    );
};

const container = document.getElementById('admin-react-root');
if (container) {
    const root = ReactDOM.createRoot(container);
    root.render(<AdminPaymentsApp />);
}
