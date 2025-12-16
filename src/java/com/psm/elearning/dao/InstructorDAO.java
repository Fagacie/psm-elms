package com.psm.elearning.dao;

import com.psm.elearning.model.Instructor;
import java.util.List;

public interface InstructorDAO {
    boolean create(Instructor instructor);
    Instructor findByUserId(int userId);
    List<Instructor> findAll();
    boolean update(Instructor instructor);
}
