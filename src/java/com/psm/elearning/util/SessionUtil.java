package com.psm.elearning.util;

import javax.servlet.http.HttpSession;
import java.util.Locale;

public final class SessionUtil {

    private SessionUtil() {
    }

    public static Integer resolveUserId(HttpSession session) {
        if (session == null) {
            return null;
        }

        Object raw = session.getAttribute("userId");
        if (raw instanceof Integer) {
            int parsed = (Integer) raw;
            return parsed > 0 ? parsed : null;
        }
        if (raw instanceof String) {
            try {
                int parsed = Integer.parseInt(((String) raw).trim());
                return parsed > 0 ? parsed : null;
            } catch (NumberFormatException ex) {
                return null;
            }
        }
        return null;
    }

    public static String resolveRole(HttpSession session) {
        if (session == null) {
            return null;
        }

        Object raw = session.getAttribute("userRole");
        if (raw == null) {
            raw = session.getAttribute("role");
        }
        if (raw == null) {
            return null;
        }

        String normalized = raw.toString().trim();
        if (normalized.isEmpty()) {
            return null;
        }

        String role = normalized.toLowerCase(Locale.ENGLISH);
        if ("admin".equals(role)) return "Admin";
        if ("student".equals(role)) return "Student";
        if ("instructor".equals(role)) return "Instructor";
        return null;
    }
}