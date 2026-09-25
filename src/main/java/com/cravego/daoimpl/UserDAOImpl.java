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
            "SELECT * FROM users "
          + "WHERE user_id = ?";

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
            "SELECT * FROM users "
          + "ORDER BY username ASC";

    private static final String UPDATE_USER =
            "UPDATE users SET "
          + "username = ?, "
          + "password = ?, "
          + "email = ?, "
          + "phone = ?, "
          + "address = ?, "
          + "role = ? "
          + "WHERE user_id = ?";

    private static final String DELETE_USER =
            "DELETE FROM users "
          + "WHERE user_id = ?";

    @Override
    public int addUser(User user) {

        int generatedUserId = 0;

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                        INSERT_USER,
                        Statement.RETURN_GENERATED_KEYS
                    )
        ) {

            preparedStatement.setString(
                    1,
                    user.getUsername()
            );

            preparedStatement.setString(
                    2,
                    user.getPassword()
            );

            preparedStatement.setString(
                    3,
                    user.getEmail()
            );

            preparedStatement.setString(
                    4,
                    user.getPhone()
            );

            preparedStatement.setString(
                    5,
                    user.getAddress()
            );

            preparedStatement.setString(
                    6,
                    user.getRole()
            );

            int affectedRows =
                    preparedStatement.executeUpdate();

            if (affectedRows > 0) {

                try (
                    ResultSet resultSet =
                            preparedStatement
                                .getGeneratedKeys()
                ) {

                    if (resultSet.next()) {

                        generatedUserId =
                                resultSet.getInt(1);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return generatedUserId;
    }

    @Override
    public User getUserById(int userId) {

        User user = null;

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            GET_USER_BY_ID
                    )
        ) {

            preparedStatement.setInt(
                    1,
                    userId
            );

            try (
                ResultSet resultSet =
                        preparedStatement.executeQuery()
            ) {

                if (resultSet.next()) {

                    user =
                            mapUser(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }

    @Override
    public User getUserByEmail(String email) {

        User user = null;

        if (email == null
                || email.trim().isEmpty()) {

            return null;
        }

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            GET_USER_BY_EMAIL
                    )
        ) {

            preparedStatement.setString(
                    1,
                    email.trim()
            );

            try (
                ResultSet resultSet =
                        preparedStatement.executeQuery()
            ) {

                if (resultSet.next()) {

                    user =
                            mapUser(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }

    @Override
    public User validateUser(
            String email,
            String password) {

        User user = null;

        if (email == null
                || email.trim().isEmpty()
                || password == null
                || password.isEmpty()) {

            return null;
        }

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            VALIDATE_USER
                    )
        ) {

            preparedStatement.setString(
                    1,
                    email.trim()
            );

            preparedStatement.setString(
                    2,
                    password
            );

            try (
                ResultSet resultSet =
                        preparedStatement.executeQuery()
            ) {

                if (resultSet.next()) {

                    user =
                            mapUser(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }

    @Override
    public boolean isEmailExists(String email) {

        if (email == null
                || email.trim().isEmpty()) {

            return false;
        }

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            CHECK_EMAIL
                    )
        ) {

            preparedStatement.setString(
                    1,
                    email.trim()
            );

            try (
                ResultSet resultSet =
                        preparedStatement.executeQuery()
            ) {

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

        List<User> users =
                new ArrayList<>();

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            GET_ALL_USERS
                    );

            ResultSet resultSet =
                    preparedStatement.executeQuery()
        ) {

            while (resultSet.next()) {

                users.add(
                        mapUser(resultSet)
                );
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }

    @Override
    public boolean updateUser(User user) {

        boolean updated = false;

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            UPDATE_USER
                    )
        ) {

            preparedStatement.setString(
                    1,
                    user.getUsername()
            );

            preparedStatement.setString(
                    2,
                    user.getPassword()
            );

            preparedStatement.setString(
                    3,
                    user.getEmail()
            );

            preparedStatement.setString(
                    4,
                    user.getPhone()
            );

            preparedStatement.setString(
                    5,
                    user.getAddress()
            );

            preparedStatement.setString(
                    6,
                    user.getRole()
            );

            preparedStatement.setInt(
                    7,
                    user.getUserId()
            );

            updated =
                    preparedStatement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return updated;
    }

    @Override
    public boolean deleteUser(int userId) {

        boolean deleted = false;

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            DELETE_USER
                    )
        ) {

            preparedStatement.setInt(
                    1,
                    userId
            );

            deleted =
                    preparedStatement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return deleted;
    }

    private User mapUser(
            ResultSet resultSet)
            throws SQLException {

        User user =
                new User();

        user.setUserId(
                resultSet.getInt("user_id")
        );

        user.setUsername(
                resultSet.getString("username")
        );

        user.setPassword(
                resultSet.getString("password")
        );

        user.setEmail(
                resultSet.getString("email")
        );

        user.setPhone(
                resultSet.getString("phone")
        );

        user.setAddress(
                resultSet.getString("address")
        );

        user.setRole(
                resultSet.getString("role")
        );

        return user;
    }
}