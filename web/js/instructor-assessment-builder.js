document.addEventListener("DOMContentLoaded", () => {
    // Sidebar toggle remains handled elsewhere; keep lightweight form behavior here
    const typeSelect = document.getElementById('assessmentType');
    const durationInput = document.getElementById('assessmentDuration');
    const marksInput = document.getElementById('assessmentTotalMarks');
    const objectiveFields = document.querySelectorAll('[data-type-visible="objective"]');
    const assignmentFields = document.querySelectorAll('[data-type-visible="assignment"]');
    const form = document.getElementById('assessmentDetailsForm');
    const workflowActionInput = document.getElementById('assessmentWorkflowAction');

    function updateFormFields() {
        const type = typeSelect ? typeSelect.value : '';
        if (!typeSelect) return;

        if (type === 'Quiz' || type === 'Exam') {
            objectiveFields.forEach(f => f.classList.remove('hidden-field'));
            assignmentFields.forEach(f => f.classList.add('hidden-field'));
            if (durationInput) durationInput.setAttribute('required', 'required');
            if (marksInput) marksInput.removeAttribute('required');
        } else if (type === 'Assignment') {
            assignmentFields.forEach(f => f.classList.remove('hidden-field'));
            objectiveFields.forEach(f => f.classList.add('hidden-field'));
            if (durationInput) durationInput.removeAttribute('required');
            if (marksInput) marksInput.setAttribute('required', 'required');
        } else {
            objectiveFields.forEach(f => f.classList.add('hidden-field'));
            assignmentFields.forEach(f => f.classList.add('hidden-field'));
            if (durationInput) durationInput.removeAttribute('required');
            if (marksInput) marksInput.removeAttribute('required');
        }
    }

    if (typeSelect) {
        typeSelect.addEventListener('change', updateFormFields);
        updateFormFields();
    }

    // Basic client-side validation for required title and type
    if (form) {
        form.querySelectorAll('[data-workflow-action]').forEach((button) => {
            button.addEventListener('click', () => {
                if (workflowActionInput) {
                    workflowActionInput.value = button.getAttribute('data-workflow-action') || 'details';
                }
            });
        });

        form.addEventListener('submit', (e) => {
            const title = document.getElementById('assessmentTitle');
            let valid = true;
            // reset errors
            document.querySelectorAll('.error-message').forEach(n=>n.remove());
            title && title.classList.remove('field-error');

            if (!title || !title.value.trim()) {
                valid = false;
                if (title) {
                    title.classList.add('field-error');
                    const err = document.createElement('div');
                    err.className = 'error-message';
                    err.innerText = 'Please provide an assessment title.';
                    title.parentNode.appendChild(err);
                }
            }

            if (typeSelect && !typeSelect.value) {
                valid = false;
                const err = document.createElement('div');
                err.className = 'error-message';
                err.innerText = 'Please select an assessment type.';
                typeSelect.parentNode.appendChild(err);
            }

            if (!valid) {
                e.preventDefault();
                const firstError = document.querySelector('.field-error, .error-message');
                if (firstError) firstError.scrollIntoView({behavior:'smooth', block:'center'});
            }
        });
    }
});
