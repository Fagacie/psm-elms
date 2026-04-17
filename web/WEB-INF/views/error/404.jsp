<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - PSM E-Learning</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <jsp:include page="/WEB-INF/views/common/head-external-assets.jsp"/>
    <style>
        body {
            margin: 0;
            min-height: 100vh;
            display: grid;
            place-items: center;
            padding: 24px;
            font-family: 'Inter', sans-serif;
            background:
                radial-gradient(circle at top, rgba(14, 165, 233, 0.16), transparent 28%),
                linear-gradient(180deg, #f8fafc, #e2e8f0);
            color: #0f172a;
        }

        .error-shell {
            width: min(560px, 100%);
            padding: 40px;
            border: 1px solid rgba(15, 23, 42, 0.08);
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.88);
            box-shadow: 0 24px 60px rgba(15, 23, 42, 0.14);
            text-align: center;
        }

        .error-code {
            margin: 0 0 8px;
            font-size: clamp(3rem, 9vw, 5rem);
            line-height: 1;
        }

        .error-title {
            margin: 0 0 12px;
            font-size: 1.6rem;
        }

        .error-copy {
            margin: 0 0 24px;
            color: #475569;
            line-height: 1.6;
        }

        .error-actions {
            display: flex;
            justify-content: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .error-link {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 44px;
            padding: 0 18px;
            border-radius: 999px;
            text-decoration: none;
            font-weight: 700;
        }

        .error-link.primary {
            background: #0f172a;
            color: #fff;
        }

        .error-link.secondary {
            border: 1px solid rgba(15, 23, 42, 0.14);
            color: #0f172a;
            background: rgba(255, 255, 255, 0.7);
        }

        html[data-theme='dark'] body {
            background:
                radial-gradient(circle at top, rgba(56, 189, 248, 0.18), transparent 28%),
                linear-gradient(180deg, #020617, #111827);
            color: #e2e8f0;
        }

        html[data-theme='dark'] .error-shell {
            background: rgba(15, 23, 42, 0.9);
            border-color: rgba(148, 163, 184, 0.18);
            box-shadow: 0 24px 60px rgba(2, 6, 23, 0.45);
        }

        html[data-theme='dark'] .error-copy {
            color: #94a3b8;
        }

        html[data-theme='dark'] .error-link.primary {
            background: #38bdf8;
            color: #082f49;
        }

        html[data-theme='dark'] .error-link.secondary {
            background: rgba(15, 23, 42, 0.8);
            border-color: rgba(148, 163, 184, 0.22);
            color: #e2e8f0;
        }
    </style>
</head>
<body>
<main class="error-shell">
    <p class="error-code">404</p>
    <h1 class="error-title">This page doesn't exist.</h1>
    <p class="error-copy">The link may be outdated, the address may be incorrect, or the page may have moved while the project was evolving.</p>
    <div class="error-actions">
        <a class="error-link primary" href="${pageContext.request.contextPath}/landing">Go to Landing</a>
        <a class="error-link secondary" href="${pageContext.request.contextPath}/dashboard">Open Dashboard</a>
    </div>
</main>
</body>
</html>
