package com.cravego.model;

import java.time.LocalDateTime;

public class Order {

    private int orderId;
    private int userId;
    private int restaurantId;
    private LocalDateTime orderDate;
    private double totalAmount;
    private String status;
    private String paymentMode;

    // Payment details
    private String paymentStatus = "UNVERIFIED";
    private String razorpayOrderId;
    private String razorpayPaymentId;
    private LocalDateTime paidAt;

    public Order() {
    }

    /*
     * Existing constructor retained for compatibility.
     */
    public Order(
            int orderId,
            int userId,
            int restaurantId,
            LocalDateTime orderDate,
            double totalAmount,
            String status,
            String paymentMode) {

        this.orderId = orderId;
        this.userId = userId;
        this.restaurantId = restaurantId;
        this.orderDate = orderDate;
        this.totalAmount = totalAmount;
        this.status = status;
        this.paymentMode = paymentMode;
    }

    /*
     * Constructor including payment details.
     */
    public Order(
            int orderId,
            int userId,
            int restaurantId,
            LocalDateTime orderDate,
            double totalAmount,
            String status,
            String paymentMode,
            String paymentStatus,
            String razorpayOrderId,
            String razorpayPaymentId,
            LocalDateTime paidAt) {

        this(
                orderId,
                userId,
                restaurantId,
                orderDate,
                totalAmount,
                status,
                paymentMode
        );

        this.paymentStatus = paymentStatus;
        this.razorpayOrderId = razorpayOrderId;
        this.razorpayPaymentId = razorpayPaymentId;
        this.paidAt = paidAt;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    public LocalDateTime getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(LocalDateTime orderDate) {
        this.orderDate = orderDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPaymentMode() {
        return paymentMode;
    }

    public void setPaymentMode(String paymentMode) {
        this.paymentMode = paymentMode;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getRazorpayOrderId() {
        return razorpayOrderId;
    }

    public void setRazorpayOrderId(String razorpayOrderId) {
        this.razorpayOrderId = razorpayOrderId;
    }

    public String getRazorpayPaymentId() {
        return razorpayPaymentId;
    }

    public void setRazorpayPaymentId(String razorpayPaymentId) {
        this.razorpayPaymentId = razorpayPaymentId;
    }

    public LocalDateTime getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(LocalDateTime paidAt) {
        this.paidAt = paidAt;
    }

    /*
     * Indicates the saved payment status.
     * Gateway verification must happen before setting PAID.
     */
    public boolean isPaid() {
        return "PAID".equalsIgnoreCase(paymentStatus);
    }

    @Override
    public String toString() {
        return "Order{" +
                "orderId=" + orderId +
                ", userId=" + userId +
                ", restaurantId=" + restaurantId +
                ", orderDate=" + orderDate +
                ", totalAmount=" + totalAmount +
                ", status='" + status + '\'' +
                ", paymentMode='" + paymentMode + '\'' +
                ", paymentStatus='" + paymentStatus + '\'' +
                ", razorpayOrderId='" + razorpayOrderId + '\'' +
                ", razorpayPaymentId='" + razorpayPaymentId + '\'' +
                ", paidAt=" + paidAt +
                '}';
    }
}