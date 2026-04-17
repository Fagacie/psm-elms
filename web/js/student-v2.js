(function () {
    var body = document.body;
    var shellToggle = document.getElementById('svShellToggle') || document.getElementById('svMenuBtn');
    var sidebar = document.getElementById('svSidebar');
    var overlay = document.getElementById('svOverlay');
    var profileBtn = document.getElementById('svProfileMenuBtn');
    var profileMenu = document.getElementById('svProfileMenu');
    var profileDropdown = document.getElementById('svProfileDropdown');
    var notificationBtn = document.getElementById('svNotificationBtn');
    var notificationPanel = document.getElementById('svNotificationPanel');
    var notificationWrap = document.getElementById('svNotificationWrap');
    var desktopMedia = window.matchMedia('(max-width: 1100px)');
    var collapseStorageKey = 'svSidebarCollapsed';

    body.classList.add('sv-page-enter');
    window.requestAnimationFrame(function () {
        body.classList.add('sv-page-enter-active');
    });

    function isMobileShell() {
        return desktopMedia.matches;
    }

    function syncToggleState() {
        if (!shellToggle) {
            return;
        }

        if (isMobileShell()) {
            shellToggle.setAttribute('aria-expanded', body.classList.contains('sv-mobile-nav-open') ? 'true' : 'false');
            return;
        }

        shellToggle.setAttribute('aria-expanded', body.classList.contains('sv-shell-collapsed') ? 'true' : 'false');
    }

    function closeMobileSidebar() {
        if (!sidebar || !overlay) return;
        body.classList.remove('sv-mobile-nav-open');
        sidebar.classList.remove('open');
        overlay.classList.remove('show');
        syncToggleState();
    }

    function openMobileSidebar() {
        if (!sidebar || !overlay) return;
        body.classList.add('sv-mobile-nav-open');
        sidebar.classList.add('open');
        overlay.classList.add('show');
        syncToggleState();
    }

    function syncDesktopState() {
        if (isMobileShell()) {
            body.classList.remove('sv-shell-collapsed');
            closeMobileSidebar();
            syncToggleState();
            return;
        }

        if (window.localStorage.getItem(collapseStorageKey) === '1') {
            body.classList.add('sv-shell-collapsed');
        } else {
            body.classList.remove('sv-shell-collapsed');
        }
        syncToggleState();
    }

    function closePopover(button, panel) {
        if (!button || !panel) return;
        button.setAttribute('aria-expanded', 'false');
        panel.classList.remove('open');
    }

    function togglePopover(button, panel) {
        if (!button || !panel) return;
        var expanded = button.getAttribute('aria-expanded') === 'true';
        button.setAttribute('aria-expanded', expanded ? 'false' : 'true');
        panel.classList.toggle('open', !expanded);
    }

    syncDesktopState();

    if (shellToggle && sidebar && overlay) {
        shellToggle.addEventListener('click', function () {
            if (isMobileShell()) {
                if (body.classList.contains('sv-mobile-nav-open')) {
                    closeMobileSidebar();
                } else {
                    openMobileSidebar();
                }
                return;
            }

            var collapsed = body.classList.toggle('sv-shell-collapsed');
            window.localStorage.setItem(collapseStorageKey, collapsed ? '1' : '0');
            syncToggleState();
        });

        overlay.addEventListener('click', closeMobileSidebar);
    }

    if (profileBtn && profileMenu && profileDropdown) {
        profileBtn.addEventListener('click', function () {
            closePopover(notificationBtn, notificationPanel);
            togglePopover(profileBtn, profileMenu);
        });
    }

    if (notificationBtn && notificationPanel && notificationWrap) {
        notificationBtn.addEventListener('click', function () {
            closePopover(profileBtn, profileMenu);
            togglePopover(notificationBtn, notificationPanel);
        });
    }

    document.addEventListener('click', function (event) {
        if (profileDropdown && !profileDropdown.contains(event.target)) {
            closePopover(profileBtn, profileMenu);
        }
        if (notificationWrap && !notificationWrap.contains(event.target)) {
            closePopover(notificationBtn, notificationPanel);
        }
    });

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            closeMobileSidebar();
            closePopover(profileBtn, profileMenu);
            closePopover(notificationBtn, notificationPanel);
        }
    });

    window.addEventListener('resize', syncDesktopState);
    if (desktopMedia.addEventListener) {
        desktopMedia.addEventListener('change', syncDesktopState);
    } else if (desktopMedia.addListener) {
        desktopMedia.addListener(syncDesktopState);
    }

    if (sidebar) {
        var sidebarLinks = sidebar.querySelectorAll('a');
        for (var i = 0; i < sidebarLinks.length; i++) {
            sidebarLinks[i].addEventListener('click', function () {
                if (isMobileShell()) {
                    closeMobileSidebar();
                }
            });
        }
    }
})();
