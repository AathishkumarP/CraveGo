package com.cravego.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

import com.cravego.dao.RestaurantDAO;
import com.cravego.model.Restaurant;
import com.cravego.util.DBConnection;

public class RestaurantDAOImpl implements RestaurantDAO {

    private static final String INSERT_RESTAURANT =
            "INSERT INTO restaurants "
          + "(name, cuisine_type, delivery_time, address, "
          + "admin_user_id, rating, is_active, image_path, "
          + "opening_time, closing_time) "
          + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String GET_RESTAURANT_BY_ID =
            "SELECT * FROM restaurants "
          + "WHERE restaurant_id = ? "
          + "AND is_active = true";

    private static final String GET_ALL_RESTAURANTS =
            "SELECT * FROM restaurants "
          + "WHERE is_active = true "
          + "ORDER BY rating DESC, name ASC";

    private static final String SEARCH_RESTAURANTS =
            "SELECT * FROM restaurants "
          + "WHERE is_active = true "
          + "AND (LOWER(name) LIKE ? "
          + "OR LOWER(cuisine_type) LIKE ? "
          + "OR LOWER(address) LIKE ?) "
          + "ORDER BY rating DESC, name ASC";

    private static final String GET_RESTAURANTS_BY_CUISINE =
            "SELECT * FROM restaurants "
          + "WHERE is_active = true "
          + "AND LOWER(cuisine_type) LIKE ? "
          + "ORDER BY rating DESC, name ASC";

    private static final String UPDATE_RESTAURANT =
            "UPDATE restaurants SET "
          + "name = ?, "
          + "cuisine_type = ?, "
          + "delivery_time = ?, "
          + "address = ?, "
          + "admin_user_id = ?, "
          + "rating = ?, "
          + "is_active = ?, "
          + "image_path = ?, "
          + "opening_time = ?, "
          + "closing_time = ? "
          + "WHERE restaurant_id = ?";

    private static final String DELETE_RESTAURANT =
            "UPDATE restaurants "
          + "SET is_active = false "
          + "WHERE restaurant_id = ?";

    @Override
    public int addRestaurant(Restaurant restaurant) {

        int restaurantId = 0;

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            INSERT_RESTAURANT,
                            Statement.RETURN_GENERATED_KEYS
                    )
        ) {

            preparedStatement.setString(
                    1,
                    restaurant.getName()
            );

            preparedStatement.setString(
                    2,
                    restaurant.getCuisineType()
            );

            preparedStatement.setInt(
                    3,
                    restaurant.getDeliveryTime()
            );

            preparedStatement.setString(
                    4,
                    restaurant.getAddress()
            );

            preparedStatement.setInt(
                    5,
                    restaurant.getAdminUserId()
            );

            preparedStatement.setDouble(
                    6,
                    restaurant.getRating()
            );

            preparedStatement.setBoolean(
                    7,
                    restaurant.isActive()
            );

            preparedStatement.setString(
                    8,
                    restaurant.getImagePath()
            );

            preparedStatement.setTime(
                    9,
                    convertToSqlTime(
                            restaurant.getOpeningTime(),
                            LocalTime.of(9, 0)
                    )
            );

            preparedStatement.setTime(
                    10,
                    convertToSqlTime(
                            restaurant.getClosingTime(),
                            LocalTime.of(23, 0)
                    )
            );

            int affectedRows =
                    preparedStatement.executeUpdate();

            if (affectedRows > 0) {

                try (
                    ResultSet resultSet =
                            preparedStatement.getGeneratedKeys()
                ) {

                    if (resultSet.next()) {
                        restaurantId =
                                resultSet.getInt(1);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurantId;
    }

    @Override
    public Restaurant getRestaurantById(
            int restaurantId) {

        Restaurant restaurant = null;

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            GET_RESTAURANT_BY_ID
                    )
        ) {

            preparedStatement.setInt(
                    1,
                    restaurantId
            );

            try (
                ResultSet resultSet =
                        preparedStatement.executeQuery()
            ) {

                if (resultSet.next()) {

                    restaurant =
                            mapRestaurant(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurant;
    }

    @Override
    public List<Restaurant> getAllRestaurants() {

        List<Restaurant> restaurants =
                new ArrayList<>();

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            GET_ALL_RESTAURANTS
                    );

            ResultSet resultSet =
                    preparedStatement.executeQuery()
        ) {

            while (resultSet.next()) {

                restaurants.add(
                        mapRestaurant(resultSet)
                );
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurants;
    }

    @Override
    public List<Restaurant> searchRestaurants(
            String searchText) {

        List<Restaurant> restaurants =
                new ArrayList<>();

        if (searchText == null
                || searchText.trim().isEmpty()) {

            return getAllRestaurants();
        }

        String searchValue =
                "%"
                + searchText.trim().toLowerCase()
                + "%";

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            SEARCH_RESTAURANTS
                    )
        ) {

            preparedStatement.setString(
                    1,
                    searchValue
            );

            preparedStatement.setString(
                    2,
                    searchValue
            );

            preparedStatement.setString(
                    3,
                    searchValue
            );

            try (
                ResultSet resultSet =
                        preparedStatement.executeQuery()
            ) {

                while (resultSet.next()) {

                    restaurants.add(
                            mapRestaurant(resultSet)
                    );
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurants;
    }

    @Override
    public List<Restaurant> getRestaurantsByCuisine(
            String cuisineType) {

        List<Restaurant> restaurants =
                new ArrayList<>();

        if (cuisineType == null
                || cuisineType.trim().isEmpty()) {

            return getAllRestaurants();
        }

        String cuisineValue =
                "%"
                + cuisineType.trim().toLowerCase()
                + "%";

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            GET_RESTAURANTS_BY_CUISINE
                    )
        ) {

            preparedStatement.setString(
                    1,
                    cuisineValue
            );

            try (
                ResultSet resultSet =
                        preparedStatement.executeQuery()
            ) {

                while (resultSet.next()) {

                    restaurants.add(
                            mapRestaurant(resultSet)
                    );
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurants;
    }

    @Override
    public boolean updateRestaurant(
            Restaurant restaurant) {

        boolean updated = false;

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            UPDATE_RESTAURANT
                    )
        ) {

            preparedStatement.setString(
                    1,
                    restaurant.getName()
            );

            preparedStatement.setString(
                    2,
                    restaurant.getCuisineType()
            );

            preparedStatement.setInt(
                    3,
                    restaurant.getDeliveryTime()
            );

            preparedStatement.setString(
                    4,
                    restaurant.getAddress()
            );

            preparedStatement.setInt(
                    5,
                    restaurant.getAdminUserId()
            );

            preparedStatement.setDouble(
                    6,
                    restaurant.getRating()
            );

            preparedStatement.setBoolean(
                    7,
                    restaurant.isActive()
            );

            preparedStatement.setString(
                    8,
                    restaurant.getImagePath()
            );

            preparedStatement.setTime(
                    9,
                    convertToSqlTime(
                            restaurant.getOpeningTime(),
                            LocalTime.of(9, 0)
                    )
            );

            preparedStatement.setTime(
                    10,
                    convertToSqlTime(
                            restaurant.getClosingTime(),
                            LocalTime.of(23, 0)
                    )
            );

            preparedStatement.setInt(
                    11,
                    restaurant.getRestaurantId()
            );

            updated =
                    preparedStatement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return updated;
    }

    @Override
    public boolean deleteRestaurant(
            int restaurantId) {

        boolean deleted = false;

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement preparedStatement =
                    connection.prepareStatement(
                            DELETE_RESTAURANT
                    )
        ) {

            preparedStatement.setInt(
                    1,
                    restaurantId
            );

            deleted =
                    preparedStatement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return deleted;
    }

    private Restaurant mapRestaurant(
            ResultSet resultSet)
            throws SQLException {

        Restaurant restaurant =
                new Restaurant();

        restaurant.setRestaurantId(
                resultSet.getInt(
                        "restaurant_id"
                )
        );

        restaurant.setName(
                resultSet.getString(
                        "name"
                )
        );

        restaurant.setCuisineType(
                resultSet.getString(
                        "cuisine_type"
                )
        );

        restaurant.setDeliveryTime(
                resultSet.getInt(
                        "delivery_time"
                )
        );

        restaurant.setAddress(
                resultSet.getString(
                        "address"
                )
        );

        restaurant.setAdminUserId(
                resultSet.getInt(
                        "admin_user_id"
                )
        );

        restaurant.setRating(
                resultSet.getDouble(
                        "rating"
                )
        );

        restaurant.setActive(
                resultSet.getBoolean(
                        "is_active"
                )
        );

        restaurant.setImagePath(
                resultSet.getString(
                        "image_path"
                )
        );

        Time openingTime =
                resultSet.getTime(
                        "opening_time"
                );

        Time closingTime =
                resultSet.getTime(
                        "closing_time"
                );

        if (openingTime != null) {

            restaurant.setOpeningTime(
                    openingTime.toLocalTime()
            );
        }

        if (closingTime != null) {

            restaurant.setClosingTime(
                    closingTime.toLocalTime()
            );
        }

        return restaurant;
    }

    private Time convertToSqlTime(
            LocalTime time,
            LocalTime defaultTime) {

        LocalTime finalTime =
                time != null
                ? time
                : defaultTime;

        return Time.valueOf(finalTime);
    }
}