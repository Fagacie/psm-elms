<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Error - PSM E-Learning</title>
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
                radial-gradient(circle at top, rgba(249, 115, 22, 0.18), transparent 28%),
                linear-gradient(180deg, #fff7ed, #ffedd5);
            color: #7c2d12;
        }

        .error-shell {
            width: min(560px, 100%);
            padding: 40px;
            border: 1px solid rgba(124, 45, 18, 0.12);
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.9);
            box-shadow: 0 24px 60px rgba(124, 45, 18, 0.14);
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
            color: #9a3412;
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
            background: #c2410c;
            color: #fff;
        }

        .error-link.secondary {
            border: 1px solid rgba(124, 45, 18, 0.16);
            color: #7c2d12;
            background: rgba(255, 255, 255, 0.72);
        }

        html[data-theme='dark'] body {
            background:
                radial-gradient(circle at top, rgba(251, 146, 60, 0.2), transparent 28%),
                linear-gradient(180deg, #111827, #1f2937);
            color: #fed7aa;
        }

        html[data-theme='dark'] .error-shell {
            background: rgba(31, 41, 55, 0.92);
            border-color: rgba(251, 146, 60, 0.2);
            box-shadow: 0 24px 60px rgba(0, 0, 0, 0.42);
        }

        html[data-theme='dark'] .error-copy {
            color: #fdba74;
        }

        html[data-theme='dark'] .error-link.primary {
            background: #fb923c;
            color: #431407;
        }

        html[data-theme='dark'] .error-link.secondary {
            background: rgba(17, 24, 39, 0.84);
            border-color: rgba(251, 146, 60, 0.24);
            color: #ffedd5;
        }
    </style>
</head>
<body>
<main class="error-shell">
    <p class="error-code">500</p>
    <h1 class="error-title">Something went wrong on our side.</h1>
    <p class="error-copy">The request reached the server, but it could not complete successfully. Returning to a stable page is the safest next step while the issue is investigated.</p>
    <div class="error-actions">
        <a class="error-link primary" href="${pageContext.request.contextPath}/landing">Go to Landing</a>
        <a class="error-link secondary" href="${pageContext.request.contextPath}/dashboard">Try Dashboard Again</a>
    </div>
</main>
</body>
</html>
