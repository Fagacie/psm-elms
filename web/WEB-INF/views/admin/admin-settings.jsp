<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Platform Settings - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/AdminNav.module.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-settings-gf.css?v=1.1">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    
    <!-- React & ReactDOM UMD production versions -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
    
    <!-- Babel Standalone for live JSX translation -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>`n    
    
    <!-- React Hook Form UMD build -->
    <script src="https://unpkg.com/react-hook-form@7.51.5/dist/index.umd.js"></script>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Settings"/>
    <jsp:param name="pageSubtitle" value="Platform configurations and operational defaults"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <!-- Success/Error Banners in Greenfield Styling -->
    <div style="max-width: 1200px; margin: 2rem auto 0 auto; padding: 0 2rem;">
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
        <c:if test="${not empty infoMessage}">
            <div class="alert-gf alert-success-gf" style="background-color: #fef3c7; color: #b45309; border: 1px solid rgba(180, 83, 9, 0.15); margin-bottom: 1.5rem;">
                <i class="fas fa-info-circle"></i> <c:out value="${infoMessage}"/>
            </div>
        </c:if>
    </div>

    <!-- React Mounting Entry Node -->
    <div id="admin-react-root"></div>
</main>

<%-- JSTL data serialization to JSON bridge --%>
<%
    java.util.Map<String, String> settings = (java.util.Map<String, String>) request.getAttribute("settings");
    org.json.JSONObject sJson = new org.json.JSONObject();
    if (settings != null) {
        for (java.util.Map.Entry<String, String> e : settings.entrySet()) {
            sJson.put(e.getKey(), e.getValue() != null ? e.getValue() : "");
        }
    }
    
    java.util.List<com.psm.elearning.model.AppSettingAuditEntry> audits = (java.util.List<com.psm.elearning.model.AppSettingAuditEntry>) request.getAttribute("audits");
    org.json.JSONArray aJson = new org.json.JSONArray();
    if (audits != null) {
        for (com.psm.elearning.model.AppSettingAuditEntry entry : audits) {
            org.json.JSONObject obj = new org.json.JSONObject();
            obj.put("auditId", entry.getAuditId());
            obj.put("settingKey", entry.getSettingKey() != null ? entry.getSettingKey() : "");
            obj.put("oldValue", entry.getOldValue() != null ? entry.getOldValue() : "");
            obj.put("newValue", entry.getNewValue() != null ? entry.getNewValue() : "");
            obj.put("changedBy", entry.getChangedBy() != null ? entry.getChangedBy() : 0);
            obj.put("changedAt", entry.getChangedAt() != null ? entry.getChangedAt().toString() : "");
            aJson.put(obj);
        }
    }
    
    pageContext.setAttribute("serializedSettings", sJson.toString());
    pageContext.setAttribute("serializedAudits", aJson.toString());
%>

<script type="text/javascript">
    window.__CONTEXT_PATH__ = "${pageContext.request.contextPath}";
    window.__SETTINGS__ = ${serializedSettings};
    window.__AUDITS__ = ${serializedAudits};
    window.__HAS_PAYSTACK_SECRET__ = ${hasPaystackSecret != null ? hasPaystackSecret : false};
    window.__HAS_WEBHOOK_SECRET__ = ${hasWebhookSecret != null ? hasWebhookSecret : false};
    window.__HAS_SMTP_PASSWORD__ = ${hasSmtpPassword != null ? hasSmtpPassword : false};
    window.__HAS_CLOUDINARY_SECRET__ = ${hasCloudinarySecret != null ? hasCloudinarySecret : false};
</script>

<script src="${pageContext.request.contextPath}/js/react-jsx-bridge.js"></script>
    <script type="text/jsx-custom" data-plugins="transform-react-jsx">
    const { useState, useEffect } = React;
    const { useForm } = window.ReactHookForm || {};

    function SettingsHub() {
        const [activeTab, setActiveTab] = useState(() => {
            try { return sessionStorage.getItem('settingsActiveTab') || 'general'; } catch(e) { return 'general'; }
        });
        
        const [submitting, setSubmitting] = useState(false);
        const [formAction, setFormAction] = useState('save');
        const [toast, setToast] = useState(null);

        // Fetch values
        const s = window.__SETTINGS__ || {};
        const audits = window.__AUDITS__ || [];
        const ctxPath = window.__CONTEXT_PATH__;

        // Auto clear toast
        useEffect(() => {
            if (toast) {
                const timer = setTimeout(() => setToast(null), 5000);
                return () => clearTimeout(timer);
            }
        }, [toast]);

        // Form mapping
        const { register, handleSubmit, watch, getValues, formState: { errors } } = useForm({
            defaultValues: {
                platformName: s['platform.name'] || '',
                supportEmail: s['platform.supportEmail'] || '',
                timezone: s['platform.timezone'] || 'Africa/Lagos',
                maxFileUploadMB: s['platform.maxFileUploadMB'] || '50',
                certificateEnabled: s['platform.certificateEnabled'] !== 'false',
                
                sessionTimeoutMinutes: s['security.sessionTimeoutMinutes'] || '30',
                minPasswordLength: s['security.minPasswordLength'] || '8',
                
                paymentMode: s['payment.mode'] || 'LIVE',
                paymentCurrency: s['payment.currency'] || 'NGN',
                paystackEnabled: s['payment.paystack.enabled'] !== 'false',
                paystackPublicKey: s['payment.paystackPublicKey'] || '',
                paystackSecretKey: s['payment.paystackSecretKey'] || '',
                paystackWebhookSecret: s['payment.paystackWebhookSecret'] || '',
                paymentCallbackUrl: s['payment.callbackUrl'] || '',
                
                smtpHost: s['email.smtp.host'] || '',
                smtpPort: s['email.smtp.port'] || '587',
                smtpUsername: s['email.smtp.username'] || '',
                smtpPassword: s['email.smtp.password'] || '',
                smtpFromEmail: s['email.from.email'] || '',
                smtpFromName: s['email.from.name'] || 'PSM E-Learning Platform',
                smtpStartTls: s['email.smtp.starttls'] !== 'false',
                
                completionMaterialPercent: s['learning.completionMaterialPercent'] || '100',
                defaultPassMark: s['assessment.defaultPassMark'] || '70',
                defaultMaxAttempts: s['assessment.defaultMaxAttempts'] || '3',
                autoActivateEnrollment: s['enrollment.autoActivateOnPayment'] !== 'false',
                
                youtubeApiKey: s['platform.youtubeApiKey'] || '',
                defaultInstructorCommission: s['platform.defaultInstructorCommission'] || '20',
                autoApproveCourses: s['platform.autoApproveCourses'] === 'true',
                
                cloudinaryCloudName: s['cloudinary.cloudName'] || '',
                cloudinaryApiKey: s['cloudinary.apiKey'] || '',
                cloudinaryApiSecret: s['cloudinary.apiSecret'] || '',
                cloudinaryFolderPassports: s['cloudinary.folderPassports'] || 'psm/passports',
                cloudinaryFolderMaterials: s['cloudinary.folderMaterials'] || 'psm/materials',
                cloudinaryFolderCertificates: s['cloudinary.folderCertificates'] || 'psm/certificates',
                cloudinaryFolderCourseBanners: s['cloudinary.folderCourseBanners'] || 'psm/course-banners'
            }
        });

        // Watch gateway state for conditional validators
        const paystackEnabled = watch('paystackEnabled');
        const paymentMode = watch('paymentMode');

        const changeTab = (tabId) => {
            setActiveTab(tabId);
            try { sessionStorage.setItem('settingsActiveTab', tabId); } catch(e) {}
        };

        const onSubmit = async (data, e) => {
            setSubmitting(true);
            setFormAction('save');
            setToast(null);
            try {
                const response = await fetch(ctxPath + '/admin/settings', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'save',
                        ...data
                    })
                });
                const result = await response.json();
                if (response.ok && result.success) {
                    setToast({ type: 'success', message: result.message || 'Settings saved successfully.' });
                    setTimeout(() => {
                        window.location.reload();
                    }, 1500);
                } else {
                    setToast({ type: 'error', message: result.message || 'Unable to save settings.' });
                }
            } catch (err) {
                setToast({ type: 'error', message: 'Network error occurred. Please try again.' });
            } finally {
                setSubmitting(false);
            }
        };

        const handleTestSmtp = async () => {
            setSubmitting(true);
            setFormAction('testsmtp');
            setToast(null);
            const formData = getValues();
            try {
                const response = await fetch(ctxPath + '/admin/settings', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'testsmtp',
                        ...formData
                    })
                });
                const result = await response.json();
                if (response.ok && result.success) {
                    setToast({ type: 'success', message: result.message || 'SMTP connection test passed.' });
                } else {
                    setToast({ type: 'error', message: result.message || 'SMTP connection test failed.' });
                }
            } catch (err) {
                setToast({ type: 'error', message: 'Network error occurred testing SMTP.' });
            } finally {
                setSubmitting(false);
                setFormAction('save');
            }
        };

        return (
            <div className="settings-container-gf">
                {/* Typographic Header */}
                <header className="settings-header-gf">
                    <div className="admin-breadcrumb" style={{ margin: '0 0 0.5rem 0' }}>
                        <a href={ctxPath + '/dashboard'}>Dashboard</a>
                        <span>&gt;</span>
                        <span>Settings Hub</span>
                    </div>
                    <h1>Platform configurations</h1>
                    <p>Govern platform membership rules, update gateway API credentials, configure SMTP email servers, and review settings audit trails.</p>
                </header>

                {/* Dashboard Metrics Strip */}
                <section className="settings-metrics-gf">
                    <article className="metric-card-gf">
                        <span className="label"><i className="fas fa-building"></i> Platform Identity</span>
                        <span className="value">{s['platform.name'] || 'PSME Platform'}</span>
                        <span className="sub">Support: {s['platform.supportEmail']}</span>
                    </article>
                    <article className="metric-card-gf">
                        <span className="label"><i className="fas fa-credit-card"></i> Gateways Mode</span>
                        <span className="value" style={{ color: s['payment.mode'] === 'LIVE' ? 'var(--gf-success)' : 'var(--gf-warning)' }}>
                            {s['payment.mode'] || 'LIVE'}
                        </span>
                        <span className="sub">
                            {window.__HAS_PAYSTACK_SECRET__ ? 'Paystack Ready' : 'Pending Paystack'}
                        </span>
                    </article>
                    <article className="metric-card-gf">
                        <span className="label"><i className="fas fa-envelope"></i> SMTP Server</span>
                        <span className="value">{window.__HAS_SMTP_PASSWORD__ ? 'Ready' : 'Unconfigured'}</span>
                        <span className="sub">{s['email.smtp.host'] || 'SMTP Pending'}</span>
                    </article>
                    <article className="metric-card-gf">
                        <span className="label"><i className="fas fa-clock-rotate-left"></i> Integrity Auditing</span>
                        <span className="value">{audits.length} entries</span>
                        <span className="sub">Tracked operational state changes</span>
                    </article>
                </section>

                {/* Horizontal Tab Navigation */}
                <div className="tab-navigation-gf">
                    <button type="button" className={'tab-button-gf ' + (activeTab === 'general' ? 'active' : '')} onClick={() => changeTab('general')}>
                        <i className="fas fa-sliders-h"></i> General
                    </button>
                    <button type="button" className={'tab-button-gf ' + (activeTab === 'payments' ? 'active' : '')} onClick={() => changeTab('payments')}>
                        <i className="fas fa-credit-card"></i> Payment Gateways
                    </button>
                    <button type="button" className={'tab-button-gf ' + (activeTab === 'storage' ? 'active' : '')} onClick={() => changeTab('storage')}>
                        <i className="fas fa-cloud"></i> Media Storage
                    </button>
                    <button type="button" className={'tab-button-gf ' + (activeTab === 'email' ? 'active' : '')} onClick={() => changeTab('email')}>
                        <i className="fas fa-envelope"></i> Email (SMTP)
                    </button>
                    <button type="button" className={'tab-button-gf ' + (activeTab === 'operations' ? 'active' : '')} onClick={() => changeTab('operations')}>
                        <i className="fas fa-gears"></i> Operations
                    </button>
                    <button type="button" className={'tab-button-gf ' + (activeTab === 'audit' ? 'active' : '')} onClick={() => changeTab('audit')}>
                        <i className="fas fa-history"></i> Audit Logs
                    </button>
                </div>

                {/* Single Form Wrapping All tab panels to preserve state */}
                <form id="adminSettingsForm" method="post" action={ctxPath + '/admin/settings'} onSubmit={handleSubmit(onSubmit)}>
                    <input type="hidden" name="action" value={formAction} />

                    {/* ═══ TAB: General ═══ */}
                    <div className={'tab-panel-gf ' + (activeTab === 'general' ? 'active' : '')}>
                        <div className="settings-card-gf">
                            <div className="settings-card-header-gf">
                                <div>
                                    <h2>Platform &amp; Security Identity</h2>
                                    <p>Core name, support emails, timezones, session parameters and password requirements.</p>
                                </div>
                                <span className="badge-gf badge-active-gf">Active</span>
                            </div>

                            <div className="settings-grid-gf">
                                <div className="form-group-gf">
                                    <label>Platform Name *</label>
                                    <input type="text" maxLength="120" {...register('platformName', { required: 'Platform name is required.' })} />
                                    {errors.platformName && <small style={{ color: 'var(--gf-error)' }}>{errors.platformName.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <label>Support Email Address *</label>
                                    <input type="email" maxLength="150" {...register('supportEmail', { 
                                        required: 'Support email is required.', 
                                        pattern: { value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i, message: 'Invalid email address.' } 
                                    })} />
                                    {errors.supportEmail && <small style={{ color: 'var(--gf-error)' }}>{errors.supportEmail.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <label>Default Currency *</label>
                                    <input type="text" maxLength="10" placeholder="e.g. NGN" {...register('paymentCurrency', { required: 'Currency is required.' })} />
                                    {errors.paymentCurrency && <small style={{ color: 'var(--gf-error)' }}>{errors.paymentCurrency.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <label>Timezone *</label>
                                    <input type="text" maxLength="80" {...register('timezone', { required: 'Timezone is required.' })} />
                                    {errors.timezone && <small style={{ color: 'var(--gf-error)' }}>{errors.timezone.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <label>Session Timeout (Minutes) *</label>
                                    <input type="number" min="5" max="480" {...register('sessionTimeoutMinutes', { 
                                        required: 'Session timeout is required.', 
                                        min: { value: 5, message: 'Minimum 5 minutes.' },
                                        max: { value: 480, message: 'Maximum 480 minutes.' }
                                    })} />
                                    {errors.sessionTimeoutMinutes && <small style={{ color: 'var(--gf-error)' }}>{errors.sessionTimeoutMinutes.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <label>Minimum Password Length *</label>
                                    <input type="number" min="6" max="64" {...register('minPasswordLength', { 
                                        required: 'Min password length is required.', 
                                        min: { value: 6, message: 'Minimum length 6.' },
                                        max: { value: 64, message: 'Maximum length 64.' }
                                    })} />
                                    {errors.minPasswordLength && <small style={{ color: 'var(--gf-error)' }}>{errors.minPasswordLength.message}</small>}
                                </div>
                            </div>
                        </div>

                        <div className="save-action-bar-gf">
                            <button type="submit" className="btn-primary-gf" disabled={submitting}>
                                {submitting && <div className="spinner-gf"></div>}
                                <i className="fas fa-save"></i> Save General Settings
                            </button>
                        </div>
                    </div>

                    {/* ═══ TAB: Payments ═══ */}
                    <div className={'tab-panel-gf ' + (activeTab === 'payments' ? 'active' : '')}>
                        <div className="settings-card-gf">
                            <div className="settings-card-header-gf">
                                <div>
                                    <h2>Gateway Configuration</h2>
                                    <p>Toggle active checkout modules, specify environments, and store secure secret access tokens.</p>
                                </div>
                                <span className={'badge-gf ' + (paymentMode === 'LIVE' ? 'badge-active-gf' : 'badge-pending-gf')}>
                                    {paymentMode}
                                </span>
                            </div>

                            <div className="settings-grid-gf">
                                <div className="form-group-gf">
                                    <label>Payment Mode / Environment *</label>
                                    <select {...register('paymentMode', { required: 'Payment mode is required.' })}>
                                        <option value="LIVE">LIVE Mode</option>
                                        <option value="TEST">TEST Mode</option>
                                    </select>
                                </div>

                                <div className="form-group-gf">
                                    <label>Callback URL Override</label>
                                    <input type="text" maxLength="255" placeholder="https://yourdomain.com/student/payment-callback" {...register('paymentCallbackUrl')} />
                                </div>

                                {/* Paystack section */}
                                <div className="gateway-divider-gf">
                                    <h3>Paystack gateway</h3>
                                    <div className="line-gf"></div>
                                </div>

                                <div className="form-group-gf span-full-gf">
                                    <div className="toggle-group-gf">
                                        <div className="toggle-info-gf">
                                            <span>Enable Paystack Payments</span>
                                            <small>Allow customers to pay via Card, Web transfer, or Bank USSD through Paystack integration.</small>
                                        </div>
                                        <label className="switch-gf">
                                            <input type="checkbox" {...register('paystackEnabled')} />
                                            <span className="slider-gf"></span>
                                        </label>
                                    </div>
                                </div>

                                <div className="form-group-gf">
                                    <label>Paystack Public Key</label>
                                    <input type="text" placeholder="pk_..." {...register('paystackPublicKey', {
                                        validate: v => !paystackEnabled || !v || v.startsWith('pk_') || 'Paystack public key must start with pk_'
                                    })} />
                                    {errors.paystackPublicKey && <small style={{ color: 'var(--gf-error)' }}>{errors.paystackPublicKey.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <label>Paystack Secret Key</label>
                                    <input type="password" placeholder={window.__HAS_PAYSTACK_SECRET__ ? 'Stored (enter new key to replace)' : 'sk_...'} {...register('paystackSecretKey', {
                                        validate: v => !paystackEnabled || v || window.__HAS_PAYSTACK_SECRET__ || 'Secret Key is required when gateway is active.'
                                    })} />
                                    {errors.paystackSecretKey && <small style={{ color: 'var(--gf-error)' }}>{errors.paystackSecretKey.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <label>Paystack Webhook Secret</label>
                                    <input type="password" placeholder={window.__HAS_WEBHOOK_SECRET__ ? 'Stored (enter webhook key to replace)' : 'Not configured'} {...register('paystackWebhookSecret', {
                                        validate: v => !paystackEnabled || paymentMode !== 'LIVE' || v || window.__HAS_WEBHOOK_SECRET__ || 'Webhook secret is required in LIVE mode.'
                                    })} />
                                    {errors.paystackWebhookSecret && <small style={{ color: 'var(--gf-error)' }}>{errors.paystackWebhookSecret.message}</small>}
                                </div>
                            </div>
                        </div>

                        <div className="save-action-bar-gf">
                            <button type="submit" className="btn-primary-gf" disabled={submitting}>
                                {submitting && <div className="spinner-gf"></div>}
                                <i className="fas fa-save"></i> Save Payment Gateways
                            </button>
                        </div>
                    </div>

                    {/* ═══ TAB: Email (SMTP) ═══ */}
                    <div className={'tab-panel-gf ' + (activeTab === 'email' ? 'active' : '')}>
                        <div className="settings-card-gf">
                            <div className="settings-card-header-gf">
                                <div>
                                    <h2>SMTP Outbox Delivery</h2>
                                    <p>Provide network credentials and port settings to enable platform registration and transactional emails.</p>
                                </div>
                                <span className="badge-gf badge-active-gf">SMTP Controller</span>
                            </div>

                            <div className="settings-grid-gf">
                                <div className="form-group-gf">
                                    <label>SMTP Mail Host</label>
                                    <input type="text" placeholder="smtp.gmail.com" {...register('smtpHost')} />
                                </div>

                                <div className="form-group-gf">
                                    <label>SMTP Port</label>
                                    <input type="number" placeholder="587" min="1" max="65535" {...register('smtpPort')} />
                                </div>

                                <div className="form-group-gf">
                                    <label>SMTP Authentication Username</label>
                                    <input type="text" placeholder="user@gmail.com" {...register('smtpUsername')} />
                                </div>

                                <div className="form-group-gf">
                                    <label>SMTP Password</label>
                                    <input type="password" placeholder={window.__HAS_SMTP_PASSWORD__ ? 'Stored (enter new password to replace)' : 'Not configured'} {...register('smtpPassword')} />
                                </div>

                                <div className="form-group-gf">
                                    <label>Sender 'From' Email</label>
                                    <input type="email" placeholder="no-reply@yourdomain.com" {...register('smtpFromEmail')} />
                                </div>

                                <div className="form-group-gf">
                                    <label>Sender Display Name</label>
                                    <input type="text" {...register('smtpFromName')} />
                                </div>

                                <div className="form-group-gf">
                                    <div className="toggle-group-gf" style={{ border: 'none', padding: '0.2rem 0' }}>
                                        <div className="toggle-info-gf">
                                            <span>Enforce STARTTLS Security</span>
                                            <small>Require encrypted TLS connections when connecting to the SMTP host.</small>
                                        </div>
                                        <label className="switch-gf">
                                            <input type="checkbox" {...register('smtpStartTls')} />
                                            <span className="slider-gf"></span>
                                        </label>
                                    </div>
                                    <input type="hidden" name="smtpStartTls" value={watch('smtpStartTls') ? 'true' : 'false'} />
                                </div>
                            </div>
                        </div>

                        <div className="save-action-bar-gf">
                            <button type="button" className="btn-secondary-gf" onClick={handleTestSmtp} disabled={submitting}>
                                {submitting && formAction === 'testsmtp' && <div className="spinner-gf"></div>}
                                <i className="fas fa-paper-plane"></i> Send Test Email
                            </button>
                            <button type="submit" className="btn-primary-gf" onClick={() => setFormAction('save')} disabled={submitting}>
                                {submitting && formAction === 'save' && <div className="spinner-gf"></div>}
                                <i className="fas fa-save"></i> Save SMTP Settings
                            </button>
                        </div>
                    </div>

                    {/* ═══ TAB: Operations ═══ */}
                    <div className={'tab-panel-gf ' + (activeTab === 'operations' ? 'active' : '')}>
                        <div className="settings-card-gf">
                            <div className="settings-card-header-gf">
                                <div>
                                    <h2>Operational Defaults &amp; Commission</h2>
                                    <p>Specify course syllabus thresholds, tutor payouts percentages, and automatic approval parameters.</p>
                                </div>
                                <span className="badge-gf badge-active-gf">Rules Matrix</span>
                            </div>

                            <div className="settings-grid-gf">
                                <div className="form-group-gf">
                                    <label>Default Instructor Commission (%) *</label>
                                    <input type="number" min="0" max="100" {...register('defaultInstructorCommission', {
                                        required: 'Commission percentage is required.',
                                        min: { value: 0, message: 'Commission cannot be negative.' },
                                        max: { value: 100, message: 'Commission cannot exceed 100%.' }
                                    })} />
                                    {errors.defaultInstructorCommission && <small style={{ color: 'var(--gf-error)' }}>{errors.defaultInstructorCommission.message}</small>}
                                </div>

                                <div className="form-group-gf span-full-gf">
                                    <div className="toggle-group-gf">
                                        <div className="toggle-info-gf">
                                            <span>Auto-Approve Courses</span>
                                            <small>Skip the admin review process. Newly created courses by instructors will go live instantly.</small>
                                        </div>
                                        <label className="switch-gf">
                                            <input type="checkbox" {...register('autoApproveCourses')} />
                                            <span className="slider-gf"></span>
                                        </label>
                                    </div>
                                </div>

                                <div className="form-group-gf">
                                    <label>Material Completion Threshold (%) *</label>
                                    <input type="number" min="1" max="100" {...register('completionMaterialPercent', {
                                        required: 'Completion threshold is required.',
                                        min: { value: 1, message: 'Min threshold is 1%.' },
                                        max: { value: 100, message: 'Max threshold is 100%.' }
                                    })} />
                                    {errors.completionMaterialPercent && <small style={{ color: 'var(--gf-error)' }}>{errors.completionMaterialPercent.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <label>Default Assessment Pass Mark (%) *</label>
                                    <input type="number" min="1" max="100" {...register('defaultPassMark', {
                                        required: 'Default pass mark is required.',
                                        min: { value: 1, message: 'Min pass mark is 1%.' },
                                        max: { value: 100, message: 'Max pass mark is 100%.' }
                                    })} />
                                    {errors.defaultPassMark && <small style={{ color: 'var(--gf-error)' }}>{errors.defaultPassMark.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <label>Default Max Assessment Attempts *</label>
                                    <input type="number" min="1" max="10" {...register('defaultMaxAttempts', {
                                        required: 'Default attempts limit is required.',
                                        min: { value: 1, message: 'Min attempt limit is 1.' },
                                        max: { value: 10, message: 'Max attempt limit is 10.' }
                                    })} />
                                    {errors.defaultMaxAttempts && <small style={{ color: 'var(--gf-error)' }}>{errors.defaultMaxAttempts.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <label>Max Allowed File Upload (MB) *</label>
                                    <input type="number" min="1" max="500" {...register('maxFileUploadMB', {
                                        required: 'Max upload size is required.',
                                        min: { value: 1, message: 'Min upload size is 1MB.' },
                                        max: { value: 500, message: 'Max upload size is 500MB.' }
                                    })} />
                                    {errors.maxFileUploadMB && <small style={{ color: 'var(--gf-error)' }}>{errors.maxFileUploadMB.message}</small>}
                                </div>

                                <div className="form-group-gf">
                                    <div className="toggle-group-gf" style={{ border: 'none', padding: '0.2rem 0' }}>
                                        <div className="toggle-info-gf">
                                            <span>Auto-Activate Enrollment After Payment</span>
                                            <small>Unlock learning materials instantly upon Paystack callback approval.</small>
                                        </div>
                                        <label className="switch-gf">
                                            <input type="checkbox" {...register('autoActivateEnrollment')} />
                                            <span className="slider-gf"></span>
                                        </label>
                                    </div>
                                    <input type="hidden" name="autoActivateEnrollment" value={watch('autoActivateEnrollment') ? 'true' : 'false'} />
                                </div>

                                <div className="form-group-gf">
                                    <div className="toggle-group-gf" style={{ border: 'none', padding: '0.2rem 0' }}>
                                        <div className="toggle-info-gf">
                                            <span>Generate Credentials Certificates</span>
                                            <small>Issue verifiable PDF certificates immediately when students complete a course.</small>
                                        </div>
                                        <label className="switch-gf">
                                            <input type="checkbox" {...register('certificateEnabled')} />
                                            <span className="slider-gf"></span>
                                        </label>
                                    </div>
                                    <input type="hidden" name="certificateEnabled" value={watch('certificateEnabled') ? 'true' : 'false'} />
                                </div>

                                <div className="form-group-gf span-full-gf">
                                    <label>YouTube Integration Data API Key (Optional)</label>
                                    <input type="text" maxLength="255" placeholder="AIzaSy..." {...register('youtubeApiKey')} />
                                    <small>Instructors can embed YouTube videos as course materials. Standard iframe video player works without a key.</small>
                                </div>
                            </div>
                        </div>

                        <div className="save-action-bar-gf">
                            <button type="submit" className="btn-primary-gf" onClick={() => setFormAction('save')} disabled={submitting}>
                                {submitting && <div className="spinner-gf"></div>}
                                <i className="fas fa-save"></i> Save Operational Settings
                            </button>
                        </div>
                    </div>

                    {/* ═══ TAB: Cloud Storage ═══ */}
                    <div className={'tab-panel-gf ' + (activeTab === 'storage' ? 'active' : '')}>
                        <div className="settings-card-gf">
                            <div className="settings-card-header-gf">
                                <div>
                                    <h2>Cloudinary Cloud Storage</h2>
                                    <p>Configure dynamic Cloudinary API keys to store passports, banners, certificates, and student learning materials securely in the cloud.</p>
                                </div>
                                <span className="badge-gf badge-active-gf">Cloud API</span>
                            </div>

                            <div className="settings-grid-gf">
                                <div className="form-group-gf">
                                     <label>Cloud Name</label>
                                     <input type="text" placeholder="e.g. dxyz1234" {...register('cloudinaryCloudName')} />
                                </div>

                                <div className="form-group-gf">
                                     <label>API Key</label>
                                     <input type="text" placeholder="e.g. 123456789012345" {...register('cloudinaryApiKey')} />
                                </div>

                                <div className="form-group-gf">
                                     <label>API Secret</label>
                                     <input type="password" placeholder={window.__HAS_CLOUDINARY_SECRET__ ? 'Stored (enter new secret to replace)' : 'Not configured'} {...register('cloudinaryApiSecret')} />
                                </div>

                                <div className="gateway-divider-gf">
                                     <h3>Cloud Folder Paths</h3>
                                     <div className="line-gf"></div>
                                </div>

                                <div className="form-group-gf">
                                     <label>Passports/Profile Pics Folder</label>
                                     <input type="text" {...register('cloudinaryFolderPassports')} />
                                </div>

                                <div className="form-group-gf">
                                     <label>Course Materials Folder</label>
                                     <input type="text" {...register('cloudinaryFolderMaterials')} />
                                </div>

                                <div className="form-group-gf">
                                     <label>Certificates Folder</label>
                                     <input type="text" {...register('cloudinaryFolderCertificates')} />
                                </div>

                                <div className="form-group-gf">
                                     <label>Course Banners Folder</label>
                                     <input type="text" {...register('cloudinaryFolderCourseBanners')} />
                                </div>
                            </div>
                        </div>

                        <div className="save-action-bar-gf">
                             <button type="submit" className="btn-primary-gf" onClick={() => setFormAction('save')} disabled={submitting}>
                                 {submitting && <div className="spinner-gf"></div>}
                                 <i className="fas fa-save"></i> Save Cloud Storage
                             </button>
                        </div>
                    </div>
                </form>

                {/* ═══ TAB: Audit Log (read-only list, outside form) ═══ */}
                <div className={'tab-panel-gf ' + (activeTab === 'audit' ? 'active' : '')}>
                    <div className="settings-card-gf">
                        <div className="settings-card-header-gf">
                            <div>
                                <h2>Auditing Ledger</h2>
                                <p>Complete traceability log capturing key modification parameters, user IDs, and transition states.</p>
                            </div>
                            <span className="badge-gf badge-active-gf">{audits.length} Audited Logs</span>
                        </div>

                        {audits.length === 0 ? (
                            <div className="empty-state-gf">
                                <i className="fas fa-history"></i>
                                <p>No settings modifications logged in database yet.</p>
                            </div>
                        ) : (
                            <div style={{ overflowX: 'auto' }}>
                                <table className="audit-table-gf">
                                    <thead>
                                        <tr>
                                            <th>Timestamp</th>
                                            <th>Key Configured</th>
                                            <th>Previous State</th>
                                            <th>Updated State</th>
                                            <th>Changed By User ID</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {audits.map(a => (
                                            <tr key={a.auditId}>
                                                <td>{new Date(a.changedAt.replace(' ', 'T')).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' })}</td>
                                                <td><strong style={{ color: 'var(--gf-accent)' }}>{a.settingKey}</strong></td>
                                                <td style={{ fontFamily: 'monospace', fontSize: '0.8rem', maxWidth: '240px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{a.oldValue || '-'}</td>
                                                <td style={{ fontFamily: 'monospace', fontSize: '0.8rem', maxWidth: '240px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{a.newValue || '-'}</td>
                                                <td><strong>{"#" + a.changedBy}</strong></td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>
                </div>
                {toast && (
                    <div className={'toast-gf toast-' + toast.type + '-gf'}>
                        <i className={toast.type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-circle'}></i>
                        <span>{toast.message}</span>
                    </div>
                )}
            </div>
        );
    }

    const container = document.getElementById('admin-react-root');
    const root = ReactDOM.createRoot(container);
    root.render(<SettingsHub />);
</script>
</body>
</html>
