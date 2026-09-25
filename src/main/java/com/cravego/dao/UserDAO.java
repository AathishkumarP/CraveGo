package com.cravego.dao;

import java.util.List;

import com.cravego.model.User;

public interface UserDAO {

    int addUser(User user);

    User getUserById(int userId);

    User getUserByEmail(String email);

    User validateUser(
            String email,
            String password
    );

    boolean isEmailExists(String email);

    List<User> getAllUsers();

    boolean updateUser(User user);

    boolean deleteUser(int userId);
}