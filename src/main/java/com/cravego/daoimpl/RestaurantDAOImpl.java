package com.cravego.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.cravego.dao.RestaurantDAO;
import com.cravego.model.Restaurant;
import com.cravego.util.DBConnection;

public class RestaurantDAOImpl implements RestaurantDAO {

    private static final String INSERT_RESTAURANT =
            "INSERT INTO restaurants " +
            "(name, cuisine_type, delivery_time, address, " +
            "admin_user_id, rating, is_active, image_path) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_RESTAURANT_BY_ID =
            "SELECT * FROM restaurants WHERE restaurant_id = ?";

    private static final String SELECT_ALL_RESTAURANTS =
            "SELECT * FROM restaurants";

    private static final String SELECT_ACTIVE_RESTAURANTS =
            "SELECT * FROM restaurants WHERE is_active = TRUE";

    private static final String UPDATE_RESTAURANT =
            "UPDATE restaurants SET name = ?, cuisine_type = ?, " +
            "delivery_time = ?, address = ?, admin_user_id = ?, " +
            "rating = ?, is_active = ?, image_path = ? " +
            "WHERE restaurant_id = ?";

    private static final String DELETE_RESTAURANT =
            "DELETE FROM restaurants WHERE restaurant_id = ?";

    @Override
    public int addRestaurant(Restaurant restaurant) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(INSERT_RESTAURANT)) {

            statement.setString(1, restaurant.getName());
            statement.setString(2, restaurant.getCuisineType());
            statement.setInt(3, restaurant.getDeliveryTime());
            statement.setString(4, restaurant.getAddress());
            statement.setInt(5, restaurant.getAdminUserId());
            statement.setDouble(6, restaurant.getRating());
            statement.setBoolean(7, restaurant.isActive());
            statement.setString(8, restaurant.getImagePath());

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public Restaurant getRestaurantById(int restaurantId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_RESTAURANT_BY_ID)) {

            statement.setInt(1, restaurantId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return extractRestaurant(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<Restaurant> getAllRestaurants() {

        List<Restaurant> restaurants = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_ALL_RESTAURANTS);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                restaurants.add(extractRestaurant(resultSet));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurants;
    }

    @Override
    public List<Restaurant> getActiveRestaurants() {

        List<Restaurant> restaurants = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_ACTIVE_RESTAURANTS);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                restaurants.add(extractRestaurant(resultSet));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return restaurants;
    }

    @Override
    public int updateRestaurant(Restaurant restaurant) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(UPDATE_RESTAURANT)) {

            statement.setString(1, restaurant.getName());
            statement.setString(2, restaurant.getCuisineType());
            statement.setInt(3, restaurant.getDeliveryTime());
            statement.setString(4, restaurant.getAddress());
            statement.setInt(5, restaurant.getAdminUserId());
            statement.setDouble(6, restaurant.getRating());
            statement.setBoolean(7, restaurant.isActive());
            statement.setString(8, restaurant.getImagePath());
            statement.setInt(9, restaurant.getRestaurantId());

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public int deleteRestaurant(int restaurantId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(DELETE_RESTAURANT)) {

            statement.setInt(1, restaurantId);

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    private Restaurant extractRestaurant(ResultSet resultSet)
            throws SQLException {

        Restaurant restaurant = new Restaurant();

        restaurant.setRestaurantId(
                resultSet.getInt("restaurant_id"));
        restaurant.setName(
                resultSet.getString("name"));
        restaurant.setCuisineType(
                resultSet.getString("cuisine_type"));
        restaurant.setDeliveryTime(
                resultSet.getInt("delivery_time"));
        restaurant.setAddress(
                resultSet.getString("address"));
        restaurant.setAdminUserId(
                resultSet.getInt("admin_user_id"));
        restaurant.setRating(
                resultSet.getDouble("rating"));
        restaurant.setActive(
                resultSet.getBoolean("is_active"));
        restaurant.setImagePath(
                resultSet.getString("image_path"));

        return restaurant;
    }
}