/**
 * Instructor UX Utilities
 * Provides lightweight vanilla JS enhancements for the Instructor Portal.
 */
const InsUX = (function() {
    
    // --- 1. TOAST NOTIFICATIONS ---
    
    function getToastContainer() {
        let container = document.getElementById('ins-toast-container');
        if (!container) {
            container = document.createElement('div');
            container.id = 'ins-toast-container';
            container.className = 'ins-toast-container';
            document.body.appendChild(container);
        }
        return container;
    }

    /**
     * Shows a toast notification.
     * @param {string} message - The message to display.
     * @param {string} type - 'success', 'error', 'warning', or 'info'.
     * @param {number} durationMs - How long to show the toast (default 4000ms).
     */
    function showToast(message, type = 'info', durationMs = 4000) {
        const container = getToastContainer();
        const toast = document.createElement('div');
        toast.className = 'ins-toast ins-toast-' + type;
        
        let iconClass = 'fa-info-circle';
        if (type === 'success') iconClass = 'fa-check-circle';
        if (type === 'error') iconClass = 'fa-exclamation-circle';
        if (type === 'warning') iconClass = 'fa-exclamation-triangle';

        toast.innerHTML = `
            <i class="fas ${iconClass} ins-toast-icon"></i>
            <span class="ins-toast-msg">${message}</span>
            <button type="button" class="ins-toast-close" aria-label="Close">&times;</button>
        `;

        container.appendChild(toast);

        // Force reflow for animation
        toast.offsetHeight;
        toast.classList.add('show');

        let isClosed = false;

        const closeToast = () => {
            if (isClosed) return;
            isClosed = true;
            toast.classList.remove('show');
            setTimeout(() => {
                if (toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 300); // Wait for transition
        };

        toast.querySelector('.ins-toast-close').addEventListener('click', closeToast);

        if (durationMs > 0) {
            setTimeout(closeToast, durationMs);
        }
    }

    // --- 2. NATIVE DIALOG MODALS ---

    function getDialogElement() {
        let dialog = document.getElementById('ins-confirm-dialog');
        if (!dialog) {
            dialog = document.createElement('dialog');
            dialog.id = 'ins-confirm-dialog';
            dialog.className = 'ins-dialog';
            document.body.appendChild(dialog);
        }
        return dialog;
    }

    /**
     * Shows a confirmation modal using the native <dialog> element.
     * @param {string} title 
     * @param {string} message 
     * @param {function} onConfirmCallback 
     */
    function confirmAction(title, message, onConfirmCallback) {
        const dialog = getDialogElement();
        
        dialog.innerHTML = `
            <div class="ins-dialog-content">
                <h3 class="ins-dialog-title">${title}</h3>
                <p class="ins-dialog-msg">${message}</p>
                <div class="ins-dialog-actions">
                    <button type="button" class="btn btn-secondary" id="ins-dialog-cancel">Cancel</button>
                    <button type="button" class="btn btn-primary" id="ins-dialog-confirm">Confirm</button>
                </div>
            </div>
        `;

        const cancelBtn = dialog.querySelector('#ins-dialog-cancel');
        const confirmBtn = dialog.querySelector('#ins-dialog-confirm');

        const closeDialog = () => {
            dialog.classList.remove('show');
            setTimeout(() => dialog.close(), 200); // fade out
        };

        cancelBtn.addEventListener('click', closeDialog);
        
        confirmBtn.addEventListener('click', () => {
            closeDialog();
            if (typeof onConfirmCallback === 'function') {
                onConfirmCallback();
            }
        });

        // Click outside to close
        dialog.addEventListener('click', (e) => {
            const rect = dialog.getBoundingClientRect();
            if (e.clientY < rect.top || e.clientY > rect.bottom || e.clientX < rect.left || e.clientX > rect.right) {
                closeDialog();
            }
        });

        dialog.showModal();
        dialog.classList.add('show');
    }

    // --- 3. LIVE SEARCH FILTER ---

    function initLiveSearch() {
        const searchInputs = document.querySelectorAll('[data-search-target]');
        
        searchInputs.forEach(input => {
            input.addEventListener('input', function(e) {
                const targetSelector = this.getAttribute('data-search-target');
                const itemSelector = this.getAttribute('data-search-item');
                const term = e.target.value.toLowerCase().trim();
                
                const container = document.querySelector(targetSelector);
                if (!container) return;

                const items = container.querySelectorAll(itemSelector);
                let visibleCount = 0;

                items.forEach(item => {
                    // Collect text from specific elements or the whole item
                    const textElements = item.querySelectorAll('[data-search-text]');
                    let content = '';
                    
                    if (textElements.length > 0) {
                        textElements.forEach(el => content += el.textContent.toLowerCase() + ' ');
                    } else {
                        content = item.textContent.toLowerCase();
                    }

                    if (content.includes(term)) {
                        item.style.display = '';
                        visibleCount++;
                    } else {
                        item.style.display = 'none';
                    }
                });
                
                // Handle empty state visually if needed
                let emptyState = container.querySelector('.ins-search-empty-state');
                if (visibleCount === 0 && items.length > 0) {
                    if (!emptyState) {
                        emptyState = document.createElement('div');
                        emptyState.className = 'empty-state-box ins-search-empty-state';
                        emptyState.style.gridColumn = '1 / -1';
                        emptyState.innerHTML = '<i class="fas fa-search"></i><p>No matches found for "' + term + '".</p>';
                        container.appendChild(emptyState);
                    } else {
                        emptyState.innerHTML = '<i class="fas fa-search"></i><p>No matches found for "' + term + '".</p>';
                        emptyState.style.display = '';
                    }
                } else if (emptyState) {
                    emptyState.style.display = 'none';
                }
            });
        });
    }

    // --- 4. AUTO CONVERT STATIC ALERTS TO TOASTS ---
    
    function convertAlertsToToasts() {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            // We only want to convert generic page alerts, not inline form validation if they are explicitly inline
            if (alert.closest('.form-group')) return;

            let type = 'info';
            if (alert.classList.contains('alert-success')) type = 'success';
            if (alert.classList.contains('alert-error') || alert.classList.contains('alert-danger')) type = 'error';
            if (alert.classList.contains('alert-warning')) type = 'warning';

            // Extract text carefully
            let msg = alert.textContent.trim();
            
            // Show toast
            showToast(msg, type, 5000);
            
            // Hide the original alert gracefully
            alert.style.display = 'none';
        });
    }

    // Initialize everything on DOM load
    document.addEventListener('DOMContentLoaded', () => {
        initLiveSearch();
        convertAlertsToToasts();
    });

    // Public API
    return {
        showToast,
        confirm: confirmAction,
        initLiveSearch
    };
})();
