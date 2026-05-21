(function () {
    var prefersReducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    // =============================================
    // 1. COUNTER ANIMATIONS
    // =============================================
    var counters = document.querySelectorAll('.sd3-count[data-counter]');
    
    function animateCounters() {
        counters.forEach(function (counter) {
            if (counter.dataset.counted === '1') return;
            var target = parseInt(counter.getAttribute('data-counter'), 10);
            if (isNaN(target)) return;
            var suffix = counter.getAttribute('data-suffix') || '';
            counter.dataset.counted = '1';
            var startTs = 0;
            var duration = prefersReducedMotion ? 0 : 800;

            function tick(ts) {
                if (!startTs) startTs = ts;
                var p = duration === 0 ? 1 : Math.min((ts - startTs) / duration, 1);
                var eased = 1 - Math.pow(1 - p, 3);
                counter.textContent = Math.floor(target * eased) + suffix;
                if (p < 1) window.requestAnimationFrame(tick);
            }

            window.requestAnimationFrame(tick);
        });
    }

    // =============================================
    // 2. SVG CIRCULAR PROGRESS ANIMATIONS
    // =============================================
    function animateProgressCircles() {
        // Main overall progress circular ring
        var mainCircle = document.querySelector('.sd3-progress-circle-fg');
        if (mainCircle) {
            var progress = parseFloat(mainCircle.getAttribute('data-progress')) || 0;
            var radius = parseFloat(mainCircle.getAttribute('r')) || 40;
            var circumference = 2 * Math.PI * radius; // 251.2
            
            mainCircle.style.strokeDasharray = circumference;
            mainCircle.style.strokeDashoffset = circumference;
            
            setTimeout(function() {
                var offset = circumference - (Math.min(100, Math.max(0, progress)) / 100) * circumference;
                mainCircle.style.strokeDashoffset = offset;
            }, 100);
        }

        // Compact course progress rings inside cards
        var compactCircles = document.querySelectorAll('.sd3-compact-circle-fg');
        compactCircles.forEach(function (circle) {
            var progress = parseFloat(circle.getAttribute('data-progress')) || 0;
            var radius = parseFloat(circle.getAttribute('r')) || 18;
            var circumference = 2 * Math.PI * radius; // 113.1

            circle.style.strokeDasharray = circumference;
            circle.style.strokeDashoffset = circumference;

            // Set progress color dynamically based on thresholds
            var color = '#dc2626'; // Under 35% Red
            if (progress >= 35 && progress < 75) {
                color = '#f59e0b'; // 35-74% Gold
            } else if (progress >= 75) {
                color = '#10b981'; // 75%+ Green
            }
            circle.style.stroke = color;

            setTimeout(function() {
                var offset = circumference - (Math.min(100, Math.max(0, progress)) / 100) * circumference;
                circle.style.strokeDashoffset = offset;
            }, 150);
        });
    }

    // =============================================
    // 3. WIDGET DRAG-AND-DROP & CUSTOMIZATION
    // =============================================
    var STORAGE_KEY = 'sd3_student_dashboard_widgets_v1';
    var dashboard = document.querySelector('.sd3-dashboard');
    var container = document.getElementById('sd3WidgetsContainer');
    var customizeBtn = document.getElementById('btnCustomizeLayout');
    var saveBtn = document.getElementById('btnSaveLayout');
    var resetBtn = document.getElementById('btnResetLayout');
    var customizerPanel = document.getElementById('sd3CustomizerPanel');
    var a11yLive = document.getElementById('sd3A11yLive');
    
    var defaultLayout = {
        order: ['widget-courses', 'widget-credentials', 'widget-quicknav'],
        visible: {
            'widget-courses': true,
            'widget-credentials': true,
            'widget-quicknav': true
        }
    };

    function loadSavedLayout() {
        try {
            var saved = localStorage.getItem(STORAGE_KEY);
            if (saved) {
                return JSON.parse(saved);
            }
        } catch(e) {
            console.error('Error loading widget layout', e);
        }
        return defaultLayout;
    }

    function saveLayout(layout) {
        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(layout));
        } catch(e) {
            console.error('Error saving widget layout', e);
        }
    }

    function applyLayout() {
        if (!container) return;
        var layout = loadSavedLayout();
        
        // 1. Re-order DOM nodes
        layout.order.forEach(function (widgetId) {
            var widgetEl = document.getElementById(widgetId);
            if (widgetEl) {
                container.appendChild(widgetEl); // append moves the existing element
            }
        });

        // 2. Set visibility states
        layout.order.forEach(function (widgetId) {
            var widgetEl = document.getElementById(widgetId);
            if (widgetEl) {
                var isVisible = layout.visible[widgetId] !== false;
                widgetEl.style.display = isVisible ? '' : 'none';
                
                // Keep checkbox checked state in sync
                var cb = document.getElementById('toggle-' + widgetId);
                if (cb) {
                    cb.checked = isVisible;
                }
            }
        });
    }

    function getWidgetOrder() {
        if (!container) return [];
        var widgets = container.querySelectorAll('.sd3-widget');
        var order = [];
        widgets.forEach(function (widget) {
            order.push(widget.getAttribute('data-widget-id'));
        });
        return order;
    }

    function getWidgetVisibility() {
        var visible = {};
        var layout = loadSavedLayout();
        layout.order.forEach(function (widgetId) {
            var cb = document.getElementById('toggle-' + widgetId);
            if (cb) {
                visible[widgetId] = cb.checked;
            } else {
                visible[widgetId] = layout.visible[widgetId] !== false;
            }
        });
        return visible;
    }

    function announceA11y(text) {
        if (a11yLive) {
            a11yLive.textContent = text;
        }
    }

    function toggleCustomizeMode(active) {
        if (!dashboard || !customizerPanel || !customizeBtn) return;

        dashboard.classList.toggle('sd3-customize-active', active);
        customizerPanel.style.display = active ? 'flex' : 'none';
        customizeBtn.setAttribute('aria-expanded', active ? 'true' : 'false');
        
        var widgets = document.querySelectorAll('.sd3-widget');
        widgets.forEach(function (widget) {
            // When customizer is active, widgets are interactive and draggable
            widget.setAttribute('draggable', active ? 'true' : 'false');
            if (active) {
                widget.style.display = ''; // temporarily show hidden widgets in edit mode with a dashed layout
                widget.setAttribute('aria-describedby', 'widget-customize-instructions');
            } else {
                // Apply the saved/actual visibility state when exiting
                var layout = loadSavedLayout();
                var isVisible = layout.visible[widget.id] !== false;
                widget.style.display = isVisible ? '' : 'none';
                widget.removeAttribute('aria-describedby');
            }
        });

        if (active) {
            announceA11y("Dashboard customization mode active. Draggables are ready. Use tab to access switches, or arrow keys to sort focused widgets.");
            customizerPanel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        } else {
            announceA11y("Layout saved successfully.");
        }
    }

    // --- Drag and Drop Events ---
    var draggedWidget = null;

    function initDragAndDrop() {
        if (!container) return;

        container.addEventListener('dragstart', function (e) {
            if (!dashboard.classList.contains('sd3-customize-active')) return;
            
            var target = e.target.closest('.sd3-widget');
            if (!target) return;

            draggedWidget = target;
            draggedWidget.classList.add('widget-ghost');
            
            e.dataTransfer.effectAllowed = 'move';
            e.dataTransfer.setData('text/plain', target.id);
        });

        container.addEventListener('dragend', function (e) {
            if (draggedWidget) {
                draggedWidget.classList.remove('widget-ghost');
                draggedWidget = null;
            }
            
            var hoverEls = container.querySelectorAll('.widget-drag-over');
            hoverEls.forEach(function (el) {
                el.classList.remove('widget-drag-over');
            });
        });

        container.addEventListener('dragover', function (e) {
            if (!dashboard.classList.contains('sd3-customize-active') || !draggedWidget) return;
            e.preventDefault();
            
            var target = e.target.closest('.sd3-widget');
            if (!target || target === draggedWidget) return;

            target.classList.add('widget-drag-over');
            e.dataTransfer.dropEffect = 'move';
        });

        container.addEventListener('dragleave', function (e) {
            var target = e.target.closest('.sd3-widget');
            if (target) {
                target.classList.remove('widget-drag-over');
            }
        });

        container.addEventListener('drop', function (e) {
            if (!dashboard.classList.contains('sd3-customize-active') || !draggedWidget) return;
            e.preventDefault();

            var target = e.target.closest('.sd3-widget');
            if (!target || target === draggedWidget) return;

            target.classList.remove('widget-drag-over');

            // Calculate where to drop (before or after the target)
            var rect = target.getBoundingClientRect();
            var next = (e.clientY - rect.top) > (rect.height / 2);
            
            if (next) {
                container.insertBefore(draggedWidget, target.nextSibling);
            } else {
                container.insertBefore(draggedWidget, target);
            }

            var widgetName = draggedWidget.querySelector('h2, h3').textContent.trim();
            var newIndex = Array.from(container.children).indexOf(draggedWidget) + 1;
            announceA11y("Dropped " + widgetName + " at position " + newIndex + " of " + container.children.length);
        });
    }

    // --- Keyboard accessibility for reordering ---
    function initKeyboardSorting() {
        if (!container) return;

        container.addEventListener('keydown', function (e) {
            if (!dashboard.classList.contains('sd3-customize-active')) return;

            var activeWidget = document.activeElement.closest('.sd3-widget');
            if (!activeWidget) return;

            var key = e.key;
            if (key === 'ArrowUp' || key === 'ArrowLeft') {
                e.preventDefault();
                var prev = activeWidget.previousElementSibling;
                if (prev && prev.classList.contains('sd3-widget')) {
                    container.insertBefore(activeWidget, prev);
                    activeWidget.focus();
                    var name = activeWidget.querySelector('h2, h3').textContent.trim();
                    var pos = Array.from(container.children).indexOf(activeWidget) + 1;
                    announceA11y("Moved " + name + " up to position " + pos + " of " + container.children.length);
                }
            } else if (key === 'ArrowDown' || key === 'ArrowRight') {
                e.preventDefault();
                var next = activeWidget.nextElementSibling;
                if (next && next.classList.contains('sd3-widget')) {
                    container.insertBefore(activeWidget, next.nextSibling);
                    activeWidget.focus();
                    var name = activeWidget.querySelector('h2, h3').textContent.trim();
                    var pos = Array.from(container.children).indexOf(activeWidget) + 1;
                    announceA11y("Moved " + name + " down to position " + pos + " of " + container.children.length);
                }
            }
        });
    }

    // --- Customize Control Buttons and Panel Setup ---
    function setupCustomizerActions() {
        if (customizeBtn) {
            customizeBtn.addEventListener('click', function () {
                toggleCustomizeMode(true);
            });
        }

        if (saveBtn) {
            saveBtn.addEventListener('click', function () {
                var order = getWidgetOrder();
                var visible = getWidgetVisibility();
                
                saveLayout({
                    order: order,
                    visible: visible
                });
                
                toggleCustomizeMode(false);
                applyLayout();
            });
        }

        if (resetBtn) {
            resetBtn.addEventListener('click', function () {
                localStorage.removeItem(STORAGE_KEY);
                applyLayout();
                toggleCustomizeMode(false);
                announceA11y("Dashboard layout reset to factory defaults.");
            });
        }
    }

    // =============================================
    // 4. GREETING DYNAMICS
    // =============================================
    function updateGreeting() {
        var greetingEl = document.getElementById('sd3DynamicGreeting');
        if (!greetingEl) return;
        var rawText = greetingEl.textContent || '';
        var userName = rawText.replace('Welcome back, ', '').trim();
        var hour = new Date().getHours();
        var greeting = 'Welcome back';
        if (hour < 12) {
            greeting = 'Good morning';
        } else if (hour < 18) {
            greeting = 'Good afternoon';
        } else {
            greeting = 'Good evening';
        }
        greetingEl.innerHTML = greeting + ', <span class="sd3-welcome-banner__username">' + userName + '</span>';
    }

    // Initialize Everything
    applyLayout();
    animateCounters();
    animateProgressCircles();
    updateGreeting();
    
    initDragAndDrop();
    initKeyboardSorting();
    setupCustomizerActions();
})();
