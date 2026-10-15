package com.cravego.dao;

import java.util.List;

import com.cravego.model.Order;
import com.cravego.model.OrderItem;

public interface OrderDAO {

    int addOrder(Order order);

    int placeOrder(Order order, List<OrderItem> orderItems);

    Order getOrderById(int orderId);

    Order getOrderByRazorpayOrderId(String razorpayOrderId);

    List<Order> getOrdersByUserId(int userId);

    List<Order> getAllOrders();

    int updateOrderStatus(int orderId, String status);

    boolean cancelOrder(int orderId, int userId);

    boolean attachRazorpayOrder(
            int orderId,
            int userId,
            String razorpayOrderId
    );

    /*
     * Call only after verifying the gateway payment,
     * including captured status, amount and currency.
     */
    boolean confirmOnlinePayment(
            int orderId,
            String razorpayOrderId,
            String razorpayPaymentId
    );

    int deleteOrder(int orderId);
}