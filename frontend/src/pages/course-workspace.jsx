const { useState, useEffect, useMemo, useRef } = window.React || React;
const ReactDOM = window.ReactDOM;

const workspaceData = window.__WORKSPACE_DATA__ || {};

function classFor(value) {
    return String(value || 'general').toLowerCase().replace(/[^a-z0-9]+/g, '-');
}

function previewUrl(material) {
    return `${workspaceData.contextPath}/instructor/materials-preview?action=preview&id=${material.materialId}&fragment=true`;
}

function downloadUrl(material) {
    return `${workspaceData.contextPath}/instructor/materials-preview?action=download&id=${material.materialId}`;
}

// Simple Error Boundary
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
                            Diagnostic: Backend data is missing! Clean and Build the project, then restart Tomcat.
                        </p>
                    )}
                </div>
            );
        }
        return this.props.children;
    }
}

function WorkspaceApp() {
    const validTabs = ['overview', 'materials', 'assessments', 'students'];
    const [activeTab, setActiveTab] = useState(
        validTabs.includes(window.location.hash.replace('#', ''))
            ? window.location.hash.replace('#', '')
            : 'overview'
    );
    const [previewMaterial, setPreviewMaterial] = useState(null);

    useEffect(() => {
        if (window.location.hash.replace('#', '') !== activeTab) {
            window.location.hash = activeTab;
        }
    }, [activeTab]);

    useEffect(() => {
        const onHashChange = () => {
            const next = window.location.hash.replace('#', '');
            if (validTabs.includes(next)) setActiveTab(next);
        };
        window.addEventListener('hashchange', onHashChange);
        return () => window.removeEventListener('hashchange', onHashChange);
    }, []);

    return (
        <div className="workspace-react-container iwm-workspace">
            <nav className="ins_ws_nav_bar iwm-tabs" aria-label="Workspace navigation">
                {[
                    { id: 'overview',     icon: 'fa-table-columns',   label: 'Overview' },
                    { id: 'materials',    icon: 'fa-book-open',        label: 'Materials' },
                    { id: 'assessments', icon: 'fa-clipboard-check',  label: 'Assessments' },
                    { id: 'students',    icon: 'fa-users',             label: 'Students' },
                ].map(tab => (
                    <button
                        key={tab.id}
                        type="button"
                        className={`ins_ws_nav_link ${activeTab === tab.id ? 'active' : ''}`}
                        onClick={() => setActiveTab(tab.id)}
                    >
                        <i className={`fas ${tab.icon}`}></i>
                        <span>{tab.label}</span>
                    </button>
                ))}
            </nav>

            <section className="ws-tab-content active iwm-panel" key={activeTab}>
                <ErrorBoundary>
                    {activeTab === 'overview'     && <OverviewTab />}
                    {activeTab === 'materials'    && <MaterialsTab onPreview={setPreviewMaterial} />}
                    {activeTab === 'assessments'  && <AssessmentsTab />}
                    {activeTab === 'students'     && <StudentsTab />}
                </ErrorBoundary>
            </section>

            {previewMaterial && (
                <MaterialPreviewModal
                    material={previewMaterial}
                    onClose={() => setPreviewMaterial(null)}
                />
            )}
        </div>
    );
}

/* ── Overview ─────────────────────────────────────────────── */
function OverviewTab() {
    const course       = workspaceData.course       || {};
    const stats        = workspaceData.stats        || {};
    const materials    = workspaceData.materials    || [];
    const assessments  = workspaceData.assessments  || [];
    const enrollments  = workspaceData.enrollments  || [];
    const avgProgress  = enrollments.length
        ? Math.round(enrollments.reduce((s, e) => s + Number(e.progress || 0), 0) / enrollments.length)
        : 0;
    const recentMaterials = materials.slice(0, 3);

    return (
        <div className="iwm-overview-grid">
            {/* Course description card */}
            <article className="iwm-course-card">
                <div className="iwm-card-head">
                    <div>
                        <span className="iwm-eyebrow">Course workspace</span>
                        <h3>Course Description</h3>
                    </div>
                    <span className={`status-badge status-${classFor(course.status)}`}>
                        {course.status || 'Draft'}
                    </span>
                </div>
                <p className="iwm-course-desc">
                    {course.description || 'Add a course description to help students understand the learning path.'}
                </p>
                <div className="ins_ws_meta_chips">
                    <span className="ins_ws_meta_pill"><i className="fas fa-tag"></i> {course.category || 'General'}</span>
                    <span className="ins_ws_meta_pill"><i className="fas fa-chart-line"></i> {course.level || 'Self-paced'}</span>
                    <span className="ins_ws_meta_pill"><i className="far fa-clock"></i> {course.displayDuration || 'Flexible'}</span>
                </div>
            </article>

            {/* Side stack */}
            <aside className="iwm-side-stack">
                <article className="iwm-hero-tile">
                    <span>Instructor Workspace</span>
                    <strong>{course.courseName || 'Course'}</strong>
                </article>

                <article className="iwm-activity-card">
                    <div className="iwm-card-head">
                        <h3>Recent Activity</h3>
                    </div>
                    {recentMaterials.length
                        ? recentMaterials.map(material => (
                            <div className="iwm-activity-item" key={material.materialId}>
                                <span className={`iwm-dot type-${classFor(material.type)}`}></span>
                                <div>
                                    <strong>{material.title}</strong>
                                    <small>{material.type || 'Material'} material available</small>
                                </div>
                            </div>
                        ))
                        : <p className="iwm-muted-copy">Upload materials to start building the course timeline.</p>
                    }
                </article>
            </aside>

            {/* KPI strip */}
            <section className="ins_ws_kpi_grid iwm-kpi-row">
                <KpiCard icon="fa-users"       tone="students"    value={stats.totalStudents || 0}      label="Total Enrolled" />
                <KpiCard icon="fa-check-circle" tone="materials"  value={`${avgProgress}%`}             label="Average Progress" />
                <KpiCard icon="fa-book-open"   tone="assessments" value={stats.publishedMaterials || 0} label="Materials" />
                <KpiCard icon="fa-inbox"       tone="pending"     value={stats.pendingGrading || 0}     label="Needs Grading" />
            </section>

            {/* Trend sparkbar */}
            <article className="iwm-trend-card">
                <div className="iwm-card-head">
                    <div>
                        <span className="iwm-eyebrow">Performance</span>
                        <h3>Course Performance Trend</h3>
                    </div>
                    <span className="iwm-muted-copy">{assessments.length} assessments</span>
                </div>
                <div className="iwm-bars">
                    {[34, 42, 55, 66, 74, Math.max(12, avgProgress || 84)].map((value, i) => (
                        <span key={i} style={{ height: `${value}%` }} className={i === 5 ? 'active' : ''}></span>
                    ))}
                </div>
            </article>

            {/* Quick actions */}
            <article className="ins_ws_actions_sec iwm-actions-card">
                <h3 className="ins_ws_actions_title">Quick Actions</h3>
                <div className="ins_ws_actions_grid">
                    <button type="button" onClick={() => window.openUploadModal()} className="ins_ws_action_btn">
                        <i className="fas fa-upload"></i> <span>Upload Material</span>
                    </button>
                    <a href={`${workspaceData.assessmentBaseUrl}&view=editor`} className="ins_ws_action_btn">
                        <i className="fas fa-plus"></i> <span>Create Assessment</span>
                    </a>
                    <a href={`${workspaceData.assessmentBaseUrl}&view=submissions`} className="ins_ws_action_btn">
                        <i className="fas fa-inbox"></i> <span>Review Submissions</span>
                    </a>
                </div>
            </article>
        </div>
    );
}

function KpiCard({ icon, tone, value, label }) {
    return (
        <article className="ins_ws_kpi_card iwm-kpi-card">
            <div className={`ins_ws_kpi_icon ${tone}`}><i className={`fas ${icon}`}></i></div>
            <div className="ins_ws_kpi_data">
                <strong>{value}</strong>
                <span>{label}</span>
            </div>
        </article>
    );
}

/* ── Materials ────────────────────────────────────────────── */
function MaterialsTab({ onPreview }) {
    const [materials, setMaterials] = useState(workspaceData.materials || []);
    const [query,     setQuery]     = useState('');
    const [saving,    setSaving]    = useState(false);
    const [changed,   setChanged]   = useState(false);
    const dragFrom = useRef(null);
    const dragTo   = useRef(null);

    const filtered = useMemo(() => {
        const needle = query.trim().toLowerCase();
        if (!needle) return materials;
        return materials.filter(m =>
            `${m.title || ''} ${m.description || ''} ${m.type || ''}`.toLowerCase().includes(needle)
        );
    }, [materials, query]);

    function reorder() {
        if (dragFrom.current === null || dragTo.current === null || dragFrom.current === dragTo.current) return;
        const next = [...materials];
        const item = next.splice(dragFrom.current, 1)[0];
        next.splice(dragTo.current, 0, item);
        dragFrom.current = null;
        dragTo.current   = null;
        setMaterials(next);
        setChanged(true);
    }

    function saveOrder() {
        setSaving(true);
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = `${workspaceData.contextPath}/instructor/content-organizer`;
        [['action', 'saveContentOrder'], ['courseId', workspaceData.course.courseId]].forEach(([name, val]) => {
            const input = document.createElement('input');
            input.type  = 'hidden';
            input.name  = name;
            input.value = val;
            form.appendChild(input);
        });
        materials.forEach(mat => {
            const input = document.createElement('input');
            input.type  = 'hidden';
            input.name  = 'materialIds[]';
            input.value = mat.materialId;
            form.appendChild(input);
        });
        document.body.appendChild(form);
        form.submit();
    }

    return (
        <div className="iwm-management">
            <div className="iwm-toolbar">
                <div>
                    <span className="iwm-eyebrow">Materials Management</span>
                    <h3>{materials.length} curriculum items</h3>
                </div>
                <div className="iwm-toolbar-actions">
                    <label className="iwm-search">
                        <i className="fas fa-search"></i>
                        <input
                            type="text"
                            value={query}
                            onChange={e => setQuery(e.target.value)}
                            placeholder="Search materials..."
                        />
                    </label>
                    <button type="button" className="ws-btn ws-btn-primary" onClick={() => window.openUploadModal()}>
                        <i className="fas fa-upload"></i> Upload
                    </button>
                    <button
                        type="button"
                        className={`ws-btn ${changed ? 'ws-btn-primary' : 'ws-btn-secondary'}`}
                        disabled={!changed || saving}
                        onClick={saveOrder}
                    >
                        {saving
                            ? <><i className="fas fa-spinner fa-spin"></i> Saving</>
                            : <><i className="fas fa-save"></i> Save Order</>
                        }
                    </button>
                </div>
            </div>

            {filtered.length ? (
                <div className="pm-materials-list iwm-material-list">
                    {filtered.map((material, visibleIndex) => {
                        const index = materials.findIndex(m => m.materialId === material.materialId);
                        const type  = classFor(material.type);
                        const icon  = type === 'video'    ? 'fa-file-video'
                                    : type === 'slides'   ? 'fa-file-powerpoint'
                                    : type === 'link'     ? 'fa-link'
                                    : type === 'youtube'  ? 'fa-play-circle'
                                    : 'fa-file-pdf';
                        return (
                            <article
                                key={material.materialId}
                                className="pm-material-card iwm-material-card"
                                draggable
                                onDragStart={e => { dragFrom.current = index; e.currentTarget.classList.add('dragging'); }}
                                onDragEnter={e => { dragTo.current   = index; e.currentTarget.classList.add('drag-over'); }}
                                onDragLeave={e => e.currentTarget.classList.remove('drag-over')}
                                onDragEnd={e => {
                                    e.currentTarget.classList.remove('dragging');
                                    document.querySelectorAll('.pm-material-card').forEach(n => n.classList.remove('drag-over'));
                                    reorder();
                                }}
                                onDragOver={e => e.preventDefault()}
                            >
                                <div className="pm-material-drag-handle" title="Drag to reorder">
                                    <i className="fas fa-grip-vertical"></i>
                                </div>
                                <div className={`pm-material-type-icon type-${type}`}>
                                    <i className={`fas ${icon}`}></i>
                                </div>
                                <div className="pm-material-details">
                                    <div className="pm-material-title-row">
                                        <span className="pm-material-title">{material.title}</span>
                                        <span className={`type-badge badge-${type}`}>{material.type || 'Material'}</span>
                                    </div>
                                    <p className="pm-material-desc">{material.description || 'No description provided.'}</p>
                                    <div className="pm-material-meta">
                                        <span className="pm-material-meta-item">#{visibleIndex + 1}</span>
                                        <span className="pm-material-meta-item">{material.filePath ? 'Preview ready' : 'Missing source'}</span>
                                    </div>
                                </div>
                                <div className="pm-material-actions">
                                    {material.filePath && (
                                        <button
                                            type="button"
                                            className="ws-btn ws-btn-secondary ws-btn-xs"
                                            onClick={() => onPreview(material)}
                                        >
                                            <i className="fas fa-eye"></i> Preview
                                        </button>
                                    )}
                                    <button
                                        type="button"
                                        className="ws-btn ws-btn-secondary ws-btn-xs"
                                        onClick={() => {
                                            const btn = document.createElement('button');
                                            btn.dataset.materialId  = material.materialId;
                                            btn.dataset.title       = material.title || '';
                                            btn.dataset.type        = material.type  || 'PDF';
                                            btn.dataset.order       = material.order || '';
                                            btn.dataset.description = material.description || '';
                                            btn.dataset.externalUrl = material.filePath || '';
                                            window.openEditMaterialModal(btn, false);
                                        }}
                                    >
                                        <i className="fas fa-edit"></i> Edit
                                    </button>
                                    <form
                                        action={`${workspaceData.contextPath}/instructor/materials`}
                                        method="get"
                                        onSubmit={e => { if (!window.confirm('Delete this material?')) e.preventDefault(); }}
                                        style={{ display: 'inline' }}
                                    >
                                        <input type="hidden" name="action"   value="delete" />
                                        <input type="hidden" name="id"       value={material.materialId} />
                                        <input type="hidden" name="courseId" value={workspaceData.course.courseId} />
                                        <input type="hidden" name="source"   value="workspace" />
                                        <button type="submit" className="ws-btn ws-btn-danger ws-btn-xs">
                                            <i className="fas fa-trash"></i> Delete
                                        </button>
                                    </form>
                                </div>
                            </article>
                        );
                    })}
                </div>
            ) : (
                <div className="empty-state-box workspace-empty-box iwm-empty">
                    <i className="fas fa-folder-open"></i>
                    <h3>No matching materials</h3>
                    <p>Upload a file, video, link, or YouTube resource to build the curriculum.</p>
                </div>
            )}
        </div>
    );
}

/* ── Assessments ─────────────────────────────────────────── */
function AssessmentsTab() {
    const assessments    = workspaceData.assessments || [];
    const averageAttempts = assessments.length
        ? Math.round(assessments.reduce((s, a) => s + Number(a.attempts || 0), 0) / assessments.length)
        : 0;

    return (
        <div className="iwm-assessments">
            <div className="iwm-toolbar">
                <div>
                    <span className="iwm-eyebrow">Assessment Creator</span>
                    <h3>Assessment workflow</h3>
                </div>
                <div className="iwm-toolbar-actions">
                    <a href={`${workspaceData.assessmentBaseUrl}&view=editor`} className="ws-btn ws-btn-primary">
                        <i className="fas fa-plus"></i> Create New Assessment
                    </a>
                    <a href={`${workspaceData.assessmentBaseUrl}&view=submissions`} className="ws-btn ws-btn-secondary">
                        <i className="fas fa-inbox"></i> Submissions
                    </a>
                </div>
            </div>

            <div className="iwm-assessment-summary">
                <article>
                    <span>Active filters</span>
                    <strong>All assessments</strong>
                    <small>Quizzes, exams, assignments</small>
                </article>
                <article>
                    <span>Average attempts</span>
                    <strong>{averageAttempts}</strong>
                    <small>Across visible items</small>
                </article>
                <article className="is-primary">
                    <span>Workflow</span>
                    <strong>Create → Questions → Publish</strong>
                    <small>Structured setup path</small>
                </article>
            </div>

            {assessments.length ? (
                <div className="iwm-assessment-list">
                    {assessments.map(assessment => {
                        const type = classFor(assessment.type);
                        const icon = type === 'assignment' ? 'fa-file-signature' : 'fa-stopwatch';
                        return (
                            <article key={assessment.id} className="assessment-card iwm-assessment-card">
                                <div className="assessment-card-header">
                                    <div className={`assessment-icon-circle ${type}`}>
                                        <i className={`fas ${icon}`}></i>
                                    </div>
                                    <span className={`type-badge badge-${type}`}>{assessment.type}</span>
                                </div>
                                <h4 className="assessment-title">{assessment.title}</h4>
                                <p className="assessment-desc">{assessment.instructions || 'No instructions added yet.'}</p>
                                <div className="assessment-stats-row">
                                    <div className="stat-bubble">
                                        <span className="stat-num">{assessment.attempts || 0}</span>
                                        <span className="stat-lbl">Submissions</span>
                                    </div>
                                    <div className="stat-bubble">
                                        <span className="stat-num">{assessment.duration ? `${assessment.duration}m` : '-'}</span>
                                        <span className="stat-lbl">Duration</span>
                                    </div>
                                    <div className="stat-bubble">
                                        <span className="stat-num">{assessment.points || '-'}</span>
                                        <span className="stat-lbl">Marks</span>
                                    </div>
                                </div>
                                <div className="assessment-actions">
                                    <a href={`${workspaceData.assessmentBaseUrl}&view=editor&assessmentId=${assessment.id}`}
                                       className="ws-btn ws-btn-secondary ws-btn-sm">
                                        <i className="fas fa-sliders"></i> Settings
                                    </a>
                                    <a href={`${workspaceData.assessmentBaseUrl}&view=questions&assessmentId=${assessment.id}`}
                                       className="ws-btn ws-btn-secondary ws-btn-sm">
                                        <i className="fas fa-list-check"></i> Questions
                                    </a>
                                    <a href={`${workspaceData.assessmentBaseUrl}&view=submissions&assessmentId=${assessment.id}`}
                                       className="ws-btn ws-btn-primary ws-btn-sm">
                                        <i className="fas fa-inbox"></i> Grade
                                    </a>
                                </div>
                            </article>
                        );
                    })}
                </div>
            ) : (
                <div className="empty-state-box workspace-empty-box iwm-empty">
                    <i className="fas fa-clipboard-list"></i>
                    <h3>No assessments yet</h3>
                    <p>Create a quiz, exam, or assignment and then add questions.</p>
                </div>
            )}
        </div>
    );
}

/* ── Students ─────────────────────────────────────────────── */
function StudentsTab() {
    const enrollments = workspaceData.enrollments || [];
    const [query, setQuery] = useState('');
    const filtered = enrollments.filter(s =>
        `${s.name || ''} ${s.email || ''}`.toLowerCase().includes(query.toLowerCase())
    );

    return (
        <div className="iwm-management">
            <div className="iwm-toolbar">
                <div>
                    <span className="iwm-eyebrow">Student roster</span>
                    <h3>{enrollments.length} enrolled students</h3>
                </div>
                <label className="iwm-search">
                    <i className="fas fa-search"></i>
                    <input
                        type="text"
                        value={query}
                        onChange={e => setQuery(e.target.value)}
                        placeholder="Search students..."
                    />
                </label>
            </div>

            {filtered.length ? (
                <div className="premium-table-wrapper iwm-table-wrap">
                    <table className="premium-table">
                        <thead>
                            <tr>
                                <th>Student</th>
                                <th>Status</th>
                                <th>Progress</th>
                                <th>Registration</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filtered.map(student => (
                                <tr key={student.id}>
                                    <td>
                                        <div className="iwm-student-cell">
                                            <span className="iwm-avatar">{(student.name || '?').charAt(0)}</span>
                                            <div>
                                                <strong>{student.name}</strong>
                                                <small>{student.email}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span className={`status-badge status-${classFor(student.status)}`}>
                                            {student.status || 'Active'}
                                        </span>
                                    </td>
                                    <td>
                                        <div className="iwm-progress">
                                            <span style={{ width: `${Number(student.progress || 0)}%` }}></span>
                                            <small>{student.progress || 0}%</small>
                                        </div>
                                    </td>
                                    <td><span className="iwm-muted-copy">{student.date || '-'}</span></td>
                                    <td>
                                        <a href={`${workspaceData.assessmentBaseUrl}&view=submissions`}
                                           className="ws-btn ws-btn-secondary ws-btn-xs">
                                            <i className="fas fa-chart-bar"></i> Grades
                                        </a>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            ) : (
                <div className="empty-state-box workspace-empty-box iwm-empty">
                    <i className="fas fa-user-slash"></i>
                    <h3>No students found</h3>
                    <p>Students will appear here once they enroll.</p>
                </div>
            )}
        </div>
    );
}

/* ── Material Preview Modal ─────────────────────────────── */
function MaterialPreviewModal({ material, onClose }) {
    const url = previewUrl(material);

    // Close on Escape key
    useEffect(() => {
        const handler = e => { if (e.key === 'Escape') onClose(); };
        document.addEventListener('keydown', handler);
        return () => document.removeEventListener('keydown', handler);
    }, [onClose]);

    return (
        <div className="iwm-preview-overlay" role="dialog" aria-modal="true" onClick={e => { if (e.target === e.currentTarget) onClose(); }}>
            <div className="iwm-preview-modal">
                <header className="iwm-preview-head">
                    <div>
                        <span className={`type-badge badge-${classFor(material.type)}`}>{material.type || 'Material'}</span>
                        <h3>{material.title}</h3>
                    </div>
                    <div className="iwm-preview-actions">
                        <a href={url.replace('&fragment=true', '')} target="_blank" rel="noopener noreferrer" className="ws-btn ws-btn-secondary ws-btn-sm">
                            <i className="fas fa-up-right-from-square"></i> Open Full Page
                        </a>
                        <a href={downloadUrl(material)} target="_blank" rel="noopener noreferrer" className="ws-btn ws-btn-secondary ws-btn-sm">
                            <i className="fas fa-download"></i> Download
                        </a>
                        <button type="button" className="ws-btn ws-btn-secondary ws-btn-sm" onClick={onClose}>
                            <i className="fas fa-xmark"></i> Close
                        </button>
                    </div>
                </header>
                <iframe className="iwm-preview-frame" src={url} title={`Preview ${material.title}`}></iframe>
            </div>
        </div>
    );
}

/* ── Bootstrap ───────────────────────────────────────────── */
const rootNode = document.getElementById('workspace-react-root');
if (rootNode) {
    window.ReactDOM.createRoot(rootNode).render(<WorkspaceApp />);
}
