package com.cravego.dao;

import java.util.List;

import com.cravego.model.OrderItem;

public interface OrderItemDAO {

    int addOrderItem(OrderItem orderItem);

    OrderItem getOrderItemById(int orderItemId);

    List<OrderItem> getOrderItemsByOrderId(int orderId);

    List<OrderItem> getAllOrderItems();

    int updateOrderItem(OrderItem orderItem);

    int deleteOrderItem(int orderItemId);
}