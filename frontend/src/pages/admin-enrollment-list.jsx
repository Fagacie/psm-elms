const { useState, useEffect, useMemo, useCallback, useRef } = window.React || React;
const ReactDOM = window.ReactDOM;

    
    const { 
        useReactTable, getCoreRowModel, getPaginationRowModel, getSortedRowModel, flexRender 
    } = window.ReactTable || {};

    function EnrollmentsControl() {
        const [enrollments, setEnrollments] = useState(window.__ENROLLMENTS__ || []);
        const [globalFilter, setGlobalFilter] = useState('');
        const [statusFilter, setStatusFilter] = useState('All');
        const [courseFilter, setCourseFilter] = useState('All');
        
        // Pagination state
        const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
        
        // Sorting state
        const [sorting, setSorting] = useState([{ id: 'enrollmentId', desc: true }]);

        // Dropdown tracking
        const [activeDropdownId, setActiveDropdownId] = useState(null);

        // Drawer states
        const [drawerOpen, setDrawerOpen] = useState(false);
        const [drawerMode, setDrawerMode] = useState('view'); // 'view', 'expiry'
        const [selectedEnrollment, setSelectedEnrollment] = useState(null);

        // Revoke Confirmation Modal states
        const [revokeModalOpen, setRevokeModalOpen] = useState(false);
        const [enrollmentToRevoke, setEnrollmentToRevoke] = useState(null);

        // Expiry Form fields
        const [expiryOverride, setExpiryOverride] = useState('');

        const [isSubmitting, setIsSubmitting] = useState(false);

        useEffect(() => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        }, [enrollments, pagination, globalFilter, statusFilter, courseFilter, sorting, drawerOpen, revokeModalOpen]);

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

        // Calculate unique courses for dropdown filter
        const uniqueCourses = React.useMemo(() => {
            const set = new Set();
            enrollments.forEach(e => {
                if (e.courseName) set.add(e.courseName);
            });
            return Array.from(set).sort();
        }, [enrollments]);

        // Metrics calculations
        const totalCount = enrollments.length;
        const activeCount = enrollments.filter(e => e.status === 'Active' || e.status === 'Enrolled').length;
        const completedCount = enrollments.filter(e => e.status === 'Completed').length;
        const revokedCount = enrollments.filter(e => e.status === 'Cancelled' || e.status === 'Revoked').length;
        const totalRevenue = enrollments
            .filter(e => e.paymentStatus === 'Paid' || e.paymentStatus === 'Paid' || e.paymentStatus === 'success')
            .reduce((sum, e) => sum + Number(e.coursePrice || 0), 0);

        // Custom filtering based on status filters, course filters, and search queries
        const filteredData = React.useMemo(() => {
            return enrollments.filter(item => {
                // Status filter
                if (statusFilter !== 'All') {
                    if (statusFilter === 'Active' && item.status !== 'Active' && item.status !== 'Enrolled') return false;
                    if (statusFilter === 'Completed' && item.status !== 'Completed') return false;
                    if (statusFilter === 'Revoked' && item.status !== 'Cancelled' && item.status !== 'Revoked') return false;
                }
                
                // Course filter
                if (courseFilter !== 'All' && item.courseName !== courseFilter) return false;
                
                // Search query filter
                if (globalFilter.trim()) {
                    const query = globalFilter.toLowerCase();
                    return (
                        item.studentName.toLowerCase().includes(query) ||
                        item.studentEmail.toLowerCase().includes(query) ||
                        item.courseName.toLowerCase().includes(query) ||
                        item.paymentRef.toLowerCase().includes(query)
                    );
                }
                return true;
            });
        }, [enrollments, globalFilter, statusFilter, courseFilter]);

        // Open drawer in View details mode
        const handleOpenView = (enrollment) => {
            setSelectedEnrollment(enrollment);
            setDrawerMode('view');
            setDrawerOpen(true);
        };

        // Open drawer in Manage Expiry mode
        const handleOpenExpiry = (enrollment) => {
            setSelectedEnrollment(enrollment);
            setExpiryOverride(enrollment.expiryDateOverride || '');
            setDrawerMode('expiry');
            setDrawerOpen(true);
        };

        // Open revoke confirmation modal
        const handleOpenRevoke = (enrollment) => {
            setEnrollmentToRevoke(enrollment);
            setRevokeModalOpen(true);
        };

        // Execute asynchronous Access Revocation
        const handleRevokeConfirm = () => {
            if (!enrollmentToRevoke) return;
            setIsSubmitting(true);
            fetch(window.__CONTEXT_PATH__ + '/admin/enrollments?action=revoke&id=' + enrollmentToRevoke.enrollmentId)
                .then(() => window.location.reload())
                .catch(err => {
                    console.error("Revoke access error:", err);
                    setIsSubmitting(false);
                });
        };

        // Setup headless React Table column cells
        const columns = React.useMemo(() => [
            {
                accessorKey: 'enrollmentId',
                header: 'ID',
                cell: info => <span style={{ fontWeight: '500' }}>{"#" + info.getValue()}</span>
            },
            {
                accessorKey: 'studentName',
                header: 'Student',
                cell: info => {
                    const row = info.row.original;
                    const initials = row.studentName.split(' ').map(n => n[0]).join('').substring(0, 2);
                    return (
                        <div className="student-cell-gf">
                            <div className="student-avatar-gf">{initials}</div>
                            <div className="student-meta-gf">
                                <span className="student-name-gf">{row.studentName}</span>
                                <span className="student-email-gf">{row.studentEmail}</span>
                            </div>
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
                        <div className="course-cell-gf">
                            <span className="course-title-gf">{row.courseName}</span>
                            <span className="course-category-gf">Instructor: {row.instructorName}</span>
                        </div>
                    );
                }
            },
            {
                accessorKey: 'enrollmentDate',
                header: 'Enrollment Date',
                cell: info => {
                    const val = info.getValue();
                    if (!val) return 'N/A';
                    const d = new Date(val);
                    return <span>{d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>;
                }
            },
            {
                accessorKey: 'progress',
                header: 'Status & Progress',
                cell: info => {
                    const row = info.row.original;
                    const prog = info.getValue() || 0;
                    
                    // Resolve status class
                    let badgeClass = 'badge-pending-gf';
                    let displayStatus = row.status;
                    if (row.status === 'Active' || row.status === 'Enrolled') {
                        badgeClass = 'badge-active-gf';
                        displayStatus = 'Active';
                    } else if (row.status === 'Completed') {
                        badgeClass = 'badge-completed-gf';
                    } else if (row.status === 'Cancelled' || row.status === 'Revoked') {
                        badgeClass = 'badge-cancelled-gf';
                        displayStatus = 'Revoked';
                    }

                    return (
                        <div className="progress-container-gf">
                            <div className="progress-header-gf">
                                <span className={"badge-gf " + badgeClass}>{displayStatus}</span>
                                <span className="progress-val-gf">{prog}%</span>
                            </div>
                            <div className="progress-track-gf">
                                <div className="progress-bar-gf" style={{ width: prog + '%' }}></div>
                            </div>
                        </div>
                    );
                }
            },
            {
                id: 'actions',
                header: '',
                cell: info => {
                    const row = info.row.original;
                    const isOpen = activeDropdownId === row.enrollmentId;
                    return (
                        <div className="actions-cell-gf">
                            <button 
                                className="actions-btn-gf"
                                onClick={(e) => {
                                    e.stopPropagation();
                                    setActiveDropdownId(isOpen ? null : row.enrollmentId);
                                }}
                            >
                                <i className="fas fa-ellipsis-v"></i>
                            </button>
                            {isOpen && (
                                <div className="actions-dropdown-gf">
                                    <button className="dropdown-item-gf" onClick={() => handleOpenView(row)}>
                                        <i className="fas fa-user-graduate"></i> View Progress
                                    </button>
                                    <button className="dropdown-item-gf" onClick={() => handleOpenExpiry(row)}>
                                        <i className="fas fa-calendar-alt"></i> Manage Expiry
                                    </button>
                                    {row.status !== 'Cancelled' && row.status !== 'Revoked' && (
                                        <button className="dropdown-item-gf danger" onClick={() => handleOpenRevoke(row)}>
                                            <i className="fas fa-user-slash"></i> Revoke Access
                                        </button>
                                    )}
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
                {/* Data Table Shell */}
                <section className="table-card-gf">
                    <div className="table-controls-gf">
                        <h2 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '700', color: 'var(--gf-text-primary)' }}>Enrollments</h2>
                        <div className="controls-left-gf">
                            {/* Search Box */}
                            <div className="search-box-gf">
                                <i className="fas fa-search"></i>
                                <input 
                                    type="text" 
                                    placeholder="Search student or course..." 
                                    value={globalFilter}
                                    onChange={e => setGlobalFilter(e.target.value)}
                                />
                            </div>

                            {/* Course dropdown filter */}
                            <select 
                                className="select-filter-gf" 
                                value={courseFilter}
                                onChange={e => setCourseFilter(e.target.value)}
                            >
                                <option value="All">All Courses</option>
                                {uniqueCourses.map(c => (
                                    <option key={c} value={c}>{c}</option>
                                ))}
                            </select>

                            {/* Status Tabs toggles */}
                            <div className="filter-tabs-gf">
                                <button className={"tab-btn-gf " + (statusFilter === 'All' ? 'active' : '')} onClick={() => setStatusFilter('All')}>All</button>
                                <button className={"tab-btn-gf " + (statusFilter === 'Active' ? 'active' : '')} onClick={() => setStatusFilter('Active')}>Active</button>
                                <button className={"tab-btn-gf " + (statusFilter === 'Completed' ? 'active' : '')} onClick={() => setStatusFilter('Completed')}>Completed</button>
                                <button className={"tab-btn-gf " + (statusFilter === 'Revoked' ? 'active' : '')} onClick={() => setStatusFilter('Revoked')}>Revoked</button>
                            </div>
                        </div>
                    </div>

                    {/* Table Render */}
                    {table && table.getRowModel && table.getRowModel().rows.length === 0 ? (
                        <div className="empty-state-gf">
                            <i className="fas fa-folder-open"></i>
                            <p>No enrollment records matching requested criteria.</p>
                        </div>
                    ) : (
                        <div style={{ overflowX: 'auto' }}>
                            <table className="enrollments-table-gf">
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
                                    {table && table.getRowModel().rows.map(row => (
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

                {/* Right Slide-out Drawer */}
                {drawerOpen && selectedEnrollment && (
                    <div className="drawer-overlay-gf" onClick={() => setDrawerOpen(false)}>
                        <div className="drawer-container-gf" onClick={e => e.stopPropagation()}>
                            <header className="drawer-header-gf">
                                <h2>
                                    {drawerMode === 'view' ? 'Student Learning Progress' : 'Manage Access Expiration'}
                                </h2>
                                <button className="drawer-close-gf" onClick={() => setDrawerOpen(false)}>×</button>
                            </header>

                            <div className="drawer-body-gf">
                                {drawerMode === 'view' ? (
                                    /* Enrollment detailed view */
                                    <div className="details-section-gf">
                                        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.4rem', borderBottom: '1px solid var(--gf-border)', paddingBottom: '1.5rem', marginBottom: '0.5rem' }}>
                                            <h3 style={{ margin: 0, fontSize: '1.2rem', fontWeight: '700', color: 'var(--gf-text-primary)' }}>{selectedEnrollment.studentName}</h3>
                                            <span style={{ fontSize: '0.85rem', color: 'var(--gf-text-muted)' }}>{selectedEnrollment.studentEmail}</span>
                                        </div>

                                        <div className="details-grid-gf">
                                            <div className="details-item-gf">
                                                <span>Enrollment ID</span>
                                                <strong>{"#" + selectedEnrollment.enrollmentId}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Payment Status</span>
                                                <strong style={{ color: selectedEnrollment.paymentStatus === 'Paid' ? '#10b981' : '#b45309' }}>
                                                    {selectedEnrollment.paymentStatus}
                                                </strong>
                                            </div>
                                            <div className="details-item-gf span-2">
                                                <span>Course Enrolled</span>
                                                <strong>{selectedEnrollment.courseName}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Enrolled On</span>
                                                <strong>{selectedEnrollment.enrollmentDate || '-'}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Access Duration</span>
                                                <strong>{selectedEnrollment.displayDuration}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Access Status</span>
                                                <strong>{selectedEnrollment.status}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Progress / Completion</span>
                                                <strong>{selectedEnrollment.progress}% ({selectedEnrollment.completionStatus})</strong>
                                            </div>
                                            <div className="details-item-gf span-2">
                                                <span>Gateway Reference</span>
                                                <strong style={{ fontFamily: 'monospace', fontSize: '0.85rem' }}>{selectedEnrollment.paymentRef}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Syllabus End Date</span>
                                                <strong>{selectedEnrollment.effectiveEndDate || '-'}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Days Remaining</span>
                                                <strong style={{ color: selectedEnrollment.daysRemaining >= 0 && selectedEnrollment.daysRemaining <= 7 ? 'var(--gf-red)' : 'inherit' }}>
                                                    {selectedEnrollment.daysRemaining >= 0 ? selectedEnrollment.daysRemaining + ' Days' : 'Expired'}
                                                </strong>
                                            </div>
                                        </div>
                                    </div>
                                ) : (
                                    /* Manage Course Expiry form */
                                    <div className="details-section-gf">
                                        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.4rem', marginBottom: '1rem' }}>
                                            <h3 style={{ margin: 0, fontSize: '1.2rem', fontWeight: '700', color: 'var(--gf-text-primary)' }}>{selectedEnrollment.courseName}</h3>
                                            <span style={{ fontSize: '0.85rem', color: 'var(--gf-text-muted)' }}>Student: {selectedEnrollment.studentName} ({selectedEnrollment.studentEmail})</span>
                                        </div>

                                        <form id="expiryForm" className="expiry-form-gf" method="post" action={window.__CONTEXT_PATH__ + "/admin/enrollments"}>
                                            <p>Set a custom learning hub access end date for this learner. Leave empty to clear overrides and fall back to the standard course duration parameters.</p>
                                            <input type="hidden" name="enrollmentId" value={selectedEnrollment.enrollmentId} />
                                            <div className="form-group-gf">
                                                <label>Expiry Date Override</label>
                                                <input 
                                                    type="date" 
                                                    id="expiryDateOverride" 
                                                    name="expiryDateOverride"
                                                    value={expiryOverride}
                                                    onChange={e => setExpiryOverride(e.target.value)}
                                                />
                                            </div>
                                        </form>
                                    </div>
                                )}
                            </div>

                            <footer className="drawer-footer-gf">
                                <button className="btn-secondary-gf" onClick={() => setDrawerOpen(false)}>
                                    {drawerMode === 'view' ? 'Close' : 'Cancel'}
                                </button>
                                {drawerMode === 'expiry' && (
                                    <button 
                                        type="submit" 
                                        form="expiryForm" 
                                        className="btn-primary-gf"
                                        disabled={isSubmitting}
                                    >
                                        Save Expiry Date
                                    </button>
                                )}
                            </footer>
                        </div>
                    </div>
                )}

                {/* Centered Revocation Confirmation Modal */}
                {revokeModalOpen && enrollmentToRevoke && (
                    <div className="modal-overlay-gf" onClick={() => setRevokeModalOpen(false)}>
                        <div className="modal-box-gf" onClick={e => e.stopPropagation()}>
                            <h3 className="modal-title-gf">
                                <i className="fas fa-exclamation-triangle"></i> Revoke Course Access
                            </h3>
                            <div className="modal-body-gf">
                                <p>
                                    Are you absolutely sure you want to revoke <strong>{enrollmentToRevoke.studentName}</strong>'s access to the course <strong>{enrollmentToRevoke.courseName}</strong>?
                                </p>
                                <p style={{ marginTop: '0.5rem', fontSize: '0.85rem', color: 'var(--gf-red)', lineHeight: '1.4' }}>
                                    This will cancel the enrollment, disable learning hub content navigation, and suspend their material progression status.
                                </p>
                            </div>
                            <footer className="modal-footer-gf">
                                <button className="btn-secondary-gf" onClick={() => setRevokeModalOpen(false)} disabled={isSubmitting}>
                                    Cancel
                                </button>
                                <button className="btn-danger-gf" onClick={handleRevokeConfirm} disabled={isSubmitting}>
                                    {isSubmitting ? 'Revoking...' : 'Confirm Revocation'}
                                </button>
                            </footer>
                        </div>
                    </div>
                )}
            </div>
        );
    }

    const container = document.getElementById('admin-react-root');
    const root = ReactDOM.createRoot(container);
    root.render(<EnrollmentsControl />);
