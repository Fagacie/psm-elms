(function () {
    var scenes = document.querySelectorAll('.av2-scene');
    if (!scenes.length) return;

    var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduceMotion) return;

    function applyTransform(scene, event) {
        var rect = scene.getBoundingClientRect();
        var x = ((event.clientX - rect.left) / rect.width) - 0.5;
        var y = ((event.clientY - rect.top) / rect.height) - 0.5;
        var objs = scene.querySelectorAll('.av2-obj');

        objs.forEach(function (obj) {
            var depth = parseFloat(obj.getAttribute('data-depth')) || 14;
            var tx = x * depth;
            var ty = y * depth;
            obj.style.transform = 'translate3d(' + tx.toFixed(2) + 'px,' + ty.toFixed(2) + 'px,0)';
        });
    }

    function reset(scene) {
        var objs = scene.querySelectorAll('.av2-obj');
        objs.forEach(function (obj) {
            obj.style.transform = 'translate3d(0,0,0)';
        });
    }

    scenes.forEach(function (scene) {
        scene.classList.add('is-parallax');
        scene.addEventListener('mousemove', function (event) {
            applyTransform(scene, event);
        });

        scene.addEventListener('mouseleave', function () {
            reset(scene);
        });
    });
})();

