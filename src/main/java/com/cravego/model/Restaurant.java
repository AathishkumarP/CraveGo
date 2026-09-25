package com.cravego.model;

import java.time.LocalTime;
import java.time.ZoneId;

public class Restaurant {

    private int restaurantId;
    private String name;
    private String cuisineType;
    private int deliveryTime;
    private String address;
    private int adminUserId;
    private double rating;
    private boolean active;
    private String imagePath;
    private LocalTime openingTime;
    private LocalTime closingTime;

    public Restaurant() {
    }

    /*
     * Existing constructor retained so your current DAO code
     * will continue working until we update it.
     */
    public Restaurant(
            int restaurantId,
            String name,
            String cuisineType,
            int deliveryTime,
            String address,
            int adminUserId,
            double rating,
            boolean active,
            String imagePath) {

        this.restaurantId = restaurantId;
        this.name = name;
        this.cuisineType = cuisineType;
        this.deliveryTime = deliveryTime;
        this.address = address;
        this.adminUserId = adminUserId;
        this.rating = rating;
        this.active = active;
        this.imagePath = imagePath;
    }

    /*
     * New constructor containing opening and closing times.
     */
    public Restaurant(
            int restaurantId,
            String name,
            String cuisineType,
            int deliveryTime,
            String address,
            int adminUserId,
            double rating,
            boolean active,
            String imagePath,
            LocalTime openingTime,
            LocalTime closingTime) {

        this.restaurantId = restaurantId;
        this.name = name;
        this.cuisineType = cuisineType;
        this.deliveryTime = deliveryTime;
        this.address = address;
        this.adminUserId = adminUserId;
        this.rating = rating;
        this.active = active;
        this.imagePath = imagePath;
        this.openingTime = openingTime;
        this.closingTime = closingTime;
    }

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCuisineType() {
        return cuisineType;
    }

    public void setCuisineType(String cuisineType) {
        this.cuisineType = cuisineType;
    }

    public int getDeliveryTime() {
        return deliveryTime;
    }

    public void setDeliveryTime(int deliveryTime) {
        this.deliveryTime = deliveryTime;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getAdminUserId() {
        return adminUserId;
    }

    public void setAdminUserId(int adminUserId) {
        this.adminUserId = adminUserId;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public LocalTime getOpeningTime() {
        return openingTime;
    }

    public void setOpeningTime(LocalTime openingTime) {
        this.openingTime = openingTime;
    }

    public LocalTime getClosingTime() {
        return closingTime;
    }

    public void setClosingTime(LocalTime closingTime) {
        this.closingTime = closingTime;
    }

    /*
     * Checks the current Indian time and determines whether
     * the restaurant is currently open.
     */
    public boolean isCurrentlyOpen() {

        if (!active || openingTime == null || closingTime == null) {
            return false;
        }

        LocalTime currentTime =
                LocalTime.now(ZoneId.of("Asia/Kolkata"));

        /*
         * Same opening and closing times are treated
         * as open for 24 hours.
         */
        if (openingTime.equals(closingTime)) {
            return true;
        }

        /*
         * Regular schedule:
         * Example: 09:00 AM to 11:00 PM.
         */
        if (openingTime.isBefore(closingTime)) {

            return !currentTime.isBefore(openingTime)
                    && currentTime.isBefore(closingTime);
        }

        /*
         * Overnight schedule:
         * Example: 06:00 PM to 02:00 AM.
         */
        return !currentTime.isBefore(openingTime)
                || currentTime.isBefore(closingTime);
    }

    @Override
    public String toString() {

        return "Restaurant{" +
                "restaurantId=" + restaurantId +
                ", name='" + name + '\'' +
                ", cuisineType='" + cuisineType + '\'' +
                ", deliveryTime=" + deliveryTime +
                ", address='" + address + '\'' +
                ", adminUserId=" + adminUserId +
                ", rating=" + rating +
                ", active=" + active +
                ", imagePath='" + imagePath + '\'' +
                ", openingTime=" + openingTime +
                ", closingTime=" + closingTime +
                '}';
    }
}