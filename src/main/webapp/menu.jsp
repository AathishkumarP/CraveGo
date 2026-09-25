<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.cravego.model.Restaurant" %>
<%@ page import="com.cravego.model.Menu" %>
<%@ page import="com.cravego.model.User" %>

<%!
    private String escapeHtml(String value) {

        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    String contextPath =
            request.getContextPath();

    Restaurant restaurant =
            (Restaurant) request.getAttribute(
                    "restaurant"
            );

    List<Menu> menuItems =
            (List<Menu>) request.getAttribute(
                    "menuItems"
            );

    Integer menuItemCount =
            (Integer) request.getAttribute(
                    "menuItemCount"
            );

    User loggedInUser =
            (User) session.getAttribute(
                    "loggedInUser"
            );

    Map<Integer, Integer> cart =
            (Map<Integer, Integer>)
            session.getAttribute("cart");

    if (restaurant == null) {

        response.sendRedirect(
                contextPath + "/restaurants"
        );

        return;
    }

    if (menuItemCount == null) {

        menuItemCount =
                menuItems == null
                ? 0
                : menuItems.size();
    }

    int cartCount = 0;

    if (cart != null) {

        for (Integer quantity : cart.values()) {

            if (quantity != null) {
                cartCount += quantity;
            }
        }
    }

    String cartMessage =
            request.getParameter("message");

    boolean cartMessageIsError =
            cartMessage != null
            && (
                cartMessage.toLowerCase()
                    .contains("unavailable")
                || cartMessage.toLowerCase()
                    .contains("another restaurant")
                || cartMessage.toLowerCase()
                    .contains("not found")
            );
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        <%= escapeHtml(restaurant.getName()) %> | CraveGo
    </title>

    <style>

        :root {
            --navy: #111827;
            --navy-light: #1f2937;
            --coral: #ff6647;
            --coral-dark: #e95234;
            --mint: #29b783;
            --mint-dark: #218d67;
            --mint-light: #dff8ef;
            --cream: #fffaf2;
            --white: #ffffff;
            --text: #18212f;
            --muted: #687385;
            --border: #e5e7eb;
            --yellow: #ffc857;
            --danger: #d92d20;
            --danger-light: #fff0ee;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            min-height: 100vh;
            color: var(--text);
            background:
                radial-gradient(
                    circle at top left,
                    rgba(255, 200, 87, 0.1),
                    transparent 25%
                ),
                var(--cream);
            font-family: Arial, Helvetica, sans-serif;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        button {
            font-family: inherit;
        }

        /* =========================
           NAVBAR
        ========================= */

        .navbar-wrapper {
            position: sticky;
            top: 0;
            z-index: 100;
            padding: 13px 5%;
            background-color: rgba(255, 250, 242, 0.9);
            backdrop-filter: blur(13px);
        }

        .navbar {
            width: min(1240px, 100%);
            min-height: 68px;
            margin: auto;
            padding: 10px 13px 10px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 22px;
            background-color: var(--white);
            border: 1px solid rgba(17, 24, 39, 0.06);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(17, 24, 39, 0.08);
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .logo-symbol {
            position: relative;
            width: 41px;
            height: 41px;
            display: grid;
            place-items: center;
            overflow: hidden;
            color: var(--white);
            background-color: var(--coral);
            border-radius: 13px 13px 13px 4px;
            font-size: 20px;
            font-weight: 900;
        }

        .logo-symbol::after {
            content: "";
            position: absolute;
            right: -6px;
            bottom: -6px;
            width: 18px;
            height: 18px;
            background-color: var(--yellow);
            border-radius: 50%;
        }

        .logo-text {
            color: var(--navy);
            font-size: 24px;
            font-weight: 900;
            letter-spacing: -1px;
        }

        .logo-text span {
            color: var(--coral);
        }

        .navbar-links {
            display: flex;
            align-items: center;
            gap: 9px;
        }

        .nav-link,
        .welcome-text {
            padding: 9px 11px;
            color: var(--navy);
            font-size: 13px;
            font-weight: 800;
        }

        .nav-link:hover {
            color: var(--coral);
        }

        .navbar-cart {
            padding: 9px 13px;
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--navy);
            background-color: var(--mint-light);
            border-radius: 11px;
            font-size: 13px;
            font-weight: 900;
        }

        .cart-count {
            min-width: 23px;
            height: 23px;
            padding: 0 6px;
            display: grid;
            place-items: center;
            color: var(--white);
            background-color: var(--mint);
            border-radius: 50px;
            font-size: 11px;
        }

        .login-link {
            padding: 10px 16px;
            color: var(--navy);
            border: 1px solid var(--border);
            border-radius: 11px;
            font-size: 13px;
            font-weight: 800;
        }

        .signup-link,
        .logout-link {
            padding: 11px 17px;
            color: var(--white);
            background-color: var(--navy);
            border-radius: 11px;
            font-size: 13px;
            font-weight: 800;
        }

        .signup-link:hover,
        .logout-link:hover {
            background-color: var(--coral);
        }

        /* =========================
           COMPACT COVER
        ========================= */

        .cover {
            position: relative;
            width: min(1240px, 90%);
            height: 285px;
            margin: 28px auto 0;
            overflow: hidden;
            color: var(--white);
            background-color: var(--navy);
            border-radius: 31px;
            box-shadow: 0 20px 45px rgba(17, 24, 39, 0.16);
        }

        .cover-image {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .cover-overlay {
            position: absolute;
            inset: 0;
            background:
                linear-gradient(
                    90deg,
                    rgba(10, 16, 28, 0.97) 0%,
                    rgba(10, 16, 28, 0.77) 46%,
                    rgba(10, 16, 28, 0.18) 100%
                );
        }

        .cover-content {
            position: relative;
            z-index: 2;
            height: 100%;
            padding: 36px 46px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .back-link {
            position: absolute;
            top: 25px;
            left: 46px;
            color: #b7c0cd;
            font-size: 11px;
            font-weight: 800;
        }

        .back-link:hover {
            color: var(--coral);
        }

        .cover-label {
            width: fit-content;
            margin-top: 20px;
            padding: 7px 11px;
            color: #c4f2e2;
            background-color: rgba(41, 183, 131, 0.15);
            border: 1px solid rgba(41, 183, 131, 0.35);
            border-radius: 50px;
            font-size: 9px;
            font-weight: 900;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        .cover h1 {
            max-width: 650px;
            margin-top: 12px;
            font-family: Georgia, "Times New Roman", serif;
            font-size: clamp(34px, 4vw, 50px);
            line-height: 1.05;
        }

        .cover-cuisine {
            margin-top: 9px;
            color: var(--coral);
            font-size: 13px;
            font-weight: 800;
        }

        .cover-details {
            margin-top: 16px;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .cover-detail {
            padding: 8px 11px;
            color: #e7ebf1;
            background-color: rgba(255, 255, 255, 0.09);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 9px;
            font-size: 10px;
            font-weight: 800;
        }

        .rating-detail {
            color: var(--navy);
            background-color: var(--yellow);
            border-color: var(--yellow);
        }

        /* =========================
           MESSAGE
        ========================= */

        .message-wrapper {
            width: min(900px, 90%);
            margin: 24px auto 0;
        }

        .message {
            padding: 14px 17px;
            display: flex;
            align-items: flex-start;
            gap: 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 700;
            line-height: 1.5;
        }

        .success-message {
            color: #147352;
            background-color: var(--mint-light);
            border: 1px solid #a7ddca;
        }

        .error-message {
            color: var(--danger);
            background-color: var(--danger-light);
            border: 1px solid #f3beb8;
        }

        /* =========================
           FOOD STUDIO LAYOUT
        ========================= */

        .studio-layout {
            width: min(1240px, 90%);
            margin: 55px auto 110px;
            display: grid;
            grid-template-columns: 285px 1fr;
            gap: 40px;
            align-items: start;
        }

        /* =========================
           SIDEBAR
        ========================= */

        .studio-sidebar {
            position: sticky;
            top: 110px;
            padding: 24px;
            color: var(--white);
            background-color: var(--navy);
            border-radius: 24px;
            box-shadow: 0 15px 35px rgba(17, 24, 39, 0.15);
        }

        .sidebar-label {
            color: var(--mint);
            font-size: 10px;
            font-weight: 900;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        .studio-sidebar h2 {
            margin-top: 10px;
            font-family: Georgia, "Times New Roman", serif;
            font-size: 28px;
            line-height: 1.2;
        }

        .sidebar-description {
            margin-top: 13px;
            color: #aeb7c5;
            font-size: 12px;
            line-height: 1.7;
        }

        .sidebar-information {
            margin-top: 22px;
            display: grid;
            gap: 11px;
        }

        .sidebar-item {
            padding: 13px;
            background-color: rgba(255, 255, 255, 0.07);
            border-radius: 12px;
        }

        .sidebar-item small {
            display: block;
            color: #818c9d;
            font-size: 9px;
            font-weight: 800;
            text-transform: uppercase;
        }

        .sidebar-item strong {
            display: block;
            margin-top: 5px;
            color: var(--white);
            font-size: 12px;
            line-height: 1.5;
        }

        .sidebar-cart {
            margin-top: 20px;
            padding: 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            color: var(--navy);
            background-color: var(--yellow);
            border-radius: 13px;
            font-size: 12px;
            font-weight: 900;
        }

        .sidebar-cart span {
            width: 29px;
            height: 29px;
            display: grid;
            place-items: center;
            color: var(--white);
            background-color: var(--navy);
            border-radius: 9px;
        }

        /* =========================
           MENU CATALOGUE
        ========================= */

        .catalogue-header {
            margin-bottom: 25px;
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 20px;
        }

        .catalogue-label {
            color: var(--mint-dark);
            font-size: 10px;
            font-weight: 900;
            letter-spacing: 1.1px;
            text-transform: uppercase;
        }

        .catalogue-header h2 {
            margin-top: 7px;
            color: var(--navy);
            font-family: Georgia, "Times New Roman", serif;
            font-size: clamp(31px, 4vw, 42px);
        }

        .menu-count {
            padding: 9px 13px;
            color: var(--navy);
            background-color: var(--mint-light);
            border-radius: 10px;
            font-size: 11px;
            font-weight: 900;
        }

        .menu-list {
            display: grid;
            gap: 18px;
        }

        /* =========================
           DISH CARD
        ========================= */

.dish-card {
    width: 100%;
    height: 210px;
    min-height: 210px;
    max-height: 210px;
    padding: 16px;

    display: grid;
    grid-template-columns: 220px minmax(0, 1fr);
    gap: 23px;
    align-items: stretch;

    overflow: hidden;
    background-color: var(--white);
    border: 1px solid rgba(17, 24, 39, 0.06);
    border-radius: 22px;
    box-shadow: 0 7px 22px rgba(17, 24, 39, 0.06);

    transition:
        transform 0.25s ease,
        box-shadow 0.25s ease;
}

        .dish-card:hover {
            transform: translateX(5px);
            box-shadow: 0 14px 30px rgba(17, 24, 39, 0.11);
        }

        .dish-image-wrapper {
    position: relative;
    width: 220px;
    height: 178px;
    min-height: 178px;
    max-height: 178px;
    overflow: hidden;
    border-radius: 16px 55px 16px 16px;
    background-color: #eeeeee;
}

       .dish-image {
    display: block;
    width: 100%;
    height: 178px;
    min-height: 178px;
    max-height: 178px;
    object-fit: cover;
    object-position: center;
    transition: transform 0.4s ease;
}

        .dish-card:hover .dish-image {
            transform: scale(1.06);
        }

        .food-indicator {
            position: absolute;
            top: 12px;
            right: 12px;
            width: 24px;
            height: 24px;
            display: grid;
            place-items: center;
            background-color: var(--white);
            border: 2px solid var(--mint);
            border-radius: 6px;
        }

        .food-indicator::after {
            content: "";
            width: 9px;
            height: 9px;
            background-color: var(--mint);
            border-radius: 50%;
        }

       .dish-information {
    min-width: 0;
    height: 178px;
    padding: 8px 7px 6px 0;
    display: flex;
    flex-direction: column;
    overflow: hidden;
}

        .dish-status {
            width: fit-content;
            padding: 6px 9px;
            color: var(--mint-dark);
            background-color: var(--mint-light);
            border-radius: 8px;
            font-size: 9px;
            font-weight: 900;
            text-transform: uppercase;
        }

        .dish-status.unavailable {
            color: var(--danger);
            background-color: var(--danger-light);
        }

        .dish-name {
            margin-top: 11px;
            color: var(--navy);
            font-size: 20px;
            line-height: 1.35;
        }

        .dish-description {
    display: -webkit-box;
    max-width: 580px;
    margin-top: 8px;
    overflow: hidden;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.65;
    text-overflow: ellipsis;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: 2;
}

        .dish-bottom {
            margin-top: auto;
            padding-top: 15px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            border-top: 1px solid var(--border);
        }

        .dish-price {
            color: var(--navy);
            font-size: 19px;
            font-weight: 900;
        }

        /* =========================
           ADD AND QUANTITY BUTTONS
        ========================= */

        .add-button {
            min-width: 115px;
            padding: 11px 15px;
            color: var(--white);
            background-color: var(--coral);
            border: none;
            border-radius: 11px;
            font-size: 11px;
            font-weight: 900;
            text-transform: uppercase;
            cursor: pointer;
        }

        .add-button:hover {
            background-color: var(--coral-dark);
        }

        .login-add-button {
            min-width: 115px;
            padding: 11px 14px;
            display: inline-block;
            color: var(--navy);
            background-color: var(--yellow);
            border-radius: 11px;
            font-size: 10px;
            font-weight: 900;
            text-align: center;
            text-transform: uppercase;
        }

        .unavailable-button {
            min-width: 115px;
            padding: 11px 14px;
            color: #8b93a0;
            background-color: #eceef1;
            border: none;
            border-radius: 11px;
            font-size: 10px;
            font-weight: 900;
            text-transform: uppercase;
            cursor: not-allowed;
        }

        .quantity-control {
            height: 39px;
            display: flex;
            align-items: center;
            overflow: hidden;
            background-color: var(--mint-light);
            border: 1px solid #addfce;
            border-radius: 11px;
        }

        .quantity-form {
            height: 100%;
            display: flex;
        }

        .quantity-button {
            width: 39px;
            height: 100%;
            color: var(--mint-dark);
            background-color: transparent;
            border: none;
            font-size: 18px;
            font-weight: 900;
            cursor: pointer;
        }

        .quantity-button:hover {
            color: var(--white);
            background-color: var(--mint);
        }

        .quantity-button:disabled {
            color: #a9b2bc;
            background-color: transparent;
            cursor: not-allowed;
        }

        .quantity-value {
            min-width: 37px;
            color: var(--navy);
            font-size: 13px;
            font-weight: 900;
            text-align: center;
        }

        /* =========================
           EMPTY MENU
        ========================= */

        .empty-menu {
            padding: 75px 30px;
            color: var(--white);
            background-color: var(--navy);
            border-radius: 27px;
            text-align: center;
        }

        .empty-icon {
            width: 70px;
            height: 70px;
            margin: auto;
            display: grid;
            place-items: center;
            color: var(--navy);
            background-color: var(--yellow);
            border-radius: 22px;
            font-size: 31px;
        }

        .empty-menu h2 {
            margin-top: 22px;
            font-family: Georgia, "Times New Roman", serif;
            font-size: 28px;
        }

        .empty-menu p {
            margin-top: 10px;
            color: #aab4c3;
            line-height: 1.6;
        }

        .empty-menu a {
            margin-top: 22px;
            padding: 12px 19px;
            display: inline-block;
            color: var(--white);
            background-color: var(--coral);
            border-radius: 10px;
            font-size: 12px;
            font-weight: 900;
        }

        /* =========================
           FLOATING CART
        ========================= */

        .floating-cart {
            position: fixed;
            right: 23px;
            bottom: 23px;
            z-index: 90;
            min-width: 265px;
            padding: 14px 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            color: var(--white);
            background-color: var(--coral);
            border: 3px solid var(--white);
            border-radius: 16px;
            box-shadow: 0 17px 35px rgba(17, 24, 39, 0.25);
        }

        .floating-cart strong {
            display: block;
            font-size: 12px;
        }

        .floating-cart small {
            display: block;
            margin-top: 4px;
            color: #ffe3dc;
            font-size: 10px;
        }

        .floating-arrow {
            width: 35px;
            height: 35px;
            display: grid;
            place-items: center;
            flex-shrink: 0;
            color: var(--white);
            background-color: var(--navy);
            border-radius: 10px;
        }

        /* =========================
           FOOTER
        ========================= */

        .footer {
            padding: 34px 6%;
            color: #8f99a9;
            background-color: #0b101b;
            font-size: 12px;
        }

        .footer-content {
            width: min(1240px, 100%);
            margin: auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 25px;
        }

        .footer strong {
            color: var(--white);
            font-size: 17px;
        }

        .footer strong span {
            color: var(--coral);
        }

        /* =========================
           RESPONSIVE
        ========================= */

        @media (max-width: 950px) {

            .studio-layout {
                grid-template-columns: 1fr;
            }

            .studio-sidebar {
                position: static;
            }

            .sidebar-information {
                grid-template-columns: repeat(3, 1fr);
            }
        }

        @media (max-width: 700px) {

            .navbar {
                align-items: flex-start;
            }

            .navbar-links {
                justify-content: flex-end;
                flex-wrap: wrap;
            }

            .welcome-text {
                display: none;
            }

            .cover {
                height: 235px;
            }

            .cover-content {
                padding: 30px;
            }

            .back-link {
                top: 20px;
                left: 30px;
            }

            .dish-card {
                grid-template-columns: 165px 1fr;
            }

            .sidebar-information {
                grid-template-columns: 1fr;
            }

            .footer-content {
                align-items: flex-start;
                flex-direction: column;
            }
        }

        @media (max-width: 540px) {

            .logo-text {
                font-size: 20px;
            }

            .logo-symbol {
                width: 37px;
                height: 37px;
                font-size: 18px;
            }

            .nav-link,
            .login-link,
            .signup-link,
            .logout-link,
            .navbar-cart {
                padding: 8px 9px;
                font-size: 11px;
            }

            .cover {
                height: 215px;
            }

            .cover h1 {
                font-size: 33px;
            }

            .cover-address {
                display: none;
            }

           .dish-card {
    height: 420px;
    min-height: 420px;
    max-height: 420px;
    grid-template-columns: 1fr;
    grid-template-rows: 195px minmax(0, 1fr);
}

.dish-image-wrapper {
    width: 100%;
    height: 195px;
    min-height: 195px;
    max-height: 195px;
}

.dish-image {
    width: 100%;
    height: 195px;
    min-height: 195px;
    max-height: 195px;
}

.dish-information {
    width: 100%;
    height: 193px;
    padding: 5px;
}
            .dish-information {
                padding: 5px;
            }

            .floating-cart {
                right: 12px;
                bottom: 12px;
                left: 12px;
                min-width: auto;
            }
        }

    </style>

</head>

<body>

<!-- =========================
     NAVBAR
========================= -->

<div class="navbar-wrapper">

    <header class="navbar">

        <a class="logo"
           href="<%= contextPath %>/">

            <span class="logo-symbol">C</span>

            <span class="logo-text">
                Crave<span>Go</span>
            </span>

        </a>

        <nav class="navbar-links">

            <a class="nav-link"
               href="<%= contextPath %>/">
                Home
            </a>

            <a class="nav-link"
               href="<%= contextPath %>/restaurants">
                Restaurants
            </a>

            <% if (loggedInUser == null) { %>

                <a class="login-link"
                   href="<%= contextPath %>/login">
                    Login
                </a>

                <a class="signup-link"
                   href="<%= contextPath %>/register">
                    Create Account
                </a>

            <% } else { %>

                <span class="welcome-text">
                    Hi, <%= escapeHtml(
                            loggedInUser.getUsername()
                    ) %>
                </span>

                <a class="navbar-cart"
                   href="<%= contextPath %>/cart">

                    Cart

                    <span class="cart-count">
                        <%= cartCount %>
                    </span>

                </a>

                <a class="logout-link"
                   href="<%= contextPath %>/logout">
                    Logout
                </a>

            <% } %>

        </nav>

    </header>

</div>

<!-- =========================
     COMPACT RESTAURANT COVER
========================= -->

<section class="cover">

    <img class="cover-image"
         src="<%= escapeHtml(
                 restaurant.getImagePath()
         ) %>"
         alt="<%= escapeHtml(
                 restaurant.getName()
         ) %>"
         onerror="this.src='https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&amp;fit=crop&amp;w=1300&amp;q=85'">

    <div class="cover-overlay"></div>

    <div class="cover-content">

        <a class="back-link"
           href="<%= contextPath %>/restaurants">
            ← Back to restaurants
        </a>

        <div class="cover-label">
            CraveGo Food Studio
        </div>

        <h1>
            <%= escapeHtml(
                    restaurant.getName()
            ) %>
        </h1>

        <p class="cover-cuisine">
            <%= escapeHtml(
                    restaurant.getCuisineType()
            ) %>
        </p>

        <div class="cover-details">

            <span class="cover-detail rating-detail">
                ★ <%= restaurant.getRating() %>
            </span>

            <span class="cover-detail">
                <%= restaurant.getDeliveryTime() %>
                minute delivery
            </span>

            <span class="cover-detail cover-address">
                <%= escapeHtml(
                        restaurant.getAddress()
                ) %>
            </span>

        </div>

    </div>

</section>

<!-- =========================
     CART MESSAGE
========================= -->

<%
    if (cartMessage != null
            && !cartMessage.trim().isEmpty()) {
%>

    <div class="message-wrapper">

        <div class="message
             <%= cartMessageIsError
                 ? "error-message"
                 : "success-message" %>">

            <span>
                <%= cartMessageIsError ? "!" : "✓" %>
            </span>

            <span>
                <%= escapeHtml(cartMessage) %>
            </span>

        </div>

    </div>

<%
    }
%>

<!-- =========================
     FOOD STUDIO
========================= -->

<main class="studio-layout">

    <!-- SIDEBAR -->

    <aside class="studio-sidebar">

        <p class="sidebar-label">
            Kitchen profile
        </p>

        <h2>
            Made for your current craving.
        </h2>

        <p class="sidebar-description">
            Explore freshly prepared dishes from
            <%= escapeHtml(restaurant.getName()) %>
            and build your meal directly from this page.
        </p>

        <div class="sidebar-information">

            <div class="sidebar-item">

                <small>Menu size</small>

                <strong>
                    <%= menuItemCount %>
                    <%= menuItemCount == 1
                        ? "dish"
                        : "dishes" %>
                </strong>

            </div>

            <div class="sidebar-item">

                <small>Delivery estimate</small>

                <strong>
                    <%= restaurant.getDeliveryTime() %>
                    minutes
                </strong>

            </div>

            <div class="sidebar-item">

                <small>Restaurant rating</small>

                <strong>
                    ★ <%= restaurant.getRating() %>
                </strong>

            </div>

        </div>

        <% if (loggedInUser != null) { %>

            <a class="sidebar-cart"
               href="<%= contextPath %>/cart">

                <span>
                    <%= cartCount %>
                </span>

                View your cart →

            </a>

        <% } %>

    </aside>

    <!-- CATALOGUE -->

    <section class="catalogue">

        <div class="catalogue-header">

            <div>

                <p class="catalogue-label">
                    Today’s kitchen selection
                </p>

                <h2>
                    Choose your dishes
                </h2>

            </div>

            <span class="menu-count">

                <%= menuItemCount %>

                <%= menuItemCount == 1
                    ? "choice"
                    : "choices" %>

            </span>

        </div>

        <%
            if (menuItems != null
                    && !menuItems.isEmpty()) {
        %>

            <div class="menu-list">

                <%
                    for (Menu menuItem : menuItems) {

                        int currentQuantity = 0;

                        if (cart != null) {

                            currentQuantity =
                                    cart.getOrDefault(
                                        menuItem.getMenuId(),
                                        0
                                    );
                        }
                %>

                    <article class="dish-card">

                        <div class="dish-image-wrapper">

                            <img class="dish-image"
                                 src="<%= escapeHtml(
                                         menuItem.getImagePath()
                                 ) %>"
                                 alt="<%= escapeHtml(
                                         menuItem.getItemName()
                                 ) %>"
                                 onerror="this.src='https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&amp;fit=crop&amp;w=700&amp;q=85'">

                            <span class="food-indicator"></span>

                        </div>

                        <div class="dish-information">

                            <span class="dish-status
                                <%= menuItem.isAvailable()
                                    ? ""
                                    : "unavailable" %>">

                                <%= menuItem.isAvailable()
                                    ? "Freshly available"
                                    : "Currently unavailable" %>

                            </span>

                            <h3 class="dish-name">
                                <%= escapeHtml(
                                        menuItem.getItemName()
                                ) %>
                            </h3>

                            <p class="dish-description">
                                <%= escapeHtml(
                                        menuItem.getDescription()
                                ) %>
                            </p>

                            <div class="dish-bottom">

                                <span class="dish-price">
                                    ₹<%= String.format(
                                            "%.2f",
                                            menuItem.getPrice()
                                    ) %>
                                </span>

                                <%
                                    if (!menuItem.isAvailable()) {
                                %>

                                    <button class="unavailable-button"
                                            type="button"
                                            disabled>
                                        Unavailable
                                    </button>

                                <%
                                    } else if (
                                        loggedInUser == null
                                    ) {
                                %>

                                    <a class="login-add-button"
                                       href="<%= contextPath %>/login">
                                        Login to Add
                                    </a>

                                <%
                                    } else if (
                                        currentQuantity == 0
                                    ) {
                                %>

                                    <form action="<%= contextPath %>/add-to-cart"
                                          method="post">

                                        <input type="hidden"
                                               name="menuId"
                                               value="<%= menuItem.getMenuId() %>">

                                        <input type="hidden"
                                               name="restaurantId"
                                               value="<%= restaurant.getRestaurantId() %>">

                                        <button class="add-button"
                                                type="submit">
                                            Add to Cart
                                        </button>

                                    </form>

                                <%
                                    } else {
                                %>

                                    <div class="quantity-control">

                                        <!-- DECREASE -->

                                        <form class="quantity-form"
                                              action="<%= contextPath %>/cart"
                                              method="post">

                                            <input type="hidden"
                                                   name="action"
                                                   value="decrease">

                                            <input type="hidden"
                                                   name="menuId"
                                                   value="<%= menuItem.getMenuId() %>">

                                            <input type="hidden"
                                                   name="returnTo"
                                                   value="menu">

                                            <input type="hidden"
                                                   name="restaurantId"
                                                   value="<%= restaurant.getRestaurantId() %>">

                                            <button class="quantity-button"
                                                    type="submit"
                                                    aria-label="Decrease quantity">
                                                −
                                            </button>

                                        </form>

                                        <span class="quantity-value">
                                            <%= currentQuantity %>
                                        </span>

                                        <!-- INCREASE -->

                                        <form class="quantity-form"
                                              action="<%= contextPath %>/cart"
                                              method="post">

                                            <input type="hidden"
                                                   name="action"
                                                   value="increase">

                                            <input type="hidden"
                                                   name="menuId"
                                                   value="<%= menuItem.getMenuId() %>">

                                            <input type="hidden"
                                                   name="returnTo"
                                                   value="menu">

                                            <input type="hidden"
                                                   name="restaurantId"
                                                   value="<%= restaurant.getRestaurantId() %>">

                                            <button class="quantity-button"
                                                    type="submit"
                                                    aria-label="Increase quantity"
                                                    <%= currentQuantity >= 10
                                                        ? "disabled"
                                                        : "" %>>
                                                +
                                            </button>

                                        </form>

                                    </div>

                                <%
                                    }
                                %>

                            </div>

                        </div>

                    </article>

                <%
                    }
                %>

            </div>

        <%
            } else {
        %>

            <section class="empty-menu">

                <div class="empty-icon">
                    🍽
                </div>

                <h2>
                    This kitchen is updating its menu
                </h2>

                <p>
                    Explore another Bengaluru restaurant
                    while new dishes are being prepared.
                </p>

                <a href="<%= contextPath %>/restaurants">
                    Discover Other Restaurants
                </a>

            </section>

        <%
            }
        %>

    </section>

</main>

<!-- =========================
     FLOATING CART
========================= -->

<%
    if (loggedInUser != null
            && cartCount > 0) {
%>

    <a class="floating-cart"
       href="<%= contextPath %>/cart">

        <div>

            <strong>
                Your meal is taking shape
            </strong>

            <small>
                <%= cartCount %>
                <%= cartCount == 1
                    ? "item"
                    : "items" %>
                in your cart
            </small>

        </div>

        <span class="floating-arrow">
            →
        </span>

    </a>

<%
    }
%>

<!-- =========================
     FOOTER
========================= -->

<footer class="footer">

    <div class="footer-content">

        <strong>
            Crave<span>Go</span>
        </strong>

        <span>
            Good food should feel personal.
        </span>

        <span>
            © 2026 CraveGo
        </span>

    </div>

</footer>

</body>

</html>