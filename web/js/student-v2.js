(function () {
    var menuBtn = document.getElementById('svMenuBtn');
    var sidebar = document.getElementById('svSidebar');
    var overlay = document.getElementById('svOverlay');

    function closeSidebar() {
        if (!sidebar || !overlay) return;
        sidebar.classList.remove('open');
        overlay.classList.remove('show');
    }

    if (menuBtn && sidebar && overlay) {
        menuBtn.addEventListener('click', function () {
            sidebar.classList.toggle('open');
            overlay.classList.toggle('show');
        });

        overlay.addEventListener('click', closeSidebar);
        window.addEventListener('resize', function () {
            if (window.innerWidth > 1024) closeSidebar();
        });
    }
})();
