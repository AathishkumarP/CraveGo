package com.cravego.dao;

import java.util.List;

import com.cravego.model.Menu;

public interface MenuDAO {

    int addMenu(Menu menu);

    Menu getMenuById(int menuId);

    List<Menu> getMenuByRestaurantId(int restaurantId);

    List<Menu> getAvailableMenuByRestaurantId(int restaurantId);

    int updateMenu(Menu menu);

    int deleteMenu(int menuId);
}