<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script>
    (function () {
        var root = document.documentElement;
        var theme = 'light';
        root.classList.add('theme-preload');
        try {
            var saved = window.localStorage.getItem('psme-theme');
            if (saved === 'light' || saved === 'dark') {
                theme = saved;
            } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
                theme = 'dark';
            }
        } catch (error) {
            if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
                theme = 'dark';
            }
        }

        root.setAttribute('data-theme', theme);
        root.style.colorScheme = theme;
    })();
</script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/theme-toggle.css">
<script defer src="${pageContext.request.contextPath}/js/theme-toggle.js"></script>
