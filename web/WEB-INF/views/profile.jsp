<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="isAdminProfile" value="${sessionScope.userRole == 'Admin'}"/>
<c:set var="isStudentProfile" value="${sessionScope.userRole == 'Student'}"/>
<c:set var="isInstructorProfile" value="${sessionScope.userRole == 'Instructor'}"/>
<c:set var="openPasswordModal" value="${param.openPasswordModal == '1' or not empty sessionScope.passwordError}" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Settings | PSM E-Learning</title>
    <jsp:include page="/WEB-INF/views/common/student-head-assets.jsp"/>
    <c:if test="${isAdminProfile}">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    </c:if>
    <c:if test="${isInstructorProfile}">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/instructor-shell.css">
    </c:if>
    <!-- Scoped Profile Settings CSS Module -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Profile.module.css">
    
    <!-- React, Animation & Lucide CDNs -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <script src="https://unpkg.com/framer-motion@10.16.4/dist/framer-motion.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="${isInstructorProfile ? 'instructor-ui' : (isAdminProfile ? 'admin-page profile-admin sv-page' : 'sv-page')}">
<c:choose>
    <c:when test="${isInstructorProfile}">
        <jsp:include page="/WEB-INF/views/common/instructor-header.jsp">
            <jsp:param name="pageTitle" value="Profile"/>
        </jsp:include>
    </c:when>
    <c:when test="${isAdminProfile}">
        <jsp:include page="/WEB-INF/views/common/admin-header.jsp">
            <jsp:param name="pageTitle" value="Profile"/>
            <jsp:param name="pageSubtitle" value="Manage your account details and personal information"/>
        </jsp:include>
    </c:when>
    <c:when test="${isStudentProfile}">
        <c:set var="topbarTitle" value="Profile"/>
        <c:set var="topbarSubtitle" value="Manage your account details and personal information"/>
        <c:set var="topbarShowSearch" value="false"/>
        <jsp:include page="/WEB-INF/views/common/student-topbar.jsp"/>
    </c:when>
    <c:otherwise>
        <c:set var="topbarTitle" value="Profile"/>
        <c:set var="topbarSubtitle" value="Manage your account details and personal information"/>
        <jsp:include page="/WEB-INF/views/common/account-topbar.jsp"/>
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${isInstructorProfile}">
        <c:set var="activeInstructorPage" value="profile"/>
        <jsp:include page="/WEB-INF/views/common/instructor-sidebar.jsp"/>
        
        <main class="app-main profile-page">
            <div class="content-wrapper">
                <nav class="breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                    <span>&gt;</span>
                    <span>Profile</span>
                </nav>
    </c:when>
    <c:otherwise>
        <div class="sv-layout">
            <c:choose>
                <c:when test="${isAdminProfile}">
                    <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>
                </c:when>
                <c:when test="${isStudentProfile}">
                    <c:set var="activePage" value="profile"/>
                    <jsp:include page="/WEB-INF/views/common/student-sidebar.jsp"/>
                </c:when>
                <c:otherwise>
                    <c:set var="activePage" value="profile"/>
                    <jsp:include page="/WEB-INF/views/common/account-sidebar.jsp"/>
                </c:otherwise>
            </c:choose>

            <main class="sv-main profile-page">
                <div class="sv-breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                    <i class="fas fa-angle-right"></i>
                    <span>Profile</span>
                </div>
    </c:otherwise>
</c:choose>

        <!-- React Account Settings Workspace Target Root -->
        <div id="profile-settings-react-root"></div>

<c:choose>
    <c:when test="${isInstructorProfile}">
            </div>
        </main>
    </c:when>
    <c:otherwise>
    </main>
</div>
    </c:otherwise>
</c:choose>

<!-- JSTL JSP Data Bridge to browser React state variables -->
<script>
    window.contextPath = "${pageContext.request.contextPath}";
    window.profileData = {
        fullName: `${fn:escapeXml(user.fullName)}`,
        email: `${fn:escapeXml(user.email)}`,
        phone: `${fn:escapeXml(user.phone)}`,
        userRole: "${sessionScope.userRole}",
        profilePicture: "${user.profilePicture}",
        
        // Student Specific Details
        studentRegNumber: "${student.regNumber}",
        studentDob: "${student.dob}",
        studentGender: "${student.gender}",
        studentCountry: `${fn:escapeXml(student.country)}`,
        studentState: `${fn:escapeXml(student.state)}`,
        studentEmergencyContact: "${student.emergencyContact}",
        studentQualification: `${fn:escapeXml(student.qualification)}`,
        studentPassportPath: "${student.passportPath}",

        // Instructor Specific Details
        instructorSpecialization: `${fn:escapeXml(instructor.specialization)}`,
        instructorYearsOfExperience: "${instructor.yearsOfExperience}",
        instructorCertification: `${fn:escapeXml(instructor.certification)}`,
        instructorHireDate: "${instructor.hireDate}"
    };
    
    window.profileStatus = {
        profileSuccess: `${fn:escapeXml(sessionScope.profileSuccess)}`,
        profileError: `${fn:escapeXml(sessionScope.profileError)}`,
        passwordSuccess: `${fn:escapeXml(sessionScope.passwordSuccess)}`,
        passwordError: `${fn:escapeXml(sessionScope.passwordError)}`,
        openPasswordModal: ${openPasswordModal}
    };
</script>
<c:remove var="profileSuccess" scope="session"/>
<c:remove var="profileError" scope="session"/>
<c:remove var="passwordSuccess" scope="session"/>
<c:remove var="passwordError" scope="session"/>

<!-- React Settings Workspace compiled in browser via Babel -->
<script type="text/babel">
    const styles = {
        viewport: 'prof_viewport',
        container: 'prof_container',
        header: 'prof_header',
        titleSection: 'prof_titleSection',
        title: 'prof_title',
        subtitle: 'prof_subtitle',
        grid: 'prof_grid',
        sidebar: 'prof_sidebar',
        avatarCircle: 'prof_avatarCircle',
        avatarImg: 'prof_avatarImg',
        avatarPlaceholder: 'prof_avatarPlaceholder',
        avatarOverlay: 'prof_avatarOverlay',
        avatarLabel: 'prof_avatarLabel',
        name: 'prof_name',
        role: 'prof_role',
        metaList: 'prof_metaList',
        metaItem: 'prof_metaItem',
        metaLabel: 'prof_metaLabel',
        metaValue: 'prof_metaValue',
        mainContent: 'prof_mainContent',
        card: 'prof_card',
        sectionTitle: 'prof_sectionTitle',
        sectionDesc: 'prof_sectionDesc',
        formGrid: 'prof_formGrid',
        field: 'prof_field',
        fieldFull: 'prof_fieldFull',
        label: 'prof_label',
        input: 'prof_input',
        inputReadOnly: 'prof_inputReadOnly',
        select: 'prof_select',
        cardActions: 'prof_cardActions',
        primaryBtn: 'prof_primaryBtn',
        secondaryBtn: 'prof_secondaryBtn',
        btnGroup: 'prof_btnGroup',
        modalOverlay: 'prof_modalOverlay',
        modalContent: 'prof_modalContent',
        modalHeader: 'prof_modalHeader',
        modalTitle: 'prof_modalTitle',
        modalClose: 'prof_modalClose',
        modalForm: 'prof_modalForm',
        passwordNote: 'prof_passwordNote'
    };

    const ProfileSettingsWorkspace = () => {
        const data = window.profileData || {};
        const status = window.profileStatus || {};

        const [fullName, setFullName] = React.useState(data.fullName || '');
        const [phone, setPhone] = React.useState(data.phone || '');
        const [dob, setDob] = React.useState(data.studentDob || '');
        const [gender, setGender] = React.useState(data.studentGender || '');
        const [country, setCountry] = React.useState(data.studentCountry || '');
        const [state, setState] = React.useState(data.studentState || '');
        const [emergencyContact, setEmergencyContact] = React.useState(data.studentEmergencyContact || '');
        const [qualification, setQualification] = React.useState(data.studentQualification || '');

        const [savingProfile, setSavingProfile] = React.useState(false);
        const [updatingPassword, setUpdatingPassword] = React.useState(false);
        const [showPasswordModal, setShowPasswordModal] = React.useState(status.openPasswordModal || false);
        
        const fileInputRef = React.useRef(null);

        // Alert banners
        const [alerts, setAlerts] = React.useState({
            profileSuccess: status.profileSuccess || '',
            profileError: status.profileError || '',
            passwordSuccess: status.passwordSuccess || '',
            passwordError: status.passwordError || ''
        });

        React.useEffect(() => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        }, [alerts, savingProfile, updatingPassword, showPasswordModal]);

        const triggerFileSelect = () => {
            if (fileInputRef.current) {
                fileInputRef.current.click();
            }
        };

        const handlePhotoChange = (e) => {
            if (e.target.files && e.target.files[0]) {
                document.getElementById('photoUploadForm').submit();
            }
        };

        const handleProfileSubmit = (e) => {
            setSavingProfile(true);
        };

        const handlePasswordSubmit = (e) => {
            const newPass = document.getElementById('newPassword').value;
            const confirmPass = document.getElementById('confirmPassword').value;

            if (newPass !== confirmPass) {
                e.preventDefault();
                alert('New password and confirmation password do not match. Please try again.');
                return;
            }
            setUpdatingPassword(true);
        };

        // Determine correct avatar path
        let avatarUrl = '';
        if (data.profilePicture) {
            avatarUrl = data.profilePicture.startsWith('http') ? data.profilePicture : (window.contextPath + '/' + data.profilePicture);
        } else if (data.studentPassportPath) {
            avatarUrl = data.studentPassportPath.startsWith('http') ? data.studentPassportPath : (window.contextPath + '/' + data.studentPassportPath);
        }

        return (
            <div className={styles.viewport}>
                <div className={styles.container}>
                    {/* Header Banner */}
                    <div className={styles.header}>
                        <div className={styles.titleSection}>
                            <h2 className={styles.title}>Account Settings</h2>
                            <p className={styles.subtitle}>Manage your personal information, role details, and security.</p>
                        </div>
                    </div>

                    {/* Alert Banners */}
                    {alerts.profileSuccess && (
                        <div className="alert alert-success" style={{ borderRadius: '8px', margin: 0 }}>
                            <i className="fas fa-check-circle" style={{ marginRight: '8px' }}></i> {alerts.profileSuccess}
                        </div>
                    )}
                    {alerts.profileError && (
                        <div className="alert alert-error" style={{ borderRadius: '8px', margin: 0 }}>
                            <i className="fas fa-exclamation-circle" style={{ marginRight: '8px' }}></i> {alerts.profileError}
                        </div>
                    )}
                    {alerts.passwordSuccess && (
                        <div className="alert alert-success" style={{ borderRadius: '8px', margin: 0 }}>
                            <i className="fas fa-check-circle" style={{ marginRight: '8px' }}></i> {alerts.passwordSuccess}
                        </div>
                    )}
                    {alerts.passwordError && (
                        <div className="alert alert-error" style={{ borderRadius: '8px', margin: 0 }}>
                            <i className="fas fa-exclamation-circle" style={{ marginRight: '8px' }}></i> {alerts.passwordError}
                        </div>
                    )}

                    {/* Two-Column Workspace Layout */}
                    <div className={styles.grid}>
                        
                        {/* Left Side: Avatar and Metadata Sidebar */}
                        <aside className={styles.sidebar}>
                            <form 
                                action={window.contextPath + "/profile-picture"} 
                                method="post" 
                                enctype="multipart/form-data" 
                                id="photoUploadForm" 
                                style={{ margin: 0 }}
                            >
                                <div className={styles.avatarCircle} onClick={triggerFileSelect}>
                                    {avatarUrl ? (
                                        <img src={avatarUrl} alt="Profile Photo" className={styles.avatarImg} />
                                    ) : (
                                        <div className={styles.avatarPlaceholder}>
                                            <i data-lucide="user" style={{ width: 44, height: 44, color: '#cbd5e1' }}></i>
                                        </div>
                                    )}
                                    <div className={styles.avatarOverlay}>
                                        <i data-lucide="camera" style={{ width: 22, height: 22, color: '#ffffff' }}></i>
                                    </div>
                                </div>
                                <input 
                                    type="file" 
                                    name="passportPhoto" 
                                    id="photoInput" 
                                    ref={fileInputRef}
                                    onChange={handlePhotoChange}
                                    accept="image/jpeg,image/png,image/gif" 
                                    style={{ display: 'none' }} 
                                    required 
                                />
                            </form>

                            <h3 className={styles.name}>{fullName || 'N/A'}</h3>
                            <span className={styles.role}>{data.userRole}</span>

                            <div className={styles.metaList}>
                                <div className={styles.metaItem}>
                                    <span className={styles.metaLabel}>Email Address</span>
                                    <span className={styles.metaValue} style={{ wordBreak: 'break-all' }}>{data.email}</span>
                                </div>
                                {data.userRole === 'Student' && (
                                    <div className={styles.metaItem}>
                                        <span className={styles.metaLabel}>Student ID</span>
                                        <span className={styles.metaValue}>{data.studentRegNumber || 'N/A'}</span>
                                    </div>
                                )}
                                {data.userRole === 'Instructor' && data.instructorSpecialization && (
                                    <div className={styles.metaItem}>
                                        <span className={styles.metaLabel}>Specialization</span>
                                        <span className={styles.metaValue}>{data.instructorSpecialization}</span>
                                    </div>
                                )}
                            </div>
                        </aside>

                        {/* Right Side: Primary Forms Main Content */}
                        <div className={styles.mainContent}>
                            <form 
                                action={window.contextPath + "/profile"} 
                                method="post" 
                                onSubmit={handleProfileSubmit}
                                className={styles.card}
                            >
                                <h3 className={styles.sectionTitle}>Personal Details</h3>
                                <p className={styles.sectionDesc}>Update your profile fields and contact details.</p>
                                
                                <div className={styles.formGrid}>
                                    <div className={styles.field}>
                                        <label className={styles.label}>Full Name *</label>
                                        <input 
                                            type="text" 
                                            name="fullName" 
                                            value={fullName}
                                            onChange={(e) => setFullName(e.target.value)}
                                            required 
                                            className={styles.input} 
                                        />
                                    </div>

                                    <div className={styles.field}>
                                        <label className={styles.label}>Phone Number</label>
                                        <input 
                                            type="tel" 
                                            name="phone" 
                                            value={phone}
                                            onChange={(e) => setPhone(e.target.value)}
                                            className={styles.input} 
                                        />
                                    </div>

                                    {data.userRole === 'Student' && (
                                        <>
                                            <div className={styles.field}>
                                                <label className={styles.label}>Date of Birth</label>
                                                <input 
                                                    type="date" 
                                                    name="dob" 
                                                    value={dob}
                                                    onChange={(e) => setDob(e.target.value)}
                                                    className={styles.input} 
                                                />
                                            </div>

                                            <div className={styles.field}>
                                                <label className={styles.label}>Gender</label>
                                                <select 
                                                    name="gender" 
                                                    value={gender}
                                                    onChange={(e) => setGender(e.target.value)}
                                                    className={styles.select}
                                                >
                                                    <option value="">Select Gender</option>
                                                    <option value="Male">Male</option>
                                                    <option value="Female">Female</option>
                                                </select>
                                            </div>

                                            <div className={styles.field}>
                                                <label className={styles.label}>Country</label>
                                                <input 
                                                    type="text" 
                                                    name="country" 
                                                    value={country}
                                                    onChange={(e) => setCountry(e.target.value)}
                                                    className={styles.input} 
                                                />
                                            </div>

                                            <div className={styles.field}>
                                                <label className={styles.label}>State / Province</label>
                                                <input 
                                                    type="text" 
                                                    name="state" 
                                                    value={state}
                                                    onChange={(e) => setState(e.target.value)}
                                                    className={styles.input} 
                                                />
                                            </div>

                                            <div className={styles.field}>
                                                <label className={styles.label}>Emergency Contact</label>
                                                <input 
                                                    type="tel" 
                                                    name="emergencyContact" 
                                                    value={emergencyContact}
                                                    onChange={(e) => setEmergencyContact(e.target.value)}
                                                    className={styles.input} 
                                                />
                                            </div>

                                            <div className={styles.field}>
                                                <label className={styles.label}>Qualification</label>
                                                <input 
                                                    type="text" 
                                                    name="qualification" 
                                                    value={qualification}
                                                    onChange={(e) => setQualification(e.target.value)}
                                                    className={styles.input} 
                                                />
                                            </div>
                                        </>
                                    )}
                                </div>

                                <div className={styles.cardActions}>
                                    <button 
                                        type="submit" 
                                        className={styles.primaryBtn}
                                        disabled={savingProfile}
                                        style={{ marginRight: 'auto' }}
                                    >
                                        {savingProfile ? (
                                            <i className="fas fa-spinner fa-spin" style={{ marginRight: 8 }}></i>
                                        ) : (
                                            <i data-lucide="save" style={{ width: 14, height: 14 }}></i>
                                        )}
                                        <span>{savingProfile ? 'Saving...' : 'Save Changes'}</span>
                                    </button>

                                    <button 
                                        type="button" 
                                        className={styles.primaryBtn}
                                        style={{ background: '#2563eb !important', borderColor: '#2563eb !important' }}
                                        onClick={() => setShowPasswordModal(true)}
                                    >
                                        <i data-lucide="lock" style={{ width: 14, height: 14 }}></i>
                                        <span>Change Password</span>
                                    </button>

                                    <a href={window.contextPath + "/dashboard"} className={styles.secondaryBtn}>
                                        <i data-lucide="arrow-left" style={{ width: 14, height: 14 }}></i>
                                        <span>Back</span>
                                    </a>
                                </div>
                            </form>


                        </div>

                    </div>
                </div>

                {/* Scoped floating Password Update Modal Overlay */}
                {showPasswordModal && (
                    <div className={styles.modalOverlay}>
                        <div className={styles.modalContent}>
                            <div className={styles.modalHeader}>
                                <div>
                                    <h3 className={styles.modalTitle}>Change Password</h3>
                                    <p style={{ margin: '4px 0 0 0', fontSize: '0.82rem', color: '#64748b' }}>
                                        Update your institutional account password below.
                                    </p>
                                </div>
                                <button 
                                    type="button" 
                                    className={styles.modalClose} 
                                    onClick={() => setShowPasswordModal(false)}
                                    aria-label="Close modal"
                                >
                                    <i className="fas fa-times"></i>
                                </button>
                            </div>

                            <form 
                                action={window.contextPath + "/change-password"} 
                                method="post" 
                                onSubmit={handlePasswordSubmit}
                                className={styles.modalForm}
                            >
                                <div className={styles.field}>
                                    <label className={styles.label}>Current Password *</label>
                                    <input 
                                        type="password" 
                                        id="currentPassword" 
                                        name="currentPassword" 
                                        required 
                                        placeholder="Enter current password" 
                                        className={styles.input} 
                                    />
                                </div>

                                <div className={styles.field}>
                                    <label className={styles.label}>New Password *</label>
                                    <input 
                                        type="password" 
                                        id="newPassword" 
                                        name="newPassword" 
                                        required 
                                        placeholder="Enter new password" 
                                        className={styles.input} 
                                    />
                                </div>

                                <div className={styles.field}>
                                    <label className={styles.label}>Confirm New Password *</label>
                                    <input 
                                        type="password" 
                                        id="confirmPassword" 
                                        name="confirmPassword" 
                                        required 
                                        placeholder="Confirm new password" 
                                        className={styles.input} 
                                    />
                                </div>

                                <p className={styles.passwordNote}>
                                    Use at least 8 characters, mixing letters, numbers, and symbols.
                                </p>

                                <div style={{ display: 'flex', gap: '12px', marginTop: '8px' }}>
                                    <button 
                                        type="submit" 
                                        className={styles.primaryBtn} 
                                        style={{ flex: 2 }}
                                        disabled={updatingPassword}
                                    >
                                        {updatingPassword ? (
                                            <i className="fas fa-spinner fa-spin" style={{ marginRight: 8 }}></i>
                                        ) : (
                                            <i data-lucide="lock" style={{ width: 14, height: 14 }}></i>
                                        )}
                                        <span>Update Password</span>
                                    </button>
                                    <button 
                                        type="button" 
                                        className={styles.secondaryBtn} 
                                        style={{ flex: 1 }}
                                        onClick={() => setShowPasswordModal(false)}
                                    >
                                        Cancel
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                )}
            </div>
        );
    };

    const container = document.getElementById('profile-settings-react-root');
    const root = ReactDOM.createRoot(container);
    root.render(<ProfileSettingsWorkspace />);
</script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
