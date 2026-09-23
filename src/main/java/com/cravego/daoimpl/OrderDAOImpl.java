package com.cravego.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.cravego.dao.OrderDAO;
import com.cravego.model.Order;
import com.cravego.util.DBConnection;

public class OrderDAOImpl implements OrderDAO {

    private static final String INSERT_ORDER =
            "INSERT INTO orders " +
            "(user_id, restaurant_id, order_date, total_amount, " +
            "status, payment_mode) VALUES (?, ?, ?, ?, ?, ?)";

    private static final String SELECT_ORDER_BY_ID =
            "SELECT * FROM orders WHERE order_id = ?";

    private static final String SELECT_ORDERS_BY_USER_ID =
            "SELECT * FROM orders WHERE user_id = ? " +
            "ORDER BY order_date DESC";

    private static final String SELECT_ALL_ORDERS =
            "SELECT * FROM orders ORDER BY order_date DESC";

    private static final String UPDATE_ORDER_STATUS =
            "UPDATE orders SET status = ? WHERE order_id = ?";

    private static final String DELETE_ORDER =
            "DELETE FROM orders WHERE order_id = ?";

    @Override
    public int addOrder(Order order) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             INSERT_ORDER,
                             Statement.RETURN_GENERATED_KEYS)) {

            LocalDateTime orderDate = order.getOrderDate();

            if (orderDate == null) {
                orderDate = LocalDateTime.now();
            }

            statement.setInt(1, order.getUserId());
            statement.setInt(2, order.getRestaurantId());
            statement.setTimestamp(
                    3, Timestamp.valueOf(orderDate));
            statement.setDouble(4, order.getTotalAmount());
            statement.setString(5, order.getStatus());
            statement.setString(6, order.getPaymentMode());

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                try (ResultSet generatedKeys =
                             statement.getGeneratedKeys()) {

                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public Order getOrderById(int orderId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_ORDER_BY_ID)) {

            statement.setInt(1, orderId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return extractOrder(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<Order> getOrdersByUserId(int userId) {

        List<Order> orders = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_ORDERS_BY_USER_ID)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    orders.add(extractOrder(resultSet));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orders;
    }

    @Override
    public List<Order> getAllOrders() {

        List<Order> orders = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_ALL_ORDERS);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                orders.add(extractOrder(resultSet));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orders;
    }

    @Override
    public int updateOrderStatus(int orderId, String status) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             UPDATE_ORDER_STATUS)) {

            statement.setString(1, status);
            statement.setInt(2, orderId);

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public int deleteOrder(int orderId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(DELETE_ORDER)) {

            statement.setInt(1, orderId);

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    private Order extractOrder(ResultSet resultSet)
            throws SQLException {

        Order order = new Order();

        order.setOrderId(
                resultSet.getInt("order_id"));
        order.setUserId(
                resultSet.getInt("user_id"));
        order.setRestaurantId(
                resultSet.getInt("restaurant_id"));

        Timestamp timestamp =
                resultSet.getTimestamp("order_date");

        if (timestamp != null) {
            order.setOrderDate(timestamp.toLocalDateTime());
        }

        order.setTotalAmount(
                resultSet.getDouble("total_amount"));
        order.setStatus(
                resultSet.getString("status"));
        order.setPaymentMode(
                resultSet.getString("payment_mode"));

        return order;
    }
}