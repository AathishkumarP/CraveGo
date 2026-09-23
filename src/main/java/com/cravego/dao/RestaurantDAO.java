package com.cravego.dao;

import java.util.List;

import com.cravego.model.Restaurant;

public interface RestaurantDAO {

    int addRestaurant(Restaurant restaurant);

    Restaurant getRestaurantById(int restaurantId);

    List<Restaurant> getAllRestaurants();

    List<Restaurant> getActiveRestaurants();

    int updateRestaurant(Restaurant restaurant);

    int deleteRestaurant(int restaurantId);
}