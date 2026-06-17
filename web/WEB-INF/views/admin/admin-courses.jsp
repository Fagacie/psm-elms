<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Catalog Management - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-courses-gf.css?v=1.0">
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
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Courses"/>
    <jsp:param name="pageSubtitle" value="Review approvals and keep the course catalog organized"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- JSTL Success/Error Notification Banners -->
    <div style="max-width: 1400px; margin: 2rem auto 0 auto; padding: 0 2rem;">
        <c:if test="${param.success == 'approved'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Course approved successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'rejected'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Course pending request rejected.
            </div>
        </c:if>
        <c:if test="${param.success == 'created'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Course created and published successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'edited'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Course catalog specifications updated successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'assigned'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Instructor assigned to course catalog successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'archived'}">
            <div class="alert-gf alert-success-gf" style="background-color: #f1f5f9; color: #475569; border: 1px solid rgba(71, 85, 105, 0.15); margin-bottom: 1.5rem;">
                <i class="fas fa-archive"></i> Course archived and hidden from student catalog.
            </div>
        </c:if>
        <c:if test="${param.success == 'restored'}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> Course restored back to active student catalog successfully.
            </div>
        </c:if>
        <c:if test="${param.success == 'deleted'}">
            <div class="alert-gf alert-success-gf" style="background-color: #fef2f2; color: #b91c1c; border: 1px solid rgba(185, 28, 28, 0.15); margin-bottom: 1.5rem;">
                <i class="fas fa-trash-alt"></i> Course has been completely hard-deleted from database records.
            </div>
        </c:if>
        <c:if test="${param.error != null}">
            <div class="alert-gf alert-error-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-exclamation-circle"></i> An operation error occurred. Please verify and try again.
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
    List<Course> coursesList = (List<Course>) request.getAttribute("courses");
    List<User> instructorsList = (List<User>) request.getAttribute("instructors");
    java.util.Map<Integer, Integer> enrollmentCountsMap = (java.util.Map<Integer, Integer>) request.getAttribute("enrollmentCounts");

    // Map active instructor details
    java.util.Map<Integer, String> instructorLabels = new java.util.HashMap<>();
    if (instructorsList != null) {
        for (User ins : instructorsList) {
            instructorLabels.put(ins.getUserId(), ins.getFullName());
        }
    }

    org.json.JSONArray coursesJsonArray = new org.json.JSONArray();
    if (coursesList != null) {
        for (Course c : coursesList) {
            org.json.JSONObject courseObj = new org.json.JSONObject();
            int cid = c.getCourseId();
            courseObj.put("courseId", cid);
            courseObj.put("courseName", c.getCourseName() != null ? c.getCourseName() : "");
            courseObj.put("description", c.getDescription() != null ? c.getDescription() : "");
            courseObj.put("category", c.getCategory() != null ? c.getCategory() : "Uncategorized");
            courseObj.put("duration", c.getDuration() != null ? c.getDuration() : 0);
            courseObj.put("level", c.getLevel() != null ? c.getLevel() : "Beginner");
            courseObj.put("courseFee", c.getCourseFee() != null ? c.getCourseFee() : java.math.BigDecimal.ZERO);
            courseObj.put("status", c.getStatus() != null ? c.getStatus() : "Pending");
            courseObj.put("courseBanner", c.getCourseBanner() != null ? c.getCourseBanner() : "");
            courseObj.put("createdBy", c.getCreatedBy() != null ? c.getCreatedBy() : 0);
            courseObj.put("createdAt", c.getCreatedAt() != null ? c.getCreatedAt().toString() : "");
            courseObj.put("enrolledCount", (enrollmentCountsMap != null && enrollmentCountsMap.get(cid) != null) ? enrollmentCountsMap.get(cid) : 0);
            
            // Instructor label
            String insLabel = "Unassigned";
            if (c.getCreatedBy() != null && instructorLabels.containsKey(c.getCreatedBy())) {
                insLabel = instructorLabels.get(c.getCreatedBy());
            }
            courseObj.put("instructorLabel", insLabel);
            
            coursesJsonArray.put(courseObj);
        }
    }

    org.json.JSONArray instructorsJsonArray = new org.json.JSONArray();
    if (instructorsList != null) {
        for (User ins : instructorsList) {
            org.json.JSONObject insObj = new org.json.JSONObject();
            insObj.put("userId", ins.getUserId());
            insObj.put("fullName", ins.getFullName() != null ? ins.getFullName() : "");
            insObj.put("email", ins.getEmail() != null ? ins.getEmail() : "");
            instructorsJsonArray.put(insObj);
        }
    }

    pageContext.setAttribute("serializedCoursesJson", coursesJsonArray.toString());
    pageContext.setAttribute("serializedInstructorsJson", instructorsJsonArray.toString());
%>

<!-- Serialize JSTL variables securely to window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__COURSES__ = ${serializedCoursesJson};
    window.__INSTRUCTORS__ = ${serializedInstructorsJson};
</script>

<!-- Interactive React Command Center Application -->
<script type="text/babel" data-presets="react">
    const { useState, useEffect } = React;
    const { 
        useReactTable, getCoreRowModel, getPaginationRowModel, getSortedRowModel, flexRender 
    } = window.ReactTable || {};

    // Custom Autocomplete Searchable Select component for Instructor Assignments
    function AutocompleteSelect({ options, value, onChange, placeholder }) {
        const [search, setSearch] = useState('');
        const [isOpen, setIsOpen] = useState(false);
        const containerRef = React.useRef(null);
        
        // Find active label for current value
        const selectedOption = options.find(opt => opt.userId === Number(value));
        const displayLabel = selectedOption ? selectedOption.fullName : '';

        // Filter options based on search query
        const filteredOptions = options.filter(opt => 
            opt.fullName.toLowerCase().includes(search.toLowerCase()) ||
            opt.email.toLowerCase().includes(search.toLowerCase())
        );

        useEffect(() => {
            const handleOutsideClick = (e) => {
                if (containerRef.current && !containerRef.current.contains(e.target)) {
                    setIsOpen(false);
                }
            };
            document.addEventListener('mousedown', handleOutsideClick);
            return () => document.removeEventListener('mousedown', handleOutsideClick);
        }, []);

        return (
            <div ref={containerRef} className="autocomplete-container-gf">
                <div className="autocomplete-input-wrapper-gf">
                    <input 
                        type="text" 
                        placeholder={placeholder || "Search and select instructor..."}
                        value={isOpen ? search : displayLabel}
                        onFocus={() => {
                            setSearch('');
                            setIsOpen(true);
                        }}
                        onChange={e => setSearch(e.target.value)}
                    />
                    <i className="fas fa-chevron-down" onClick={() => setIsOpen(!isOpen)} style={{ cursor: 'pointer' }}></i>
                </div>
                {isOpen && (
                    <div className="autocomplete-dropdown-gf">
                        <button 
                            type="button"
                            className={"autocomplete-item-gf " + (!value ? "selected" : "")}
                            onClick={() => {
                                onChange('');
                                setIsOpen(false);
                            }}
                        >
                            No instructor assigned
                        </button>
                        {filteredOptions.map(opt => (
                            <button
                                key={opt.userId}
                                type="button"
                                className={"autocomplete-item-gf " + (Number(value) === opt.userId ? "selected" : "")}
                                onClick={() => {
                                    onChange(opt.userId);
                                    setIsOpen(false);
                                }}
                            >
                                {opt.fullName}
                                <span className="subtext">{opt.email}</span>
                            </button>
                        ))}
                        {filteredOptions.length === 0 && (
                            <div style={{ padding: '0.6rem 1rem', fontSize: '0.85rem', color: 'var(--gf-text-muted)', textAlign: 'center' }}>
                                No active instructors found.
                            </div>
                        )}
                    </div>
                )}
            </div>
        );
    }

    const GRADIENTS = [
        'linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%)',
        'linear-gradient(135deg, #0ea5e9 0%, #2563eb 100%)',
        'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
        'linear-gradient(135deg, #10b981 0%, #059669 100%)',
        'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)'
    ];

    function CoursesManagement() {
        const [courses, setCourses] = useState(window.__COURSES__ || []);
        const [instructors] = useState(window.__INSTRUCTORS__ || []);
        const [globalFilter, setGlobalFilter] = useState('');
        const [statusFilter, setStatusFilter] = useState('All');
        
        // Pagination state
        const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
        
        // Sorting state
        const [sorting, setSorting] = useState([{ id: 'courseId', desc: true }]);

        // Dropdown tracking
        const [activeDropdownCourseId, setActiveDropdownCourseId] = useState(null);

        // Drawer states
        const [drawerOpen, setDrawerOpen] = useState(false);
        const [drawerMode, setDrawerMode] = useState('create'); // 'create', 'edit', 'view'
        const [selectedCourse, setSelectedCourse] = useState(null);

        // Delete Confirmation Modal states
        const [deleteModalOpen, setDeleteModalOpen] = useState(false);
        const [courseToDelete, setCourseToDelete] = useState(null);

        // Form Fields State
        const [courseName, setCourseName] = useState('');
        const [category, setCategory] = useState('');
        const [description, setDescription] = useState('');
        const [level, setLevel] = useState('Beginner');
        const [duration, setDuration] = useState('');
        const [courseFee, setCourseFee] = useState('0');
        const [instructorId, setInstructorId] = useState('');

        const [isSubmitting, setIsSubmitting] = useState(false);

        useEffect(() => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        }, [courses, pagination, globalFilter, statusFilter, sorting, drawerOpen, deleteModalOpen]);

        // Close dropdown on click outside
        useEffect(() => {
            const handleOutsideClick = (e) => {
                if (activeDropdownCourseId && !e.target.closest('.actions-cell-gf')) {
                    setActiveDropdownCourseId(null);
                }
            };
            window.addEventListener('click', handleOutsideClick);
            return () => window.removeEventListener('click', handleOutsideClick);
        }, [activeDropdownCourseId]);

        // Metrics calculations
        const totalCourses = courses.length;
        const pendingCount = courses.filter(c => c.status === 'Pending').length;
        const approvedCount = courses.filter(c => c.status === 'Approved').length;
        const archivedCount = courses.filter(c => c.status === 'Archived').length;
        const unassignedCount = courses.filter(c => !c.createdBy || c.instructorLabel === 'Unassigned').length;

        // Custom filtering based on status filter tabs & search queries
        const filteredData = React.useMemo(() => {
            return courses.filter(course => {
                // Status tab filter
                if (statusFilter !== 'All' && course.status !== statusFilter) return false;
                
                // Search query filter
                if (globalFilter.trim()) {
                    const query = globalFilter.toLowerCase();
                    return (
                        course.courseName.toLowerCase().includes(query) ||
                        course.category.toLowerCase().includes(query) ||
                        course.instructorLabel.toLowerCase().includes(query)
                    );
                }
                return true;
            });
        }, [courses, globalFilter, statusFilter]);

        // Reset drawer form state
        const resetForm = () => {
            setCourseName('');
            setCategory('');
            setDescription('');
            setLevel('Beginner');
            setDuration('');
            setCourseFee('0');
            setInstructorId('');
            setSelectedCourse(null);
            
            const fileInput = document.getElementById('courseBannerFile');
            if (fileInput) fileInput.value = '';
        };

        // Open drawer in Create mode
        const handleOpenCreate = () => {
            resetForm();
            setDrawerMode('create');
            setDrawerOpen(true);
        };

        // Open drawer in Edit mode
        const handleOpenEdit = (course) => {
            resetForm();
            setSelectedCourse(course);
            setCourseName(course.courseName || '');
            setCategory(course.category || '');
            setDescription(course.description || '');
            setLevel(course.level || 'Beginner');
            setDuration(course.duration || '');
            setCourseFee(course.courseFee || '0');
            setInstructorId(course.createdBy || '');
            setDrawerMode('edit');
            setDrawerOpen(true);
        };

        // Open drawer in View details mode
        const handleOpenView = (course) => {
            resetForm();
            setSelectedCourse(course);
            setDrawerMode('view');
            setDrawerOpen(true);
        };

        // Open deletion warning modal
        const handleOpenDelete = (course) => {
            setCourseToDelete(course);
            setDeleteModalOpen(true);
        };

        // Execute asynchronous Hard Deletion GET call
        const handleDeleteConfirm = () => {
            if (!courseToDelete) return;
            fetch(window.__CONTEXT_PATH__ + '/admin/courses?action=delete&id=' + courseToDelete.courseId)
                .then(() => window.location.reload())
                .catch(err => console.error("Delete course error:", err));
        };

        // Execute asynchronous Multi-part Form Submit (Create & Edit POST)
        const handleSubmit = (e) => {
            e.preventDefault();
            setIsSubmitting(true);

            const formData = new FormData();
            formData.append('action', drawerMode === 'edit' ? 'edit' : 'create');
            if (drawerMode === 'edit') {
                formData.append('courseId', selectedCourse.courseId);
            }
            formData.append('courseName', courseName);
            formData.append('courseFee', courseFee);
            // Only append instructorId if one was actually selected — empty string confuses the server
            if (instructorId !== '' && instructorId !== null && instructorId !== undefined) {
                formData.append('instructorId', instructorId);
            }
            formData.append('description', description);
            formData.append('category', category);
            formData.append('level', level);
            if (duration !== '' && duration !== null && duration !== undefined) {
                formData.append('duration', duration);
            }

            const bannerInput = document.getElementById('courseBannerFile');
            if (bannerInput && bannerInput.files && bannerInput.files[0]) {
                formData.append('courseBanner', bannerInput.files[0]);
            }

            fetch(window.__CONTEXT_PATH__ + '/admin/courses', {
                method: 'POST',
                body: formData,
                redirect: 'follow'
            })
            .then(response => {
                // Navigate to the final URL the server redirected us to.
                // This preserves ?success=created or ?error=createfailed params
                // so the JSP banners actually render.
                window.location.href = response.url || (window.__CONTEXT_PATH__ + '/admin/courses');
            })
            .catch(err => {
                console.error("Submit error:", err);
                alert('Network error during submission. Please check your connection and try again.');
                setIsSubmitting(false);
            });
        };

        // Setup headless React Table column cells
        const columns = React.useMemo(() => [
            {
                accessorKey: 'courseId',
                header: 'ID',
                cell: info => <span style={{ fontWeight: '500' }}>{info.getValue()}</span>
            },
            {
                accessorKey: 'courseName',
                header: 'Course details',
                cell: info => {
                    const row = info.row.original;
                    const banner = row.courseBanner;
                    const fallbackGradient = GRADIENTS[row.courseId % 5];
                    const fallbackText = row.courseName ? row.courseName.substring(0, 2).toUpperCase() : 'CO';
                    return (
                        <div className="course-cell-gf">
                            <div className="course-thumbnail-gf" style={{ background: banner ? 'transparent' : fallbackGradient, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#ffffff', fontWeight: 'bold' }}>
                                {banner ? (
                                    <img src={banner} alt={row.courseName} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                ) : (
                                    <span>{fallbackText}</span>
                                )}
                            </div>
                            <div className="course-meta-gf">
                                <span className="course-title-gf">{row.courseName}</span>
                                <span className="course-category-gf">{row.category}</span>
                            </div>
                        </div>
                    );
                }
            },
            {
                accessorKey: 'instructorLabel',
                header: 'Assigned Instructor',
                cell: info => {
                    const row = info.row.original;
                    const label = info.getValue() || 'Unassigned';
                    const hasInstructor = row.createdBy > 0 && label !== 'Unassigned';
                    
                    if (hasInstructor) {
                        const initials = label.split(' ').map(n => n[0]).join('').substring(0, 2);
                        return (
                            <div className="instructor-cell-gf">
                                <div className="instructor-avatar-gf">{initials}</div>
                                <span className="instructor-name-gf">{label}</span>
                            </div>
                        );
                    } else {
                        return <span className="badge-unassigned-gf">Unassigned</span>;
                    }
                }
            },
            {
                accessorKey: 'level',
                header: 'Level',
                cell: info => <span>{info.getValue() || 'Beginner'}</span>
            },
            {
                accessorKey: 'courseFee',
                header: 'Price / Tuition',
                cell: info => {
                    const val = Number(info.getValue() || 0);
                    if (val === 0) {
                        return <span style={{ fontWeight: '600', color: '#10b981' }}>Free</span>;
                    }
                    return <span style={{ fontWeight: '500' }}>₦{val.toLocaleString('en-NG', { minimumFractionDigits: 2 })}</span>;
                }
            },
            {
                accessorKey: 'status',
                header: 'Status',
                cell: info => {
                    const val = info.getValue() || 'Pending';
                    const badgeClass = val === 'Approved' ? 'badge-published-gf' : val === 'Pending' ? 'badge-pending-gf' : 'badge-archived-gf';
                    return <span className={"badge-gf " + badgeClass}>{val === 'Approved' ? 'Published' : val}</span>;
                }
            },
            {
                accessorKey: 'enrolledCount',
                header: 'Students',
                cell: info => <span style={{ fontWeight: '600' }}>{info.getValue() || 0}</span>
            },
            {
                id: 'actions',
                header: '',
                cell: info => {
                    const row = info.row.original;
                    const isOpen = activeDropdownCourseId === row.courseId;
                    return (
                        <div className="actions-cell-gf">
                            <button 
                                className="actions-btn-gf"
                                onClick={(e) => {
                                    e.stopPropagation();
                                    setActiveDropdownCourseId(isOpen ? null : row.courseId);
                                }}
                            >
                                <i className="fas fa-ellipsis-v"></i>
                            </button>
                            {isOpen && (
                                <div className="actions-dropdown-gf">
                                    <button className="dropdown-item-gf" onClick={() => handleOpenView(row)}>
                                        <i className="fas fa-info-circle"></i> View Details
                                    </button>
                                    <button className="dropdown-item-gf" onClick={() => handleOpenEdit(row)}>
                                        <i className="fas fa-edit"></i> Edit Course
                                    </button>
                                    {row.status === 'Pending' && (
                                        <React.Fragment>
                                            <a href={window.__CONTEXT_PATH__ + "/admin/courses?action=approve&id=" + row.courseId} className="dropdown-item-gf" style={{ textDecoration: 'none' }} onClick={() => setIsSubmitting(true)}>
                                                <i className="fas fa-check-circle" style={{ color: '#10b981' }}></i> Approve Course
                                            </a>
                                            <a href={window.__CONTEXT_PATH__ + "/admin/courses?action=reject&id=" + row.courseId} className="dropdown-item-gf" style={{ textDecoration: 'none' }} onClick={() => setIsSubmitting(true)}>
                                                <i className="fas fa-times-circle" style={{ color: '#ef4444' }}></i> Reject Course
                                            </a>
                                        </React.Fragment>
                                    )}
                                    {row.status === 'Approved' && (
                                        <a href={window.__CONTEXT_PATH__ + "/admin/courses?action=archive&id=" + row.courseId} className="dropdown-item-gf" style={{ textDecoration: 'none' }} onClick={() => setIsSubmitting(true)}>
                                            <i className="fas fa-archive"></i> Archive Course
                                        </a>
                                    )}
                                    {row.status === 'Archived' && (
                                        <a href={window.__CONTEXT_PATH__ + "/admin/courses?action=restore&id=" + row.courseId} className="dropdown-item-gf" style={{ textDecoration: 'none' }} onClick={() => setIsSubmitting(true)}>
                                            <i className="fas fa-sync-alt"></i> Restore Course
                                        </a>
                                    )}
                                    <button className="dropdown-item-gf danger" onClick={() => handleOpenDelete(row)}>
                                        <i className="fas fa-trash-alt"></i> Delete Course
                                    </button>
                                </div>
                            )}
                        </div>
                    );
                }
            }
        ], [activeDropdownCourseId]);

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
                    <h1>Course Catalog</h1>
                    <p>Keep the platform curriculum catalog organized, assign professional instructors dynamically, review course approval requests, and verify syllabus specifications.</p>
                </header>

                {/* Metrics Cards row */}
                <section className="metrics-grid-gf">
                    <div className="metric-card-gf">
                        <span className="label">Total Courses</span>
                        <span className="value">{totalCourses}</span>
                        <span className="meta">Total registered records</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Published</span>
                        <span className="value" style={{ color: '#047857' }}>{approvedCount}</span>
                        <span className="meta">Visible to student catalog</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Pending Review</span>
                        <span className="value" style={{ color: '#b45309' }}>{pendingCount}</span>
                        <span className="meta">Requires admin evaluation</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Unassigned</span>
                        <span className="value" style={{ color: '#ef4444' }}>{unassignedCount}</span>
                        <span className="meta">Instructors missing</span>
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
                                    placeholder="Search courses..." 
                                    value={globalFilter}
                                    onChange={e => setGlobalFilter(e.target.value)}
                                />
                            </div>

                            {/* Status Tabs toggles */}
                            <div className="filter-tabs-gf">
                                <button className={"tab-btn-gf " + (statusFilter === 'All' ? 'active' : '')} onClick={() => setStatusFilter('All')}>All</button>
                                <button className={"tab-btn-gf " + (statusFilter === 'Approved' ? 'active' : '')} onClick={() => setStatusFilter('Approved')}>Published</button>
                                <button className={"tab-btn-gf " + (statusFilter === 'Pending' ? 'active' : '')} onClick={() => setStatusFilter('Pending')}>Pending</button>
                                <button className={"tab-btn-gf " + (statusFilter === 'Archived' ? 'active' : '')} onClick={() => setStatusFilter('Archived')}>Archived</button>
                            </div>
                        </div>

                        {/* Create Primary CTA */}
                        <button className="btn-primary-gf" onClick={handleOpenCreate}>
                            <i className="fas fa-plus"></i> + Create Course
                        </button>
                    </div>

                    {/* Table Render */}
                    {table && table.getRowModel && table.getRowModel().rows.length === 0 ? (
                        <div className="empty-state-gf">
                            <i className="fas fa-folder-open"></i>
                            <p>No courses matched the requested filter requirements.</p>
                        </div>
                    ) : (
                        <div style={{ overflowX: 'auto' }}>
                            <table className="courses-table-gf">
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
                {drawerOpen && (
                    <div className="drawer-overlay-gf" onClick={() => setDrawerOpen(false)}>
                        <div className="drawer-container-gf" onClick={e => e.stopPropagation()}>
                            <header className="drawer-header-gf">
                                <h2>
                                    {drawerMode === 'create' ? 'Create New Course' : drawerMode === 'edit' ? 'Update Course details' : 'Course Details Profile'}
                                </h2>
                                <button className="drawer-close-gf" onClick={() => setDrawerOpen(false)}>×</button>
                            </header>

                            <div className="drawer-body-gf">
                                {drawerMode === 'view' ? (
                                    /* Course Details View mode */
                                    <div className="details-section-gf">
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '1.25rem', borderBottom: '1px solid var(--gf-border)', paddingBottom: '1.5rem', marginBottom: '0.5rem' }}>
                                            <div className="course-thumbnail-gf" style={{ width: '6rem', height: '4rem', background: selectedCourse.courseBanner ? 'transparent' : GRADIENTS[selectedCourse.courseId % 5], display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#ffffff', fontWeight: 'bold', fontSize: '1.5rem', borderRadius: '8px', overflow: 'hidden' }}>
                                                {selectedCourse.courseBanner ? (
                                                    <img src={selectedCourse.courseBanner} alt={selectedCourse.courseName} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                                ) : (
                                                    <span>{selectedCourse.courseName ? selectedCourse.courseName.substring(0, 2).toUpperCase() : 'CO'}</span>
                                                )}
                                            </div>
                                            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.2rem' }}>
                                                <h3 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '700', color: 'var(--gf-text-primary)' }}>{selectedCourse.courseName}</h3>
                                                <span style={{ fontSize: '0.85rem', color: 'var(--gf-text-muted)' }}>{selectedCourse.category}</span>
                                            </div>
                                        </div>

                                        <div className="details-grid-gf">
                                            <div className="details-item-gf">
                                                <span>Course ID</span>
                                                <strong>{selectedCourse.courseId}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Status</span>
                                                <strong>{selectedCourse.status}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Course Level</span>
                                                <strong>{selectedCourse.level}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Duration (Days)</span>
                                                <strong>{selectedCourse.duration ? selectedCourse.duration + ' Days' : '-'}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Enrollments</span>
                                                <strong>{selectedCourse.enrolledCount || '0'} Students</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Course Price</span>
                                                <strong>
                                                    {Number(selectedCourse.courseFee) === 0 ? 'Free' : '₦' + Number(selectedCourse.courseFee).toLocaleString('en-NG', { minimumFractionDigits: 2 })}
                                                </strong>
                                            </div>
                                            <div className="details-item-gf span-2">
                                                <span>Assigned Instructor</span>
                                                <strong>{selectedCourse.instructorLabel}</strong>
                                            </div>
                                            <div className="details-item-gf span-2">
                                                <span>Course Description</span>
                                                <strong style={{ display: 'block', fontSize: '0.85rem', color: 'var(--gf-text-secondary)', lineHeight: '1.4', marginTop: '0.25rem' }}>
                                                    {selectedCourse.description || 'No description provided.'}
                                                </strong>
                                            </div>
                                        </div>
                                    </div>
                                ) : (
                                    /* Course CRUD Form (Create / Edit) */
                                    <form id="drawerForm" onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
                                        <div className="form-group-gf">
                                            <label>Course Title *</label>
                                            <input 
                                                type="text" 
                                                required 
                                                value={courseName}
                                                onChange={e => setCourseName(e.target.value)}
                                                placeholder="e.g. Strategic Digital Marketing"
                                            />
                                        </div>

                                        <div className="form-group-gf">
                                            <label>Category *</label>
                                            <input 
                                                type="text" 
                                                required 
                                                value={category}
                                                onChange={e => setCategory(e.target.value)}
                                                placeholder="e.g. Business, Technology, Design"
                                            />
                                        </div>

                                        <div className="form-row-gf">
                                            <div className="form-group-gf">
                                                <label>Syllabus Level</label>
                                                <select value={level} onChange={e => setLevel(e.target.value)}>
                                                    <option value="Beginner">Beginner</option>
                                                    <option value="Intermediate">Intermediate</option>
                                                    <option value="Advanced">Advanced</option>
                                                </select>
                                            </div>
                                            <div className="form-group-gf">
                                                <label>Duration (Days)</label>
                                                <input 
                                                    type="number" 
                                                    min="1" 
                                                    value={duration}
                                                    onChange={e => setDuration(e.target.value)}
                                                    placeholder="e.g. 30"
                                                />
                                            </div>
                                        </div>

                                        <div className="form-group-gf">
                                            <label>Tuition Fee (NGN) *</label>
                                            <input 
                                                type="number" 
                                                min="0" 
                                                step="0.01" 
                                                required 
                                                value={courseFee}
                                                onChange={e => setCourseFee(e.target.value)}
                                                placeholder="0.00"
                                            />
                                        </div>

                                        {/* Autocomplete Instructor search select dropdown */}
                                        <div className="form-group-gf">
                                            <label>Assigned Instructor</label>
                                            <AutocompleteSelect 
                                                options={instructors}
                                                value={instructorId}
                                                onChange={setInstructorId}
                                                placeholder="Type to search instructors..."
                                            />
                                        </div>

                                        <div className="form-group-gf">
                                            <label>Course Banner File</label>
                                            <input 
                                                type="file" 
                                                id="courseBannerFile" 
                                                accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"
                                            />
                                            <small style={{ fontSize: '0.75rem', color: 'var(--gf-text-muted)' }}>
                                                Upload banner banner (JPG, PNG, WEBP up to 5MB).
                                            </small>
                                        </div>

                                        <div className="form-group-gf">
                                            <label>Syllabus Description Summary</label>
                                            <textarea 
                                                value={description}
                                                onChange={e => setDescription(e.target.value)}
                                                placeholder="Concise course syllabus overview..."
                                                rows="5"
                                            ></textarea>
                                        </div>
                                    </form>
                                )}
                            </div>

                            <footer className="drawer-footer-gf">
                                <button className="btn-secondary-gf" onClick={() => setDrawerOpen(false)}>
                                    {drawerMode === 'view' ? 'Close' : 'Cancel'}
                                </button>
                                {drawerMode !== 'view' && (
                                    <button 
                                        type="submit" 
                                        form="drawerForm" 
                                        className="btn-primary-gf"
                                        disabled={isSubmitting}
                                    >
                                        {isSubmitting ? 'Saving...' : drawerMode === 'edit' ? 'Update Course' : 'Create Course'}
                                    </button>
                                )}
                            </footer>
                        </div>
                    </div>
                )}

                {/* Centered Safe Deletion Modal Overlay */}
                {deleteModalOpen && courseToDelete && (
                    <div className="modal-overlay-gf" onClick={() => setDeleteModalOpen(false)}>
                        <div className="modal-box-gf" onClick={e => e.stopPropagation()}>
                            <h3 className="modal-title-gf">
                                <i className="fas fa-exclamation-triangle"></i> Safe Deletion Warning
                            </h3>
                            <div className="modal-body-gf">
                                <p>
                                    Are you absolutely sure you want to delete <strong>{courseToDelete.courseName}</strong>?
                                </p>
                                <p style={{ marginTop: '0.5rem', fontSize: '0.85rem', color: 'var(--gf-red)' }}>
                                    This action is database-safe but will fail if the course currently holds active student enrollments, grading histories, or syllabus materials.
                                </p>
                            </div>
                            <footer className="modal-footer-gf">
                                <button className="btn-secondary-gf" onClick={() => setDeleteModalOpen(false)}>
                                    Cancel
                                </button>
                                <button className="btn-danger-gf" onClick={handleDeleteConfirm}>
                                    Confirm Deletion
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
    root.render(<CoursesManagement />);
</script>
</body>
</html>
