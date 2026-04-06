package com.psm.elearning.dao;

import com.psm.elearning.model.Notification;
import com.psm.elearning.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAOImpl implements NotificationDAO {

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification notification = new Notification();
        notification.setNotificationId(rs.getInt("NotificationID"));
        int recipientUserId = rs.getInt("RecipientUserID");
        notification.setRecipientUserId(rs.wasNull() ? null : recipientUserId);
        notification.setRecipientEmail(rs.getString("RecipientEmail"));
        notification.setRecipientName(rs.getString("RecipientName"));
        notification.setTitle(rs.getString("Title"));
        notification.setMessage(rs.getString("Message"));
        notification.setNotificationType(rs.getString("NotificationType"));
        notification.setRelatedEntityType(rs.getString("RelatedEntityType"));
        int relatedEntityId = rs.getInt("RelatedEntityID");
        notification.setRelatedEntityId(rs.wasNull() ? null : relatedEntityId);
        notification.setChannel(rs.getString("Channel"));
        notification.setRead(rs.getBoolean("IsRead"));
        Timestamp readAt = rs.getTimestamp("ReadAt");
        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        notification.setReadAt(readAt != null ? readAt.toLocalDateTime() : null);
        notification.setCreatedAt(createdAt != null ? createdAt.toLocalDateTime() : null);
        return notification;
    }

    @Override
    public Notification create(Notification notification) {
        String sql = "INSERT INTO Notification (RecipientUserID, RecipientEmail, RecipientName, Title, Message, NotificationType, RelatedEntityType, RelatedEntityID, Channel, IsRead, ReadAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (notification.getRecipientUserId() != null) {
                ps.setInt(1, notification.getRecipientUserId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, notification.getRecipientEmail());
            ps.setString(3, notification.getRecipientName());
            ps.setString(4, notification.getTitle());
            ps.setString(5, notification.getMessage());
            ps.setString(6, notification.getNotificationType());
            ps.setString(7, notification.getRelatedEntityType());
            if (notification.getRelatedEntityId() != null) {
                ps.setInt(8, notification.getRelatedEntityId());
            } else {
                ps.setNull(8, Types.INTEGER);
            }
            ps.setString(9, notification.getChannel() != null ? notification.getChannel() : Notification.CHANNEL_IN_APP);
            ps.setBoolean(10, notification.isRead());
            if (notification.isRead()) {
                ps.setTimestamp(11, Timestamp.valueOf(notification.getReadAt() != null ? notification.getReadAt() : java.time.LocalDateTime.now()));
            } else {
                ps.setNull(11, Types.TIMESTAMP);
            }
            int affected = ps.executeUpdate();
            if (affected == 0) {
                return null;
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    notification.setNotificationId(rs.getInt(1));
                }
            }
            return notification;
        } catch (SQLException e) {
            return null;
        }
    }

    @Override
    public int countUnreadByRecipientUserId(int recipientUserId) {
        String sql = "SELECT COUNT(*) FROM Notification WHERE RecipientUserID = ? AND IsRead = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recipientUserId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ignored) {
        }
        return 0;
    }

    @Override
    public List<Notification> findRecentByRecipientUserId(int recipientUserId, int limit) {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM Notification WHERE RecipientUserID = ? ORDER BY CreatedAt DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recipientUserId);
            ps.setInt(2, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapRow(rs));
                }
            }
        } catch (SQLException ignored) {
        }
        return notifications;
    }

    @Override
    public boolean markReadByRecipientUserIdAndEntity(int recipientUserId, String relatedEntityType, Integer relatedEntityId) {
        String sql = "UPDATE Notification SET IsRead = 1, ReadAt = CASE WHEN ReadAt IS NULL THEN CURRENT_TIMESTAMP ELSE ReadAt END WHERE RecipientUserID = ? AND RelatedEntityType = ? AND RelatedEntityID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recipientUserId);
            ps.setString(2, relatedEntityType);
            if (relatedEntityId != null) {
                ps.setInt(3, relatedEntityId);
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException ignored) {
            return false;
        }
    }
}