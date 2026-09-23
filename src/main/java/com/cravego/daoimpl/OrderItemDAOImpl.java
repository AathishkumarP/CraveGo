package com.cravego.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.cravego.dao.OrderItemDAO;
import com.cravego.model.OrderItem;
import com.cravego.util.DBConnection;

public class OrderItemDAOImpl implements OrderItemDAO {

    private static final String INSERT_ORDER_ITEM =
            "INSERT INTO order_items " +
            "(order_id, menu_id, quantity, total_amount) " +
            "VALUES (?, ?, ?, ?)";

    private static final String SELECT_ORDER_ITEM_BY_ID =
            "SELECT * FROM order_items WHERE order_item_id = ?";

    private static final String SELECT_ITEMS_BY_ORDER_ID =
            "SELECT * FROM order_items WHERE order_id = ?";

    private static final String SELECT_ALL_ORDER_ITEMS =
            "SELECT * FROM order_items";

    private static final String UPDATE_ORDER_ITEM =
            "UPDATE order_items SET order_id = ?, menu_id = ?, " +
            "quantity = ?, total_amount = ? " +
            "WHERE order_item_id = ?";

    private static final String DELETE_ORDER_ITEM =
            "DELETE FROM order_items WHERE order_item_id = ?";

    @Override
    public int addOrderItem(OrderItem orderItem) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(INSERT_ORDER_ITEM)) {

            statement.setInt(1, orderItem.getOrderId());
            statement.setInt(2, orderItem.getMenuId());
            statement.setInt(3, orderItem.getQuantity());
            statement.setDouble(4, orderItem.getTotalAmount());

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public OrderItem getOrderItemById(int orderItemId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_ORDER_ITEM_BY_ID)) {

            statement.setInt(1, orderItemId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return extractOrderItem(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<OrderItem> getOrderItemsByOrderId(int orderId) {

        List<OrderItem> orderItems = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_ITEMS_BY_ORDER_ID)) {

            statement.setInt(1, orderId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    orderItems.add(extractOrderItem(resultSet));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItems;
    }

    @Override
    public List<OrderItem> getAllOrderItems() {

        List<OrderItem> orderItems = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_ALL_ORDER_ITEMS);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                orderItems.add(extractOrderItem(resultSet));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItems;
    }

    @Override
    public int updateOrderItem(OrderItem orderItem) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(UPDATE_ORDER_ITEM)) {

            statement.setInt(1, orderItem.getOrderId());
            statement.setInt(2, orderItem.getMenuId());
            statement.setInt(3, orderItem.getQuantity());
            statement.setDouble(4, orderItem.getTotalAmount());
            statement.setInt(5, orderItem.getOrderItemId());

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public int deleteOrderItem(int orderItemId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(DELETE_ORDER_ITEM)) {

            statement.setInt(1, orderItemId);

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    private OrderItem extractOrderItem(ResultSet resultSet)
            throws SQLException {

        OrderItem orderItem = new OrderItem();

        orderItem.setOrderItemId(
                resultSet.getInt("order_item_id"));
        orderItem.setOrderId(
                resultSet.getInt("order_id"));
        orderItem.setMenuId(
                resultSet.getInt("menu_id"));
        orderItem.setQuantity(
                resultSet.getInt("quantity"));
        orderItem.setTotalAmount(
                resultSet.getDouble("total_amount"));

        return orderItem;
    }
}