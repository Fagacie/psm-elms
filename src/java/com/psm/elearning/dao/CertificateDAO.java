package com.psm.elearning.dao;

import com.psm.elearning.model.Certificate;
import java.util.List;

public interface CertificateDAO {
    Certificate create(Certificate certificate);
    Certificate findById(int certificateId);
    Certificate findByEnrollment(int enrollmentId);
    List<Certificate> findByUser(int userId);
}
