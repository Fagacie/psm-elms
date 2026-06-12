import re
import sys

path = r'c:\Users\ACER\Desktop\FYP\elearning\PSME\web\WEB-INF\views\student\enrollment-details.jsp'
try:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # The file got duplicated multiple times. 
    # We need to find the first valid closing of the HTML
    # Specifically, we know the main content ends right before:
    # <div class="sv-overlay" id="svOverlay"></div>

    parts = content.split('<div class="sv-overlay" id="svOverlay"></div>')
    if len(parts) > 1:
        clean_top = parts[0]
        
        clean_bottom = """<div class="sv-overlay" id="svOverlay"></div>
<script>
function updateHubFileName(input, isRetake) {
    var suffix = isRetake ? 'Retake' : 'Initial';
    var fileBox = document.getElementById('selectedFileHubName' + suffix);
    var textSpan = document.getElementById('fileNameHubText' + suffix);
    if (input.files && input.files.length > 0) {
        textSpan.textContent = input.files[0].name;
        fileBox.style.display = 'flex';
    } else {
        fileBox.style.display = 'none';
    }
}

function toggleSidebarMaterial(event, materialId, enrollmentId, btn) {
    event.preventDefault();
    event.stopPropagation();
    
    if (btn.disabled) return;
    
    btn.disabled = true;
    var icon = btn.querySelector('i');
    var originalClass = icon.className;
    icon.className = 'fas fa-spinner fa-spin';
    
    var payload = 'materialId=' + encodeURIComponent(materialId) + '&enrollmentId=' + encodeURIComponent(enrollmentId);
    
    fetch('${pageContext.request.contextPath}/student/mark-material-completed', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: payload
    })
    .then(function (response) {
        if (!response.ok) throw new Error('Error');
        return response.json();
    })
    .then(function (data) {
        if (data.success) {
            btn.classList.add('hub_completionToggleComplete');
            icon.className = 'fas fa-check-circle';
            
            // Sync progress elements
            var progressPercentNode = document.getElementById('lhSidebarProgressPercent');
            var topbarPct = document.getElementById('lhTopbarPct');
            var topbarFill = document.getElementById('lhTopbarFill');
            var progressBar = document.getElementById('lhSidebarProgressBar');
            
            var pctText = data.progressPercent + '%';
            if (progressPercentNode) progressPercentNode.textContent = pctText;
            if (topbarPct) {
                if (topbarPct.textContent.indexOf('Modules') !== -1) {
                    topbarPct.textContent = data.progressPercent + '% Modules';
                } else {
                    topbarPct.textContent = pctText;
                }
            }
            if (topbarFill) topbarFill.style.width = data.progressPercent + '%';
            if (progressBar) progressBar.style.width = data.progressPercent + '%';
            
            // Sync active sidebar item state
            var row = btn.closest('.hub_moduleItem');
            if (row) {
                row.classList.add('is-completed');
                var kindSub = row.querySelector('.hub_moduleKind');
                if (kindSub) kindSub.textContent = 'Completed';
            }
            
            // Sync page data bridge
            document.body.dataset.progressPercent = data.progressPercent;
            
            // If the active material on main stage is this one, sync complete button & badge
            var mainCompleteBtn = document.getElementById('edMarkCompleted');
            if (mainCompleteBtn && mainCompleteBtn.getAttribute('data-material-id') === materialId) {
                mainCompleteBtn.disabled = true;
                mainCompleteBtn.innerHTML = '<i class="fas fa-check-circle"></i><span>Completed</span>';
                var badge = document.getElementById('lhItemStatusBadge');
                if (badge) {
                    badge.className = 'status-badge status-Approved';
                    badge.textContent = 'Completed';
                }
            }
        } else {
            icon.className = originalClass;
            btn.disabled = false;
        }
    })
    .catch(function () {
        icon.className = originalClass;
        btn.disabled = false;
    });
}

// Mobile sidebar toggle logic
document.addEventListener('DOMContentLoaded', function() {
    var mobileToggle = document.getElementById('hubMobileToggle');
    var mobileOverlay = document.getElementById('hubMobileOverlay');
    var body = document.body;
    
    if (mobileToggle && mobileOverlay) {
        mobileToggle.addEventListener('click', function() {
            body.classList.toggle('hub-mobile-open');
        });
        
        mobileOverlay.addEventListener('click', function() {
            body.classList.remove('hub-mobile-open');
        });
    }
});
</script>
<script src="${pageContext.request.contextPath}/js/learning-hub.js"></script>
<script defer src="${pageContext.request.contextPath}/js/student-assessment-flow.js"></script>
<script src="${pageContext.request.contextPath}/js/student-v2.js"></script>
</body>
</html>
"""

        with open(path, 'w', encoding='utf-8') as f:
            f.write(clean_top + clean_bottom)
        print('Fixed the file!')
    else:
        print('Could not find the target string.')

except Exception as e:
    print("Error:", e)
