(function () {
    var filters = document.querySelectorAll('.cert-filter');
    var searchInput = document.getElementById('certQuickSearch');
    var rows = document.querySelectorAll('.cert-row');
    var noRows = document.getElementById('certNoRows');
    var copyButtons = document.querySelectorAll('[data-cert-copy]');
    var downloadButtons = document.querySelectorAll('[data-cert-download]');
    var copyToast = document.getElementById('certCopyToast');

    function showCopyToast(message) {
        if (!copyToast) return;
        copyToast.textContent = message;
        copyToast.classList.add('is-visible');
        window.clearTimeout(showCopyToast._timer);
        showCopyToast._timer = window.setTimeout(function () {
            copyToast.classList.remove('is-visible');
        }, 1800);
    }

    function flashCopyState(button, text) {
        var original = button.innerHTML;
        button.innerHTML = '<i class="fas fa-check"></i><span>' + text + '</span>';
        window.setTimeout(function () {
            button.innerHTML = original;
        }, 1200);
    }

    function copyCertificateCode(code, button) {
        if (!code) return;

        function onSuccess() {
            if (button) flashCopyState(button, 'Code Copied');
            showCopyToast('Certificate code copied: ' + code);
        }

        function onFailure() {
            if (button) flashCopyState(button, 'Copy Failed');
            showCopyToast('Copy failed. Please copy manually: ' + code);
        }

        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(code).then(onSuccess).catch(onFailure);
            return;
        }

        var temp = document.createElement('input');
        temp.type = 'text';
        temp.value = code;
        document.body.appendChild(temp);
        temp.select();
        try {
            document.execCommand('copy');
            onSuccess();
        } catch (e) {
            onFailure();
        }
        document.body.removeChild(temp);
    }

    function wireCopyButtons() {
        if (!copyButtons.length) return;
        copyButtons.forEach(function (btn) {
            btn.addEventListener('click', function () {
                copyCertificateCode(btn.getAttribute('data-cert-copy'), btn);
            });
        });
    }

    function triggerBackgroundDownload(url) {
        if (!url) return;
        var iframe = document.getElementById('certPngDownloadFrame');
        if (!iframe) {
            iframe = document.createElement('iframe');
            iframe.id = 'certPngDownloadFrame';
            iframe.style.position = 'fixed';
            iframe.style.left = '-10000px';
            iframe.style.top = '0';
            iframe.style.width = '1600px';
            iframe.style.height = '1200px';
            iframe.style.border = '0';
            iframe.style.opacity = '0';
            iframe.style.pointerEvents = 'none';
            document.body.appendChild(iframe);
        }
        var sep = url.indexOf('?') === -1 ? '?' : '&';
        iframe.src = url + sep + '_ts=' + Date.now();
    }

    function wireDownloadButtons() {
        if (!downloadButtons.length) return;
        downloadButtons.forEach(function (btn) {
            btn.addEventListener('click', function () {
                var url = btn.getAttribute('data-cert-download');
                triggerBackgroundDownload(url);
                showCopyToast('Preparing certificate PDF download...');
            });
        });
    }

    function applyFilters() {
        if (!rows.length) return;

        var activeButton = document.querySelector('.cert-filter.active');
        var mode = activeButton ? activeButton.getAttribute('data-filter') : 'all';
        var q = searchInput ? searchInput.value.trim().toLowerCase() : '';
        var visibleCount = 0;

        rows.forEach(function (row) {
            var status = row.getAttribute('data-status') || '';
            var course = (row.getAttribute('data-course') || '').toLowerCase();
            var cert = (row.getAttribute('data-cert') || '').toLowerCase();
            var modeMatch = mode === 'all' ? true : status === mode;
            var searchMatch = q ? (course.indexOf(q) !== -1 || cert.indexOf(q) !== -1) : true;
            var show = modeMatch && searchMatch;

            row.style.display = show ? '' : 'none';
            if (show) visibleCount += 1;
        });

        if (noRows) {
            noRows.style.display = visibleCount === 0 ? 'grid' : 'none';
        }
    }

    filters.forEach(function (btn) {
        btn.addEventListener('click', function () {
            filters.forEach(function (b) { b.classList.remove('active'); });
            btn.classList.add('active');
            applyFilters();
        });
    });

    if (searchInput) {
        searchInput.addEventListener('input', applyFilters);

        document.addEventListener('keydown', function (event) {
            if (event.key === '/' && document.activeElement !== searchInput) {
                event.preventDefault();
                searchInput.focus();
            }
            if (event.key === 'Escape' && document.activeElement === searchInput) {
                searchInput.value = '';
                applyFilters();
                searchInput.blur();
            }
        });
    }

    wireCopyButtons();
    wireDownloadButtons();
    applyFilters();
})();
