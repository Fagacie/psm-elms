# PSM E-Learning Design System Migration Guide

## Overview
This guide documents the migration from Bootstrap/rounded design to our institutional sharp-edge design system.

## Design Principles
- **NO BORDER RADIUS**: All elements have sharp, rectangular edges
- **Light Color Palette**: White backgrounds, soft greys, institutional blue accents
- **Flat Design**: No gradients, minimal shadows (max 2px)
- **Professional Typography**: Inter font, clear hierarchy
- **Consistent Spacing**: CSS variables for all spacing

## CSS Files Structure
- `landing.css` - Landing page + core design tokens
- `app.css` - Application-wide components (forms, tables, cards, etc.)

## Design Tokens (CSS Variables)
```css
--color-primary: #2B5A8E;
--color-primary-dark: #1E3F5F;
--color-secondary: #5C7A99;
--color-white: #FFFFFF;
--color-background: #F8F9FA;
--color-light-grey: #E9ECEF;
--color-medium-grey: #CED4DA;
--color-text: #2C3E50;
--color-text-light: #6C757D;
```

## Component Patterns

### Authentication Pages (login, register, forgot/reset-password)
```html
<head>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <style>
        body {
            background: var(--color-background);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .auth-container { max-width: 480px; }
        .auth-card { background: var(--color-white); border: 1px solid var(--color-light-grey); }
        .auth-header { background: var(--color-primary); color: var(--color-white); padding: var(--spacing-xl); }
    </style>
</head>
```

### Dashboard/Internal Pages
```html
<head>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>
    <div class="app-container">
        <aside class="sidebar">
            <!-- Navigation -->
        </aside>
        <main class="main-content">
            <div class="content-header">
                <h1 class="page-title">Page Title</h1>
                <p class="page-subtitle">Description</p>
            </div>
            <!-- Content -->
        </main>
    </div>
</body>
```

### Forms (Replace all Bootstrap classes)
**Old (Bootstrap):**
```html
<div class="mb-3">
    <label class="form-label">Label</label>
    <input type="text" class="form-control">
</div>
```

**New (Our Design):**
```html
<div class="form-group">
    <label class="form-label">Label</label>
    <input type="text" class="form-control">
</div>
```

### Buttons
**Old:**
```html
<button class="btn btn-primary">Click</button>
<button class="btn btn-outline-primary">Click</button>
```

**New:** (Same classes, but no border-radius in CSS)
```html
<button class="btn btn-primary">Click</button>
<button class="btn btn-outline">Click</button>
```

### Cards
**Old:**
```html
<div class="card">
    <div class="card-header">Header</div>
    <div class="card-body">Content</div>
</div>
```

**New:** (Same structure, new styling)
```html
<div class="card">
    <div class="card-header">
        <h3 class="card-title">Header</h3>
    </div>
    <div class="card-body">Content</div>
</div>
```

### Tables
**Old:**
```html
<table class="table table-striped">
```

**New:**
```html
<div class="table-container">
    <table class="table">
        <thead>...</thead>
        <tbody>...</tbody>
    </table>
</div>
```

### Alerts
**Old:**
```html
<div class="alert alert-success alert-dismissible fade show">
    <i class="fas fa-check"></i> Message
    <button class="btn-close" data-bs-dismiss="alert"></button>
</div>
```

**New:**
```html
<div class="alert alert-success">
    Message
</div>
```

### Badges/Status
**Old:**
```html
<span class="badge bg-success">Active</span>
```

**New:**
```html
<span class="badge badge-success">Active</span>
```

## Migration Checklist for Each Page

### 1. Update Head Section
- [ ] Remove Bootstrap CDN link
- [ ] Remove Font Awesome CDN (if not needed)
- [ ] Add `landing.css` and `app.css`
- [ ] Remove any `border-radius` in inline styles
- [ ] Remove gradient backgrounds
- [ ] Replace color schemes with design tokens

### 2. Update Body/Layout
- [ ] Remove Bootstrap containers (`container`, `container-fluid`)
- [ ] Use `app-container` for dashboard pages
- [ ] Use `auth-container` + `auth-card` for auth pages
- [ ] Remove Bootstrap grid classes if not needed
- [ ] Use `.grid`, `.grid-2`, `.grid-3` for layouts

### 3. Update Components
- [ ] Replace `mb-3`, `mt-3`, etc. with design token spacing
- [ ] Update button classes (remove Bootstrap-specific)
- [ ] Update form classes
- [ ] Update table classes
- [ ] Update alert classes
- [ ] Remove all icon prefixes (keep content only)

### 4. Update Scripts
- [ ] Remove Bootstrap JS bundle
- [ ] Remove jQuery if only used for Bootstrap
- [ ] Add vanilla JS equivalents for interactions

### 5. Test
- [ ] Verify no rounded corners anywhere
- [ ] Check responsive behavior
- [ ] Test form submissions
- [ ] Verify color consistency

## Pages to Migrate (25 total)

### Auth Pages (Priority 1) ✅
- [x] login.jsp - DONE
- [ ] register.jsp
- [ ] forgot-password.jsp
- [ ] reset-password.jsp
- [ ] change-password.jsp

### Student Pages (Priority 2)
- [ ] student/available-courses.jsp
- [ ] student/course-details.jsp
- [ ] student/my-enrollments.jsp
- [ ] student/enrollment-details.jsp
- [ ] student/enrollment-summary.jsp
- [ ] student/payment.jsp
- [ ] student/payment-success.jsp
- [ ] student/payment-failed.jsp

### Instructor Pages (Priority 3)
- [ ] instructor/instructor-courses.jsp
- [ ] instructor/instructor-course-form.jsp

### Admin Pages (Priority 4)
- [ ] admin/users.jsp
- [ ] admin/user-form.jsp
- [ ] admin/admin-courses.jsp
- [ ] admin/admin-enrollment-list.jsp
- [ ] admin/admin-enrollment-details.jsp
- [ ] admin/payments.jsp (web/admin/)
- [ ] admin/payment-detail.jsp (web/admin/)

### Shared Pages (Priority 5)
- [ ] dashboard.jsp
- [ ] profile.jsp
- [ ] register_old.jsp (consider removing)

## Quick Reference: Class Mapping

| Old (Bootstrap) | New (Our System) |
|----------------|------------------|
| `container` | `auth-container` or `main-content` |
| `mb-3`, `mt-3` | Use `form-group` (has built-in spacing) |
| `btn-lg` | `btn-large` |
| `d-grid` | `btn-full` (for full-width buttons) |
| `text-center` | `style="text-align: center"` |
| `text-muted` | `style="color: var(--color-text-light)"` |
| `card-body p-4` | `card-body` (padding built-in) |
| `form-select` | `form-control` |
| `alert-dismissible` | Remove (no close button in simple design) |

## Color Usage Guidelines

### Backgrounds
- Main background: `var(--color-background)` (#F8F9FA)
- Card background: `var(--color-white)`
- Header background: `var(--color-primary)`

### Text
- Primary text: `var(--color-text)` (#2C3E50)
- Secondary text: `var(--color-text-light)` (#6C757D)
- On primary background: `var(--color-white)`

### Borders
- Light borders: `var(--color-light-grey)` (#E9ECEF)
- Medium borders: `var(--color-medium-grey)` (#CED4DA)
- Active/Focus: `var(--color-primary)`

### Actions
- Primary button: `var(--color-primary)`
- Secondary button: `var(--color-secondary)`
- Links: `var(--color-primary)`

## Next Steps
1. Use this guide to systematically update remaining 24 pages
2. Test each page after migration
3. Commit in batches (auth pages, student pages, etc.)
4. Update any missing components in app.css as needed

## Notes
- All new pages should follow this system
- No external CSS libraries (except for specific needs like charts)
- Keep JavaScript vanilla (no jQuery)
- Mobile-first responsive design
