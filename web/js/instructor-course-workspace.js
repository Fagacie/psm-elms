document.addEventListener('DOMContentLoaded', function () {
    const links = document.querySelectorAll('[data-section-link]');

    function syncActiveSection() {
        const activeSection = window.location.hash.replace('#', '') || 'overview';
        links.forEach(function (link) {
            link.classList.toggle('active', link.dataset.sectionLink === activeSection);
        });
    }

    syncActiveSection();
    window.addEventListener('hashchange', syncActiveSection);

    const type = document.getElementById('materialType');
    const file = document.getElementById('materialFile');
    const url = document.getElementById('externalUrl');
    const editType = document.getElementById('editType');
    const editFile = document.getElementById('editFile');
    const editUrl = document.getElementById('editExternalUrl');

    const fileFieldContainer = document.getElementById('fileFieldContainer');
    const urlFieldContainer = document.getElementById('urlFieldContainer');
    const editFileFieldContainer = document.getElementById('editFileFieldContainer');
    const editUrlFieldContainer = document.getElementById('editUrlFieldContainer');

    function applyTypeRules(selectedType, fileInput, urlInput, fileContainer, urlContainer) {
        const isUrlBased = selectedType === 'Link' || selectedType === 'YouTube';
        if (fileInput) {
            fileInput.required = !!selectedType && !isUrlBased && !fileInput.id.includes('edit');
            fileInput.disabled = !!selectedType && isUrlBased;
        }
        if (urlInput) {
            urlInput.required = !!selectedType && isUrlBased;
            urlInput.disabled = !!selectedType && !isUrlBased;
            urlInput.placeholder = selectedType === 'YouTube' ? 'https://www.youtube.com/watch?v=...' : 'https://';
        }
        if (fileContainer) {
            fileContainer.style.display = isUrlBased ? 'none' : 'flex';
        }
        if (urlContainer) {
            urlContainer.style.display = isUrlBased ? 'flex' : 'none';
        }
    }

    if (type) {
        type.addEventListener('change', function () {
            applyTypeRules(type.value, file, url, fileFieldContainer, urlFieldContainer);
        });
        applyTypeRules(type.value, file, url, fileFieldContainer, urlFieldContainer);
    }

    if (editType) {
        editType.addEventListener('change', function () {
            applyTypeRules(editType.value, editFile, editUrl, editFileFieldContainer, editUrlFieldContainer);
        });
        applyTypeRules(editType.value, editFile, editUrl, editFileFieldContainer, editUrlFieldContainer);
    }
});

window.filterRosterTable = function () {
    const input = document.getElementById('wsRosterSearchInput');
    const table = document.getElementById('wsRosterTable');
    if (!input || !table) {
        return;
    }

    const query = input.value.toLowerCase();
    const rows = table.querySelectorAll('.student-table-row');

    rows.forEach(function (row) {
        const nameNode = row.querySelector('.student-search-name');
        const emailNode = row.querySelector('.student-search-email');
        const name = nameNode ? nameNode.textContent.toLowerCase() : '';
        const email = emailNode ? emailNode.textContent.toLowerCase() : '';
        row.style.display = name.includes(query) || email.includes(query) ? '' : 'none';
    });
};

window.openUploadModal = function () {
    const modal = document.getElementById('uploadModal');
    if (!modal) {
        return;
    }
    modal.classList.add('show');
    document.body.style.overflow = 'hidden';
};

window.closeUploadModal = function () {
    const modal = document.getElementById('uploadModal');
    const form = document.getElementById('uploadForm');
    const fileField = document.getElementById('fileFieldContainer');
    const urlField = document.getElementById('urlFieldContainer');
    if (modal) {
        modal.classList.remove('show');
    }
    document.body.style.overflow = 'auto';
    if (form) {
        form.reset();
    }
    if (fileField) {
        fileField.style.display = 'flex';
    }
    if (urlField) {
        urlField.style.display = 'none';
    }
};

window.openEditMaterialModal = function (button, focusFile) {
    if (!button) {
        return;
    }

    const materialId = document.getElementById('editMaterialId');
    const title = document.getElementById('editTitle');
    const type = document.getElementById('editType');
    const order = document.getElementById('editOrder');
    const description = document.getElementById('editDescription');
    const externalUrl = document.getElementById('editExternalUrl');
    const fileInput = document.getElementById('editFile');
    const modal = document.getElementById('editMaterialModal');

    if (materialId) materialId.value = button.dataset.materialId || '';
    if (title) title.value = button.dataset.title || '';
    if (type) type.value = button.dataset.type || 'PDF';
    if (order) order.value = button.dataset.order || '';
    if (description) description.value = button.dataset.description || '';
    if (externalUrl) externalUrl.value = button.dataset.externalUrl || '';
    if (fileInput) fileInput.value = '';

    if (type) {
        type.dispatchEvent(new Event('change'));
    }

    if (modal) {
        modal.classList.add('show');
    }
    document.body.style.overflow = 'hidden';

    if (focusFile && fileInput) {
        window.setTimeout(function () {
            fileInput.focus();
        }, 0);
    }
};

window.closeEditMaterialModal = function () {
    const modal = document.getElementById('editMaterialModal');
    const fileInput = document.getElementById('editFile');
    if (modal) {
        modal.classList.remove('show');
    }
    document.body.style.overflow = 'auto';
    if (fileInput) {
        fileInput.value = '';
    }
};

window.openAssessmentPage = function (view, assessmentId) {
    const baseUrl = window.assessmentWorkspaceBaseUrl || '';
    if (!baseUrl) {
        return;
    }

    const resolvedView = view || 'editor';
    let nextUrl = baseUrl + '&view=' + encodeURIComponent(resolvedView);
    if (assessmentId) {
        nextUrl += '&assessmentId=' + encodeURIComponent(assessmentId);
    }
    window.location.href = nextUrl;
};

window.addEventListener('click', function (event) {
    const uploadModal = document.getElementById('uploadModal');
    const editModal = document.getElementById('editMaterialModal');
    if (uploadModal && event.target === uploadModal) {
        window.closeUploadModal();
    }
    if (editModal && event.target === editModal) {
        window.closeEditMaterialModal();
    }
});

window.addEventListener('keydown', function (event) {
    if (event.key !== 'Escape') {
        return;
    }
    window.closeUploadModal();
    window.closeEditMaterialModal();
});
