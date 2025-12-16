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
    boolean updateStatus(int userId, String status);
    boolean updateLastLogin(int userId);
    boolean delete(int userId);
}
