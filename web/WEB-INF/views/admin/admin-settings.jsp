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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-settings.css">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
</head>
<body class="admin-page">
<jsp:include page="/WEB-INF/views/common/admin-header.jsp">
    <jsp:param name="pageTitle" value="Settings"/>
    <jsp:param name="pageSubtitle" value="Review platform configuration and operational defaults"/>
</jsp:include>

<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

<main class="app-main">
    <div class="content-wrapper">
        <c:set var="smtpConfigured" value="${not empty settings['email.smtp.host'] and not empty settings['email.smtp.username'] and hasSmtpPassword}" />
        <c:set var="paystackConfigured" value="${not empty settings['payment.paystackPublicKey'] and hasPaystackSecret}" />
        <c:set var="autoActivateLabel" value="${settings['enrollment.autoActivateOnPayment'] == 'true' ? 'Enabled' : 'Manual'}" />

        <section class="admin-page-head">
            <div class="admin-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <span>&gt;</span>
                <span>Settings</span>
            </div>

            <div class="admin-hero admin-settings-hero">
                <div class="admin-hero-copy">
                    <p class="admin-kicker">System Settings</p>
                    <h2>Run the platform from one operational settings workspace</h2>
                    <p>Configure platform identity, security policy, payments, email delivery, and learning defaults in one professional admin control center.</p>
                    <div class="admin-settings-actions">
                        <button type="submit" form="adminSettingsForm" name="action" value="save" class="admin-btn primary">
                            <i class="fas fa-save"></i> Save Settings
                        </button>
                        <button type="submit" form="adminSettingsForm" name="action" value="testsmtp" class="admin-btn secondary">
                            <i class="fas fa-envelope-circle-check"></i> Test SMTP
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/settings" class="admin-btn secondary">Reset</a>
                    </div>
                </div>
                <div class="admin-hero-scene admin-settings-scene" aria-hidden="true">
                    <div class="admin-scene-panel">
                        <span>Payment Mode</span>
                        <strong>${settings['payment.mode']}</strong>
                    </div>
                    <div class="admin-scene-panel">
                        <span>SMTP</span>
                        <strong>${smtpConfigured ? 'Ready' : 'Needs Setup'}</strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="metrics-grid admin-settings-metrics">
            <article class="metric-card">
                <span class="metric-label">Platform</span>
                <div class="metric-value">${settings['platform.name']}</div>
                <p class="metric-meta">Support: ${settings['platform.supportEmail']}</p>
            </article>
            <article class="metric-card">
                <span class="metric-label">Gateway</span>
                <div class="metric-value">${settings['payment.mode']}</div>
                <p class="metric-meta">${paystackConfigured ? 'Paystack keys configured' : 'Paystack keys pending'}</p>
            </article>
            <article class="metric-card">
                <span class="metric-label">Email Delivery</span>
                <div class="metric-value">${smtpConfigured ? 'Ready' : 'Pending'}</div>
                <p class="metric-meta">${smtpConfigured ? settings['email.smtp.host'] : 'Configure SMTP to enable notifications'}</p>
            </article>
            <article class="metric-card">
                <span class="metric-label">Automation</span>
                <div class="metric-value">${autoActivateLabel}</div>
                <p class="metric-meta">${fn:length(audits)} recent audit entries available</p>
            </article>
        </section>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> ${errorMessage}
            </div>
        </c:if>
        <c:if test="${not empty infoMessage}">
            <div class="alert alert-warning">
                <i class="fas fa-circle-info"></i> ${infoMessage}
            </div>
        </c:if>

        <form id="adminSettingsForm" method="post" action="${pageContext.request.contextPath}/admin/settings" class="admin-form-layout">
            <section class="section-card">
                <div class="section-header">
                    <div>
                        <h2>Platform Profile</h2>
                        <p class="section-caption">Core identity settings used across the application experience.</p>
                    </div>
                    <span class="status-badge status-success">Active</span>
                </div>
                <div class="panel-stack">
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>Public Identity</strong>
                            <span>Defines the default name and support details shown across system workflows.</span>
                        </div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="platformName">Platform Name</label>
                                <input type="text" id="platformName" name="platformName" required maxlength="120" value="${settings['platform.name']}">
                            </div>
                            <div class="admin-form-group">
                                <label for="supportEmail">Support Email</label>
                                <input type="email" id="supportEmail" name="supportEmail" required maxlength="150" value="${settings['platform.supportEmail']}">
                            </div>
                            <div class="admin-form-group">
                                <label for="timezone">Timezone</label>
                                <input type="text" id="timezone" name="timezone" required maxlength="80" value="${settings['platform.timezone']}">
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <div>
                        <h2>Security Policy</h2>
                        <p class="section-caption">Session and password defaults for all role-based access.</p>
                    </div>
                    <span class="status-badge status-success">Protected</span>
                </div>
                <div class="panel-stack">
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>Baseline Access Rules</strong>
                            <span>Applies password and session defaults across role logins.</span>
                        </div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="sessionTimeoutMinutes">Session Timeout (Minutes)</label>
                                <input type="number" id="sessionTimeoutMinutes" name="sessionTimeoutMinutes" min="5" max="480" required value="${settings['security.sessionTimeoutMinutes']}">
                            </div>
                            <div class="admin-form-group">
                                <label for="minPasswordLength">Minimum Password Length</label>
                                <input type="number" id="minPasswordLength" name="minPasswordLength" min="6" max="64" required value="${settings['security.minPasswordLength']}">
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <div>
                        <h2>Payment Defaults</h2>
                        <p class="section-caption">Baseline gateway mode and currency used by enrollment payments.</p>
                    </div>
                    <span class="status-badge ${settings['payment.mode'] == 'LIVE' ? 'status-success' : 'status-warning'}">${settings['payment.mode']}</span>
                </div>
                <div class="panel-stack">
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>Gateway Behavior</strong>
                            <span>Controls mode and currency defaults used by payment workflows.</span>
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
                        </div>
                    </div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <div>
                        <h2>Paystack Credentials</h2>
                        <p class="section-caption">Securely manage gateway credentials and callback behavior.</p>
                    </div>
                    <span class="status-badge ${paystackConfigured ? 'status-success' : 'status-warning'}">${paystackConfigured ? 'Configured' : 'Pending'}</span>
                </div>
                <div class="panel-stack">
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>Gateway Secrets and Callback</strong>
                            <span>Secret fields are write-only in this form. Leave blank to keep current stored values.</span>
                        </div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="paystackPublicKey">Paystack Public Key</label>
                                <input type="text" id="paystackPublicKey" name="paystackPublicKey" maxlength="255" value="${settings['payment.paystackPublicKey']}">
                            </div>
                            <div class="admin-form-group">
                                <label for="paystackSecretKey">Paystack Secret Key</label>
                                <input type="password" id="paystackSecretKey" name="paystackSecretKey" maxlength="255" placeholder="${hasPaystackSecret ? 'Stored. Enter new value to replace.' : 'Not configured'}">
                                <small class="table-subtext">${hasPaystackSecret ? 'A secret key is already stored.' : 'No secret key stored yet.'}</small>
                            </div>
                            <div class="admin-form-group">
                                <label for="paystackWebhookSecret">Webhook Secret</label>
                                <input type="password" id="paystackWebhookSecret" name="paystackWebhookSecret" maxlength="255" placeholder="${hasWebhookSecret ? 'Stored. Enter new value to replace.' : 'Not configured'}">
                                <small class="table-subtext">${hasWebhookSecret ? 'Webhook secret already stored.' : 'Webhook secret not configured.'}</small>
                            </div>
                            <div class="admin-form-group">
                                <label for="paymentCallbackUrl">Callback URL (Optional Override)</label>
                                <input type="text" id="paymentCallbackUrl" name="paymentCallbackUrl" maxlength="255" value="${settings['payment.callbackUrl']}">
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <div>
                        <h2>Email (SMTP) and Delivery</h2>
                        <p class="section-caption">Notification infrastructure for system emails, alerts, and onboarding.</p>
                    </div>
                    <span class="status-badge ${smtpConfigured ? 'status-success' : 'status-warning'}">${smtpConfigured ? 'Ready' : 'Needs Setup'}</span>
                </div>
                <div class="panel-stack">
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>Notification Infrastructure</strong>
                            <span>Configure SMTP transport and test connectivity before using automated emails in production.</span>
                        </div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="smtpHost">SMTP Host</label>
                                <input type="text" id="smtpHost" name="smtpHost" maxlength="120" value="${settings['email.smtp.host']}">
                            </div>
                            <div class="admin-form-group">
                                <label for="smtpPort">SMTP Port</label>
                                <input type="number" id="smtpPort" name="smtpPort" min="1" max="65535" value="${settings['email.smtp.port']}">
                            </div>
                            <div class="admin-form-group">
                                <label for="smtpUsername">SMTP Username</label>
                                <input type="text" id="smtpUsername" name="smtpUsername" maxlength="150" value="${settings['email.smtp.username']}">
                            </div>
                            <div class="admin-form-group">
                                <label for="smtpPassword">SMTP Password</label>
                                <input type="password" id="smtpPassword" name="smtpPassword" maxlength="255" placeholder="${hasSmtpPassword ? 'Stored. Enter new value to replace.' : 'Not configured'}">
                                <small class="table-subtext">${hasSmtpPassword ? 'A password is already stored.' : 'No SMTP password stored yet.'}</small>
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
                    </div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <div>
                        <h2>Enrollment and Learning Rules</h2>
                        <p class="section-caption">Default completion and assessment rules used across courses.</p>
                    </div>
                    <span class="status-badge status-secondary">${autoActivateLabel}</span>
                </div>
                <div class="panel-stack">
                    <div class="status-item">
                        <div class="status-item-copy">
                            <strong>Progress and Completion Defaults</strong>
                            <span>Sets baseline learning policy for activation, completion gate, and assessment defaults.</span>
                        </div>
                        <div class="admin-form-grid">
                            <div class="admin-form-group">
                                <label for="completionMaterialPercent">Material Completion Threshold (%)</label>
                                <input type="number" id="completionMaterialPercent" name="completionMaterialPercent" min="1" max="100" required value="${settings['learning.completionMaterialPercent']}">
                            </div>
                            <div class="admin-form-group">
                                <label for="defaultPassMark">Default Assessment Pass Mark (%)</label>
                                <input type="number" id="defaultPassMark" name="defaultPassMark" min="1" max="100" required value="${settings['assessment.defaultPassMark']}">
                            </div>
                            <div class="admin-form-group">
                                <label for="defaultMaxAttempts">Default Max Attempts</label>
                                <input type="number" id="defaultMaxAttempts" name="defaultMaxAttempts" min="1" max="10" required value="${settings['assessment.defaultMaxAttempts']}">
                            </div>
                            <div class="admin-form-group">
                                <label for="autoActivateEnrollment">Activate Enrollment After Successful Payment</label>
                                <select id="autoActivateEnrollment" name="autoActivateEnrollment">
                                    <option value="true" ${settings['enrollment.autoActivateOnPayment'] == 'true' ? 'selected' : ''}>Yes</option>
                                    <option value="false" ${settings['enrollment.autoActivateOnPayment'] == 'false' ? 'selected' : ''}>No</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <div>
                        <h2>Save Changes</h2>
                        <p class="section-caption">Commit or validate configuration changes from here.</p>
                    </div>
                </div>
                <div class="section-actions-inset">
                    <button type="submit" name="action" value="save" class="admin-btn primary"><i class="fas fa-save"></i>&nbsp;Save Settings</button>
                    <button type="submit" name="action" value="testsmtp" class="admin-btn secondary"><i class="fas fa-envelope-circle-check"></i>&nbsp;Test SMTP</button>
                    <a href="${pageContext.request.contextPath}/admin/settings" class="admin-btn secondary">Reset</a>
                </div>
            </section>

            <section class="section-card">
                <div class="section-header">
                    <div>
                        <h2>Recent Settings Audit</h2>
                        <p class="section-caption">Track recent configuration changes for accountability and troubleshooting.</p>
                    </div>
                    <span class="status-badge status-secondary">${fn:length(audits)} entries</span>
                </div>
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                        <tr>
                            <th>When</th>
                            <th>Key</th>
                            <th>Old Value</th>
                            <th>New Value</th>
                            <th>Changed By</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${empty audits}">
                                <tr>
                                    <td colspan="5">
                                        <div class="empty-state empty-state-inset">
                                            <i class="fas fa-clock-rotate-left"></i>
                                            <p>No setting changes have been logged yet.</p>
                                        </div>
                                    </td>
                                </tr>
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
        </form>
    </div>
</main>
</body>
</html>
