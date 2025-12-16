package com.psm.elearning.dao;

import com.psm.elearning.model.Student;
import java.util.List;

public interface StudentDAO {
    boolean create(Student student);
    Student findByUserId(int userId);
    Student findByRegNumber(String regNumber);
    List<Student> findAll();
    boolean updateProfile(Student student);
    String getNextRegNumber();
}
