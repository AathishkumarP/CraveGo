<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.cravego.model.Restaurant" %>
<%@ page import="com.cravego.model.User" %>

<%
    @SuppressWarnings("unchecked")
    List<Restaurant> restaurants =
            (List<Restaurant>) request.getAttribute("restaurants");

    User loggedInUser =
            (User) session.getAttribute("loggedInUser");

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Restaurants | CraveGo</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            background-color: #f8f8f8;
            color: #282c3f;
        }

        .navbar {
            height: 75px;
            padding: 0 7%;
            background-color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo {
            color: #fc8019;
            font-size: 30px;
            font-weight: 800;
            text-decoration: none;
        }

        .navbar-links {
            display: flex;
            align-items: center;
            gap: 25px;
        }

        .navbar-links a {
            color: #3d4152;
            font-size: 15px;
            font-weight: 600;
            text-decoration: none;
        }

        .navbar-links a:hover {
            color: #fc8019;
        }

        .page-container {
            width: min(1200px, 90%);
            margin: 40px auto;
        }

        .page-heading {
            margin-bottom: 30px;
        }

        .page-heading h1 {
            font-size: 28px;
            margin-bottom: 8px;
        }

        .page-heading p {
            color: #686b78;
            font-size: 15px;
        }

        .restaurant-grid {
            display: grid;
            grid-template-columns:
                    repeat(auto-fill, minmax(270px, 1fr));
            gap: 28px;
        }

        .restaurant-card {
            background-color: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid #eeeeee;
            transition: transform 0.25s ease,
                        box-shadow 0.25s ease;
        }

        .restaurant-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 25px
                        rgba(0, 0, 0, 0.12);
        }

        .restaurant-image {
            width: 100%;
            height: 190px;
            object-fit: cover;
            display: block;
            background-color: #eeeeee;
        }

        .restaurant-details {
            padding: 18px;
        }

        .restaurant-name {
            font-size: 20px;
            margin-bottom: 7px;
        }

        .cuisine {
            color: #686b78;
            font-size: 14px;
            margin-bottom: 14px;
        }

        .restaurant-info {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            margin-bottom: 14px;
            font-size: 14px;
        }

        .rating {
            color: #ffffff;
            background-color: #24963f;
            padding: 5px 8px;
            border-radius: 5px;
            font-weight: 700;
        }

        .delivery-time {
            color: #535665;
            font-weight: 600;
            padding: 5px 0;
        }

        .address {
            min-height: 38px;
            color: #686b78;
            font-size: 13px;
            line-height: 1.5;
            margin-bottom: 16px;
        }

        .menu-button {
            display: block;
            width: 100%;
            padding: 11px;
            color: #ffffff;
            background-color: #fc8019;
            border-radius: 8px;
            text-decoration: none;
            text-align: center;
            font-weight: 700;
            transition: background-color 0.2s ease;
        }

        .menu-button:hover {
            background-color: #e86f0c;
        }

        .empty-message {
            grid-column: 1 / -1;
            padding: 50px;
            background-color: #ffffff;
            border-radius: 12px;
            text-align: center;
            color: #686b78;
        }

        @media (max-width: 700px) {

            .navbar {
                height: auto;
                padding: 18px 5%;
                align-items: flex-start;
                gap: 15px;
            }

            .navbar-links {
                flex-direction: column;
                align-items: flex-end;
                gap: 10px;
            }

            .page-container {
                width: 92%;
                margin-top: 25px;
            }

            .restaurant-grid {
                grid-template-columns: 1fr;
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

    <nav class="navbar-links">

        <a href="<%= contextPath %>/restaurants">
            Restaurants
        </a>

        <%
            if (loggedInUser != null) {
        %>

            <span>
                Hi, <%= loggedInUser.getUsername() %>
            </span>

            <a href="<%= contextPath %>/orders">
                My Orders
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

<main class="page-container">

    <section class="page-heading">

        <h1>Restaurants in Bengaluru</h1>

        <p>
            Discover delicious food from restaurants
            near you.
        </p>

    </section>

    <section class="restaurant-grid">

        <%
            if (restaurants != null
                    && !restaurants.isEmpty()) {

                for (Restaurant restaurant : restaurants) {
        %>

            <article class="restaurant-card">

                <img class="restaurant-image"
                     src="<%= restaurant.getImagePath() %>"
                     alt="<%= restaurant.getName() %>">

                <div class="restaurant-details">

                    <h2 class="restaurant-name">
                        <%= restaurant.getName() %>
                    </h2>

                    <p class="cuisine">
                        <%= restaurant.getCuisineType() %>
                    </p>

                    <div class="restaurant-info">

                        <span class="rating">
                            ★ <%= restaurant.getRating() %>
                        </span>

                        <span class="delivery-time">
                            <%= restaurant.getDeliveryTime() %>
                            minutes
                        </span>

                    </div>

                    <p class="address">
                        <%= restaurant.getAddress() %>
                    </p>

                    <a class="menu-button"
                       href="<%= contextPath %>/menu?restaurantId=<%= restaurant.getRestaurantId() %>">
                        View Menu
                    </a>

                </div>

            </article>

        <%
                }

            } else {
        %>

            <div class="empty-message">

                <h2>No restaurants available</h2>

                <p>
                    Please check again later.
                </p>

            </div>

        <%
            }
        %>

    </section>

</main>

</body>

</html>