package com.psm.elearning.dao;

import com.psm.elearning.model.AppSettingAuditEntry;
import java.util.List;
import java.util.Map;

public interface AppSettingDAO {
    Map<String, String> findAllAsMap();
    boolean upsertAll(Map<String, String> settings, Integer updatedBy);
    List<AppSettingAuditEntry> findRecentAudits(int limit);
}
