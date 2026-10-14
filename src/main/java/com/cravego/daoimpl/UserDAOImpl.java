package com.cravego.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.cravego.dao.UserDAO;
import com.cravego.model.User;
import com.cravego.util.DBConnection;

public class UserDAOImpl implements UserDAO {

    private static final String INSERT_USER =
            "INSERT INTO users "
          + "(username, password, email, phone, address, role) "
          + "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String GET_USER_BY_ID =
            "SELECT * FROM users WHERE user_id = ?";

    private static final String GET_USER_BY_EMAIL =
            "SELECT * FROM users "
          + "WHERE LOWER(email) = LOWER(?)";

    private static final String VALIDATE_USER =
            "SELECT * FROM users "
          + "WHERE LOWER(email) = LOWER(?) "
          + "AND password = ?";

    private static final String CHECK_EMAIL =
            "SELECT COUNT(*) FROM users "
          + "WHERE LOWER(email) = LOWER(?)";

    private static final String GET_ALL_USERS =
            "SELECT * FROM users ORDER BY username ASC";

    private static final String UPDATE_USER =
            "UPDATE users SET "
          + "username = ?, "
          + "password = ?, "
          + "email = ?, "
          + "phone = ?, "
          + "address = ?, "
          + "role = ? "
          + "WHERE user_id = ?";

    private static final String UPDATE_PROFILE =
            "UPDATE users SET "
          + "username = ?, "
          + "email = ?, "
          + "phone = ?, "
          + "address = ? "
          + "WHERE user_id = ?";

    private static final String CHANGE_PASSWORD =
            "UPDATE users SET password = ? "
          + "WHERE user_id = ? AND password = ?";

    private static final String DELETE_USER =
            "DELETE FROM users WHERE user_id = ?";

    @Override
    public int addUser(User user) {

        if (user == null) {
            return 0;
        }

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(
                            INSERT_USER,
                            Statement.RETURN_GENERATED_KEYS
                    )
        ) {

            statement.setString(1, user.getUsername());
            statement.setString(2, user.getPassword());
            statement.setString(3, user.getEmail());
            statement.setString(4, user.getPhone());
            statement.setString(5, user.getAddress());
            statement.setString(6, user.getRole());

            int affectedRows = statement.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet resultSet = statement.getGeneratedKeys()) {

                    if (resultSet.next()) {
                        return resultSet.getInt(1);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public User getUserById(int userId) {

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(GET_USER_BY_ID)
        ) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    return mapUser(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public User getUserByEmail(String email) {

        if (email == null || email.trim().isEmpty()) {
            return null;
        }

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(GET_USER_BY_EMAIL)
        ) {

            statement.setString(1, email.trim());

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    return mapUser(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public User validateUser(String email, String password) {

        if (email == null
                || email.trim().isEmpty()
                || password == null
                || password.isEmpty()) {

            return null;
        }

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(VALIDATE_USER)
        ) {

            statement.setString(1, email.trim());
            statement.setString(2, password);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    return mapUser(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public boolean isEmailExists(String email) {

        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(CHECK_EMAIL)
        ) {

            statement.setString(1, email.trim());

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    return resultSet.getInt(1) > 0;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public List<User> getAllUsers() {

        List<User> users = new ArrayList<>();

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(GET_ALL_USERS);

            ResultSet resultSet = statement.executeQuery()
        ) {

            while (resultSet.next()) {
                users.add(mapUser(resultSet));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }

    @Override
    public boolean updateUser(User user) {

        if (user == null || user.getUserId() <= 0) {
            return false;
        }

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(UPDATE_USER)
        ) {

            statement.setString(1, user.getUsername());
            statement.setString(2, user.getPassword());
            statement.setString(3, user.getEmail());
            statement.setString(4, user.getPhone());
            statement.setString(5, user.getAddress());
            statement.setString(6, user.getRole());
            statement.setInt(7, user.getUserId());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /*
     * Updates profile details without changing password or role.
     */
    @Override
    public boolean updateProfile(User user) {

        if (user == null || user.getUserId() <= 0) {
            return false;
        }

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(UPDATE_PROFILE)
        ) {

            statement.setString(1, user.getUsername());
            statement.setString(2, user.getEmail());
            statement.setString(3, user.getPhone());
            statement.setString(4, user.getAddress());
            statement.setInt(5, user.getUserId());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /*
     * Checks the current password and updates it
     * in a single database operation.
     */
    @Override
    public boolean changePassword(
            int userId,
            String currentPassword,
            String newPassword) {

        if (userId <= 0
                || currentPassword == null
                || currentPassword.isEmpty()
                || newPassword == null
                || newPassword.isBlank()
                || currentPassword.equals(newPassword)) {

            return false;
        }

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(CHANGE_PASSWORD)
        ) {

            statement.setString(1, newPassword);
            statement.setInt(2, userId);
            statement.setString(3, currentPassword);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean deleteUser(int userId) {

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(DELETE_USER)
        ) {

            statement.setInt(1, userId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private User mapUser(ResultSet resultSet) throws SQLException {

        User user = new User();

        user.setUserId(resultSet.getInt("user_id"));
        user.setUsername(resultSet.getString("username"));
        user.setPassword(resultSet.getString("password"));
        user.setEmail(resultSet.getString("email"));
        user.setPhone(resultSet.getString("phone"));
        user.setAddress(resultSet.getString("address"));
        user.setRole(resultSet.getString("role"));

        return user;
    }
}