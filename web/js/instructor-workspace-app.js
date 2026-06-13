import React, { useState, useEffect, useMemo, useRef } from 'react';
import ReactDOM from 'react-dom/client';

// We rely on Framer Motion and Lucide globally.
const MotionDiv = window.Motion && window.Motion.motion ? window.Motion.motion.div : (props) => <div {...props}>{props.children}</div>;

export default function InstructorWorkspace() {
    // 1. Core State
    const [activeTab, setActiveTab] = useState(window.location.hash.replace('#', '') || 'overview');
    
    // Data from JSP
    const [course] = useState(window.__WORKSPACE_DATA__?.course || {});
    const [materials, setMaterials] = useState(window.__WORKSPACE_DATA__?.materials || []);
    const [assessments] = useState(window.__WORKSPACE_DATA__?.assessments || []);
    const [enrollments] = useState(window.__WORKSPACE_DATA__?.enrollments || []);
    const [stats] = useState(window.__WORKSPACE_DATA__?.stats || {});

    // Sync tab with URL hash
    useEffect(() => {
        window.location.hash = activeTab;
    }, [activeTab]);

    return (
        <div className="course-workspace-react-app">
            {/* Minimalist Page Header */}
            <header className="ws-page-head-slim">
                <div className="ws-head-left-slim">
                    <h2>{course.courseName} <span className={`status-badge status-${course.status?.toLowerCase()}`}>{course.status}</span></h2>
                </div>
                <div className="overview-meta-chips">
                    <span className="meta-badge-chip"><i className="fas fa-layer-group"></i> {course.category || 'General'}</span>
                    <span className="meta-badge-chip"><i className="far fa-clock"></i> {course.displayDuration}</span>
                </div>
            </header>

            {/* Premium Tab Navigation */}
            <nav className="ins_ws_nav_bar">
                {['overview', 'curriculum', 'assessments', 'roster'].map(tab => (
                    <button 
                        key={tab}
                        className={`ins_ws_nav_link ${activeTab === tab ? 'active' : ''}`}
                        onClick={() => setActiveTab(tab)}
                        style={{ background: 'none', border: 'none', cursor: 'pointer', borderBottom: '2px solid transparent', paddingBottom: '12px' }}
                    >
                        {tab === 'overview' && <i className="fas fa-table-columns"></i>}
                        {tab === 'curriculum' && <i className="fas fa-book-open"></i>}
                        {tab === 'assessments' && <i className="fas fa-clipboard-check"></i>}
                        {tab === 'roster' && <i className="fas fa-users"></i>}
                        {tab.charAt(0).toUpperCase() + tab.slice(1)}
                    </button>
                ))}
            </nav>

            {/* Content Canvas */}
            <main className="ws-content-canvas">
                {activeTab === 'overview' && <OverviewTab course={course} stats={stats} />}
                {activeTab === 'curriculum' && <CurriculumTab course={course} materials={materials} setMaterials={setMaterials} />}
                {activeTab === 'assessments' && <AssessmentsTab course={course} assessments={assessments} />}
                {activeTab === 'roster' && <RosterTab course={course} enrollments={enrollments} />}
            </main>
        </div>
    );
}

// ==========================================
// OVERVIEW TAB
// ==========================================
function OverviewTab({ course, stats }) {
    return (
        <MotionDiv initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="ws-tab-panel">
            <p className="overview-course-desc">{course.description || 'No description provided.'}</p>
            
            <div className="overview-kpis-grid-modern" style={{ marginTop: '30px' }}>
                <KpiCard icon="fas fa-users" colorClass="students" value={stats.totalStudents || 0} label="Total Students" />
                <KpiCard icon="fas fa-book-open" colorClass="materials" value={stats.publishedMaterials || 0} label="Published Materials" />
                <KpiCard icon="fas fa-clipboard-check" colorClass="assessments" value={stats.assessmentCount || 0} label="Active Assessments" />
                <KpiCard icon="fas fa-clock" colorClass="pending" value={stats.pendingGrading || 0} label="Pending Grading" />
            </div>

            <div className="overview-actions-section">
                <h3>Quick Actions</h3>
                <div className="overview-actions-grid">
                    <a href={`?action=materials&courseId=${course.courseId}`} className="action-pill-btn">
                        <i className="fas fa-plus"></i> Add Material
                    </a>
                    <a href={`?action=assessments&courseId=${course.courseId}`} className="action-pill-btn">
                        <i className="fas fa-plus"></i> Create Assessment
                    </a>
                </div>
            </div>
        </MotionDiv>
    );
}

function KpiCard({ icon, colorClass, value, label }) {
    return (
        <div className="kpi-card-modern">
            <div className={`kpi-icon-wrapper ${colorClass}`}><i className={icon}></i></div>
            <div className="kpi-data-wrapper">
                <strong>{value}</strong>
                <span>{label}</span>
            </div>
        </div>
    );
}

// ==========================================
// CURRICULUM TAB (Materials)
// ==========================================
function CurriculumTab({ course, materials, setMaterials }) {
    // We will build a smooth drag and drop UI here
    return (
        <MotionDiv initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="ws-tab-panel">
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
                <h3>Course Curriculum</h3>
                <button className="action-pill-btn" style={{ background: '#6366f1', color: 'white', borderColor: '#6366f1' }}>
                    <i className="fas fa-plus"></i> Upload Material
                </button>
            </div>

            <div className="premium-table-wrapper">
                <table className="premium-table">
                    <thead>
                        <tr>
                            <th>Content Module</th>
                            <th>Type</th>
                            <th>Status</th>
                            <th style={{ textAlign: 'right' }}>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {materials.length === 0 ? (
                            <tr><td colSpan="4" style={{ textAlign: 'center', padding: '40px', color: '#94a3b8' }}>No materials uploaded yet.</td></tr>
                        ) : materials.map((mat, index) => (
                            <tr key={mat.materialId}>
                                <td>
                                    <div className="material-name-block">
                                        <div className={`material-avatar type-${mat.contentType?.toLowerCase() || 'link'}`}>
                                            <i className="fas fa-file"></i>
                                        </div>
                                        <div>
                                            <div className="material-title">{mat.title}</div>
                                            <div className="material-desc">Order: {mat.contentOrder}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span className={`type-badge badge-${mat.contentType?.toLowerCase() || 'link'}`}>{mat.contentType}</span>
                                </td>
                                <td>
                                    <span className={`status-badge status-${mat.status?.toLowerCase()}`}>{mat.status}</span>
                                </td>
                                <td style={{ textAlign: 'right' }}>
                                    <button className="btn-icon"><i className="fas fa-pen"></i></button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </MotionDiv>
    );
}

// ==========================================
// ASSESSMENTS TAB
// ==========================================
function AssessmentsTab({ course, assessments }) {
    return (
        <MotionDiv initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="ws-tab-panel">
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
                <h3>Assessments</h3>
                <button className="action-pill-btn" style={{ background: '#6366f1', color: 'white', borderColor: '#6366f1' }}>
                    <i className="fas fa-plus"></i> New Assessment
                </button>
            </div>
            
            <div className="assessments-grid">
                {assessments.map(ass => (
                    <div className="assessment-card" key={ass.assessmentId}>
                        <div className="assessment-card-header">
                            <div className={`assessment-icon-circle ${ass.assessmentType?.toLowerCase()}`}>
                                <i className="fas fa-clipboard-list"></i>
                            </div>
                            <span className="status-badge status-published">{ass.status}</span>
                        </div>
                        <h4 className="assessment-title">{ass.title}</h4>
                        <div className="assessment-actions">
                            <a href={`?action=assessment-submissions&assessmentId=${ass.assessmentId}`} className="action-pill-btn" style={{ fontSize: '0.75rem', padding: '6px 12px' }}>Submissions</a>
                        </div>
                    </div>
                ))}
            </div>
        </MotionDiv>
    );
}

// ==========================================
// ROSTER TAB
// ==========================================
function RosterTab({ course, enrollments }) {
    return (
        <MotionDiv initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="ws-tab-panel">
            <h3>Student Roster</h3>
            <div className="premium-table-wrapper">
                <table className="premium-table">
                    <thead>
                        <tr>
                            <th>Student Name</th>
                            <th>Enrollment Date</th>
                            <th>Status</th>
                            <th>Progress</th>
                        </tr>
                    </thead>
                    <tbody>
                        {enrollments.map(enr => (
                            <tr key={enr.enrollmentId}>
                                <td>{enr.studentName}</td>
                                <td>{enr.enrollmentDate}</td>
                                <td><span className={`status-badge status-${enr.status?.toLowerCase()}`}>{enr.status}</span></td>
                                <td>
                                    <div style={{ width: '100px', height: '6px', background: '#e2e8f0', borderRadius: '4px', overflow: 'hidden' }}>
                                        <div style={{ width: `${enr.progress || 0}%`, height: '100%', background: '#10b981' }}></div>
                                    </div>
                                    <span style={{ fontSize: '0.75rem', color: '#64748b' }}>{enr.progress || 0}%</span>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </MotionDiv>
    );
}
