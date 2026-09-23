package com.cravego.util;

import java.sql.Connection;
import java.sql.SQLException;

public class DBConnectionTest {

    public static void main(String[] args) {

        try (Connection connection = DBConnection.getConnection()) {

            if (connection != null && !connection.isClosed()) {
                System.out.println(
                        "CraveGo database connected successfully!"
                );
            } else {
                System.out.println(
                        "Database connection failed."
                );
            }

        } catch (SQLException e) {
            System.out.println(
                    "Database connection error: " + e.getMessage()
            );
            e.printStackTrace();
        }
    }
}