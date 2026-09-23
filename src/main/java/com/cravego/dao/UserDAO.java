package com.cravego.dao;

import java.util.List;

import com.cravego.model.User;

public interface UserDAO {

    int addUser(User user);

    User getUserById(int userId);

    User getUserByEmail(String email);

    List<User> getAllUsers();

    int updateUser(User user);

    int deleteUser(int userId);
}