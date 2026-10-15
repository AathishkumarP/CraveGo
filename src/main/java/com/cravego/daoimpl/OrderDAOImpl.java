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
import com.cravego.model.OrderItem;
import com.cravego.util.DBConnection;

public class OrderDAOImpl implements OrderDAO {

    private static final String INSERT_ORDER =
            "INSERT INTO orders "
          + "(user_id, restaurant_id, order_date, total_amount, "
          + "status, payment_mode, payment_status) "
          + "VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String INSERT_ORDER_ITEM =
            "INSERT INTO order_items "
          + "(order_id, menu_id, quantity, total_amount) "
          + "VALUES (?, ?, ?, ?)";

    @Override
    public int addOrder(Order order) {

        if (order == null) {
            return 0;
        }

        try (Connection connection = DBConnection.getConnection()) {
            return insertOrder(connection, order);

        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int placeOrder(
            Order order,
            List<OrderItem> orderItems) {

        if (order == null
                || orderItems == null
                || orderItems.isEmpty()) {
            return 0;
        }

        try (Connection connection = DBConnection.getConnection()) {

            boolean previousAutoCommit = connection.getAutoCommit();

            try {
                connection.setAutoCommit(false);

                int orderId = insertOrder(connection, order);

                if (orderId <= 0) {
                    throw new SQLException("Unable to generate order ID.");
                }

                insertOrderItems(connection, orderId, orderItems);

                connection.commit();
                return orderId;

            } catch (SQLException e) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }

                order.setOrderId(0);

                for (OrderItem item : orderItems) {
                    if (item != null) {
                        item.setOrderId(0);
                    }
                }

                e.printStackTrace();
                return 0;

            } finally {
                connection.setAutoCommit(previousAutoCommit);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public Order getOrderById(int orderId) {

        String sql = "SELECT * FROM orders WHERE order_id = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, orderId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? extractOrder(resultSet) : null;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public Order getOrderByRazorpayOrderId(String razorpayOrderId) {

        if (razorpayOrderId == null || razorpayOrderId.isBlank()) {
            return null;
        }

        String sql =
                "SELECT * FROM orders WHERE razorpay_order_id = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, razorpayOrderId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? extractOrder(resultSet) : null;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Order> getOrdersByUserId(int userId) {

        List<Order> orders = new ArrayList<>();

        String sql =
                "SELECT * FROM orders WHERE user_id = ? "
              + "ORDER BY order_date DESC, order_id DESC";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
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

        String sql =
                "SELECT * FROM orders "
              + "ORDER BY order_date DESC, order_id DESC";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql);
            ResultSet resultSet = statement.executeQuery()
        ) {
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

        if (orderId <= 0 || status == null || status.isBlank()) {
            return 0;
        }

        /*
         * Do not use this method to confirm online payments.
         * Awaiting-payment and cancelled orders cannot advance here.
         */
        String sql =
                "UPDATE orders SET status = ? "
              + "WHERE order_id = ? "
              + "AND status NOT IN ('AWAITING_PAYMENT', 'CANCELLED')";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, status);
            statement.setInt(2, orderId);

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public boolean cancelOrder(int orderId, int userId) {

        if (orderId <= 0 || userId <= 0) {
            return false;
        }

        /*
         * Keep cancellation available for COD.
         * Paid online orders require a refund workflow first.
         */
        String sql =
                "UPDATE orders SET status = 'CANCELLED' "
              + "WHERE order_id = ? AND user_id = ? "
              + "AND status = 'PLACED' "
              + "AND payment_mode = 'COD' "
              + "AND payment_status IN ('PENDING', 'UNVERIFIED')";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, orderId);
            statement.setInt(2, userId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean attachRazorpayOrder(
            int orderId,
            int userId,
            String razorpayOrderId) {

        if (orderId <= 0
                || userId <= 0
                || razorpayOrderId == null
                || razorpayOrderId.isBlank()) {
            return false;
        }

        /*
         * Once linked, the gateway order cannot be replaced.
         * Attaching the same ID again is allowed.
         */
        String sql =
                "UPDATE orders SET razorpay_order_id = ? "
              + "WHERE order_id = ? AND user_id = ? "
              + "AND status = 'AWAITING_PAYMENT' "
              + "AND payment_status = 'PENDING' "
              + "AND payment_mode = 'RAZORPAY' "
              + "AND (razorpay_order_id IS NULL "
              + "OR razorpay_order_id = ?)";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, razorpayOrderId);
            statement.setInt(2, orderId);
            statement.setInt(3, userId);
            statement.setString(4, razorpayOrderId);

            if (statement.executeUpdate() > 0) {
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        Order existing = getOrderById(orderId);

        return existing != null
                && existing.getUserId() == userId
                && "RAZORPAY".equals(existing.getPaymentMode())
                && "AWAITING_PAYMENT".equals(existing.getStatus())
                && "PENDING".equals(existing.getPaymentStatus())
                && razorpayOrderId.equals(existing.getRazorpayOrderId());
    }

    @Override
    public boolean confirmOnlinePayment(
            int orderId,
            String razorpayOrderId,
            String razorpayPaymentId) {

        if (orderId <= 0
                || razorpayOrderId == null
                || razorpayOrderId.isBlank()
                || razorpayPaymentId == null
                || razorpayPaymentId.isBlank()) {
            return false;
        }

        /*
         * Caller must first verify the payment using Razorpay.
         * This query only persists the verified result.
         */
        String sql =
                "UPDATE orders SET "
              + "payment_status = 'PAID', "
              + "razorpay_payment_id = ?, "
              + "paid_at = CURRENT_TIMESTAMP, "
              + "status = 'PLACED' "
              + "WHERE order_id = ? "
              + "AND razorpay_order_id = ? "
              + "AND payment_mode = 'RAZORPAY' "
              + "AND payment_status = 'PENDING' "
              + "AND status = 'AWAITING_PAYMENT'";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, razorpayPaymentId);
            statement.setInt(2, orderId);
            statement.setString(3, razorpayOrderId);

            if (statement.executeUpdate() > 0) {
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        /*
         * A repeated callback/webhook is successful only when
         * it matches the payment already stored.
         * It must not reset delivery status or paid_at.
         */
        Order existing = getOrderById(orderId);

        return existing != null
                && "RAZORPAY".equals(existing.getPaymentMode())
                && existing.isPaid()
                && razorpayOrderId.equals(existing.getRazorpayOrderId())
                && razorpayPaymentId.equals(existing.getRazorpayPaymentId());
    }

    @Override
    public int deleteOrder(int orderId) {

        // Preserve paid orders as payment records.
        String sql =
                "DELETE FROM orders WHERE order_id = ? "
              + "AND payment_status <> 'PAID'";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, orderId);

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    private int insertOrder(
            Connection connection,
            Order order) throws SQLException {

        LocalDateTime orderDate = order.getOrderDate();

        if (orderDate == null) {
            orderDate = LocalDateTime.now();
            order.setOrderDate(orderDate);
        }

        String paymentStatus = order.getPaymentStatus();

        // Existing COD checkout remains compatible.
        if ("COD".equals(order.getPaymentMode())
                && (paymentStatus == null
                    || "UNVERIFIED".equals(paymentStatus))) {
            paymentStatus = "PENDING";
        }

        if (paymentStatus == null || paymentStatus.isBlank()) {
            paymentStatus = "UNVERIFIED";
        }

        // New orders cannot begin as paid without verification.
        if ("PAID".equalsIgnoreCase(paymentStatus)) {
            throw new SQLException(
                    "Use verified payment confirmation to mark an order paid."
            );
        }

        if ("RAZORPAY".equals(order.getPaymentMode())
                && (!"AWAITING_PAYMENT".equals(order.getStatus())
                    || !"PENDING".equals(paymentStatus))) {
            throw new SQLException(
                    "Razorpay orders must begin awaiting payment."
            );
        }

        order.setPaymentStatus(paymentStatus);

        try (
            PreparedStatement statement = connection.prepareStatement(
                    INSERT_ORDER,
                    Statement.RETURN_GENERATED_KEYS
            )
        ) {
            statement.setInt(1, order.getUserId());
            statement.setInt(2, order.getRestaurantId());
            statement.setTimestamp(3, Timestamp.valueOf(orderDate));
            statement.setDouble(4, order.getTotalAmount());
            statement.setString(5, order.getStatus());
            statement.setString(6, order.getPaymentMode());
            statement.setString(7, paymentStatus);

            if (statement.executeUpdate() <= 0) {
                return 0;
            }

            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    int orderId = keys.getInt(1);
                    order.setOrderId(orderId);
                    return orderId;
                }
            }
        }

        return 0;
    }

    private void insertOrderItems(
            Connection connection,
            int orderId,
            List<OrderItem> orderItems) throws SQLException {

        try (
            PreparedStatement statement =
                    connection.prepareStatement(INSERT_ORDER_ITEM)
        ) {
            for (OrderItem item : orderItems) {

                if (item == null || item.getQuantity() <= 0) {
                    throw new SQLException("Invalid order item.");
                }

                item.setOrderId(orderId);

                statement.setInt(1, orderId);
                statement.setInt(2, item.getMenuId());
                statement.setInt(3, item.getQuantity());
                statement.setDouble(4, item.getTotalAmount());
                statement.addBatch();
            }

            int[] results = statement.executeBatch();

            for (int result : results) {
                if (result == Statement.EXECUTE_FAILED || result == 0) {
                    throw new SQLException("An order item could not be saved.");
                }
            }
        }
    }

    private Order extractOrder(ResultSet resultSet)
            throws SQLException {

        Order order = new Order();

        order.setOrderId(resultSet.getInt("order_id"));
        order.setUserId(resultSet.getInt("user_id"));
        order.setRestaurantId(resultSet.getInt("restaurant_id"));
        order.setTotalAmount(resultSet.getDouble("total_amount"));
        order.setStatus(resultSet.getString("status"));
        order.setPaymentMode(resultSet.getString("payment_mode"));
        order.setPaymentStatus(resultSet.getString("payment_status"));

        order.setRazorpayOrderId(
                resultSet.getString("razorpay_order_id")
        );

        order.setRazorpayPaymentId(
                resultSet.getString("razorpay_payment_id")
        );

        Timestamp orderDate = resultSet.getTimestamp("order_date");

        if (orderDate != null) {
            order.setOrderDate(orderDate.toLocalDateTime());
        }

        Timestamp paidAt = resultSet.getTimestamp("paid_at");

        if (paidAt != null) {
            order.setPaidAt(paidAt.toLocalDateTime());
        }

        return order;
    }
}