package com.psm.elearning.util;

import javax.servlet.http.HttpSession;
import java.lang.reflect.Field;

/**
 * Reads and sanitizes active assessment attempt state stored in session.
 */
public final class ActiveAssessmentAttemptUtil {

    private ActiveAssessmentAttemptUtil() {
    }

    public static boolean hasActiveAttempt(HttpSession session, Integer assessmentId) {
        if (session == null || assessmentId == null) {
            return false;
        }

        Object attemptState = session.getAttribute("assessmentAttempt_" + assessmentId);
        if (attemptState == null) {
            return false;
        }

        try {
            Field deadlineField = attemptState.getClass().getDeclaredField("deadlineMillis");
            deadlineField.setAccessible(true);
            long deadlineMillis = deadlineField.getLong(attemptState);
            boolean active = System.currentTimeMillis() < deadlineMillis;
            if (!active) {
                session.removeAttribute("assessmentAttempt_" + assessmentId);
            }
            return active;
        } catch (Exception ex) {
            return true;
        }
    }
}
