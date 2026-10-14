package com.cravego.dao;

import java.util.List;

import com.cravego.model.Order;
import com.cravego.model.OrderItem;

public interface OrderDAO {

    int addOrder(Order order);

    /*
     * Saves the order and all its items in one transaction.
     * Returns the generated order ID.
     * Returns 0 if the transaction fails.
     */
    int placeOrder(
            Order order,
            List<OrderItem> orderItems
    );

    Order getOrderById(int orderId);

    List<Order> getOrdersByUserId(int userId);

    List<Order> getAllOrders();

    int updateOrderStatus(
            int orderId,
            String status
    );

    int deleteOrder(int orderId);
    
    boolean cancelOrder(int orderId, int userId);
}