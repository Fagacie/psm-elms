package com.psm.elearning.dao;

import com.psm.elearning.model.User;
import com.psm.elearning.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * JDBC implementation of UserDAO.
 */
public class UserDAOImpl implements UserDAO {

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("UserID"));
        u.setFullName(rs.getString("FullName"));
        u.setEmail(rs.getString("Email"));
        u.setPhone(rs.getString("Phone"));
        u.setPasswordHash(rs.getString("PasswordHash"));
        u.setRole(rs.getString("Role"));
        u.setStatus(rs.getString("Status"));
        u.setProfilePicture(rs.getString("ProfilePicture"));
        Timestamp cAt = rs.getTimestamp("CreatedAt");
        Timestamp uAt = rs.getTimestamp("UpdatedAt");
        u.setCreatedAt(cAt != null ? cAt.toLocalDateTime() : null);
        u.setUpdatedAt(uAt != null ? uAt.toLocalDateTime() : null);
        return u;
    }

    @Override
    public User create(User user) {
        String sql = "INSERT INTO User (FullName, Email, Phone, PasswordHash, Role, Status) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getPasswordHash());
            ps.setString(5, user.getRole());
            ps.setString(6, user.getStatus() != null ? user.getStatus() : User.STATUS_ACTIVE);
            int affected = ps.executeUpdate();
            if (affected == 0) return null;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    user.setUserId(rs.getInt(1));
                }
            }
            // fetch created row for timestamps
            return findById(user.getUserId());
        } catch (SQLException e) {
            System.err.println("User create failed: " + e.getMessage());
            return null;
        }
    }

    @Override
    public User findById(int userId) {
        String sql = "SELECT * FROM User WHERE UserID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("findById failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public User findByEmail(String email) {
        String sql = "SELECT * FROM User WHERE Email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("findByEmail failed: " + e.getMessage());
        }
        return null;
    }

    @Override
    public List<User> findAll() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM User ORDER BY CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("findAll failed: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean update(User user) {
        String sql = "UPDATE User SET FullName=?, Email=?, Phone=?, PasswordHash=?, Role=?, Status=? WHERE UserID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getPasswordHash());
            ps.setString(5, user.getRole());
            ps.setString(6, user.getStatus());
            ps.setInt(7, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("User update failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean updateProfilePicture(int userId, String profilePicture) {
        String sql = "UPDATE User SET ProfilePicture=? WHERE UserID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, profilePicture);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("updateProfilePicture failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean updateStatus(int userId, String status) {
        String sql = "UPDATE User SET Status=? WHERE UserID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("updateStatus failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean updateLastLogin(int userId) {
        String sql = "UPDATE User SET LastLogin=CURRENT_TIMESTAMP WHERE UserID=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("updateLastLogin failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean delete(int userId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Get user to know their role
            User user = findById(userId);
            if (user == null) {
                return false;
            }
            
            // Delete from role-specific table first
            String roleDeleteSql = null;
            switch (user.getRole()) {
                case "Student":
                    roleDeleteSql = "DELETE FROM Student WHERE UserID=?";
                    break;
                case "Instructor":
                    roleDeleteSql = "DELETE FROM Instructor WHERE UserID=?";
                    break;
                case "Admin":
                    roleDeleteSql = "DELETE FROM Admin WHERE UserID=?";
                    break;
            }
            
            if (roleDeleteSql != null) {
                try (PreparedStatement ps = conn.prepareStatement(roleDeleteSql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
            }
            
            // Then delete from User table
            String userDeleteSql = "DELETE FROM User WHERE UserID=?";
            try (PreparedStatement ps = conn.prepareStatement(userDeleteSql)) {
                ps.setInt(1, userId);
                int userDeleted = ps.executeUpdate();
                
                if (userDeleted > 0) {
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                    return false;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("User delete failed: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    // Ignore rollback errors
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    // Ignore close errors
                }
            }
        }
    }

    @Override
    public int countByRole(String role) {
        String sql = "SELECT COUNT(*) FROM User WHERE Role = ? AND Status = 'Active'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("countByRole failed: " + e.getMessage());
        }
        return 0;
    }

    @Override
    public int countAll() {
        String sql = "SELECT COUNT(*) FROM User";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("countAll failed: " + e.getMessage());
        }
        return 0;
    }

    @Override
    public int countByRoleAllStatuses(String role) {
        String sql = "SELECT COUNT(*) FROM User WHERE Role = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("countByRoleAllStatuses failed: " + e.getMessage());
        }
        return 0;
    }

    @Override
    public Map<java.time.LocalDate, Integer> countRegistrationsByDate(java.time.LocalDate startDate,
                                                                       java.time.LocalDate endDate) {
        Map<java.time.LocalDate, Integer> counts = new LinkedHashMap<>();
        if (startDate == null || endDate == null || endDate.isBefore(startDate)) {
            return counts;
        }

        String sql = "SELECT DATE(CreatedAt) AS registrationDate, COUNT(*) AS userCount " +
                "FROM User " +
                "WHERE DATE(CreatedAt) BETWEEN ? AND ? " +
                "GROUP BY DATE(CreatedAt)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(startDate));
            ps.setDate(2, Date.valueOf(endDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Date sqlDate = rs.getDate("registrationDate");
                    if (sqlDate != null) {
                        counts.put(sqlDate.toLocalDate(), rs.getInt("userCount"));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("countRegistrationsByDate failed: " + e.getMessage());
        }
        return counts;
    }
}
