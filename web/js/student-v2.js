(function () {
    var menuBtn = document.getElementById('svMenuBtn');
    var sidebar = document.getElementById('svSidebar');
    var overlay = document.getElementById('svOverlay');
    var profileBtn = document.getElementById('svProfileMenuBtn');
    var profileMenu = document.getElementById('svProfileMenu');
    var profileDropdown = document.getElementById('svProfileDropdown');

    document.body.classList.add('sv-page-enter');
    window.requestAnimationFrame(function () {
        document.body.classList.add('sv-page-enter-active');
    });

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

    if (profileBtn && profileMenu && profileDropdown) {
        profileBtn.addEventListener('click', function () {
            var expanded = profileBtn.getAttribute('aria-expanded') === 'true';
            profileBtn.setAttribute('aria-expanded', expanded ? 'false' : 'true');
            profileMenu.classList.toggle('open', !expanded);
        });

        document.addEventListener('click', function (event) {
            if (!profileDropdown.contains(event.target)) {
                profileBtn.setAttribute('aria-expanded', 'false');
                profileMenu.classList.remove('open');
            }
        });
    }
})();
