/**
 * MY COURSES v3 — Premium SaaS Learning Engine & View Controller
 * Handles client-side multi-parameter filtering, instant DOM sorting, 48px SVG progress
 * ring calculations, layout toggles, localStorage preferences, and A11y live announcements.
 */

document.addEventListener("DOMContentLoaded", () => {
    // DOM Cache Elements
    const libraryContainer = document.getElementById("meLibrary");
    const toggleGridBtn = document.getElementById("toggleGridBtn");
    const toggleListBtn = document.getElementById("toggleListBtn");
    const filterChips = document.querySelectorAll(".me-filter-chip");
    const searchInput = document.getElementById("meLibrarySearch");
    const clearSearchBtn = document.getElementById("clearSearchBtn");
    const sortSelect = document.getElementById("meLibrarySort");
    const noRowsBox = document.getElementById("meNoRows");
    const a11yLive = document.getElementById("meA11yLive");

    // Exit early if empty page view
    if (!libraryContainer) return;

    // Cache original course cards (articles) on mount to preserve default DB sort order
    const courseItems = Array.from(libraryContainer.querySelectorAll(".me-course-item"));
    
    // Add natural index tracking for default sorting fallback
    courseItems.forEach((item, idx) => {
        item.setAttribute("data-natural-index", idx);
    });

    // State Variables
    let currentLayout = "grid"; 
    let currentFilter = "all";
    let searchQuery = "";
    let currentSort = "default";

    /* =============================================
       1. LAYOUT SWITCHER (GRID VS LIST)
       ============================================= */
    function setLayout(layoutType, announce = false) {
        if (layoutType === "list") {
            libraryContainer.classList.remove("me-view-grid");
            libraryContainer.classList.add("me-view-list");
            
            toggleListBtn.classList.add("active");
            toggleListBtn.setAttribute("aria-pressed", "true");
            
            toggleGridBtn.classList.remove("active");
            toggleGridBtn.setAttribute("aria-pressed", "false");
            
            currentLayout = "list";
        } else {
            libraryContainer.classList.remove("me-view-list");
            libraryContainer.classList.add("me-view-grid");
            
            toggleGridBtn.classList.add("active");
            toggleGridBtn.setAttribute("aria-pressed", "true");
            
            toggleListBtn.classList.remove("active");
            toggleListBtn.setAttribute("aria-pressed", "false");
            
            currentLayout = "grid";
        }

        // Persist view state
        localStorage.setItem("me_library_view_preference", currentLayout);

        // Visual fade indicator
        libraryContainer.style.opacity = "0.5";
        setTimeout(() => {
            libraryContainer.style.opacity = "1";
        }, 60);

        if (announce && a11yLive) {
            a11yLive.textContent = `Layout switched to ${currentLayout} view.`;
        }
    }

    if (toggleGridBtn && toggleListBtn) {
        toggleGridBtn.addEventListener("click", () => setLayout("grid", true));
        toggleListBtn.addEventListener("click", () => setLayout("list", true));
    }

    const savedLayout = localStorage.getItem("me_library_view_preference");
    if (savedLayout === "grid" || savedLayout === "list") {
        setLayout(savedLayout, false);
    }

    /* =============================================
       2. SVG PROGRESS DRAWING (48px Footprint)
       ============================================= */
    function drawProgressCircles() {
        const circles = document.querySelectorAll(".me-svg-circle-fg");
        circles.forEach(circle => {
            const progress = parseFloat(circle.getAttribute("data-progress")) || 0;
            // Radius r is 20, Circumference = 2 * Math.PI * 20 = 125.66
            const radius = 20;
            const circumference = 2 * Math.PI * radius;
            
            circle.style.strokeDasharray = `${circumference}`;
            const offset = circumference - (progress / 100) * circumference;
            
            requestAnimationFrame(() => {
                circle.style.strokeDashoffset = `${offset}`;
            });
        });
    }

    setTimeout(drawProgressCircles, 120);

    /* =============================================
       3. CLIENT-SIDE SORTING ENGINE
       ============================================= */
    function sortLibrary() {
        const itemsToSort = [...courseItems];

        itemsToSort.sort((a, b) => {
            if (currentSort === "progress-desc") {
                const progA = parseFloat(a.getAttribute("data-progress")) || 0;
                const progB = parseFloat(b.getAttribute("data-progress")) || 0;
                return progB - progA; // highest first
            }
            if (currentSort === "progress-asc") {
                const progA = parseFloat(a.getAttribute("data-progress")) || 0;
                const progB = parseFloat(b.getAttribute("data-progress")) || 0;
                return progA - progB; // lowest first
            }
            if (currentSort === "title-asc") {
                const titleA = a.getAttribute("data-title") || "";
                const titleB = b.getAttribute("data-title") || "";
                return titleA.localeCompare(titleB); // A to Z
            }
            // default natural order
            const idxA = parseInt(a.getAttribute("data-natural-index")) || 0;
            const idxB = parseInt(b.getAttribute("data-natural-index")) || 0;
            return idxA - idxB;
        });

        // Re-inject sorted items back into the DOM
        itemsToSort.forEach(item => {
            libraryContainer.appendChild(item);
        });

        if (a11yLive) {
            a11yLive.textContent = `Library sorted by ${sortSelect.options[sortSelect.selectedIndex].text}.`;
        }
    }

    if (sortSelect) {
        sortSelect.addEventListener("change", (e) => {
            currentSort = e.target.value;
            sortLibrary();
        });
    }

    /* =============================================
       4. ASYNCHRONOUS MULTI-PARAMETER FILTER
       ============================================= */
    function filterLibrary() {
        let visibleCount = 0;

        courseItems.forEach(item => {
            const status = item.getAttribute("data-status") || "";
            const title = item.getAttribute("data-title") || "";
            const instructor = item.getAttribute("data-instructor") || "";

            const matchesFilter = (currentFilter === "all" || status === currentFilter);
            const matchesSearch = searchQuery === "" || 
                                  title.includes(searchQuery) || 
                                  instructor.includes(searchQuery);

            if (matchesFilter && matchesSearch) {
                item.style.display = ""; // shows visual grid/flex row
                item.style.opacity = "1";
                visibleCount++;
            } else {
                item.style.display = "none";
                item.style.opacity = "0";
            }
        });

        if (visibleCount === 0) {
            noRowsBox.classList.remove("me-empty-hidden");
        } else {
            noRowsBox.classList.add("me-empty-hidden");
        }

        if (a11yLive) {
            a11yLive.textContent = `Showing ${visibleCount} courses matching your selection.`;
        }
    }

    if (searchInput) {
        searchInput.addEventListener("input", (e) => {
            searchQuery = e.target.value.toLowerCase().trim();
            
            if (searchQuery.length > 0) {
                clearSearchBtn.style.display = "grid";
            } else {
                clearSearchBtn.style.display = "none";
            }

            filterLibrary();
        });
    }

    if (clearSearchBtn) {
        clearSearchBtn.addEventListener("click", () => {
            searchInput.value = "";
            searchQuery = "";
            clearSearchBtn.style.display = "none";
            searchInput.focus();
            filterLibrary();
        });
    }

    filterChips.forEach(chip => {
        chip.addEventListener("click", () => {
            filterChips.forEach(c => {
                c.classList.remove("active");
                c.setAttribute("aria-pressed", "false");
            });

            chip.classList.add("active");
            chip.setAttribute("aria-pressed", "true");

            currentFilter = chip.getAttribute("data-status");
            filterLibrary();
        });
    });
});
