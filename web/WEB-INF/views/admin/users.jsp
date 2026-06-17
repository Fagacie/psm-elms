<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.psm.elearning.model.*,java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-users-gf.css?v=1.0">
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
    <jsp:param name="pageTitle" value="Users"/>
    <jsp:param name="pageSubtitle" value="Manage student, instructor, and administrator accounts"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- JSTL Success/Warning/Error Notifications -->
    <div style="max-width: 1400px; margin: 2rem auto 0 auto; padding: 0 2rem;">
        <c:if test="${not empty sessionScope.success}">
            <div class="alert-gf alert-success-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-check-circle"></i> <c:out value="${sessionScope.success}"/>
            </div>
            <c:remove var="success" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="alert-gf alert-error-gf" style="margin-bottom: 1.5rem;">
                <i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.error}"/>
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.warning}">
            <div class="alert-gf alert-success-gf" style="background-color: #fef3c7; color: #b45309; border: 1px solid rgba(180, 83, 9, 0.15); margin-bottom: 1.5rem;">
                <i class="fas fa-info-circle"></i> <c:out value="${sessionScope.warning}"/>
            </div>
            <c:remove var="warning" scope="session"/>
        </c:if>
    </div>

    <!-- React Greenfield Root Mounting Element -->
    <div id="admin-react-root"></div>
</main>

<%
    List<User> usersList = (List<User>) request.getAttribute("users");
    java.util.Map<Integer, Student> studentDetailsMap = (java.util.Map<Integer, Student>) request.getAttribute("studentDetailsMap");
    java.util.Map<Integer, Instructor> instructorDetailsMap = (java.util.Map<Integer, Instructor>) request.getAttribute("instructorDetailsMap");
    java.util.Map<Integer, String> studentEnrollmentsMap = (java.util.Map<Integer, String>) request.getAttribute("studentEnrollmentsMap");
    java.util.Map<Integer, String> instructorCoursesMap = (java.util.Map<Integer, String>) request.getAttribute("instructorCoursesMap");
    java.util.Map<Integer, Integer> instructorMaterialsCountMap = (java.util.Map<Integer, Integer>) request.getAttribute("instructorMaterialsCountMap");
    java.util.Map<Integer, Integer> instructorAssessmentsCountMap = (java.util.Map<Integer, Integer>) request.getAttribute("instructorAssessmentsCountMap");

    org.json.JSONArray usersJsonArray = new org.json.JSONArray();
    if (usersList != null) {
        for (User u : usersList) {
            org.json.JSONObject userObj = new org.json.JSONObject();
            int uid = u.getUserId();
            userObj.put("userId", uid);
            userObj.put("fullName", u.getFullName() != null ? u.getFullName() : "");
            userObj.put("email", u.getEmail() != null ? u.getEmail() : "");
            userObj.put("phone", u.getPhone() != null ? u.getPhone() : "");
            userObj.put("role", u.getRole() != null ? u.getRole() : "");
            userObj.put("status", u.getStatus() != null ? u.getStatus() : "");
            
            // Student specific details
            if (studentDetailsMap != null && studentDetailsMap.containsKey(uid)) {
                Student s = studentDetailsMap.get(uid);
                userObj.put("studentReg", s.getRegNumber() != null ? s.getRegNumber() : "");
                userObj.put("studentQualification", s.getQualification() != null ? s.getQualification() : "");
                userObj.put("studentCountry", s.getCountry() != null ? s.getCountry() : "");
                userObj.put("studentState", s.getState() != null ? s.getState() : "");
                userObj.put("studentGender", s.getGender() != null ? s.getGender() : "");
                userObj.put("studentEmergency", s.getEmergencyContact() != null ? s.getEmergencyContact() : "");
            } else {
                userObj.put("studentReg", "");
                userObj.put("studentQualification", "");
                userObj.put("studentCountry", "");
                userObj.put("studentState", "");
                userObj.put("studentGender", "");
                userObj.put("studentEmergency", "");
            }
            userObj.put("studentEnrollments", (studentEnrollmentsMap != null && studentEnrollmentsMap.get(uid) != null) ? studentEnrollmentsMap.get(uid) : "");
            
            // Instructor specific details
            if (instructorDetailsMap != null && instructorDetailsMap.containsKey(uid)) {
                Instructor ins = instructorDetailsMap.get(uid);
                userObj.put("instructorSpecialization", ins.getSpecialization() != null ? ins.getSpecialization() : "");
                userObj.put("instructorCertification", ins.getCertification() != null ? ins.getCertification() : "");
                userObj.put("instructorExperience", ins.getYearsOfExperience() != null ? ins.getYearsOfExperience().toString() : "");
                userObj.put("instructorBio", ins.getBio() != null ? ins.getBio() : "");
            } else {
                userObj.put("instructorSpecialization", "");
                userObj.put("instructorCertification", "");
                userObj.put("instructorExperience", "");
                userObj.put("instructorBio", "");
            }
            userObj.put("instructorCourses", (instructorCoursesMap != null && instructorCoursesMap.get(uid) != null) ? instructorCoursesMap.get(uid) : "");
            userObj.put("instructorMaterials", (instructorMaterialsCountMap != null && instructorMaterialsCountMap.get(uid) != null) ? instructorMaterialsCountMap.get(uid) : 0);
            userObj.put("instructorAssessments", (instructorAssessmentsCountMap != null && instructorAssessmentsCountMap.get(uid) != null) ? instructorAssessmentsCountMap.get(uid) : 0);
            
            usersJsonArray.put(userObj);
        }
    }
    pageContext.setAttribute("serializedUsersJson", usersJsonArray.toString());
%>

<!-- Serialize backend variables strictly to window scope -->
<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__CURRENT_USER_ID__ = ${sessionScope.user.userId};
    window.__USERS__ = ${serializedUsersJson};
</script>

<!-- Interactive React Command Center Application -->
<script type="text/babel" data-presets="react,env">
    const { useState, useEffect } = React;
    const { 
        useReactTable, getCoreRowModel, getPaginationRowModel, getSortedRowModel, flexRender 
    } = window.ReactTable || {};

    function UsersManagement() {
        const [users, setUsers] = useState(window.__USERS__ || []);
        const [globalFilter, setGlobalFilter] = useState('');
        const [roleFilter, setRoleFilter] = useState('All');
        
        // Pagination state
        const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
        
        // Sorting state
        const [sorting, setSorting] = useState([{ id: 'userId', desc: true }]);

        // Dropdown tracking
        const [activeDropdownUserId, setActiveDropdownUserId] = useState(null);

        // Drawer states
        const [drawerOpen, setDrawerOpen] = useState(false);
        const [drawerMode, setDrawerMode] = useState('create'); // 'create', 'edit', 'view'
        const [selectedUser, setSelectedUser] = useState(null);

        // Delete Confirmation Modal states
        const [deleteModalOpen, setDeleteModalOpen] = useState(false);
        const [userToDelete, setUserToDelete] = useState(null);

        // Form Fields State
        const [fullName, setFullName] = useState('');
        const [email, setEmail] = useState('');
        const [phone, setPhone] = useState('');
        const [password, setPassword] = useState('');
        const [role, setRole] = useState('Student');

        // Student Role Fields State
        const [qualification, setQualification] = useState('');
        const [country, setCountry] = useState('');
        const [state, setState] = useState('');
        const [gender, setGender] = useState('Male');
        const [emergencyContact, setEmergencyContact] = useState('');
        const [dob, setDob] = useState('');

        // Instructor Role Fields State
        const [specialization, setSpecialization] = useState('');
        const [certification, setCertification] = useState('');
        const [yearsOfExperience, setYearsOfExperience] = useState('');
        const [bio, setBio] = useState('');
        const [hireDate, setHireDate] = useState('');

        // Admin Role Fields State
        const [position, setPosition] = useState('');
        const [permissionLevel, setPermissionLevel] = useState('Standard');
        const [assignedDepartment, setAssignedDepartment] = useState('');

        const [isSubmitting, setIsSubmitting] = useState(false);

        useEffect(() => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        }, [users, pagination, globalFilter, roleFilter, sorting, drawerOpen, deleteModalOpen]);

        // Close dropdown on click outside
        useEffect(() => {
            const handleOutsideClick = (e) => {
                if (activeDropdownUserId && !e.target.closest('.actions-cell-gf')) {
                    setActiveDropdownUserId(null);
                }
            };
            window.addEventListener('click', handleOutsideClick);
            return () => window.removeEventListener('click', handleOutsideClick);
        }, [activeDropdownUserId]);

        // Metrics calculations
        const studentsCount = users.filter(u => u.role === 'Student').length;
        const instructorsCount = users.filter(u => u.role === 'Instructor').length;
        const adminsCount = users.filter(u => u.role === 'Admin').length;
        const activeCount = users.filter(u => u.status === 'Active' || u.status === 'active').length;
        const suspendedCount = users.filter(u => u.status === 'Suspended' || u.status === 'suspended').length;

        // Custom filtering based on role tabs & search queries
        const filteredData = React.useMemo(() => {
            return users.filter(user => {
                // Role filter
                if (roleFilter !== 'All' && user.role !== roleFilter) return false;
                
                // Search query filter
                if (globalFilter.trim()) {
                    const query = globalFilter.toLowerCase();
                    return (
                        user.fullName.toLowerCase().includes(query) ||
                        user.email.toLowerCase().includes(query) ||
                        user.phone.toLowerCase().includes(query) ||
                        (user.studentReg && user.studentReg.toLowerCase().includes(query))
                    );
                }
                return true;
            });
        }, [users, globalFilter, roleFilter]);

        // Reset drawer form state
        const resetForm = () => {
            setFullName('');
            setEmail('');
            setPhone('');
            setPassword('');
            setRole('Student');
            
            // Student
            setQualification('');
            setCountry('');
            setState('');
            setGender('Male');
            setEmergencyContact('');
            setDob('');

            // Instructor
            setSpecialization('');
            setCertification('');
            setYearsOfExperience('');
            setBio('');
            setHireDate('');

            // Admin
            setPosition('');
            setPermissionLevel('Standard');
            setAssignedDepartment('');

            setSelectedUser(null);
        };

        // Open drawer in Create mode
        const handleOpenCreate = () => {
            resetForm();
            setDrawerMode('create');
            setDrawerOpen(true);
        };

        // Open drawer in Edit mode
        const handleOpenEdit = (user) => {
            resetForm();
            setSelectedUser(user);
            setFullName(user.fullName || '');
            setEmail(user.email || '');
            setPhone(user.phone || '');
            setPassword(''); // Never pre-fill passwords
            setRole(user.role || 'Student');

            // Pre-fill role specific items
            if (user.role === 'Student') {
                setQualification(user.studentQualification || '');
                setCountry(user.studentCountry || '');
                setState(user.studentState || '');
                setGender(user.studentGender || 'Male');
                setEmergencyContact(user.studentEmergency || '');
                setDob(''); // Optional date fields can be left blank for update
            } else if (user.role === 'Instructor') {
                setSpecialization(user.instructorSpecialization || '');
                setCertification(user.instructorCertification || '');
                setYearsOfExperience(user.instructorExperience || '');
                setBio(user.instructorBio || '');
                setHireDate('');
            } else if (user.role === 'Admin') {
                setPosition('');
                setPermissionLevel('Standard');
                setAssignedDepartment('');
            }

            setDrawerMode('edit');
            setDrawerOpen(true);
        };

        // Open drawer in View Profile details mode
        const handleOpenView = (user) => {
            resetForm();
            setSelectedUser(user);
            setDrawerMode('view');
            setDrawerOpen(true);
        };

        // Open deletion warning dialog
        const handleOpenDelete = (user) => {
            setUserToDelete(user);
            setDeleteModalOpen(true);
        };

        // Execute asynchronous Toggle Status GET call
        const handleToggleStatus = (userId) => {
            fetch(window.__CONTEXT_PATH__ + '/admin/users?action=toggle-status&userId=' + userId)
                .then(() => window.location.reload())
                .catch(err => console.error("Toggle status error:", err));
        };

        // Execute asynchronous Delete User GET call
        const handleDeleteConfirm = () => {
            if (!userToDelete) return;
            fetch(window.__CONTEXT_PATH__ + '/admin/users?action=delete&userId=' + userToDelete.userId)
                .then(() => window.location.reload())
                .catch(err => console.error("Delete user error:", err));
        };

        // Execute asynchronous Form Submit (Create & Update POST)
        const handleSubmit = (e) => {
            e.preventDefault();
            setIsSubmitting(true);

            const formData = new URLSearchParams();
            formData.append('action', drawerMode === 'edit' ? 'edit' : 'create');
            if (drawerMode === 'edit') {
                formData.append('userId', selectedUser.userId);
            }
            formData.append('fullName', fullName);
            formData.append('email', email);
            formData.append('phone', phone);
            formData.append('password', password);
            formData.append('role', role);

            // Append role specific parameters
            if (role === 'Student') {
                formData.append('qualification', qualification);
                formData.append('country', country);
                formData.append('state', state);
                formData.append('gender', gender);
                formData.append('emergencyContact', emergencyContact);
                formData.append('dob', dob);
            } else if (role === 'Instructor') {
                formData.append('specialization', specialization);
                formData.append('certification', certification);
                formData.append('yearsOfExperience', yearsOfExperience);
                formData.append('bio', bio);
                formData.append('hireDate', hireDate);
            } else if (role === 'Admin') {
                formData.append('position', position);
                formData.append('permissionLevel', permissionLevel);
                formData.append('assignedDepartment', assignedDepartment);
            }

            fetch(window.__CONTEXT_PATH__ + '/admin/users', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: formData.toString()
            })
            .then(() => window.location.reload())
            .catch(err => {
                console.error("Submit error:", err);
                setIsSubmitting(false);
            });
        };

        // Setup headless React Table column cells
        const columns = React.useMemo(() => [
            {
                accessorKey: 'userId',
                header: 'ID',
                cell: info => <span style={{ fontWeight: '500' }}>{info.getValue()}</span>
            },
            {
                accessorKey: 'fullName',
                header: 'User details',
                cell: info => {
                    const row = info.row.original;
                    const initials = row.fullName ? row.fullName.split(' ').map(n => n[0]).join('').substring(0,2) : 'U';
                    return (
                        <div className="user-info-cell-gf">
                            <div className="user-avatar-circle-gf">{initials}</div>
                            <div className="user-meta-gf">
                                <span className="user-name-gf">{row.fullName}</span>
                                <span className="user-email-gf">{row.email}</span>
                            </div>
                        </div>
                    );
                }
            },
            {
                accessorKey: 'phone',
                header: 'Phone Number',
                cell: info => <span>{info.getValue() || '-'}</span>
            },
            {
                accessorKey: 'role',
                header: 'System Role',
                cell: info => {
                    const val = info.getValue();
                    const badgeClass = val === 'Admin' ? 'badge-admin-gf' : val === 'Instructor' ? 'badge-instructor-gf' : 'badge-student-gf';
                    return <span className={"badge-gf " + badgeClass}>{val}</span>;
                }
            },
            {
                accessorKey: 'status',
                header: 'Account Status',
                cell: info => {
                    const val = info.getValue() || 'Active';
                    const isActive = val.toLowerCase() === 'active';
                    const badgeClass = isActive ? 'badge-active-gf' : 'badge-suspended-gf';
                    return <span className={"badge-gf " + badgeClass}>{isActive ? 'Active' : 'Suspended'}</span>;
                }
            },
            {
                id: 'actions',
                header: '',
                cell: info => {
                    const row = info.row.original;
                    const isOpen = activeDropdownUserId === row.userId;
                    return (
                        <div className="actions-cell-gf">
                            <button 
                                className="actions-btn-gf"
                                onClick={(e) => {
                                    e.stopPropagation();
                                    setActiveDropdownUserId(isOpen ? null : row.userId);
                                }}
                            >
                                <i className="fas fa-ellipsis-v"></i>
                            </button>
                            {isOpen && (
                                <div className="actions-dropdown-gf">
                                    <button className="dropdown-item-gf" onClick={() => handleOpenView(row)}>
                                        <i className="fas fa-id-card"></i> View Details
                                    </button>
                                    <button className="dropdown-item-gf" onClick={() => handleOpenEdit(row)}>
                                        <i className="fas fa-edit"></i> Edit User
                                    </button>
                                    <button className="dropdown-item-gf" onClick={() => handleToggleStatus(row.userId)}>
                                        <i className="fas fa-sync-alt"></i> Toggle Status
                                    </button>
                                    {row.userId !== window.__CURRENT_USER_ID__ && (
                                        <button className="dropdown-item-gf danger" onClick={() => handleOpenDelete(row)}>
                                            <i className="fas fa-trash-alt"></i> Delete User
                                        </button>
                                    )}
                                </div>
                            )}
                        </div>
                    );
                }
            }
        ], [activeDropdownUserId]);

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
                {/* Modern Greenfield typographic Header */}
                <header className="dashboard-header-gf">
                    <h1>User Directory</h1>
                    <p>Govern platform membership accounts, inspect user academic credentials, update specializations, and manage administrative credentials.</p>
                </header>

                {/* Metrics Cards row */}
                <section className="metrics-grid-gf">
                    <div className="metric-card-gf">
                        <span className="label">Total Members</span>
                        <span className="value">{users.length}</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Active Students</span>
                        <span className="value">{studentsCount}</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Active Instructors</span>
                        <span className="value">{instructorsCount}</span>
                    </div>
                    <div className="metric-card-gf">
                        <span className="label">Administrators</span>
                        <span className="value">{adminsCount}</span>
                    </div>
                    <div className="metric-card-gf" style={{ borderLeft: '3px solid #10b981' }}>
                        <span className="label">Status Active</span>
                        <span className="value" style={{ color: '#047857' }}>{activeCount}</span>
                    </div>
                    <div className="metric-card-gf" style={{ borderLeft: '3px solid #ef4444' }}>
                        <span className="label">Status Suspended</span>
                        <span className="value" style={{ color: '#b91c1c' }}>{suspendedCount}</span>
                    </div>
                </section>

                {/* Headless Data Table Shell */}
                <section className="table-card-gf">
                    <div className="table-controls-gf">
                        <div className="controls-left-gf">
                            {/* Search bar */}
                            <div className="search-box-gf">
                                <i className="fas fa-search"></i>
                                <input 
                                    type="text" 
                                    placeholder="Search users..." 
                                    value={globalFilter}
                                    onChange={e => setGlobalFilter(e.target.value)}
                                />
                            </div>

                            {/* Tabs toggles */}
                            <div className="filter-tabs-gf">
                                <button className={"tab-btn-gf " + (roleFilter === 'All' ? 'active' : '')} onClick={() => setRoleFilter('All')}>All</button>
                                <button className={"tab-btn-gf " + (roleFilter === 'Student' ? 'active' : '')} onClick={() => setRoleFilter('Student')}>Students</button>
                                <button className={"tab-btn-gf " + (roleFilter === 'Instructor' ? 'active' : '')} onClick={() => setRoleFilter('Instructor')}>Instructors</button>
                                <button className={"tab-btn-gf " + (roleFilter === 'Admin' ? 'active' : '')} onClick={() => setRoleFilter('Admin')}>Admins</button>
                            </div>
                        </div>

                        {/* Add button */}
                        <button className="btn-primary-gf" onClick={handleOpenCreate}>
                            <i className="fas fa-plus"></i> + Add New User
                        </button>
                    </div>

                    {/* Headless table render */}
                    {table && table.getRowModel && table.getRowModel().rows.length === 0 ? (
                        <div className="empty-state-gf">
                            <i className="fas fa-folder-open"></i>
                            <p>No records found matching current query criteria.</p>
                        </div>
                    ) : (
                        <div style={{ overflowX: 'auto' }}>
                            <table className="users-table-gf">
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

                    {/* Pagination controller */}
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

                {/* Greenfield Slide-out CRUD & Details Drawer */}
                {drawerOpen && (
                    <div className="drawer-overlay-gf" onClick={() => setDrawerOpen(false)}>
                        <div className="drawer-container-gf" onClick={e => e.stopPropagation()}>
                            <header className="drawer-header-gf">
                                <h2>
                                    {drawerMode === 'create' ? 'Create New User' : drawerMode === 'edit' ? 'Update User Details' : 'Member Details Profile'}
                                </h2>
                                <button className="drawer-close-gf" onClick={() => setDrawerOpen(false)}>×</button>
                            </header>

                            <div className="drawer-body-gf">
                                {drawerMode === 'view' ? (
                                    /* User Profile Details Viewer Section */
                                    <div className="details-section-gf">
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '1.25rem', borderBottom: '1px solid var(--gf-border)', paddingBottom: '1.5rem', marginBottom: '0.5rem' }}>
                                            <div className="user-avatar-circle-gf" style={{ width: '4rem', height: '4rem', fontSize: '1.5rem' }}>
                                                {selectedUser.fullName ? selectedUser.fullName.split(' ').map(n => n[0]).join('').substring(0,2) : 'U'}
                                            </div>
                                            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.2rem' }}>
                                                <h3 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '700', color: 'var(--gf-text-primary)' }}>{selectedUser.fullName}</h3>
                                                <span style={{ fontSize: '0.85rem', color: 'var(--gf-text-muted)' }}>{selectedUser.email}</span>
                                            </div>
                                        </div>

                                        <div className="details-grid-gf">
                                            <div className="details-item-gf">
                                                <span>Member ID</span>
                                                <strong>{selectedUser.userId}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>System Role</span>
                                                <strong>{selectedUser.role}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Phone Number</span>
                                                <strong>{selectedUser.phone || '-'}</strong>
                                            </div>
                                            <div className="details-item-gf">
                                                <span>Account Status</span>
                                                <strong>{selectedUser.status || 'Active'}</strong>
                                            </div>

                                            {/* Role Specific Details - Student */}
                                            {selectedUser.role === 'Student' && (
                                                <React.Fragment>
                                                    <div className="details-item-gf span-2" style={{ marginTop: '0.5rem' }}>
                                                        <span className="section-subtitle-gf">Student Qualifications</span>
                                                    </div>
                                                    <div className="details-item-gf">
                                                        <span>Registration No.</span>
                                                        <strong>{selectedUser.studentReg || '-'}</strong>
                                                    </div>
                                                    <div className="details-item-gf">
                                                        <span>Academic Level</span>
                                                        <strong>{selectedUser.studentQualification || '-'}</strong>
                                                    </div>
                                                    <div className="details-item-gf">
                                                        <span>Nationality</span>
                                                        <strong>{selectedUser.studentCountry || '-'}</strong>
                                                    </div>
                                                    <div className="details-item-gf">
                                                        <span>State Residency</span>
                                                        <strong>{selectedUser.studentState || '-'}</strong>
                                                    </div>
                                                    <div className="details-item-gf">
                                                        <span>Emergency Contact</span>
                                                        <strong>{selectedUser.studentEmergency || '-'}</strong>
                                                    </div>
                                                    <div className="details-item-gf">
                                                        <span>Gender Identity</span>
                                                        <strong>{selectedUser.studentGender || '-'}</strong>
                                                    </div>
                                                    <div className="details-item-gf span-2">
                                                        <span>Enrolled Courses</span>
                                                        <strong style={{ display: 'block', fontSize: '0.85rem', color: 'var(--gf-text-secondary)', lineHeight: '1.4', marginTop: '0.25rem', whiteSpace: 'pre-line' }}>
                                                            {selectedUser.studentEnrollments && selectedUser.studentEnrollments !== 'None' 
                                                                ? selectedUser.studentEnrollments.replace(/; /g, '\n')
                                                                : 'No course enrollments recorded.'
                                                            }
                                                        </strong>
                                                    </div>
                                                </React.Fragment>
                                            )}

                                            {/* Role Specific Details - Instructor */}
                                            {selectedUser.role === 'Instructor' && (
                                                <React.Fragment>
                                                    <div className="details-item-gf span-2" style={{ marginTop: '0.5rem' }}>
                                                        <span className="section-subtitle-gf">Academic Specialization</span>
                                                    </div>
                                                    <div className="details-item-gf">
                                                        <span>Discipline Focus</span>
                                                        <strong>{selectedUser.instructorSpecialization || '-'}</strong>
                                                    </div>
                                                    <div className="details-item-gf">
                                                        <span>Professional Cert.</span>
                                                        <strong>{selectedUser.instructorCertification || '-'}</strong>
                                                    </div>
                                                    <div className="details-item-gf">
                                                        <span>Years Experience</span>
                                                        <strong>{selectedUser.instructorExperience || '0'} years</strong>
                                                    </div>
                                                    <div className="details-item-gf">
                                                        <span>Uploaded Materials</span>
                                                        <strong>{selectedUser.instructorMaterials || '0'} modules</strong>
                                                    </div>
                                                    <div className="details-item-gf span-2">
                                                        <span>Biography Summary</span>
                                                        <strong style={{ display: 'block', fontSize: '0.85rem', color: 'var(--gf-text-secondary)', lineHeight: '1.4', marginTop: '0.25rem' }}>
                                                            {selectedUser.instructorBio || 'No biography text uploaded.'}
                                                        </strong>
                                                    </div>
                                                    <div className="details-item-gf span-2">
                                                        <span>Assigned Courses</span>
                                                        <strong style={{ display: 'block', fontSize: '0.85rem', color: 'var(--gf-text-secondary)', lineHeight: '1.4', marginTop: '0.25rem' }}>
                                                            {selectedUser.instructorCourses && selectedUser.instructorCourses !== 'None' 
                                                                ? selectedUser.instructorCourses 
                                                                : 'None assigned.'
                                                            }
                                                        </strong>
                                                    </div>
                                                </React.Fragment>
                                            )}

                                            {/* Role Specific Details - Admin */}
                                            {selectedUser.role === 'Admin' && (
                                                <div className="details-item-gf span-2">
                                                    <span>Admin Operations</span>
                                                    <strong style={{ display: 'block', fontSize: '0.85rem', color: 'var(--gf-text-secondary)', lineHeight: '1.4', marginTop: '0.25rem' }}>
                                                        Unrestricted platform governance privilege. All database objects can be fully inspected, updated, or removed by this administrative user.
                                                    </strong>
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                ) : (
                                    /* User Form Component (Create & Edit Mode) */
                                    <form id="drawerForm" onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
                                        <div className="form-group-gf">
                                            <label>Full Name *</label>
                                            <input 
                                                type="text" 
                                                required 
                                                value={fullName}
                                                onChange={e => setFullName(e.target.value)}
                                                placeholder="e.g. John Doe"
                                            />
                                        </div>

                                        <div className="form-group-gf">
                                            <label>Email Address *</label>
                                            <input 
                                                type="email" 
                                                required 
                                                disabled={drawerMode === 'edit'}
                                                value={email}
                                                onChange={e => setEmail(e.target.value)}
                                                placeholder="e.g. johndoe@example.com"
                                            />
                                        </div>

                                        <div className="form-group-gf">
                                            <label>Phone Number</label>
                                            <input 
                                                type="text" 
                                                value={phone}
                                                onChange={e => setPhone(e.target.value)}
                                                placeholder="e.g. +234 803 123 4567"
                                            />
                                        </div>

                                        <div className="form-group-gf">
                                            <label>{drawerMode === 'edit' ? 'Password (leave empty to keep unchanged)' : 'Password *'}</label>
                                            <input 
                                                type="password" 
                                                required={drawerMode === 'create'}
                                                value={password}
                                                onChange={e => setPassword(e.target.value)}
                                                placeholder="••••••••"
                                            />
                                        </div>

                                        <div className="form-group-gf">
                                            <label>System Role *</label>
                                            <select 
                                                value={role}
                                                disabled={drawerMode === 'edit'}
                                                onChange={e => setRole(e.target.value)}
                                            >
                                                <option value="Student">Student</option>
                                                <option value="Instructor">Instructor</option>
                                                <option value="Admin">Administrator</option>
                                            </select>
                                        </div>

                                        <div className="section-divider-gf"></div>

                                        {/* Dynamic Role-specific Form Fields */}
                                        {role === 'Student' && (
                                            <React.Fragment>
                                                <span className="section-subtitle-gf">Student Profile</span>
                                                
                                                <div className="form-group-gf">
                                                    <label>Highest Qualification</label>
                                                    <input 
                                                        type="text" 
                                                        value={qualification}
                                                        onChange={e => setQualification(e.target.value)}
                                                        placeholder="e.g. B.Sc. Computer Science"
                                                    />
                                                </div>

                                                <div className="form-row-gf">
                                                    <div className="form-group-gf">
                                                        <label>Country</label>
                                                        <input 
                                                            type="text" 
                                                            value={country}
                                                            onChange={e => setCountry(e.target.value)}
                                                            placeholder="e.g. Nigeria"
                                                        />
                                                    </div>
                                                    <div className="form-group-gf">
                                                        <label>State</label>
                                                        <input 
                                                            type="text" 
                                                            value={state}
                                                            onChange={e => setState(e.target.value)}
                                                            placeholder="e.g. Lagos"
                                                        />
                                                    </div>
                                                </div>

                                                <div className="form-row-gf">
                                                    <div className="form-group-gf">
                                                        <label>Gender Identity</label>
                                                        <select value={gender} onChange={e => setGender(e.target.value)}>
                                                            <option value="Male">Male</option>
                                                            <option value="Female">Female</option>
                                                            <option value="Other">Other</option>
                                                        </select>
                                                    </div>
                                                    <div className="form-group-gf">
                                                        <label>Date of Birth</label>
                                                        <input 
                                                            type="date" 
                                                            value={dob}
                                                            onChange={e => setDob(e.target.value)}
                                                        />
                                                    </div>
                                                </div>

                                                <div className="form-group-gf">
                                                    <label>Emergency Contact Phone</label>
                                                    <input 
                                                        type="text" 
                                                        value={emergencyContact}
                                                        onChange={e => setEmergencyContact(e.target.value)}
                                                        placeholder="e.g. +234 803 987 6543"
                                                    />
                                                </div>
                                            </React.Fragment>
                                        )}

                                        {role === 'Instructor' && (
                                            <React.Fragment>
                                                <span className="section-subtitle-gf">Instructor Qualifications</span>
                                                
                                                <div className="form-row-gf">
                                                    <div className="form-group-gf">
                                                        <label>Specialization Discipline</label>
                                                        <input 
                                                            type="text" 
                                                            value={specialization}
                                                            onChange={e => setSpecialization(e.target.value)}
                                                            placeholder="e.g. Java Development"
                                                        />
                                                    </div>
                                                    <div className="form-group-gf">
                                                        <label>Certification Title</label>
                                                        <input 
                                                            type="text" 
                                                            value={certification}
                                                            onChange={e => setCertification(e.target.value)}
                                                            placeholder="e.g. Oracle Certified Professional"
                                                        />
                                                    </div>
                                                </div>

                                                <div className="form-row-gf">
                                                    <div className="form-group-gf">
                                                        <label>Years of Experience</label>
                                                        <input 
                                                            type="number" 
                                                            value={yearsOfExperience}
                                                            onChange={e => setYearsOfExperience(e.target.value)}
                                                            placeholder="e.g. 5"
                                                            min="0"
                                                        />
                                                    </div>
                                                    <div className="form-group-gf">
                                                        <label>Date Hired</label>
                                                        <input 
                                                            type="date" 
                                                            value={hireDate}
                                                            onChange={e => setHireDate(e.target.value)}
                                                        />
                                                    </div>
                                                </div>

                                                <div className="form-group-gf">
                                                    <label>Biography Summary</label>
                                                    <textarea 
                                                        value={bio}
                                                        onChange={e => setBio(e.target.value)}
                                                        placeholder="Write a brief professional summary of the instructor..."
                                                        rows="3"
                                                    ></textarea>
                                                </div>
                                            </React.Fragment>
                                        )}

                                        {role === 'Admin' && (
                                            <React.Fragment>
                                                <span className="section-subtitle-gf">Administrative Details</span>
                                                
                                                <div className="form-group-gf">
                                                    <label>Administrative Position</label>
                                                    <input 
                                                        type="text" 
                                                        value={position}
                                                        onChange={e => setPosition(e.target.value)}
                                                        placeholder="e.g. Systems Operator"
                                                    />
                                                </div>

                                                <div className="form-row-gf">
                                                    <div className="form-group-gf">
                                                        <label>Permission Level</label>
                                                        <select value={permissionLevel} onChange={e => setPermissionLevel(e.target.value)}>
                                                            <option value="Super">Super Administrator</option>
                                                            <option value="Standard">Standard Administrator</option>
                                                            <option value="Audit">Audit Only</option>
                                                        </select>
                                                    </div>
                                                    <div className="form-group-gf">
                                                        <label>Assigned Department</label>
                                                        <input 
                                                            type="text" 
                                                            value={assignedDepartment}
                                                            onChange={e => setAssignedDepartment(e.target.value)}
                                                            placeholder="e.g. IT Operations"
                                                        />
                                                    </div>
                                                </div>
                                            </React.Fragment>
                                        )}
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
                                        {isSubmitting ? 'Saving...' : drawerMode === 'edit' ? 'Update User' : 'Save User'}
                                    </button>
                                )}
                            </footer>
                        </div>
                    </div>
                )}

                {/* Centered Deletion Confirmation Modal Overlay */}
                {deleteModalOpen && userToDelete && (
                    <div className="modal-overlay-gf" onClick={() => setDeleteModalOpen(false)}>
                        <div className="modal-box-gf" onClick={e => e.stopPropagation()}>
                            <h3 className="modal-title-gf">
                                <i className="fas fa-exclamation-triangle"></i> Safe Deletion Warning
                            </h3>
                            <div className="modal-body-gf">
                                <p>
                                    Are you absolutely sure you want to delete <strong>{userToDelete.fullName}</strong> ({userToDelete.email})?
                                </p>
                                <p style={{ marginTop: '0.5rem', fontSize: '0.85rem', color: 'var(--gf-red)' }}>
                                    This action is irreversible and will purge all core user qualifications, grades, submissions, and course enrollments.
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
    root.render(<UsersManagement />);
</script>
</body>
</html>
