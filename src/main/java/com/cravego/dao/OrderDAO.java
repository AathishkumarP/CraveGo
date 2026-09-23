package com.cravego.dao;

import java.util.List;

import com.cravego.model.Order;

public interface OrderDAO {

    int addOrder(Order order);

    Order getOrderById(int orderId);

    List<Order> getOrdersByUserId(int userId);

    List<Order> getAllOrders();

    int updateOrderStatus(int orderId, String status);

    int deleteOrder(int orderId);
}