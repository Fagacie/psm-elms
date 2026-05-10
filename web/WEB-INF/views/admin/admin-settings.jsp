<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Settings - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css?v=2.3">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Settings"/>
    <jsp:param name="pageSubtitle" value="Platform configuration and operational defaults"/>
</jsp:include>
<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <c:set var="smtpConfigured" value="${not empty settings['email.smtp.host'] and not empty settings['email.smtp.username'] and hasSmtpPassword}"/>
        <c:set var="paystackConfigured" value="${not empty settings['payment.paystackPublicKey'] and hasPaystackSecret}"/>
        <c:set var="autoActivateLabel" value="${settings['enrollment.autoActivateOnPayment'] == 'true' ? 'Enabled' : 'Manual'}"/>

        <%-- Page Head --%>
        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span><span>Settings</span>
            </div>
        </section>

        <%-- Status Metrics Row --%>
        <section class="metrics-grid admin-settings-metrics" style="margin-bottom:24px;">
            <article class="metric-card">
                <span class="metric-label">Platform</span>
                <div class="metric-value">${settings['platform.name']}</div>
                <p class="metric-meta">Support: ${settings['platform.supportEmail']}</p>
            </article>
            <article class="metric-card">
                <span class="metric-label">Gateway</span>
                <div class="metric-value">${settings['payment.mode']}</div>
                <p class="metric-meta">${paystackConfigured ? 'Paystack configured' : 'Keys pending'}</p>
            </article>
            <article class="metric-card">
                <span class="metric-label">Email</span>
                <div class="metric-value">${smtpConfigured ? 'Ready' : 'Pending'}</div>
                <p class="metric-meta">${smtpConfigured ? settings['email.smtp.host'] : 'Configure SMTP'}</p>
            </article>
            <article class="metric-card">
                <span class="metric-label">Automation</span>
                <div class="metric-value">${autoActivateLabel}</div>
                <p class="metric-meta">${fn:length(audits)} recent audit entries</p>
            </article>
        </section>

        <%-- Alerts --%>
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${successMessage}</div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${errorMessage}</div>
        </c:if>
        <c:if test="${not empty infoMessage}">
            <div class="alert alert-warning"><i class="fas fa-circle-info"></i> ${infoMessage}</div>
        </c:if>

        <%-- Tab Nav --%>
        <div class="settings-tab-nav">
            <button class="stab-btn active" data-tab="platform"><i class="fas fa-building"></i> Platform</button>
            <button class="stab-btn" data-tab="security"><i class="fas fa-shield-halved"></i> Security</button>
            <button class="stab-btn" data-tab="payments"><i class="fas fa-credit-card"></i> Payments</button>
            <button class="stab-btn" data-tab="email"><i class="fas fa-envelope"></i> Email / SMTP</button>
            <button class="stab-btn" data-tab="learning"><i class="fas fa-graduation-cap"></i> Learning</button>
            <button class="stab-btn" data-tab="integrations"><i class="fas fa-plug"></i> Integrations</button>
            <button class="stab-btn" data-tab="audit"><i class="fas fa-clock-rotate-left"></i> Audit Log</button>
        </div>

        <form id="adminSettingsForm" method="post" action="${pageContext.request.contextPath}/admin/settings">

            <%-- TAB: Platform --%>
            <div class="stab-panel active" id="stab-platform">
                <section class="section-card">
                    <div class="section-header">
                        <div><h2>Platform Identity</h2><p class="section-caption">Core name, support email and timezone shown across the platform.</p></div>
                        <span class="status-badge status-success">Active</span>
                    </div>
                    <div class="admin-form-grid">
                        <div class="admin-form-group">
                            <label for="platformName">Platform Name *</label>
                            <input type="text" id="platformName" name="platformName" required maxlength="120" value="${settings['platform.name']}">
                        </div>
                        <div class="admin-form-group">
                            <label for="supportEmail">Support Email *</label>
                            <input type="email" id="supportEmail" name="supportEmail" required maxlength="150" value="${settings['platform.supportEmail']}">
                        </div>
                        <div class="admin-form-group">
                            <label for="timezone">Timezone</label>
                            <input type="text" id="timezone" name="timezone" maxlength="80" value="${settings['platform.timezone']}" placeholder="e.g. Africa/Lagos">
                        </div>
                        <div class="admin-form-group">
                            <label for="maxFileUploadMB">Max File Upload (MB)</label>
                            <input type="number" id="maxFileUploadMB" name="maxFileUploadMB" min="1" max="500" value="${not empty settings['platform.maxFileUploadMB'] ? settings['platform.maxFileUploadMB'] : '50'}">
                        </div>
                        <div class="admin-form-group">
                            <label for="certificateEnabled">Certificate Issuance</label>
                            <select id="certificateEnabled" name="certificateEnabled">
                                <option value="true" ${settings['platform.certificateEnabled'] != 'false' ? 'selected' : ''}>Enabled</option>
                                <option value="false" ${settings['platform.certificateEnabled'] == 'false' ? 'selected' : ''}>Disabled</option>
                            </select>
                        </div>
                    </div>
                </section>
                <div class="settings-save-bar">
                    <button type="submit" name="action" value="save" class="admin-btn primary"><i class="fas fa-save"></i> Save Platform Settings</button>
                </div>
            </div>

            <%-- TAB: Security --%>
            <div class="stab-panel" id="stab-security">
                <section class="section-card">
                    <div class="section-header">
                        <div><h2>Security Policy</h2><p class="section-caption">Session and password defaults for all role-based access.</p></div>
                        <span class="status-badge status-success">Protected</span>
                    </div>
                    <div class="admin-form-grid">
                        <div class="admin-form-group">
                            <label for="sessionTimeoutMinutes">Session Timeout (Minutes)</label>
                            <input type="number" id="sessionTimeoutMinutes" name="sessionTimeoutMinutes" min="5" max="480" required value="${settings['security.sessionTimeoutMinutes']}">
                            <small class="table-subtext">Inactive sessions expire after this duration. Recommended: 30–60 min.</small>
                        </div>
                        <div class="admin-form-group">
                            <label for="minPasswordLength">Minimum Password Length</label>
                            <input type="number" id="minPasswordLength" name="minPasswordLength" min="6" max="64" required value="${settings['security.minPasswordLength']}">
                            <small class="table-subtext">Applied during registration and password changes. Min 6, Max 64.</small>
                        </div>
                    </div>
                </section>
                <div class="settings-save-bar">
                    <button type="submit" name="action" value="save" class="admin-btn primary"><i class="fas fa-shield-halved"></i> Save Security Settings</button>
                </div>
            </div>

            <%-- TAB: Payments --%>
            <div class="stab-panel" id="stab-payments">
                <section class="section-card">
                    <div class="section-header">
                        <div><h2>Payment Gateway</h2><p class="section-caption">Gateway mode, currency, and Paystack credentials.</p></div>
                        <span class="status-badge ${settings['payment.mode'] == 'LIVE' ? 'status-success' : 'status-warning'}">${settings['payment.mode']}</span>
                    </div>
                    <div class="admin-form-grid">
                        <div class="admin-form-group">
                            <label for="paymentMode">Payment Mode</label>
                            <select id="paymentMode" name="paymentMode" required>
                                <option value="LIVE" ${settings['payment.mode'] == 'LIVE' ? 'selected' : ''}>LIVE</option>
                                <option value="TEST" ${settings['payment.mode'] == 'TEST' ? 'selected' : ''}>TEST</option>
                            </select>
                        </div>
                        <div class="admin-form-group">
                            <label for="paymentCurrency">Currency</label>
                            <input type="text" id="paymentCurrency" name="paymentCurrency" required maxlength="10" value="${settings['payment.currency']}">
                        </div>
                        <div class="admin-form-group">
                            <label for="paystackPublicKey">Paystack Public Key</label>
                            <input type="text" id="paystackPublicKey" name="paystackPublicKey" maxlength="255" value="${settings['payment.paystackPublicKey']}" placeholder="pk_...">
                        </div>
                        <div class="admin-form-group">
                            <label for="paystackSecretKey">Paystack Secret Key</label>
                            <input type="password" id="paystackSecretKey" name="paystackSecretKey" maxlength="255" placeholder="${hasPaystackSecret ? 'Stored — enter new value to replace' : 'sk_...'}">
                            <small class="table-subtext">${hasPaystackSecret ? 'A secret key is already stored.' : 'No secret key stored yet.'}</small>
                        </div>
                        <div class="admin-form-group">
                            <label for="paystackWebhookSecret">Webhook Secret</label>
                            <input type="password" id="paystackWebhookSecret" name="paystackWebhookSecret" maxlength="255" placeholder="${hasWebhookSecret ? 'Stored — enter new value to replace' : 'Not configured'}">
                            <small class="table-subtext">${hasWebhookSecret ? 'Webhook secret stored.' : 'Not configured.'}</small>
                        </div>
                        <div class="admin-form-group">
                            <label for="paymentCallbackUrl">Callback URL Override</label>
                            <input type="text" id="paymentCallbackUrl" name="paymentCallbackUrl" maxlength="255" value="${settings['payment.callbackUrl']}" placeholder="https://yourdomain.com/callback">
                        </div>
                    </div>
                </section>
                <div class="settings-save-bar">
                    <button type="submit" name="action" value="save" class="admin-btn primary"><i class="fas fa-save"></i> Save Payment Settings</button>
                </div>
            </div>

            <%-- TAB: Email --%>
            <div class="stab-panel" id="stab-email">
                <section class="section-card">
                    <div class="section-header">
                        <div><h2>SMTP Email Delivery</h2><p class="section-caption">Configure outgoing email transport for notifications and password resets.</p></div>
                        <span class="status-badge ${smtpConfigured ? 'status-success' : 'status-warning'}">${smtpConfigured ? 'Ready' : 'Needs Setup'}</span>
                    </div>
                    <div class="admin-form-grid">
                        <div class="admin-form-group">
                            <label for="smtpHost">SMTP Host</label>
                            <input type="text" id="smtpHost" name="smtpHost" maxlength="120" value="${settings['email.smtp.host']}" placeholder="smtp.gmail.com">
                        </div>
                        <div class="admin-form-group">
                            <label for="smtpPort">SMTP Port</label>
                            <input type="number" id="smtpPort" name="smtpPort" min="1" max="65535" value="${settings['email.smtp.port']}" placeholder="587">
                        </div>
                        <div class="admin-form-group">
                            <label for="smtpUsername">SMTP Username</label>
                            <input type="text" id="smtpUsername" name="smtpUsername" maxlength="150" value="${settings['email.smtp.username']}">
                        </div>
                        <div class="admin-form-group">
                            <label for="smtpPassword">SMTP Password</label>
                            <input type="password" id="smtpPassword" name="smtpPassword" maxlength="255" placeholder="${hasSmtpPassword ? 'Stored — enter to replace' : 'Not configured'}">
                            <small class="table-subtext">${hasSmtpPassword ? 'Password stored.' : 'No password stored yet.'}</small>
                        </div>
                        <div class="admin-form-group">
                            <label for="smtpFromEmail">From Email</label>
                            <input type="email" id="smtpFromEmail" name="smtpFromEmail" maxlength="150" value="${settings['email.from.email']}">
                        </div>
                        <div class="admin-form-group">
                            <label for="smtpFromName">From Name</label>
                            <input type="text" id="smtpFromName" name="smtpFromName" maxlength="150" value="${settings['email.from.name']}">
                        </div>
                        <div class="admin-form-group">
                            <label for="smtpStartTls">Use STARTTLS</label>
                            <select id="smtpStartTls" name="smtpStartTls">
                                <option value="true" ${settings['email.smtp.starttls'] == 'true' ? 'selected' : ''}>Yes</option>
                                <option value="false" ${settings['email.smtp.starttls'] == 'false' ? 'selected' : ''}>No</option>
                            </select>
                        </div>
                    </div>
                </section>
                <div class="settings-save-bar">
                    <button type="submit" name="action" value="save" class="admin-btn primary"><i class="fas fa-save"></i> Save Email Settings</button>
                    <button type="submit" name="action" value="testsmtp" class="admin-btn secondary"><i class="fas fa-envelope-circle-check"></i> Test SMTP Connection</button>
                </div>
            </div>

            <%-- TAB: Learning --%>
            <div class="stab-panel" id="stab-learning">
                <section class="section-card">
                    <div class="section-header">
                        <div><h2>Enrollment &amp; Learning Rules</h2><p class="section-caption">Completion thresholds, assessment defaults, and enrollment automation.</p></div>
                        <span class="status-badge status-secondary">${autoActivateLabel}</span>
                    </div>
                    <div class="admin-form-grid">
                        <div class="admin-form-group">
                            <label for="completionMaterialPercent">Material Completion Threshold (%)</label>
                            <input type="number" id="completionMaterialPercent" name="completionMaterialPercent" min="1" max="100" required value="${settings['learning.completionMaterialPercent']}">
                            <small class="table-subtext">% of materials a student must complete to finish a course.</small>
                        </div>
                        <div class="admin-form-group">
                            <label for="defaultPassMark">Default Assessment Pass Mark (%)</label>
                            <input type="number" id="defaultPassMark" name="defaultPassMark" min="1" max="100" required value="${settings['assessment.defaultPassMark']}">
                        </div>
                        <div class="admin-form-group">
                            <label for="defaultMaxAttempts">Default Max Assessment Attempts</label>
                            <input type="number" id="defaultMaxAttempts" name="defaultMaxAttempts" min="1" max="10" required value="${settings['assessment.defaultMaxAttempts']}">
                        </div>
                        <div class="admin-form-group">
                            <label for="autoActivateEnrollment">Auto-Activate Enrollment After Payment</label>
                            <select id="autoActivateEnrollment" name="autoActivateEnrollment">
                                <option value="true" ${settings['enrollment.autoActivateOnPayment'] == 'true' ? 'selected' : ''}>Yes — Activate Immediately</option>
                                <option value="false" ${settings['enrollment.autoActivateOnPayment'] == 'false' ? 'selected' : ''}>No — Manual Activation</option>
                            </select>
                        </div>
                    </div>
                </section>
                <div class="settings-save-bar">
                    <button type="submit" name="action" value="save" class="admin-btn primary"><i class="fas fa-graduation-cap"></i> Save Learning Settings</button>
                </div>
            </div>

            <%-- TAB: Integrations --%>
            <div class="stab-panel" id="stab-integrations">
                <section class="section-card">
                    <div class="section-header">
                        <div><h2>YouTube Integration</h2><p class="section-caption">Optional YouTube Data API key for extended video features. Basic iframe embedding works without a key.</p></div>
                        <span class="status-badge ${not empty settings['platform.youtubeApiKey'] ? 'status-success' : 'status-secondary'}">${not empty settings['platform.youtubeApiKey'] ? 'Key Configured' : 'Basic Embed'}</span>
                    </div>
                    <div class="admin-form-grid">
                        <div class="admin-form-group" style="grid-column: 1/-1;">
                            <label for="youtubeApiKey">YouTube Data API Key (Optional)</label>
                            <input type="text" id="youtubeApiKey" name="youtubeApiKey" maxlength="255" value="${settings['platform.youtubeApiKey']}" placeholder="AIza...">
                            <small class="table-subtext">Instructors can embed YouTube videos as course materials. A Data API key is optional — basic iframe embedding is always available without one.</small>
                        </div>
                    </div>
                </section>
                <div class="settings-save-bar">
                    <button type="submit" name="action" value="save" class="admin-btn primary"><i class="fas fa-plug"></i> Save Integration Settings</button>
                </div>
            </div>

        </form><%-- end form --%>

        <%-- TAB: Audit Log (outside form) --%>
        <div class="stab-panel" id="stab-audit">
            <section class="section-card">
                <div class="section-header">
                    <div><h2>Settings Audit Log</h2><p class="section-caption">Recent configuration changes for accountability and troubleshooting.</p></div>
                    <span class="status-badge status-secondary">${fn:length(audits)} entries</span>
                </div>
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                        <tr>
                            <th>When</th>
                            <th>Setting Key</th>
                            <th>Old Value</th>
                            <th>New Value</th>
                            <th>Changed By</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${empty audits}">
                                <tr><td colspan="5">
                                    <div class="empty-state empty-state-inset">
                                        <i class="fas fa-clock-rotate-left"></i>
                                        <p>No setting changes have been logged yet.</p>
                                    </div>
                                </td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="audit" items="${audits}">
                                    <tr>
                                        <td><c:out value="${audit.changedAt}" default="-"/></td>
                                        <td><strong>${audit.settingKey}</strong></td>
                                        <td><c:out value="${empty audit.oldValue ? '-' : audit.oldValue}"/></td>
                                        <td><c:out value="${empty audit.newValue ? '-' : audit.newValue}"/></td>
                                        <td><c:out value="${empty audit.changedBy ? '-' : audit.changedBy}"/></td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>

    </div><%-- content-wrapper --%>
</main>

<style>
/* Settings Tab Navigation */
.settings-tab-nav {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-bottom: 24px;
    padding: 6px;
    background: var(--ad-surface, #fff);
    border: 1px solid var(--ad-border, #e2e8f0);
    border-radius: 14px;
    box-shadow: var(--ad-shadow-sm);
}
.stab-btn {
    display: flex;
    align-items: center;
    gap: 7px;
    padding: 9px 16px;
    border: none;
    border-radius: 10px;
    background: transparent;
    color: var(--ad-muted, #64748b);
    font-family: inherit;
    font-size: 0.84rem;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.18s ease, color 0.18s ease;
}
.stab-btn:hover { background: var(--ad-surface-soft, #f8fafc); color: var(--ad-heading, #0f172a); }
.stab-btn.active { background: var(--ad-primary, #0f172a); color: #fff; }
.stab-panel { display: none; }
.stab-panel.active { display: block; }

/* Settings grid inside cards */
.admin-form-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 18px;
    margin-top: 20px;
}
.admin-form-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
}
.admin-form-group label {
    font-size: 0.82rem;
    font-weight: 700;
    color: var(--ad-heading, #0f172a);
    text-transform: uppercase;
    letter-spacing: 0.04em;
}
.admin-form-group input,
.admin-form-group select {
    padding: 10px 14px;
    border: 1px solid var(--ad-border, #e2e8f0);
    border-radius: 10px;
    font-family: inherit;
    font-size: 0.9rem;
    color: var(--ad-text, #334155);
    background: var(--ad-surface, #fff);
    transition: border-color 0.2s ease, box-shadow 0.2s ease;
}
.admin-form-group input:focus,
.admin-form-group select:focus {
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59,130,246,0.12);
    outline: none;
}
.settings-save-bar {
    display: flex;
    gap: 12px;
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid var(--ad-border, #e2e8f0);
}

/* Dark mode for settings */
:root[data-theme="dark"] .settings-tab-nav {
    background: #0e1726 !important;
    border-color: rgba(148,163,184,0.12) !important;
}
:root[data-theme="dark"] .stab-btn { color: #94a3b8 !important; }
:root[data-theme="dark"] .stab-btn:hover { background: rgba(255,255,255,0.05) !important; color: #fff !important; }
:root[data-theme="dark"] .stab-btn.active { background: #3b82f6 !important; color: #fff !important; }
:root[data-theme="dark"] .admin-form-group input,
:root[data-theme="dark"] .admin-form-group select {
    background: #111a2e !important;
    border-color: rgba(148,163,184,0.18) !important;
    color: #f1f5f9 !important;
}
:root[data-theme="dark"] .settings-save-bar {
    border-top-color: rgba(148,163,184,0.12) !important;
}
</style>

<script>
(function () {
    var tabBtns = document.querySelectorAll('.stab-btn');
    var tabPanels = document.querySelectorAll('.stab-panel');

    function activateTab(tabId) {
        tabBtns.forEach(function(btn) {
            btn.classList.toggle('active', btn.getAttribute('data-tab') === tabId);
        });
        tabPanels.forEach(function(panel) {
            panel.classList.toggle('active', panel.id === 'stab-' + tabId);
        });
        try { sessionStorage.setItem('settingsActiveTab', tabId); } catch(e) {}
    }

    tabBtns.forEach(function(btn) {
        btn.addEventListener('click', function() {
            activateTab(btn.getAttribute('data-tab'));
        });
    });

    // Restore last active tab
    var savedTab = 'platform';
    try { savedTab = sessionStorage.getItem('settingsActiveTab') || 'platform'; } catch(e) {}
    activateTab(savedTab);
})();
</script>
</body>
</html>
