/**
 * React JSX Bridge
 * 
 * This script manually compiles any <script type="text/jsx-custom"> tags found on the page
 * using the loaded in-browser Babel Standalone compiler, and then injects them into the DOM.
 * 
 * This avoids silent injection failures caused by Babel 7's automatic script sweeping
 * when dealing with complex JSP-rendered environments.
 */
window.addEventListener('load', function() {
    const scripts = document.querySelectorAll('script[type="text/babel"], script[type="text/jsx-custom"]');
    if (scripts.length > 0 && window.Babel) {
        scripts.forEach(script => {
            try {
                // Ignore empty scripts or already compiled scripts
                if (!script.textContent || !script.textContent.trim() || script.getAttribute('data-compiled') === 'true') {
                    return;
                }
                
                console.log("Compiling custom JSX script via React-JSX-Bridge...");
                const compiled = window.Babel.transform(script.textContent, { 
                    presets: [
                        ['react', { runtime: 'classic' }]
                    ] 
                }).code;
                
                const newScript = document.createElement('script');
                newScript.textContent = compiled;
                document.body.appendChild(newScript);
                
                script.setAttribute('data-compiled', 'true');
            } catch (e) {
                console.error("React-JSX-Bridge Babel compilation error:", e);
            }
        });
    } else if (scripts.length > 0) {
        console.error("React-JSX-Bridge: React JSX scripts found, but Babel Standalone is not loaded.");
    }
});
