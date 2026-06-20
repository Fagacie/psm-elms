const fs = require('fs');
let content = fs.readFileSync('frontend/src/pages/course-workspace.jsx', 'utf8');
content = content.replace(/\$\{\'\$\'\}\{/g, '${');
fs.writeFileSync('frontend/src/pages/course-workspace.jsx', content);
