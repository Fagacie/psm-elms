const { useState, useEffect, useMemo, useCallback, useRef } = window.React || React;
const ReactDOM = window.ReactDOM;

    const styles = {
        viewport: 'prof_viewport',
        container: 'prof_container',
        
        // Top Banner
        topBanner: 'prof_topBanner',
        bannerLeft: 'prof_bannerLeft',
        bannerRight: 'prof_bannerRight',
        bannerKicker: 'prof_bannerKicker',
        bannerTitle: 'prof_bannerTitle',
        bannerSubtitle: 'prof_bannerSubtitle',
        bannerBtnPrimary: 'prof_bannerBtnPrimary',
        bannerBtnSecondary: 'prof_bannerBtnSecondary',
        
        // KPI Row
        kpiRow: 'prof_kpiRow',
        kpiCard: 'prof_kpiCard',
        kpiNum: 'prof_kpiNum',
        kpiLabel: 'prof_kpiLabel',
        
        // Grid layout
        grid: 'prof_grid',
        sidebar: 'prof_sidebar',
        sidebarTitle: 'prof_sidebarTitle',
        avatarCircle: 'prof_avatarCircle',
        avatarImg: 'prof_avatarImg',
        avatarPlaceholder: 'prof_avatarPlaceholder',
        avatarOverlay: 'prof_avatarOverlay',
        profileName: 'prof_profileName',
        profileRole: 'prof_profileRole',
        uploadBtn: 'prof_uploadBtn',
        sidebarFields: 'prof_sidebarFields',
        sidebarFieldCard: 'prof_sidebarFieldCard',
        sidebarFieldLabel: 'prof_sidebarFieldLabel',
        sidebarFieldValue: 'prof_sidebarFieldValue',
        statusBadge: 'prof_statusBadge',
        
        // Main Content
        mainContent: 'prof_mainContent',
        card: 'prof_card',
        cardTitle: 'prof_cardTitle',
        formGrid: 'prof_formGrid',
        field: 'prof_field',
        label: 'prof_label',
        input: 'prof_input',
        inputReadOnly: 'prof_inputReadOnly',
        select: 'prof_select',
        
        // Account Settings buttons
        saveBtn: 'prof_saveBtn',
        settingsBtnOutline: 'prof_settingsBtnOutline',
        
        // Modal
        modalOverlay: 'prof_modalOverlay',
        modalContent: 'prof_modalContent',
        modalHeader: 'prof_modalHeader',
        modalTitle: 'prof_modalTitle',
        modalClose: 'prof_modalClose',
        modalForm: 'prof_modalForm',
        passwordNote: 'prof_passwordNote'
    };

    const countries = [
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan",
        "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia",
        "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada",
        "Cape Verde", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo", "Costa Rica", "Croatia",
        "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador",
        "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia",
        "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras",
        "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy",
        "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia",
        "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia", "Madagascar",
        "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia",
        "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal",
        "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "Norway", "Oman", "Pakistan", "Palau",
        "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania",
        "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal",
        "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea",
        "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan",
        "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan",
        "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City",
        "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"
    ];

    const statesByCountry = {
        'United States': ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'],
        'Canada': ['Alberta', 'British Columbia', 'Manitoba', 'New Brunswick', 'Newfoundland and Labrador', 'Northwest Territories', 'Nova Scotia', 'Nunavut', 'Ontario', 'Prince Edward Island', 'Quebec', 'Saskatchewan', 'Yukon'],
        'Australia': ['Australian Capital Territory', 'New South Wales', 'Northern Territory', 'Queensland', 'South Australia', 'Tasmania', 'Victoria', 'Western Australia'],
        'India': ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Puducherry', 'Lakshadweep', 'Daman and Diu'],
        'Brazil': ['Acre', 'Alagoas', 'Amapá', 'Amazonas', 'Bahia', 'Ceará', 'Distrito Federal', 'Espírito Santo', 'Goiás', 'Maranhão', 'Mato Grosso', 'Mato Grosso do Sul', 'Minas Gerais', 'Pará', 'Paraíba', 'Paraná', 'Pernambuco', 'Piauí', 'Rio de Janeiro', 'Rio Grande do Norte', 'Rio Grande do Sul', 'Rondônia', 'Roraima', 'Santa Catarina', 'São Paulo', 'Sergipe', 'Tocantins'],
        'Mexico': ['Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche', 'Chiapas', 'Chihuahua', 'Coahuila', 'Colima', 'Durango', 'Guanajuato', 'Guerrero', 'Hidalgo', 'Jalisco', 'Mexico City', 'México', 'Michoacán', 'Morelos', 'Nayarit', 'Nuevo León', 'Oaxaca', 'Puebla', 'Querétaro', 'Quintana Roo', 'San Luis Potosí', 'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 'Veracruz', 'Yucatán', 'Zacatecas'],
        'Nigeria': ['Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu', 'Federal Capital Territory', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina', 'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun', 'Ondo', 'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara'],
        'Tanzania': ['Arusha', 'Dar es Salaam', 'Dodoma', 'Geita', 'Iringa', 'Kagera', 'Katavi', 'Kigoma', 'Kilimanjaro', 'Lindi', 'Manyara', 'Mbeya', 'Morogoro', 'Moshi', 'Mwanza', 'Pwani', 'Ruvuma', 'Singida', 'Tabora', 'Tanga'],
        'United Kingdom': ['England', 'Scotland', 'Wales', 'Northern Ireland'],
        'Germany': ['Baden-Württemberg', 'Bavaria', 'Berlin', 'Brandenburg', 'Bremen', 'Hamburg', 'Hesse', 'Lower Saxony', 'Mecklenburg-Vorpommern', 'North Rhine-Westphalia', 'Rhineland-Palatinate', 'Saarland', 'Saxony', 'Saxony-Anhalt', 'Schleswig-Holstein', 'Thuringia'],
        'France': ['Alsace', 'Aquitaine', 'Auvergne', 'Bourgogne', 'Brittany', 'Centre', 'Champagne-Ardenne', 'Corsica', 'Franche-Comté', 'Île-de-France', 'Languedoc-Roussillon', 'Limousin', 'Lorraine', 'Midi-Pyrénées', 'Nord-Pas-de-Calais', 'Normandy', 'Pays de la Loire', 'Picardy', 'Poitou-Charentes', 'Provence-Alpes-Côte d\'Azur', 'Rhône-Alpes'],
        'Spain': ['Andalusia', 'Aragon', 'Asturias', 'Balearic Islands', 'Basque Country', 'Canary Islands', 'Cantabria', 'Castile and León', 'Castilla-La Mancha', 'Catalonia', 'Extremadura', 'Galicia', 'La Rioja', 'Madrid', 'Murcia', 'Navarre', 'Valencia'],
        'Italy': ['Abruzzo', 'Aosta Valley', 'Apulia', 'Basilicata', 'Calabria', 'Campania', 'Emilia-Romagna', 'Friuli Venezia Giulia', 'Lazio', 'Liguria', 'Lombardy', 'Marche', 'Molise', 'Piedmont', 'Sardinia', 'Sicily', 'Trentino-Alto Adige', 'Tuscany', 'Umbria', 'Veneto'],
        'China': ['Anhui', 'Beijing', 'Chongqing', 'Fujian', 'Gansu', 'Guangdong', 'Guangxi', 'Guizhou', 'Hainan', 'Hebei', 'Heilongjiang', 'Henan', 'Hong Kong', 'Hubei', 'Hunan', 'Inner Mongolia', 'Jiangsu', 'Jiangxi', 'Jilin', 'Liaoning', 'Macau', 'Ningxia', 'Qinghai', 'Shaanxi', 'Shandong', 'Shanghai', 'Shanxi', 'Sichuan', 'Taiwan', 'Tianjin', 'Tibet', 'Xinjiang', 'Yunnan', 'Zhejiang'],
        'Japan': ['Aichi', 'Akita', 'Aomori', 'Chiba', 'Ehime', 'Fukui', 'Fukuoka', 'Fukushima', 'Gifu', 'Gunma', 'Hiroshima', 'Hokkaido', 'Hyogo', 'Ibaraki', 'Ishikawa', 'Iwate', 'Kagawa', 'Kagoshima', 'Kanagawa', 'Kochi', 'Kumamoto', 'Kyoto', 'Mie', 'Miyagi', 'Miyazaki', 'Nagano', 'Nagasaki', 'Nara', 'Niigata', 'Oita', 'Okayama', 'Okinawa', 'Osaka', 'Saga', 'Saitama', 'Shiga', 'Shimane', 'Shizuoka', 'Tochigi', 'Tomoyama', 'Wakayama', 'Yamagata', 'Yamaguchi', 'Yamanashi'],
        'South Korea': ['Seoul', 'Busan', 'Daegu', 'Incheon', 'Gwangju', 'Daejeon', 'Ulsan', 'Gyeonggi', 'Gangwon', 'North Chungcheong', 'South Chungcheong', 'North Jeolla', 'South Jeolla', 'North Gyeongsang', 'South Gyeongsang', 'Jeju']
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
                    {/* Alert Banners */}
                    {alerts.profileSuccess && (
                        <div className="alert alert-success" style={{ borderRadius: '8px', margin: '0 0 16px 0', display: 'flex', alignItems: 'center' }}>
                            <i className="fas fa-check-circle" style={{ marginRight: '8px' }}></i> {alerts.profileSuccess}
                        </div>
                    )}
                    {alerts.profileError && (
                        <div className="alert alert-error" style={{ borderRadius: '8px', margin: '0 0 16px 0', display: 'flex', alignItems: 'center' }}>
                            <i className="fas fa-exclamation-circle" style={{ marginRight: '8px' }}></i> {alerts.profileError}
                        </div>
                    )}
                    {alerts.passwordSuccess && (
                        <div className="alert alert-success" style={{ borderRadius: '8px', margin: '0 0 16px 0', display: 'flex', alignItems: 'center' }}>
                            <i className="fas fa-check-circle" style={{ marginRight: '8px' }}></i> {alerts.passwordSuccess}
                        </div>
                    )}
                    {alerts.passwordError && (
                        <div className="alert alert-error" style={{ borderRadius: '8px', margin: '0 0 16px 0', display: 'flex', alignItems: 'center' }}>
                            <i className="fas fa-exclamation-circle" style={{ marginRight: '8px' }}></i> {alerts.passwordError}
                        </div>
                    )}

                    {/* Two-Column Workspace Layout */}
                    <div className={styles.grid}>
                        
                        {/* Left Side: Account Overview Sidebar */}
                        <aside className={styles.sidebar}>
                            <div className={styles.sidebarTitle}>Account Overview</div>
                            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', width: '100%', gap: '16px' }}>
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
                                                <i className="fas fa-user" style={{ fontSize: '2.5rem', color: '#cbd5e1' }}></i>
                                            </div>
                                        )}
                                        <div className={styles.avatarOverlay}>
                                            <i className="fas fa-camera" style={{ fontSize: '1.25rem', color: '#ffffff' }}></i>
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

                                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px' }}>
                                    <h3 className={styles.profileName}>{fullName || 'N/A'}</h3>
                                    <span className={styles.profileRole}>{data.userRole}</span>
                                </div>

                                <button type="button" className={styles.uploadBtn} onClick={triggerFileSelect}>
                                    <i className="fas fa-camera" style={{ marginRight: '8px' }}></i>
                                    Upload Photo
                                </button>

                                <div className={styles.sidebarFields}>
                                    <div className={styles.sidebarFieldCard}>
                                        <span className={styles.sidebarFieldLabel}>Full Name</span>
                                        <span className={styles.sidebarFieldValue}>{fullName || 'N/A'}</span>
                                    </div>
                                    {data.userRole === 'Student' && (
                                        <div className={styles.sidebarFieldCard}>
                                            <span className={styles.sidebarFieldLabel}>Student ID</span>
                                            <span className={styles.sidebarFieldValue}>{data.studentRegNumber || 'N/A'}</span>
                                        </div>
                                    )}
                                    <div className={styles.sidebarFieldCard}>
                                        <span className={styles.sidebarFieldLabel}>Status</span>
                                        <span className={styles.statusBadge}>Active</span>
                                    </div>
                                </div>
                            </div>
                        </aside>

                        {/* Right Side: Primary Forms Main Content */}
                        <div className={styles.mainContent}>
                            <form 
                                action={window.contextPath + "/profile"} 
                                method="post" 
                                onSubmit={handleProfileSubmit}
                                style={{ display: 'flex', flexDirection: 'column', gap: '24px', margin: 0 }}
                            >
                                {/* Card 1: Personal Information */}
                                <div className={styles.card}>
                                    <h3 className={styles.cardTitle}>Personal Information</h3>
                                    
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
                                            <label className={styles.label}>Email Address</label>
                                            <input 
                                                type="text" 
                                                value={data.email}
                                                readOnly
                                                className={styles.inputReadOnly} 
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
                                                    <select 
                                                        name="country" 
                                                        value={country}
                                                        onChange={(e) => {
                                                            setCountry(e.target.value);
                                                            setState('');
                                                        }}
                                                        className={styles.select}
                                                    >
                                                        <option value="">Select Country</option>
                                                        {countries.map(c => <option key={c} value={c}>{c}</option>)}
                                                    </select>
                                                </div>

                                                <div className={styles.field}>
                                                    <label className={styles.label}>State / Province</label>
                                                    {(statesByCountry[country] || []).length > 0 ? (
                                                        <select 
                                                            name="state" 
                                                            value={state}
                                                            onChange={(e) => setState(e.target.value)}
                                                            className={styles.select}
                                                        >
                                                            <option value="">Select State/Province</option>
                                                            {(statesByCountry[country] || []).map(s => <option key={s} value={s}>{s}</option>)}
                                                            {state && (statesByCountry[country] || []).indexOf(state) === -1 && (
                                                                <option value={state}>{state}</option>
                                                            )}
                                                        </select>
                                                    ) : (
                                                        <input 
                                                            type="text" 
                                                            name="state" 
                                                            value={state}
                                                            onChange={(e) => setState(e.target.value)}
                                                            placeholder="Enter State/Province"
                                                            className={styles.input} 
                                                        />
                                                    )}
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
                                            </>
                                        )}
                                    </div>
                                </div>

                                {/* Card 2: Academic / Professional Information */}
                                {(data.userRole === 'Student' || data.userRole === 'Instructor') && (
                                    <div className={styles.card}>
                                        <h3 className={styles.cardTitle}>
                                            {data.userRole === 'Student' ? 'Academic Information' : 'Professional Record'}
                                        </h3>
                                        
                                        <div className={styles.formGrid}>
                                            {data.userRole === 'Student' && (
                                                <>
                                                    <div className={styles.field}>
                                                        <label className={styles.label}>Registration Number</label>
                                                        <input 
                                                            type="text" 
                                                            value={data.studentRegNumber || 'N/A'}
                                                            readOnly 
                                                            className={styles.inputReadOnly} 
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

                                            {data.userRole === 'Instructor' && (
                                                <>
                                                    <div className={styles.field}>
                                                        <label className={styles.label}>Academic Specialization</label>
                                                        <input 
                                                            type="text" 
                                                            value={data.instructorSpecialization || 'N/A'}
                                                            readOnly 
                                                            className={styles.inputReadOnly} 
                                                        />
                                                    </div>

                                                    <div className={styles.field}>
                                                        <label className={styles.label}>Years of Experience</label>
                                                        <input 
                                                            type="text" 
                                                            value={data.instructorYearsOfExperience ? `${data.instructorYearsOfExperience} Years` : 'N/A'}
                                                            readOnly 
                                                            className={styles.inputReadOnly} 
                                                        />
                                                    </div>

                                                    <div className={styles.field}>
                                                        <label className={styles.label}>Key Certifications</label>
                                                        <input 
                                                            type="text" 
                                                            value={data.instructorCertification || 'N/A'}
                                                            readOnly 
                                                            className={styles.inputReadOnly} 
                                                        />
                                                    </div>

                                                    <div className={styles.field}>
                                                        <label className={styles.label}>Date of Hire</label>
                                                        <input 
                                                            type="text" 
                                                            value={data.instructorHireDate || 'N/A'}
                                                            readOnly 
                                                            className={styles.inputReadOnly} 
                                                        />
                                                    </div>
                                                </>
                                            )}
                                        </div>
                                    </div>
                                )}

                                {/* Card 3: Account Settings */}
                                <div className={styles.card}>
                                    <h3 className={styles.cardTitle}>Account Settings</h3>
                                    
                                    <div style={{ display: 'flex', gap: '12px', alignItems: 'center', flexWrap: 'wrap' }}>
                                        <button 
                                            type="submit" 
                                            className={styles.saveBtn}
                                            disabled={savingProfile}
                                            style={{ display: 'inline-flex', alignItems: 'center', gap: '8px' }}
                                        >
                                            {savingProfile ? (
                                                <i className="fas fa-spinner fa-spin"></i>
                                            ) : (
                                                <i className="fas fa-save"></i>
                                            )}
                                            <span>Save Changes</span>
                                        </button>

                                        <button 
                                            type="button" 
                                            className={styles.settingsBtnOutline}
                                            style={{ display: 'inline-flex', alignItems: 'center', gap: '8px' }}
                                            onClick={() => setShowPasswordModal(true)}
                                        >
                                            <i className="fas fa-key"></i>
                                            <span>Change Password</span>
                                        </button>

                                        <a href={window.contextPath + "/dashboard"} className={styles.settingsBtnOutline} style={{ display: 'inline-flex', alignItems: 'center', gap: '8px' }}>
                                            <i className="fas fa-arrow-left"></i>
                                            <span>Back to Dashboard</span>
                                        </a>
                                    </div>
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
                                        className={styles.saveBtn} 
                                        style={{ flex: 2, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}
                                        disabled={updatingPassword}
                                    >
                                        {updatingPassword ? (
                                            <i className="fas fa-spinner fa-spin"></i>
                                        ) : (
                                            <i className="fas fa-lock"></i>
                                        )}
                                        <span>Update Password</span>
                                    </button>
                                    <button 
                                        type="button" 
                                        className={styles.settingsBtnOutline} 
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
