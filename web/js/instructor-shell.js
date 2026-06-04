(function () {
    if (document.querySelector('.nav_mod_topbar')) {
        return;
    }
    var body = document.body;
    var toggle = document.getElementById('insMenuBtn') || document.getElementById('instructorMenuToggle');
    var sidebar = document.getElementById('insSidebar');
    var mobileMedia = window.matchMedia('(max-width: 860px)');
    var storageKey = 'insSidebarCollapsed';
    var overlay = document.getElementById('insShellOverlay');

    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'insShellOverlay';
        overlay.className = 'ins-shell-overlay';
        document.body.appendChild(overlay);
    }

    function isMobile() {
        return mobileMedia.matches;
    }

    function syncToggle() {
        if (!toggle) return;
        var expanded = isMobile() ? body.classList.contains('ins-mobile-nav-open') : !body.classList.contains('ins-shell-collapsed');
        toggle.setAttribute('aria-expanded', expanded ? 'true' : 'false');
    }

    function closeMobileNav() {
        body.classList.remove('ins-mobile-nav-open');
        if (sidebar) sidebar.classList.remove('open');
        if (overlay) overlay.classList.remove('show');
        syncToggle();
    }

    function openMobileNav() {
        body.classList.add('ins-mobile-nav-open');
        if (sidebar) sidebar.classList.add('open');
        if (overlay) overlay.classList.add('show');
        syncToggle();
    }

    function syncShellMode() {
        if (isMobile()) {
            body.classList.remove('ins-shell-collapsed');
            closeMobileNav();
            return;
        }

        closeMobileNav();
        if (window.localStorage.getItem(storageKey) === '1') {
            body.classList.add('ins-shell-collapsed');
        } else {
            body.classList.remove('ins-shell-collapsed');
        }
        syncToggle();
    }

    syncShellMode();

    if (toggle && sidebar) {
        toggle.addEventListener('click', function () {
            if (isMobile()) {
                if (body.classList.contains('ins-mobile-nav-open')) {
                    closeMobileNav();
                } else {
                    openMobileNav();
                }
                return;
            }

            var collapsed = body.classList.toggle('ins-shell-collapsed');
            window.localStorage.setItem(storageKey, collapsed ? '1' : '0');
            syncToggle();
        });
    }

    if (overlay) {
        overlay.addEventListener('click', closeMobileNav);
    }

    if (sidebar) {
        var links = sidebar.querySelectorAll('a');
        for (var i = 0; i < links.length; i++) {
            links[i].addEventListener('click', function () {
                if (isMobile()) closeMobileNav();
            });
        }
    }

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') closeMobileNav();
    });

    window.addEventListener('resize', syncShellMode);
    if (mobileMedia.addEventListener) {
        mobileMedia.addEventListener('change', syncShellMode);
    } else if (mobileMedia.addListener) {
        mobileMedia.addListener(syncShellMode);
    }
})();
