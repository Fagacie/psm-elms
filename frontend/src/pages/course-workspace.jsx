const { useState, useEffect, useMemo, useCallback, useRef } = window.React || React;
const ReactDOM = window.ReactDOM;



function CourseWorkspaceApp() {
    const [activeTab, setActiveTab] = useState(window.location.hash.replace('#', '') || 'overview');
    
    // Sync tab with URL and listen for browser back/forward buttons
    useEffect(() => {
        // Only update hash if it's different from current
        const currentHash = window.location.hash.replace('#', '');
        if (currentHash !== activeTab) {
            window.location.hash = activeTab;
        }
    }, [activeTab]);

    useEffect(() => {
        const handleHashChange = () => {
            const hashTab = window.location.hash.replace('#', '');
            if (hashTab && ['overview', 'materials', 'assessments', 'students'].includes(hashTab)) {
                setActiveTab(hashTab);
            }
        };
        window.addEventListener('hashchange', handleHashChange);
        return () => window.removeEventListener('hashchange', handleHashChange);
    }, []);
    return (
        <div className="workspace-react-container" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
            {/* Premium Tab Navigation */}
            <nav className="ins_ws_nav_bar" aria-label="Workspace navigation">
                {[
                    { id: 'overview', icon: 'fa-pie-chart', label: 'Overview' },
                    { id: 'materials', icon: 'fa-book-open', label: 'Materials' },
                    { id: 'assessments', icon: 'fa-check-square', label: 'Assessments' },
                    { id: 'students', icon: 'fa-users', label: 'Students' }
                ].map(tab => (
                    <button 
                        key={tab.id}
                        className={`ins_ws_nav_link ${activeTab === tab.id ? 'active' : ''}`}
                        onClick={() => setActiveTab(tab.id)}
                        style={{ background: 'none', border: 'none', cursor: 'pointer' }}
                    >
                        <i className={`fas ${tab.icon}`}></i> {tab.label}
                    </button>
                ))}
            </nav>

            {/* Content Canvas Area with animation */}
            <div className="ws-tab-content active" style={{ animation: 'wsFadeInUp 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards' }} key={activeTab}>
                <ErrorBoundary>
                    {activeTab === 'overview' && <OverviewTab />}
                    {activeTab === 'materials' && <MaterialsTab />}
                    {activeTab === 'assessments' && <AssessmentsTab />}
                    {activeTab === 'students' && <StudentsTab />}
                </ErrorBoundary>
            </div>
        </div>
    );
}

// Global data objects exposed from JSP
const workspaceData = window.__WORKSPACE_DATA__ || {};

// Simple Error Boundary to catch render errors instead of unmounting the whole app
class ErrorBoundary extends React.Component {
    constructor(props) {
        super(props);
        this.state = { hasError: false, error: null };
    }
    static getDerivedStateFromError(error) {
        return { hasError: true, error };
    }
    render() {
        if (this.state.hasError) {
            return (
                <div style={{ padding: '20px', background: '#fee2e2', color: '#991b1b', borderRadius: '8px', marginTop: '20px' }}>
                    <h3 style={{ marginTop: 0 }}><i className="fas fa-exclamation-triangle"></i> Render Error</h3>
                    <p>Something went wrong displaying this tab.</p>
                    <pre style={{ background: '#f87171', padding: '10px', color: 'white', borderRadius: '4px', overflowX: 'auto' }}>
                        {this.state.error?.toString()}
                    </pre>
                    {(!workspaceData.course || !workspaceData.course.courseId) && (
                        <p style={{ fontWeight: 'bold', marginTop: '10px' }}>
                            Diagnostic: Backend data is missing! You need to Clean and Build your project in NetBeans and restart Tomcat so the new Java Servlet class is loaded!
                        </p>
                    )}
                </div>
            );
        }
        return this.props.children;
    }
}

function OverviewTab() {
    const { course, stats } = workspaceData;
    return (
        <div className="overview-dashboard-container">
            <section className="overview-top-section">
                <div className="ins_ws_meta_chips">
                    <div className="ins_ws_meta_pill"><i className="fas fa-tag"></i> <span>Category: {course.category || 'General'}</span></div>
                    <div className="ins_ws_meta_pill"><i className="fas fa-chart-bar"></i> <span>Level: {course.level}</span></div>
                    <div className="ins_ws_meta_pill"><i className="far fa-clock"></i> <span>Duration: {course.displayDuration}</span></div>
                </div>
                {course.description && <p className="ins_ws_desc">{course.description}</p>}
            </section>

            <section className="ins_ws_kpi_grid" style={{ marginTop: '30px' }}>
                <KpiCard icon="fas fa-users" colorClass="students" value={stats.totalStudents} label="Total Enrolled Students" />
                <KpiCard icon="fas fa-book-open" colorClass="materials" value={stats.publishedMaterials} label="Materials Uploaded" />
                <KpiCard icon="fas fa-clipboard-list" colorClass="assessments" value={stats.assessmentCount} label="Assessments Created" />
                <KpiCard icon="fas fa-file-text" colorClass="pending" value={stats.pendingGrading} label="Pending Submissions" />
            </section>

            <section className="ins_ws_actions_sec">
                <h3 className="ins_ws_actions_title">Quick Actions</h3>
                <div className="ins_ws_actions_grid">
                    <button onClick={() => window.openUploadModal()} className="ins_ws_action_btn">
                        <i className="fas fa-upload"></i> <span>Upload New Material</span>
                    </button>
                    <a href={workspaceData.assessmentBaseUrl + '&view=editor'} className="ins_ws_action_btn">
                        <i className="fas fa-plus"></i> <span>Create Assessment</span>
                    </a>
                </div>
            </section>
        </div>
    );
}

function KpiCard({ icon, colorClass, value, label }) {
    return (
        <div className="ins_ws_kpi_card">
            <div className={`ins_ws_kpi_icon ${colorClass}`}><i className={icon}></i></div>
            <div className="ins_ws_kpi_data">
                <strong style={{ color: colorClass === 'pending' && value > 0 ? '#ef4444' : 'inherit' }}>{value}</strong>
                <span>{label}</span>
            </div>
        </div>
    );
}

function MaterialsTab() {
    const [materials, setMaterials] = useState(workspaceData.materials || []);
    const [isSavingOrder, setIsSavingOrder] = useState(false);
    const [hasOrderChanged, setHasOrderChanged] = useState(false);

    // Simple Drag and Drop state
    const dragItem = useRef(null);
    const dragOverItem = useRef(null);

    const handleSort = () => {
        if (dragItem.current === null || dragOverItem.current === null) return;
        let _materials = [...materials];
        const draggedItemContent = _materials.splice(dragItem.current, 1)[0];
        _materials.splice(dragOverItem.current, 0, draggedItemContent);
        dragItem.current = null;
        dragOverItem.current = null;
        setMaterials(_materials);
        setHasOrderChanged(true);
    };

    const saveOrder = () => {
        setIsSavingOrder(true);
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = workspaceData.contextPath + '/instructor/content-organizer';
        
        const actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'saveContentOrder';
        form.appendChild(actionInput);

        const courseIdInput = document.createElement('input');
        courseIdInput.type = 'hidden';
        courseIdInput.name = 'courseId';
        courseIdInput.value = workspaceData.course.courseId;
        form.appendChild(courseIdInput);

        materials.forEach(mat => {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'materialIds[]';
            input.value = mat.materialId;
            form.appendChild(input);
        });

        document.body.appendChild(form);
        form.submit();
    };

    return (
        <div className="section-card" style={{ padding: '0', background: 'transparent', border: 'none', boxShadow: 'none' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
                <h3 className="section-title" style={{ margin: 0, fontWeight: 800, fontSize: '1.25rem' }}>Course Curriculum Materials ({materials.length} items)</h3>
                <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
                    <button className="ws-btn ws-btn-primary" onClick={() => window.openUploadModal()}>
                        <i className="fas fa-upload"></i> Upload Material
                    </button>
                    <button className={`ws-btn ${hasOrderChanged ? 'ws-btn-primary' : 'ws-btn-secondary'}`} onClick={saveOrder} disabled={!hasOrderChanged || isSavingOrder} style={{ opacity: (!hasOrderChanged || isSavingOrder) ? 0.5 : 1 }}>
                        {isSavingOrder ? <><i className="fas fa-spinner fa-spin"></i> Saving...</> : <><i className="fas fa-save"></i> Save Order</>}
                    </button>
                </div>
            </div>

            {materials.length === 0 ? (
                <div className="empty-state-box workspace-empty-box" style={{ padding: '40px', textAlign: 'center' }}>
                    <i className="fas fa-folder-open" style={{ fontSize: '3rem', color: '#94a3b8', marginBottom: '16px' }}></i>
                    <p style={{ fontWeight: 600, marginBottom: '12px' }}>No active materials uploaded for this course yet.</p>
                    <button className="ws-btn ws-btn-primary ws-btn-sm" onClick={() => window.openUploadModal()}>Upload First Material</button>
                </div>
            ) : (
                <div className="pm-materials-list">
                    {materials.map((mat, index) => {
                        const typeClass = mat.type.toLowerCase();
                        let typeIcon = 'fa-file-alt';
                        if (typeClass === 'pdf') typeIcon = 'fa-file-pdf';
                        if (typeClass === 'video') typeIcon = 'fa-file-video';
                        if (typeClass === 'slides') typeIcon = 'fa-file-powerpoint';
                        if (typeClass === 'link') typeIcon = 'fa-link';
                        if (typeClass === 'youtube') typeIcon = 'fa-play-circle';

                        return (
                            <div 
                                key={mat.materialId}
                                className="pm-material-card"
                                draggable
                                onDragStart={(e) => { dragItem.current = index; e.currentTarget.classList.add('dragging'); }}
                                onDragEnter={(e) => { dragOverItem.current = index; e.currentTarget.classList.add('drag-over'); }}
                                onDragLeave={(e) => e.currentTarget.classList.remove('drag-over')}
                                onDragEnd={(e) => { e.currentTarget.classList.remove('dragging'); handleSort(); document.querySelectorAll('.pm-material-card').forEach(c => c.classList.remove('drag-over')); }}
                                onDragOver={(e) => e.preventDefault()}
                            >
                                <div className="pm-material-drag-handle" title="Drag to reorder"><i className="fas fa-grip-vertical"></i></div>
                                <div className={`pm-material-type-icon type-${typeClass}`}><i className={`fas ${typeIcon}`}></i></div>
                                <div className="pm-material-details">
                                    <div className="pm-material-title-row">
                                        <span className="pm-material-title">{mat.title}</span>
                                        <span className={`type-badge badge-${typeClass}`}>{mat.type}</span>
                                    </div>
                                    <p className="pm-material-desc">{mat.description || 'No description provided.'}</p>
                                </div>
                                <div className="pm-material-actions">
                                    {mat.filePath && (
                                        <a href={`${workspaceData.contextPath}/instructor/materials-preview?action=preview&id=${mat.materialId}`} target="_blank" className="ws-btn ws-btn-secondary ws-btn-xs" style={{ padding: '6px 10px' }}>
                                            <i className="fas fa-eye"></i> Preview
                                        </a>
                                    )}
                                    <button 
                                        className="ws-btn ws-btn-secondary ws-btn-xs" 
                                        style={{ padding: '6px 10px' }}
                                        onClick={(e) => {
                                            // Create an artificial DOM element to pass to the existing global openEditMaterialModal
                                            const btn = document.createElement('button');
                                            btn.dataset.materialId = mat.materialId;
                                            btn.dataset.title = mat.title;
                                            btn.dataset.type = mat.type;
                                            btn.dataset.order = mat.order;
                                            btn.dataset.description = mat.description;
                                            btn.dataset.externalUrl = mat.filePath;
                                            window.openEditMaterialModal(btn, false);
                                        }}
                                    >
                                        <i className="fas fa-edit"></i> Edit
                                    </button>
                                    <form action={`${workspaceData.contextPath}/instructor/materials`} method="get" style={{ display: 'inline' }} onSubmit={(e) => { if(!window.confirm('Delete this material?')) e.preventDefault(); }}>
                                        <input type="hidden" name="action" value="delete" />
                                        <input type="hidden" name="id" value={mat.materialId} />
                                        <input type="hidden" name="courseId" value={workspaceData.course.courseId} />
                                        <input type="hidden" name="source" value="workspace" />
                                        <button type="submit" className="ws-btn ws-btn-danger ws-btn-xs" style={{ padding: '6px 10px', fontWeight: 600 }}>
                                            <i className="fas fa-trash"></i> Delete
                                        </button>
                                    </form>
                                </div>
                            </div>
                        );
                    })}
                </div>
            )}
        </div>
    );
}

function AssessmentsTab() {
    const assessments = workspaceData.assessments || [];
    return (
        <div className="section-card" style={{ padding: '16px', borderRadius: '12px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '16px' }}>
                <h3 className="section-title" style={{ margin: 0, fontWeight: 800, fontSize: '1.25rem' }}>Course Assessments Library ({assessments.length} items)</h3>
                <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
                    <a href={`${workspaceData.assessmentBaseUrl}&view=editor`} className="ws-btn ws-btn-primary"><i className="fas fa-plus"></i> Create Assessment</a>
                    <a href={workspaceData.assessmentBaseUrl} className="ws-btn ws-btn-secondary"><i className="fas fa-clipboard-list"></i> Assessments Hub</a>
                </div>
            </div>

            {assessments.length === 0 ? (
                <div className="empty-state-box workspace-empty-box" style={{ padding: '40px', textAlign: 'center' }}>
                    <i className="fas fa-clipboard-list" style={{ fontSize: '3rem', color: '#94a3b8', marginBottom: '16px' }}></i>
                    <p style={{ fontWeight: 600, marginBottom: '12px' }}>No assessments created for this course yet.</p>
                </div>
            ) : (
                <div className="assessments-grid">
                    {assessments.map(ass => (
                        <div key={ass.id} className="assessment-card">
                            <div className="assessment-card-header">
                                <div className={`assessment-icon-circle ${ass.type.toLowerCase()}`}>
                                    <i className={`fas ${ass.type === 'Assignment' ? 'fa-file-signature' : 'fa-stopwatch'}`}></i>
                                </div>
                                <span className={`type-badge badge-${ass.type.toLowerCase()}`}>{ass.type}</span>
                            </div>
                            <h4 className="assessment-title" style={{ margin: 0, fontWeight: 700 }}>{ass.title}</h4>
                            <p className="assessment-desc">{ass.instructions}</p>
                            <div className="assessment-stats-row">
                                <div className="stat-bubble"><span className="stat-num">{ass.attempts}</span><span className="stat-lbl">Attempts</span></div>
                                <div className="stat-bubble"><span className="stat-num">{ass.duration ? `${ass.duration}m` : '-'}</span><span className="stat-lbl">Time Limit</span></div>
                                <div className="stat-bubble"><span className="stat-num">{ass.points ? ass.points : '-'}</span><span className="stat-lbl">Points</span></div>
                            </div>
                            <div className="assessment-actions">
                                <a href={`${workspaceData.assessmentBaseUrl}&view=editor&assessmentId=${ass.id}`} className="ws-btn ws-btn-secondary ws-btn-sm" style={{ flex: 1 }}><i className="fas fa-edit"></i> Edit</a>
                                <a href={`${workspaceData.assessmentBaseUrl}&view=submissions&assessmentId=${ass.id}`} className="ws-btn ws-btn-primary ws-btn-sm" style={{ flex: 1 }}><i className="fas fa-inbox"></i> Grades</a>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}

function StudentsTab() {
    const enrollments = workspaceData.enrollments || [];
    const [query, setQuery] = useState('');

    const filtered = enrollments.filter(e => e.name.toLowerCase().includes(query.toLowerCase()) || e.email.toLowerCase().includes(query.toLowerCase()));

    return (
        <div className="section-card" style={{ padding: '16px', borderRadius: '12px' }}>
            <div className="student-search-bar">
                <h3 className="section-title" style={{ margin: 0, fontWeight: 800, fontSize: '1.25rem' }}>Active Roster ({enrollments.length} students)</h3>
                <div className="search-input-wrap">
                    <i className="fas fa-search"></i>
                    <input type="text" placeholder="Filter roster by student name or email..." value={query} onChange={e => setQuery(e.target.value)} />
                </div>
            </div>

            {enrollments.length === 0 ? (
                <div className="empty-state-box workspace-empty-box" style={{ padding: '40px', textAlign: 'center' }}>
                    <i className="fas fa-user-slash" style={{ fontSize: '3rem', color: '#94a3b8', marginBottom: '16px' }}></i>
                    <p style={{ fontWeight: 600 }}>No students are enrolled in this course yet.</p>
                </div>
            ) : (
                <div className="premium-table-wrapper">
                    <table className="premium-table">
                        <thead>
                            <tr>
                                <th>Student Details</th>
                                <th style={{ width: '140px' }}>Status</th>
                                <th style={{ width: '200px' }}>Progress Tracking</th>
                                <th style={{ width: '150px' }}>Registration</th>
                                <th style={{ width: '160px', textAlign: 'right' }}>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filtered.map(enr => (
                                <tr key={enr.id} className="student-table-row">
                                    <td>
                                        <div className="material-name-block">
                                            <div style={{ width: '28px', height: '28px', borderRadius: '50%', background: 'var(--ws-primary-glow)', color: 'var(--ws-primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 700, fontSize: '0.8rem', flexShrink: 0 }}>
                                                {enr.name.charAt(0)}
                                            </div>
                                            <div>
                                                <strong style={{ fontSize: '0.95rem', color: 'var(--ins-heading, #0f172a)' }}>{enr.name}</strong>
                                                <p style={{ fontSize: '0.8rem', color: 'var(--ins-muted, #64748b)', margin: '2px 0 0' }}>{enr.email}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span className={`status-badge status-${enr.status.toLowerCase()}`}>{enr.status}</span></td>
                                    <td>
                                        <div className="ws-student-progress" style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                                            <div className="ws-progress-bar" style={{ width: '100%', height: '6px', background: 'rgba(99, 102, 241, 0.08)', borderRadius: '4px', overflow: 'hidden' }}>
                                                <div className="ws-progress-fill" style={{ width: `${enr.progress}%`, height: '100%', background: 'var(--ws-primary)', borderRadius: '4px' }}></div>
                                            </div>
                                            <span className="ws-progress-text" style={{ fontSize: '0.78rem', fontWeight: 700, color: 'var(--ins-muted)' }}>{enr.progress}% Completed</span>
                                        </div>
                                    </td>
                                    <td style={{ color: 'var(--ins-muted)', fontSize: '0.85rem' }}><i className="far fa-calendar-alt" style={{ marginRight: '6px' }}></i> {enr.date}</td>
                                    <td style={{ textAlign: 'right', display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                                        <a href={`${workspaceData.assessmentBaseUrl}&view=submissions`} className="ws-btn ws-btn-secondary ws-btn-xs" title="View Grades"><i className="fas fa-chart-bar"></i> Grades</a>
                                        {enr.progress === 100 && (
                                            <a href={`${workspaceData.contextPath}/certificate/verify?enrollmentId=${enr.id}`} className="ws-btn ws-btn-xs" title="Issue/View Certificate" target="_blank" style={{ background: 'rgba(16, 185, 129, 0.1)', border: '1px solid rgba(16, 185, 129, 0.2)', color: '#10b981', fontWeight: 600 }}><i className="fas fa-certificate"></i> Cert</a>
                                        )}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
}

// Render the application
const rootNode = document.getElementById('workspace-react-root');
if (rootNode) {
    const root = ReactDOM.createRoot(rootNode);
    root.render(<CourseWorkspaceApp />);
}

        
