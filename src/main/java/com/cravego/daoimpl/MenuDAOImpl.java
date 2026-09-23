package com.cravego.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.cravego.dao.MenuDAO;
import com.cravego.model.Menu;
import com.cravego.util.DBConnection;

public class MenuDAOImpl implements MenuDAO {

    private static final String INSERT_MENU =
            "INSERT INTO menu " +
            "(restaurant_id, item_name, description, price, " +
            "is_available, image_path) " +
            "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String SELECT_MENU_BY_ID =
            "SELECT * FROM menu WHERE menu_id = ?";

    private static final String SELECT_MENU_BY_RESTAURANT_ID =
            "SELECT * FROM menu WHERE restaurant_id = ?";

    private static final String SELECT_AVAILABLE_MENU =
            "SELECT * FROM menu " +
            "WHERE restaurant_id = ? AND is_available = TRUE";

    private static final String UPDATE_MENU =
            "UPDATE menu SET restaurant_id = ?, item_name = ?, " +
            "description = ?, price = ?, is_available = ?, " +
            "image_path = ? WHERE menu_id = ?";

    private static final String DELETE_MENU =
            "DELETE FROM menu WHERE menu_id = ?";

    @Override
    public int addMenu(Menu menu) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(INSERT_MENU)) {

            statement.setInt(1, menu.getRestaurantId());
            statement.setString(2, menu.getItemName());
            statement.setString(3, menu.getDescription());
            statement.setDouble(4, menu.getPrice());
            statement.setBoolean(5, menu.isAvailable());
            statement.setString(6, menu.getImagePath());

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public Menu getMenuById(int menuId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_MENU_BY_ID)) {

            statement.setInt(1, menuId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return extractMenu(resultSet);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<Menu> getMenuByRestaurantId(int restaurantId) {

        List<Menu> menuItems = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_MENU_BY_RESTAURANT_ID)) {

            statement.setInt(1, restaurantId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    menuItems.add(extractMenu(resultSet));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menuItems;
    }

    @Override
    public List<Menu> getAvailableMenuByRestaurantId(
            int restaurantId) {

        List<Menu> menuItems = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             SELECT_AVAILABLE_MENU)) {

            statement.setInt(1, restaurantId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    menuItems.add(extractMenu(resultSet));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menuItems;
    }

    @Override
    public int updateMenu(Menu menu) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(UPDATE_MENU)) {

            statement.setInt(1, menu.getRestaurantId());
            statement.setString(2, menu.getItemName());
            statement.setString(3, menu.getDescription());
            statement.setDouble(4, menu.getPrice());
            statement.setBoolean(5, menu.isAvailable());
            statement.setString(6, menu.getImagePath());
            statement.setInt(7, menu.getMenuId());

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public int deleteMenu(int menuId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(DELETE_MENU)) {

            statement.setInt(1, menuId);

            return statement.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    private Menu extractMenu(ResultSet resultSet)
            throws SQLException {

        Menu menu = new Menu();

        menu.setMenuId(
                resultSet.getInt("menu_id"));
        menu.setRestaurantId(
                resultSet.getInt("restaurant_id"));
        menu.setItemName(
                resultSet.getString("item_name"));
        menu.setDescription(
                resultSet.getString("description"));
        menu.setPrice(
                resultSet.getDouble("price"));
        menu.setAvailable(
                resultSet.getBoolean("is_available"));
        menu.setImagePath(
                resultSet.getString("image_path"));

        return menu;
    }
}