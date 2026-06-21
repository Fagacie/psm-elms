const jsdom = require('jsdom');
const { JSDOM } = jsdom;
const html = `<!DOCTYPE html>
<script src='https://unpkg.com/react@18/umd/react.production.min.js'></script>
<script src='https://unpkg.com/react-dom@18/umd/react-dom.production.min.js'></script>
<script src='https://unpkg.com/prop-types@15.8.1/prop-types.min.js'></script>
<script src='https://unpkg.com/recharts@3.8.1/umd/Recharts.js'></script>
<script>
  window.onload = () => {
     console.log('Recharts properties:', Object.keys(window.Recharts || {}));
  };
</script>
`;
const dom = new JSDOM(html, { runScripts: 'dangerously', resources: 'usable' });
dom.window.document.addEventListener('DOMContentLoaded', () => {
  setTimeout(() => {
    console.log(Object.keys(dom.window.Recharts || {}));
  }, 3000);
});
