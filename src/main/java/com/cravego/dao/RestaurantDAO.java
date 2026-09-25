package com.cravego.dao;

import java.util.List;

import com.cravego.model.Restaurant;

public interface RestaurantDAO {

    int addRestaurant(Restaurant restaurant);

    Restaurant getRestaurantById(int restaurantId);

    List<Restaurant> getAllRestaurants();

    List<Restaurant> searchRestaurants(String searchText);

    List<Restaurant> getRestaurantsByCuisine(String cuisineType);

    boolean updateRestaurant(Restaurant restaurant);

    boolean deleteRestaurant(int restaurantId);
}