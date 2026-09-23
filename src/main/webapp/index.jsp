<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="com.cravego.model.User" %>

<%
    String contextPath = request.getContextPath();

    User loggedInUser =
            (User) session.getAttribute("loggedInUser");
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>CraveGo | Food Delivery</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            font-family: Arial, Helvetica, sans-serif;
            color: #282c3f;
            background-color: #ffffff;
        }

        .navbar {
            height: 78px;
            padding: 0 7%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            background-color: #ffffff;
            box-shadow: 0 2px 10px
                        rgba(0, 0, 0, 0.08);
        }

        .logo {
            color: #fc8019;
            font-size: 31px;
            font-weight: 800;
            text-decoration: none;
        }

        .navbar-links {
            display: flex;
            align-items: center;
            gap: 24px;
        }

        .navbar-links a {
            color: #3d4152;
            font-size: 15px;
            font-weight: 700;
            text-decoration: none;
        }

        .navbar-links a:hover {
            color: #fc8019;
        }

        .register-link {
            padding: 11px 20px;
            color: #ffffff !important;
            background-color: #282c3f;
            border-radius: 6px;
        }

        .hero {
            min-height: calc(100vh - 78px);
            display: grid;
            grid-template-columns: 1fr 1fr;
        }

        .hero-content {
            padding: 8% 8% 8% 14%;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .hero-content h1 {
            max-width: 620px;
            margin-bottom: 20px;
            font-size: clamp(42px, 6vw, 72px);
            line-height: 1.08;
        }

        .highlight {
            color: #fc8019;
        }

        .hero-content p {
            max-width: 580px;
            margin-bottom: 34px;
            color: #686b78;
            font-size: 19px;
            line-height: 1.7;
        }

        .restaurant-button {
            width: fit-content;
            padding: 17px 30px;
            color: #ffffff;
            background-color: #fc8019;
            border-radius: 8px;
            font-size: 17px;
            font-weight: 700;
            text-decoration: none;
            box-shadow: 0 8px 18px
                        rgba(252, 128, 25, 0.3);
            transition: transform 0.2s ease,
                        background-color 0.2s ease;
        }

        .restaurant-button:hover {
            background-color: #e86f0c;
            transform: translateY(-3px);
        }

        .features {
            margin-top: 45px;
            display: flex;
            flex-wrap: wrap;
            gap: 25px;
        }

        .feature {
            color: #535665;
            font-size: 14px;
            font-weight: 700;
        }

        .hero-image-container {
            position: relative;
            min-height: 500px;
            overflow: hidden;
        }

        .hero-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .hero-overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(
                90deg,
                rgba(255, 255, 255, 0.3),
                rgba(0, 0, 0, 0.08)
            );
        }

        @media (max-width: 800px) {

            .navbar {
                height: auto;
                min-height: 75px;
                padding: 16px 5%;
            }

            .navbar-links {
                gap: 13px;
            }

            .hero {
                grid-template-columns: 1fr;
            }

            .hero-content {
                padding: 70px 8%;
                order: 2;
            }

            .hero-image-container {
                min-height: 350px;
                order: 1;
            }

            .hero-content h1 {
                font-size: 43px;
            }
        }

        @media (max-width: 520px) {

            .navbar-links {
                flex-direction: column;
                align-items: flex-end;
            }

            .hero-content h1 {
                font-size: 36px;
            }
        }

    </style>

</head>

<body>

<header class="navbar">

    <a class="logo"
       href="<%= contextPath %>/">
        CraveGo
    </a>

    <nav class="navbar-links">

        <%
            if (loggedInUser == null) {
        %>

            <a href="<%= contextPath %>/login">
                Login
            </a>

            <a class="register-link"
               href="<%= contextPath %>/register">
                Sign Up
            </a>

        <%
            } else {
        %>

            <span>
                Hi, <%= loggedInUser.getUsername() %>
            </span>

            <a href="<%= contextPath %>/logout">
                Logout
            </a>

        <%
            }
        %>

    </nav>

</header>

<main class="hero">

    <section class="hero-content">

        <h1>
            Delicious food,
            <span class="highlight">
                delivered fast.
            </span>
        </h1>

        <p>
            Explore restaurants across Bengaluru and
            order your favourite Indian dishes from
            the comfort of your home.
        </p>

        <a class="restaurant-button"
           href="<%= contextPath %>/restaurants">
            View All Restaurants
        </a>

        <div class="features">

            <span class="feature">
                ✓ 30+ restaurants
            </span>

            <span class="feature">
                ✓ 450+ dishes
            </span>

            <span class="feature">
                ✓ Fast delivery
            </span>

        </div>

    </section>

    <section class="hero-image-container">

        <img class="hero-image"
             src="https://images.unsplash.com/photo-1543353071-873f17a7a088?auto=format&fit=crop&w=1200&q=85"
             alt="Delicious food">

        <div class="hero-overlay"></div>

    </section>

</main>

</body>

</html>