<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.cravego.model.Menu" %>
<%@ page import="com.cravego.model.Restaurant" %>
<%@ page import="com.cravego.model.User" %>

<%
    Restaurant restaurant =
            (Restaurant) request.getAttribute("restaurant");

    @SuppressWarnings("unchecked")
    List<Menu> menuItems =
            (List<Menu>) request.getAttribute("menuItems");

    User loggedInUser =
            (User) session.getAttribute("loggedInUser");

    String contextPath =
            request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        <%= restaurant.getName() %> | CraveGo
    </title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            color: #282c3f;
            background-color: #f8f8f8;
        }

        .navbar {
            min-height: 75px;
            padding: 15px 7%;
            background-color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 10px
                        rgba(0, 0, 0, 0.08);
        }

        .logo {
            color: #fc8019;
            font-size: 30px;
            font-weight: 800;
            text-decoration: none;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 22px;
        }

        .nav-links a {
            color: #3d4152;
            font-weight: 600;
            text-decoration: none;
        }

        .nav-links a:hover {
            color: #fc8019;
        }

        .container {
            width: min(1100px, 90%);
            margin: 35px auto;
        }

        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #fc8019;
            font-weight: 700;
            text-decoration: none;
        }

        .restaurant-header {
            padding: 25px;
            margin-bottom: 30px;
            color: #ffffff;
            background-color: #282c3f;
            border-radius: 14px;
        }

        .restaurant-header h1 {
            margin-bottom: 10px;
            font-size: 30px;
        }

        .restaurant-header p {
            margin-top: 7px;
            color: #d8d8db;
            line-height: 1.5;
        }

        .restaurant-meta {
            margin-top: 15px;
            display: flex;
            flex-wrap: wrap;
            gap: 18px;
            font-size: 14px;
            font-weight: 700;
        }

        .rating {
            padding: 5px 9px;
            background-color: #24963f;
            border-radius: 5px;
        }

        .section-title {
            margin-bottom: 22px;
            font-size: 25px;
        }

        .menu-list {
            display: grid;
            gap: 20px;
        }

        .menu-card {
            padding: 18px;
            background-color: #ffffff;
            border: 1px solid #eeeeee;
            border-radius: 14px;
            display: grid;
            grid-template-columns: 1fr 180px;
            gap: 24px;
            align-items: center;
        }

        .item-name {
            margin-bottom: 8px;
            font-size: 20px;
        }

        .price {
            margin-bottom: 12px;
            color: #282c3f;
            font-size: 16px;
            font-weight: 700;
        }

        .description {
            color: #686b78;
            font-size: 14px;
            line-height: 1.6;
        }

        .item-image-container {
            position: relative;
        }

        .item-image {
            width: 180px;
            height: 140px;
            object-fit: cover;
            border-radius: 12px;
            background-color: #eeeeee;
        }

        .add-form {
            position: absolute;
            left: 20px;
            right: 20px;
            bottom: -12px;
        }

        .add-button {
            width: 100%;
            padding: 10px;
            color: #ffffff;
            background-color: #fc8019;
            border: none;
            border-radius: 7px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 4px 10px
                        rgba(0, 0, 0, 0.15);
        }

        .add-button:hover {
            background-color: #e86f0c;
        }

        .empty-message {
            padding: 45px;
            background-color: #ffffff;
            border-radius: 12px;
            text-align: center;
            color: #686b78;
        }

        @media (max-width: 650px) {

            .navbar {
                align-items: flex-start;
            }

            .nav-links {
                flex-direction: column;
                align-items: flex-end;
                gap: 9px;
            }

            .container {
                width: 92%;
                margin-top: 25px;
            }

            .menu-card {
                grid-template-columns: 1fr;
            }

            .item-image {
                width: 100%;
                height: 200px;
            }
        }

    </style>

</head>

<body>

<header class="navbar">

    <a class="logo"
       href="<%= contextPath %>/restaurants">
        CraveGo
    </a>

    <nav class="nav-links">

        <a href="<%= contextPath %>/restaurants">
            Restaurants
        </a>

        <%
            if (loggedInUser != null) {
        %>

            <span>
                Hi, <%= loggedInUser.getUsername() %>
            </span>

            <a href="<%= contextPath %>/cart">
                Cart
            </a>

            <a href="<%= contextPath %>/logout">
                Logout
            </a>

        <%
            } else {
        %>

            <a href="<%= contextPath %>/login">
                Login
            </a>

            <a href="<%= contextPath %>/register">
                Register
            </a>

        <%
            }
        %>

    </nav>

</header>

<main class="container">

    <a class="back-link"
       href="<%= contextPath %>/restaurants">
        ← Back to restaurants
    </a>

    <section class="restaurant-header">

        <h1>
            <%= restaurant.getName() %>
        </h1>

        <p>
            <%= restaurant.getCuisineType() %>
        </p>

        <p>
            <%= restaurant.getAddress() %>
        </p>

        <div class="restaurant-meta">

            <span class="rating">
                ★ <%= restaurant.getRating() %>
            </span>

            <span>
                <%= restaurant.getDeliveryTime() %>
                minutes
            </span>

        </div>

    </section>

    <h2 class="section-title">
        Menu
    </h2>

    <section class="menu-list">

        <%
            if (menuItems != null
                    && !menuItems.isEmpty()) {

                for (Menu menu : menuItems) {
        %>

            <article class="menu-card">

                <div>

                    <h3 class="item-name">
                        <%= menu.getItemName() %>
                    </h3>

                    <p class="price">
                        ₹<%= String.format("%.2f", menu.getPrice()) %>
                    </p>

                    <p class="description">
                        <%= menu.getDescription() %>
                    </p>

                </div>

                <div class="item-image-container">

                    <img class="item-image"
                         src="<%= menu.getImagePath() %>"
                         alt="<%= menu.getItemName() %>">

                    <form class="add-form"
                          method="post"
                          action="<%= contextPath %>/cart/add">

                        <input type="hidden"
                               name="menuId"
                               value="<%= menu.getMenuId() %>">

                        <input type="hidden"
                               name="restaurantId"
                               value="<%= restaurant.getRestaurantId() %>">

                        <input type="hidden"
                               name="quantity"
                               value="1">

                        <button class="add-button"
                                type="submit">
                            ADD
                        </button>

                    </form>

                </div>

            </article>

        <%
                }

            } else {
        %>

            <div class="empty-message">

                <h2>No menu items available</h2>

                <p>
                    This restaurant has not added any
                    available items yet.
                </p>

            </div>

        <%
            }
        %>

    </section>

</main>

</body>

</html>