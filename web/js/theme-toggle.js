(function () {
  var storageKey = 'psme-theme';
  var root = document.documentElement;
  var buttons = [];

  function ensureButtonIcon(button) {
    var icon = button.querySelector('i');
    if (!icon) {
      icon = document.createElement('i');
      icon.setAttribute('aria-hidden', 'true');
      button.insertBefore(icon, button.firstChild);
    }

    return icon;
  }

  function getPreferredTheme() {
    try {
      var saved = window.localStorage.getItem(storageKey);
      if (saved === 'light' || saved === 'dark') {
        return saved;
      }
    } catch (error) {
      // Ignore storage failures and fall back to the system preference.
    }

    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }

    return 'light';
  }

  function setButtonState(theme) {
    buttons.forEach(function (button) {
      var label = button.querySelector('.theme-toggle-label');
      var nextThemeLabel = theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
      var icon = ensureButtonIcon(button);

      button.setAttribute('aria-pressed', String(theme === 'dark'));
      button.setAttribute('aria-label', nextThemeLabel);
      button.setAttribute('title', nextThemeLabel);
      button.dataset.theme = theme;

      icon.className = theme === 'dark' ? 'fa-solid fa-sun' : 'fa-solid fa-moon';

      if (label) {
        label.textContent = nextThemeLabel;
      }
    });
  }

  function applyTheme(theme) {
    root.setAttribute('data-theme', theme);
    root.style.colorScheme = theme;

    try {
      window.localStorage.setItem(storageKey, theme);
    } catch (error) {
      // Ignore storage failures; the active theme still applies for this session.
    }

    setButtonState(theme);
  }

  function toggleTheme() {
    applyTheme(root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
  }

  function bindButtons() {
    buttons = Array.prototype.slice.call(document.querySelectorAll('[data-theme-toggle]'));

    buttons.forEach(function (button) {
      if (button.dataset.themeToggleBound === 'true') {
        return;
      }

      button.dataset.themeToggleBound = 'true';
      button.addEventListener('click', function (event) {
        event.preventDefault();
        toggleTheme();
      });
    });
  }

  bindButtons();
  applyTheme(getPreferredTheme());
  if (root.classList.contains('theme-preload')) {
    window.requestAnimationFrame(function () {
      root.classList.remove('theme-preload');
    });
  }

  if (window.matchMedia) {
    var mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener('change', function (event) {
        try {
          if (window.localStorage.getItem(storageKey)) {
            return;
          }
        } catch (error) {
          return;
        }

        applyTheme(event.matches ? 'dark' : 'light');
      });
    }
  }
})();
