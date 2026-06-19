import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react({ jsxRuntime: 'classic' })],
  build: {
    outDir: '../web/js/dist',
    emptyOutDir: true,
    rollupOptions: { external: ['react', 'react-dom'],
      input: {
        "admin-certificates": resolve(__dirname, "src/pages/admin-certificates.jsx"),
        "admin-courses": resolve(__dirname, "src/pages/admin-courses.jsx"),
        "admin-dashboard": resolve(__dirname, "src/pages/admin-dashboard.jsx"),
        "admin-enrollment-list": resolve(__dirname, "src/pages/admin-enrollment-list.jsx"),
        "admin-reports": resolve(__dirname, "src/pages/admin-reports.jsx"),
        "admin-settings": resolve(__dirname, "src/pages/admin-settings.jsx"),
        "users": resolve(__dirname, "src/pages/users.jsx"),
        "dashboard": resolve(__dirname, "src/pages/dashboard.jsx"),
        "course-workspace": resolve(__dirname, "src/pages/course-workspace.jsx"),
        "instructor-dashboard": resolve(__dirname, "src/pages/instructor-dashboard.jsx"),
        "login": resolve(__dirname, "src/pages/login.jsx"),
        "profile": resolve(__dirname, "src/pages/profile.jsx"),
        "available-courses": resolve(__dirname, "src/pages/available-courses.jsx"),
        "certificates": resolve(__dirname, "src/pages/certificates.jsx"),
        "course-details": resolve(__dirname, "src/pages/course-details.jsx"),
        "my-enrollments": resolve(__dirname, "src/pages/my-enrollments.jsx"),
        "payments": resolve(__dirname, "src/pages/payments.jsx")
      },
      output: {
        entryFileNames: '[name].js',
        chunkFileNames: 'chunks/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash][extname]'
      }
    }
  }
});
