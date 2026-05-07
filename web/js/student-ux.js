/**
 * Student UX Utilities
 * Provides lightweight vanilla JS enhancements for the Student Portal.
 */
const StudentUX = (function() {
    
    // --- 1. TOAST NOTIFICATIONS ---
    
    function getToastContainer() {
        let container = document.getElementById('sv-toast-container');
        if (!container) {
            container = document.createElement('div');
            container.id = 'sv-toast-container';
            container.className = 'sv-toast-container';
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
        toast.className = 'sv-toast sv-toast-' + type;
        
        let iconClass = 'fa-info-circle';
        if (type === 'success') iconClass = 'fa-check-circle';
        if (type === 'error') iconClass = 'fa-exclamation-circle';
        if (type === 'warning') iconClass = 'fa-exclamation-triangle';

        toast.innerHTML = `
            <i class="fas ${iconClass} sv-toast-icon"></i>
            <span class="sv-toast-msg">${message}</span>
            <button type="button" class="sv-toast-close" aria-label="Close">&times;</button>
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

        toast.querySelector('.sv-toast-close').addEventListener('click', closeToast);

        if (durationMs > 0) {
            setTimeout(closeToast, durationMs);
        }
    }

    // --- 2. NATIVE DIALOG MODALS ---

    function getDialogElement() {
        let dialog = document.getElementById('sv-confirm-dialog');
        if (!dialog) {
            dialog = document.createElement('dialog');
            dialog.id = 'sv-confirm-dialog';
            dialog.className = 'sv-dialog';
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
            <div class="sv-dialog-content">
                <h3 class="sv-dialog-title">${title}</h3>
                <p class="sv-dialog-msg">${message}</p>
                <div class="sv-dialog-actions">
                    <button type="button" class="sv-btn" id="sv-dialog-cancel">Cancel</button>
                    <button type="button" class="sv-btn primary" id="sv-dialog-confirm">Confirm</button>
                </div>
            </div>
        `;

        const cancelBtn = dialog.querySelector('#sv-dialog-cancel');
        const confirmBtn = dialog.querySelector('#sv-dialog-confirm');

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
                let emptyState = container.querySelector('.sv-search-empty-state');
                if (visibleCount === 0 && items.length > 0) {
                    if (!emptyState) {
                        emptyState = document.createElement('div');
                        emptyState.className = 'empty-state-box sv-search-empty-state';
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
            // We only want to convert generic page alerts, not inline form validation
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

    // --- 5. ZERO-DEPENDENCY COLUMN SORTING FOR TABLES ---

    function initTableSorting() {
        const tables = document.querySelectorAll('.assessment-table, .history-table, table[data-sortable]');
        tables.forEach(table => {
            const headers = table.querySelectorAll('th');
            
            headers.forEach((header, index) => {
                // Ignore action columns
                if (header.textContent.toLowerCase().includes('action') || header.hasAttribute('data-unsortable')) {
                    return;
                }
                
                header.style.cursor = 'pointer';
                header.title = 'Click to sort column';
                header.classList.add('sv-sortable-header');
                
                // Add indicator wrapper if not present
                if (!header.querySelector('.sv-sort-icon')) {
                    header.innerHTML += ' <span class="sv-sort-icon" style="opacity: 0.3; font-size: 0.75rem; margin-left: 6px;"><i class="fas fa-sort"></i></span>';
                }
                
                let ascending = true;
                
                header.addEventListener('click', () => {
                    // Reset all other headers in this table
                    headers.forEach(h => {
                        if (h !== header && h.querySelector('.sv-sort-icon')) {
                            h.querySelector('.sv-sort-icon').innerHTML = '<i class="fas fa-sort"></i>';
                            h.querySelector('.sv-sort-icon').style.opacity = '0.3';
                        }
                    });
                    
                    const tbody = table.querySelector('tbody');
                    if (!tbody) return;
                    
                    const rows = Array.from(tbody.querySelectorAll('tr'));
                    
                    // Sort rows
                    rows.sort((rowA, rowB) => {
                        const cellA = rowA.children[index]?.textContent.trim() || '';
                        const cellB = rowB.children[index]?.textContent.trim() || '';
                        
                        // Numeric check
                        const numA = parseFloat(cellA.replace(/[^0-9.-]+/g, ""));
                        const numB = parseFloat(cellB.replace(/[^0-9.-]+/g, ""));
                        
                        if (!isNaN(numA) && !isNaN(numB)) {
                            return ascending ? numA - numB : numB - numA;
                        }
                        
                        return ascending ? cellA.localeCompare(cellB) : cellB.localeCompare(cellA);
                    });
                    
                    // Update rows in DOM
                    rows.forEach(row => tbody.appendChild(row));
                    
                    // Update headers icons
                    const iconSpan = header.querySelector('.sv-sort-icon');
                    if (iconSpan) {
                        iconSpan.innerHTML = ascending ? '<i class="fas fa-sort-up"></i>' : '<i class="fas fa-sort-down"></i>';
                        iconSpan.style.opacity = '1';
                    }
                    
                    // Flip state
                    ascending = !ascending;
                });
            });
        });
    }

    // --- 6. NAV-LINK CLICKS & POPOVER TRANSITIONS ---

    function initMicroAnimations() {
        // Soft scale-up / pulse on sidebar nav hover/click
        const navLinks = document.querySelectorAll('.sv-nav-link');
        navLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                // Play a brief click scale effect
                this.style.transform = 'scale(0.96) translateX(4px)';
                setTimeout(() => {
                    this.style.transform = '';
                }, 150);
            });
        });
    }

    // Initialize everything on DOM load
    document.addEventListener('DOMContentLoaded', () => {
        initLiveSearch();
        convertAlertsToToasts();
        initTableSorting();
        initMicroAnimations();
    });

    // Public API
    return {
        showToast,
        confirm: confirmAction,
        initLiveSearch,
        initTableSorting
    };
})();
