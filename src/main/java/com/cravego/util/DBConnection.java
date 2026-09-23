package com.cravego.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/cravego";

    private static final String USERNAME = "root";

    private static final String PASSWORD =
            System.getenv("CRAVEGO_DB_PASSWORD");

    private static final String DRIVER =
            "com.mysql.cj.jdbc.Driver";

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(
                    "MySQL JDBC Driver not found.", e
            );
        }
    }

    private DBConnection() {
    }

    public static Connection getConnection()
            throws SQLException {

        if (PASSWORD == null || PASSWORD.isBlank()) {
            throw new SQLException(
                    "CRAVEGO_DB_PASSWORD environment variable is missing."
            );
        }

        return DriverManager.getConnection(
                URL,
                USERNAME,
                PASSWORD
        );
    }
}