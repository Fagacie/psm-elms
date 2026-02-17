package com.psm.elearning.dao;

import com.psm.elearning.model.Certificate;
import com.psm.elearning.model.CertificateView;
import com.psm.elearning.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CertificateDAOImpl implements CertificateDAO {

    private Certificate mapRow(ResultSet rs) throws SQLException {
        Certificate c = new Certificate();
        c.setCertificateId(rs.getInt("CertificateID"));
        c.setEnrollmentId(rs.getInt("EnrollmentID"));
        c.setCertificateNo(rs.getString("CertificateNo"));
        Timestamp id = rs.getTimestamp("IssueDate");
        c.setIssueDate(id != null ? id.toLocalDateTime() : null);
        c.setQrCodePath(rs.getString("QRCodePath"));
        c.setGeneratedBy(rs.getString("GeneratedBy"));
        c.setVerificationURL(rs.getString("VerificationURL"));
        return c;
    }

    private CertificateView mapDetailedRow(ResultSet rs) throws SQLException {
        CertificateView c = new CertificateView();
        c.setCertificateId(rs.getInt("CertificateID"));
        c.setEnrollmentId(rs.getInt("EnrollmentID"));
        c.setCourseId(rs.getInt("CourseID"));
        c.setCertificateNo(rs.getString("CertificateNo"));
        Timestamp id = rs.getTimestamp("IssueDate");
        c.setIssueDate(id != null ? id.toLocalDateTime() : null);
        c.setGeneratedBy(rs.getString("GeneratedBy"));
        c.setVerificationURL(rs.getString("VerificationURL"));
        c.setStudentName(rs.getString("StudentName"));
        c.setStudentEmail(rs.getString("StudentEmail"));
        c.setRegNumber(rs.getString("RegNumber"));
        c.setCourseName(rs.getString("CourseName"));
        c.setStudentUserId(rs.getInt("StudentUserID"));
        c.setCourseCreatedBy(rs.getInt("CourseCreatedBy"));
        return c;
    }

    private static final String CERTIFICATE_DETAIL_SELECT =
            "SELECT c.CertificateID, c.EnrollmentID, c.CertificateNo, c.IssueDate, c.GeneratedBy, c.VerificationURL, "
                    + "e.CourseID, e.UserID AS StudentUserID, co.CreatedBy AS CourseCreatedBy, "
                    + "u.FullName AS StudentName, u.Email AS StudentEmail, s.RegNumber, co.CourseName "
                    + "FROM Certificate c "
                    + "JOIN Enrollment e ON c.EnrollmentID = e.EnrollmentID "
                    + "JOIN User u ON e.UserID = u.UserID "
                    + "LEFT JOIN Student s ON s.UserID = u.UserID "
                    + "JOIN Course co ON e.CourseID = co.CourseID ";

    @Override
    public Certificate create(Certificate certificate) {
        String sql = "INSERT INTO Certificate (EnrollmentID, CertificateNo, QRCodePath, GeneratedBy, VerificationURL) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, certificate.getEnrollmentId());
            ps.setString(2, certificate.getCertificateNo());
            ps.setString(3, certificate.getQrCodePath());
            ps.setString(4, certificate.getGeneratedBy());
            ps.setString(5, certificate.getVerificationURL());
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) certificate.setCertificateId(rs.getInt(1));
            }
            return findById(certificate.getCertificateId());
        } catch (SQLException e) {
            System.err.println("Certificate create failed: " + e.getMessage());
            return null;
        }
    }

    @Override
    public Certificate findById(int certificateId) {
        String sql = "SELECT * FROM Certificate WHERE CertificateID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, certificateId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Certificate findById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public Certificate findByCertificateNo(String certificateNo) {
        String sql = "SELECT * FROM Certificate WHERE CertificateNo=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, certificateNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Certificate findByCertificateNo failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public Certificate findByEnrollment(int enrollmentId) {
        String sql = "SELECT * FROM Certificate WHERE EnrollmentID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, enrollmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Certificate findByEnrollment failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<Certificate> findByUser(int userId) {
        List<Certificate> list = new ArrayList<>();
        String sql = "SELECT c.* FROM Certificate c JOIN Enrollment e ON c.EnrollmentID = e.EnrollmentID WHERE e.UserID=? ORDER BY c.IssueDate DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Certificate findByUser failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<CertificateView> findByUserDetailed(int userId) {
        List<CertificateView> list = new ArrayList<>();
        String sql = CERTIFICATE_DETAIL_SELECT + "WHERE e.UserID=? ORDER BY c.IssueDate DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDetailedRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Certificate findByUserDetailed failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<CertificateView> findByInstructorDetailed(int instructorId) {
        List<CertificateView> list = new ArrayList<>();
        String sql = CERTIFICATE_DETAIL_SELECT + "WHERE co.CreatedBy=? ORDER BY c.IssueDate DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, instructorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDetailedRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Certificate findByInstructorDetailed failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<CertificateView> findAllDetailed() {
        List<CertificateView> list = new ArrayList<>();
        String sql = CERTIFICATE_DETAIL_SELECT + "ORDER BY c.IssueDate DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapDetailedRow(rs));
        } catch (SQLException e) {
            System.err.println("Certificate findAllDetailed failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public CertificateView findDetailedById(int certificateId) {
        String sql = CERTIFICATE_DETAIL_SELECT + "WHERE c.CertificateID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, certificateId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapDetailedRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Certificate findDetailedById failed: " + e.getMessage());
        }
        return null;
    }
}
