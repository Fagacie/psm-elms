package com.psm.elearning.dao;

import com.psm.elearning.model.Certificate;
import com.psm.elearning.model.CertificateView;
import java.util.List;

public interface CertificateDAO {
    Certificate create(Certificate certificate);
    Certificate findById(int certificateId);
    Certificate findByCertificateNo(String certificateNo);
    Certificate findByEnrollment(int enrollmentId);
    List<Certificate> findByUser(int userId);
    List<CertificateView> findByUserDetailed(int userId);
    List<CertificateView> findByInstructorDetailed(int instructorId);
    List<CertificateView> findAllDetailed();
    CertificateView findDetailedById(int certificateId);
}
