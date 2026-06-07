package com.psm.elearning.dao;

import com.psm.elearning.model.User;
import java.util.List;

/**
 * Data Access Object interface for User entity.
 */
public interface UserDAO {
    User create(User user);
    User findById(int userId);
    User findByEmail(String email);
    List<User> findAll();
    boolean update(User user);
    boolean updateProfilePicture(int userId, String profilePicture);
    boolean updateStatus(int userId, String status);
    boolean updateLastLogin(int userId);
    boolean delete(int userId);
    int countByRole(String role);
    int countAll();
    int countByRoleAllStatuses(String role);
    java.util.Map<java.time.LocalDate, Integer> countRegistrationsByDate(java.time.LocalDate startDate,
                                                                          java.time.LocalDate endDate);
}
