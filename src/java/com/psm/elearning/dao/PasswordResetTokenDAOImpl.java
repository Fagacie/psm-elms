package com.psm.elearning.dao;

import com.psm.elearning.model.PasswordResetToken;
import com.psm.elearning.util.DBConnection;
import java.sql.*;
import java.time.LocalDateTime;

public class PasswordResetTokenDAOImpl implements PasswordResetTokenDAO {

    @Override
    public boolean create(PasswordResetToken token) {
        String sql = "INSERT INTO PasswordResetToken (UserID, Token, CreatedAt, ExpiresAt, Used) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, token.getUserId());
            ps.setString(2, token.getToken());
            ps.setTimestamp(3, Timestamp.valueOf(token.getCreatedAt()));
            ps.setTimestamp(4, Timestamp.valueOf(token.getExpiresAt()));
            ps.setBoolean(5, token.isUsed());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Failed to create password reset token: " + e.getMessage());
            return false;
        }
    }

    @Override
    public PasswordResetToken findByToken(String token) {
        String sql = "SELECT * FROM PasswordResetToken WHERE Token=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                PasswordResetToken resetToken = new PasswordResetToken();
                resetToken.setTokenId(rs.getInt("TokenID"));
                resetToken.setUserId(rs.getInt("UserID"));
                resetToken.setToken(rs.getString("Token"));
                resetToken.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
                resetToken.setExpiresAt(rs.getTimestamp("ExpiresAt").toLocalDateTime());
                resetToken.setUsed(rs.getBoolean("Used"));
                return resetToken;
            }
        } catch (SQLException e) {
            System.err.println("Failed to find password reset token: " + e.getMessage());
        }
        return null;
    }

    @Override
    public boolean markAsUsed(String token) {
        String sql = "UPDATE PasswordResetToken SET Used=true WHERE Token=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Failed to mark token as used: " + e.getMessage());
            return false;
        }
    }

    @Override
    public int deleteExpiredTokens() {
        String sql = "DELETE FROM PasswordResetToken WHERE ExpiresAt < NOW()";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            return stmt.executeUpdate(sql);
        } catch (SQLException e) {
            System.err.println("Failed to delete expired tokens: " + e.getMessage());
            return 0;
        }
    }

    @Override
    public boolean invalidateUserTokens(int userId) {
        String sql = "UPDATE PasswordResetToken SET Used=true WHERE UserID=? AND Used=false";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Failed to invalidate user tokens: " + e.getMessage());
            return false;
        }
    }
}
