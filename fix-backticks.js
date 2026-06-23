const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

try {
    const filesStr = execSync('dir /s /b c:\\Users\\ACER\\Desktop\\FYP\\elearning\\PSME\\web\\WEB-INF\\views\\*.jsp', {encoding: 'utf8'});
    const files = filesStr.split('\r\n').filter(Boolean);
    files.forEach(f => {
        let content = fs.readFileSync(f, 'utf8');
        if (content.includes('`n')) {
            // Replace literal backtick followed by n and optional whitespace
            content = content.replace(/`n\s*/g, '');
            fs.writeFileSync(f, content);
            console.log('Fixed: ' + f);
        }
    });
} catch(e) {
    console.error(e);
}
