(function () {
    var scene = document.getElementById('passwordHeroScene');
    var tiltEls = document.querySelectorAll('.password-v2-tilt');
    var toggles = document.querySelectorAll('.password-v2-toggle');
    var form = document.getElementById('passwordForm');
    var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    if (scene && !reduceMotion) {
        var layers = scene.querySelectorAll('[data-depth]');

        scene.addEventListener('mousemove', function (event) {
            var rect = scene.getBoundingClientRect();
            var x = ((event.clientX - rect.left) / rect.width) - 0.5;
            var y = ((event.clientY - rect.top) / rect.height) - 0.5;

            layers.forEach(function (layer) {
                var depth = parseFloat(layer.getAttribute('data-depth')) || 12;
                var tx = x * depth;
                var ty = y * depth;
                layer.style.transform = 'translate3d(' + tx.toFixed(2) + 'px,' + ty.toFixed(2) + 'px,0)';
            });
        });

        scene.addEventListener('mouseleave', function () {
            layers.forEach(function (layer) {
                layer.style.transform = 'translate3d(0,0,0)';
            });
        });
    }

    if (!reduceMotion) {
        tiltEls.forEach(function (el) {
            el.addEventListener('mousemove', function (event) {
                var rect = el.getBoundingClientRect();
                var x = event.clientX - rect.left;
                var y = event.clientY - rect.top;
                var cx = rect.width / 2;
                var cy = rect.height / 2;
                var rx = -((y - cy) / cy) * 4;
                var ry = ((x - cx) / cx) * 4;
                el.style.transform = 'perspective(900px) rotateX(' + rx.toFixed(2) + 'deg) rotateY(' + ry.toFixed(2) + 'deg) translateY(-2px)';
            });

            el.addEventListener('mouseleave', function () {
                el.style.transform = '';
            });
        });
    }

    toggles.forEach(function (toggle) {
        toggle.addEventListener('click', function () {
            var targetId = toggle.getAttribute('data-target');
            var input = document.getElementById(targetId);
            var icon = toggle.querySelector('i');
            if (!input || !icon) return;

            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        });
    });

    if (form) {
        form.addEventListener('submit', function (event) {
            var newPassword = document.getElementById('newPassword');
            var confirmPassword = document.getElementById('confirmPassword');
            if (newPassword && confirmPassword && newPassword.value !== confirmPassword.value) {
                event.preventDefault();
                window.alert('New password and confirmation password do not match. Please try again.');
            }
        });
    }
})();
