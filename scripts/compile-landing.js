const fs = require('fs');
const path = require('path');

const landingJspPath = path.join(__dirname, '..', 'web', 'WEB-INF', 'views', 'landing.jsp');
const headAssetsPath = path.join(__dirname, '..', 'web', 'WEB-INF', 'views', 'common', 'head-external-assets.jsp');
const outHtmlPath = path.join(__dirname, '..', 'web', 'index.html');

let landingContent = fs.readFileSync(landingJspPath, 'utf8');
let headAssetsContent = fs.readFileSync(headAssetsPath, 'utf8');

// Clean head assets
headAssetsContent = headAssetsContent
    .replace(/<%@ page[\s\S]*?%>\n?/g, '')
    .replace(/<%@ include file[\s\S]*?%>\n?/g, '')
    .replace(/\$\{pageContext\.request\.contextPath\}/g, '.');

// Replace JSP includes
landingContent = landingContent.replace(/<jsp:include page="\/WEB-INF\/views\/common\/head-external-assets\.jsp"\/>/g, headAssetsContent);

// Strip JSP headers
landingContent = landingContent.replace(/<%@ page[\s\S]*?%>\n?/g, '');
landingContent = landingContent.replace(/<%@ taglib[\s\S]*?%>\n?/g, '');

// Replace Context Path
landingContent = landingContent.replace(/\$\{pageContext\.request\.contextPath\}/g, '.');

// Handle session scope success message (remove logic, keep it clean or remove entirely)
landingContent = landingContent.replace(/<c:if test="\$\{not empty sessionScope\.success\}">([\s\S]*?)<\/c:if>/g, '');
landingContent = landingContent.replace(/<c:remove var="success" scope="session"\/>/g, '');
landingContent = landingContent.replace(/<c:if test="\$\{not empty sessionScope\.error\}">([\s\S]*?)<\/c:if>/g, '');
landingContent = landingContent.replace(/<c:remove var="error" scope="session"\/>/g, '');

// Remove theme scripts
landingContent = landingContent.replace(/<link rel="stylesheet" href="\.\/css\/theme-toggle\.css">\n?/g, '');
landingContent = landingContent.replace(/<script defer src="\.\/js\/theme-toggle\.js"><\/script>\n?/g, '');

// Fix Quick Facts numbers
landingContent = landingContent.replace(/\$\{empty studentCount \? 10500 : studentCount\}/g, '10500');
landingContent = landingContent.replace(/\$\{empty instructorCount \? 320 : instructorCount\}/g, '320');
landingContent = landingContent.replace(/\$\{empty courseCount \? 1200 : courseCount\}/g, '1200');

// Replace course loop with static data
const dummyCourses = `
    <div class="course-data-item" data-id="1" data-name="Advanced Web Development" data-category="Programming" data-fee="Free" data-duration="8 Weeks" data-level="Advanced" data-banner="./img/landing/learning-hub.svg" data-context=".">Learn modern web development using React, Node.js, and MongoDB. Build real-world applications from scratch.</div>
    <div class="course-data-item" data-id="2" data-name="Digital Marketing Masterclass" data-category="Marketing" data-fee="Free" data-duration="4 Weeks" data-level="Beginner" data-banner="./img/landing/analytics-panel.svg" data-context=".">Master SEO, Social Media Marketing, and Google Analytics to drive massive traffic.</div>
    <div class="course-data-item" data-id="3" data-name="Data Science Fundamentals" data-category="Data Science" data-fee="Free" data-duration="10 Weeks" data-level="Intermediate" data-banner="./img/landing/classroom-stream.svg" data-context=".">Dive into Python, Data Analysis, and Machine Learning algorithms with hands-on projects.</div>
`;

// Replace <c:choose> block for courses
landingContent = landingContent.replace(/<c:choose>[\s\S]*?<c:when test="\$\{not empty featuredCourses\}">/g, '');
landingContent = landingContent.replace(/<c:forEach var="course" items="\$\{featuredCourses\}">[\s\S]*?<\/c:forEach>/g, dummyCourses);
landingContent = landingContent.replace(/<\/c:when>[\s\S]*?<\/c:choose>/g, '');

// Save to index.html
fs.writeFileSync(outHtmlPath, landingContent);
console.log('index.html generated successfully.');
