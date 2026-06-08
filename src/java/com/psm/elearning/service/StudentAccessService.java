package com.psm.elearning.service;

import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Payment;
import com.psm.elearning.model.PaymentStatus;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.http.HttpSession;
import java.util.Locale;

/**
 * Shared student-side access and payment rules.
 */
public class StudentAccessService {

    private final PaymentDAO paymentDAO;

    public StudentAccessService() {
        this.paymentDAO = new PaymentDAOImpl();
    }

    public boolean isStudentSession(HttpSession session) {
        return SessionUtil.resolveUserId(session) != null
                && "Student".equals(SessionUtil.resolveRole(session));
    }

    public boolean belongsToStudent(Enrollment enrollment, Integer userId) {
        return enrollment != null
                && enrollment.getUserId() != null
                && enrollment.getUserId().equals(userId);
    }

    public boolean isPaymentComplete(String paymentStatus) {
        return PaymentStatus.isComplete(paymentStatus);
    }

    public boolean isFreeEnrollment(Enrollment enrollment) {
        return enrollment != null
                && enrollment.getCoursePrice() != null
                && enrollment.getCoursePrice() <= 0.0;
    }

    public boolean requiresPayment(Enrollment enrollment) {
        return enrollment != null && !isFreeEnrollment(enrollment);
    }

    public void syncPaymentStatus(Enrollment enrollment) {
        if (enrollment == null || enrollment.getEnrollmentId() == null) {
            return;
        }
        Payment payment = paymentDAO.getPaymentByEnrollmentId(enrollment.getEnrollmentId());
        if (payment == null) {
            return;
        }

        enrollment.setPaymentStatus(payment.getStatus());
        String reference = payment.getPaystackReference();
        if (reference == null || reference.trim().isEmpty()) {
            reference = payment.getPaymentRef();
        }
        enrollment.setPaymentRef(reference);
    }

    public boolean hasCourseAccess(Enrollment enrollment) {
        if (enrollment == null) {
            return false;
        }
        if (isFreeEnrollment(enrollment)) {
            return true;
        }
        syncPaymentStatus(enrollment);
        return isPaymentComplete(enrollment.getPaymentStatus());
    }

    public boolean isCourseExpired(Enrollment enrollment) {
        return enrollment != null
                && enrollment.getCourseDuration() != null
                && enrollment.getCourseDuration() > 0
                && enrollment.getDaysRemaining() < 0;
    }

    public boolean hasActiveCourseAccess(Enrollment enrollment) {
        return hasCourseAccess(enrollment) && !isCourseExpired(enrollment);
    }
}
