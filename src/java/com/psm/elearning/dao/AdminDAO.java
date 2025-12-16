package com.psm.elearning.dao;

import com.psm.elearning.model.Admin;
import java.util.List;

public interface AdminDAO {
    boolean create(Admin admin);
    Admin findByUserId(int userId);
    List<Admin> findAll();
    boolean update(Admin admin);
}
