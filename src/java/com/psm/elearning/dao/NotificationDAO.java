package com.psm.elearning.dao;

import com.psm.elearning.model.Notification;
import java.util.List;

public interface NotificationDAO {
    Notification create(Notification notification);
    int countUnreadByRecipientUserId(int recipientUserId);
    List<Notification> findRecentByRecipientUserId(int recipientUserId, int limit);
    boolean markReadByRecipientUserIdAndEntity(int recipientUserId, String relatedEntityType, Integer relatedEntityId);
}