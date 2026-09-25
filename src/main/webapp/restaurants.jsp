<%@ page language="java"

         contentType="text/html; charset=UTF-8"

         pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>

<%@ page import="java.util.Map" %>

<%@ page import="com.cravego.model.Restaurant" %>

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

    List<Restaurant> restaurants =

            (List<Restaurant>)

            request.getAttribute("restaurants");

    String pageTitle =

            (String) request.getAttribute(

                    "pageTitle"

            );

    String searchText =

            (String) request.getAttribute(

                    "searchText"

            );

    String selectedCuisine =

            (String) request.getAttribute(

                    "selectedCuisine"

            );

    Integer resultCount =

            (Integer) request.getAttribute(

                    "resultCount"

            );

    User loggedInUser =

            (User) session.getAttribute(

                    "loggedInUser"

            );

    Map<Integer, Integer> cart =

            (Map<Integer, Integer>)

            session.getAttribute("cart");

    int cartCount = 0;

    if (cart != null) {

        for (Integer quantity : cart.values()) {

            if (quantity != null) {

                cartCount += quantity;

            }

        }

    }

    if (pageTitle == null) {

        pageTitle = "Restaurants in Bengaluru";

    }

    if (resultCount == null) {

        resultCount =

                restaurants == null

                ? 0

                : restaurants.size();

    }

%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"

          content="width=device-width, initial-scale=1.0">

    <title>

        <%= escapeHtml(pageTitle) %> | CraveGo

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
            
            --danger: #dc3545;

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

            background-color: var(--cream);

            font-family: Arial, Helvetica, sans-serif;

        }

        a {

            color: inherit;

            text-decoration: none;

        }

        button,

        input {

            font-family: inherit;

        }

        /* =========================

           NAVBAR

        ========================= */

        .navbar-wrapper {

            position: sticky;

            top: 0;

            z-index: 100;

            padding: 14px 5%;

            background-color: rgba(255, 250, 242, 0.9);

            backdrop-filter: blur(13px);

        }

        .navbar {

            width: min(1240px, 100%);

            min-height: 70px;

            margin: auto;

            padding: 11px 14px 11px 21px;

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 24px;

            background-color: var(--white);

            border: 1px solid rgba(17, 24, 39, 0.06);

            border-radius: 21px;

            box-shadow: 0 10px 30px rgba(17, 24, 39, 0.08);

        }

        .logo {

            display: flex;

            align-items: center;

            gap: 10px;

        }

        .logo-symbol {

            position: relative;

            width: 42px;

            height: 42px;

            display: grid;

            place-items: center;

            overflow: hidden;

            color: var(--white);

            background-color: var(--coral);

            border-radius: 13px 13px 13px 4px;

            font-size: 21px;

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

            font-size: 25px;

            font-weight: 900;

            letter-spacing: -1px;

        }

        .logo-text span {

            color: var(--coral);

        }

        .navbar-links {

            display: flex;

            align-items: center;

            gap: 10px;

        }

        .nav-link,

        .welcome-text {

            padding: 10px 12px;

            color: var(--navy);

            font-size: 13px;

            font-weight: 800;

        }

        .nav-link:hover {

            color: var(--coral);

        }

        .cart-link {

            padding: 10px 14px;

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

            padding: 10px 17px;

            color: var(--navy);

            border: 1px solid var(--border);

            border-radius: 11px;

            font-size: 13px;

            font-weight: 800;

        }

        .signup-link,

        .logout-link {

            padding: 11px 18px;

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

           DISCOVERY HEADER

        ========================= */

        .discovery-header {

            position: relative;

            min-height: 410px;

            padding: 75px 5% 110px;

            overflow: hidden;

            color: var(--white);

            background-color: var(--navy);

        }

        .discovery-header::before {

            content: "";

            position: absolute;

            top: -240px;

            right: -120px;

            width: 570px;

            height: 570px;

            background-color: rgba(41, 183, 131, 0.16);

            border-radius: 50%;

        }

        .discovery-header::after {

            content: "";

            position: absolute;

            left: -180px;

            bottom: -300px;

            width: 530px;

            height: 530px;

            background-color: rgba(255, 102, 71, 0.15);

            border-radius: 50%;

        }

        .header-content {

            position: relative;

            z-index: 2;

            width: min(1240px, 100%);

            margin: auto;

            display: grid;

            grid-template-columns: 1fr 0.65fr;

            align-items: end;

            gap: 60px;

        }

        .header-label {

            width: fit-content;

            padding: 8px 13px;

            color: #c7f4e5;

            background-color: rgba(41, 183, 131, 0.14);

            border: 1px solid rgba(41, 183, 131, 0.35);

            border-radius: 50px;

            font-size: 11px;

            font-weight: 900;

            letter-spacing: 1px;

            text-transform: uppercase;

        }

        .header-content h1 {

            max-width: 720px;

            margin-top: 20px;

            font-family: Georgia, "Times New Roman", serif;

            font-size: clamp(42px, 5vw, 67px);

            line-height: 1.08;

            letter-spacing: -2px;

        }

        .header-content h1 span {

            color: var(--coral);

        }

        .header-content p {

            margin-top: 18px;

            color: #b2bccb;

            font-size: 15px;

            line-height: 1.75;

        }

        .header-statistics {

            display: grid;

            grid-template-columns: 1fr 1fr;

            gap: 15px;

        }

        .header-statistic {

            padding: 20px;

            background-color: rgba(255, 255, 255, 0.07);

            border: 1px solid rgba(255, 255, 255, 0.1);

            border-radius: 17px;

        }

        .header-statistic strong {

            display: block;

            color: var(--white);

            font-size: 25px;

        }

        .header-statistic span {

            display: block;

            margin-top: 5px;

            color: #929dad;

            font-size: 11px;

        }

        /* =========================

           FLOATING SEARCH

        ========================= */

        .search-wrapper {

            position: relative;

            z-index: 10;

            width: min(1040px, 90%);

            margin: -45px auto 0;

        }

        .search-panel {

            padding: 12px;

            display: flex;

            align-items: center;

            gap: 12px;

            background-color: var(--white);

            border: 1px solid rgba(17, 24, 39, 0.06);

            border-radius: 19px;

            box-shadow: 0 18px 40px rgba(17, 24, 39, 0.14);

        }

        .search-icon {

            margin-left: 10px;

            color: var(--coral);

            font-size: 22px;

        }

        .search-panel input {

            width: 100%;

            height: 48px;

            padding: 0 5px;

            color: var(--navy);

            background: transparent;

            border: none;

            outline: none;

            font-size: 14px;

        }

        .search-button {

            height: 48px;

            padding: 0 25px;

            flex-shrink: 0;

            color: var(--white);

            background-color: var(--coral);

            border: none;

            border-radius: 12px;

            font-size: 13px;

            font-weight: 900;

            cursor: pointer;

        }

        .search-button:hover {

            background-color: var(--coral-dark);

        }

        /* =========================

           CUISINE FILTER

        ========================= */

        .filter-section {

            width: min(1240px, 90%);

            margin: auto;

            padding: 50px 0 16px;

        }

        .filter-heading {

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 25px;

        }

        .filter-heading h2 {

            color: var(--navy);

            font-family: Georgia, "Times New Roman", serif;

            font-size: 27px;

        }

        .filter-heading span {

            color: var(--muted);

            font-size: 12px;

        }

        .filter-list {

            margin-top: 20px;

            padding-bottom: 8px;

            display: flex;

            align-items: center;

            gap: 11px;

            overflow-x: auto;

            scrollbar-width: none;

        }

        .filter-list::-webkit-scrollbar {

            display: none;

        }

        .filter-button {

            flex-shrink: 0;

            padding: 11px 17px;

            color: var(--navy);

            background-color: var(--white);

            border: 1px solid var(--border);

            border-radius: 12px;

            font-size: 12px;

            font-weight: 800;

            transition:

                color 0.2s ease,

                background-color 0.2s ease,

                transform 0.2s ease;

        }

        .filter-button:hover {

            color: var(--coral);

            transform: translateY(-2px);

        }

        .filter-button.active {

            color: var(--white);

            background-color: var(--navy);

            border-color: var(--navy);

        }

        /* =========================

           RESULTS

        ========================= */

        .results-section {

            width: min(1240px, 90%);

            margin: auto;

            padding: 35px 0 90px;

        }

        .results-heading {

            margin-bottom: 27px;

            display: flex;

            align-items: flex-end;

            justify-content: space-between;

            gap: 25px;

        }

        .results-label {

            color: var(--mint-dark);

            font-size: 11px;

            font-weight: 900;

            letter-spacing: 1px;

            text-transform: uppercase;

        }

        .results-heading h2 {

            margin-top: 7px;

            color: var(--navy);

            font-family: Georgia, "Times New Roman", serif;

            font-size: clamp(29px, 4vw, 39px);

        }

        .result-count {

            padding: 9px 13px;

            color: var(--navy);

            background-color: var(--mint-light);

            border-radius: 10px;

            font-size: 12px;

            font-weight: 900;

        }

        /* =========================

           RESTAURANT GRID

        ========================= */

        .restaurant-grid {

            display: grid;

            grid-template-columns: repeat(3, minmax(0, 1fr));

            gap: 25px;

            align-items: stretch;

        }

        .restaurant-card {

            position: relative;

            height: 100%;

            overflow: hidden;

            background-color: var(--white);

            border: 1px solid rgba(17, 24, 39, 0.06);

            border-radius: 25px;

            box-shadow: 0 8px 25px rgba(17, 24, 39, 0.07);

            transition:

                transform 0.25s ease,

                box-shadow 0.25s ease;

        }

        .restaurant-card:hover {

            transform: translateY(-7px);

            box-shadow: 0 18px 38px rgba(17, 24, 39, 0.14);

        }

        .restaurant-image-wrapper {

            position: relative;

            height: 235px;

            overflow: hidden;

        }

        .restaurant-image {

            width: 100%;

            height: 100%;

            object-fit: cover;

            transition: transform 0.4s ease;

        }

        .restaurant-card:hover .restaurant-image {

            transform: scale(1.07);

        }

        .image-shade {

            position: absolute;

            inset: 0;

            background: linear-gradient(

                transparent 45%,

                rgba(10, 16, 27, 0.72)

            );

        }

        .restaurant-status {

            position: absolute;

            top: 15px;

            left: 15px;

            z-index: 2;

            padding: 8px 12px;

            display: flex;

            align-items: center;

            gap: 7px;

            color: var(--white);

            border-radius: 10px;

            font-size: 11px;

            font-weight: 900;

            box-shadow: 0 7px 15px rgba(0, 0, 0, 0.16);

        }

        .restaurant-status::before {

            content: "";

            width: 8px;

            height: 8px;

            background-color: currentColor;

            border: 2px solid var(--white);

            border-radius: 50%;

        }

        .restaurant-status.open {

            background-color: var(--mint);

        }

        .restaurant-status.closed {

            background-color: var(--danger);

        }

        .restaurant-rating {

            position: absolute;

            top: 15px;

            right: 15px;

            padding: 8px 11px;

            color: var(--white);

            background-color: var(--mint);

            border-radius: 10px;

            font-size: 12px;

            font-weight: 900;

            box-shadow: 0 7px 15px rgba(0, 0, 0, 0.16);

        }

        .delivery-time {

            position: absolute;

            left: 16px;

            bottom: 15px;

            padding: 8px 11px;

            color: var(--navy);

            background-color: var(--yellow);

            border-radius: 9px;

            font-size: 11px;

            font-weight: 900;

        }

        .restaurant-information {

            padding: 22px;

        }

        .restaurant-name {

            color: var(--navy);

            font-size: 19px;

            line-height: 1.35;

        }

        .cuisine {

            margin-top: 9px;

            color: var(--coral);

            font-size: 12px;

            font-weight: 800;

            line-height: 1.5;

        }

        .address {

            min-height: 40px;

            margin-top: 8px;

            color: var(--muted);

            font-size: 12px;

            line-height: 1.6;

        }

        .card-footer {

            margin-top: 18px;

            padding-top: 16px;

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 15px;

            border-top: 1px solid var(--border);

        }

        .card-footer span:first-child {

            color: var(--muted);

            font-size: 11px;

        }

        .view-menu {

            color: var(--coral);

            font-size: 12px;

            font-weight: 900;

        }

        /* =========================

           EMPTY RESULT

        ========================= */

        .empty-result {

            padding: 80px 30px;

            overflow: hidden;

            background-color: var(--navy);

            border-radius: 30px;

            text-align: center;

        }

        .empty-symbol {

            width: 75px;

            height: 75px;

            margin: auto;

            display: grid;

            place-items: center;

            color: var(--navy);

            background-color: var(--yellow);

            border-radius: 24px;

            font-size: 34px;

        }

        .empty-result h2 {

            margin-top: 25px;

            color: var(--white);

            font-family: Georgia, "Times New Roman", serif;

            font-size: 31px;

        }

        .empty-result p {

            max-width: 540px;

            margin: 12px auto 0;

            color: #aeb7c5;

            font-size: 14px;

            line-height: 1.7;

        }

        .empty-result a {

            margin-top: 25px;

            padding: 13px 21px;

            display: inline-block;

            color: var(--white);

            background-color: var(--coral);

            border-radius: 11px;

            font-size: 13px;

            font-weight: 900;

        }

        /* =========================

           FOOTER

        ========================= */

        .footer {

            padding: 35px 6%;

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

        .footer-links {

            display: flex;

            gap: 20px;

        }

        .footer-links a:hover {

            color: var(--coral);

        }

        /* =========================

           RESPONSIVE

        ========================= */

        @media (max-width: 1000px) {

            .header-content {

                grid-template-columns: 1fr;

            }

            .header-statistics {

                max-width: 500px;

            }

            .restaurant-grid {

                grid-template-columns: repeat(2, 1fr);

            }

            .restaurant-card:nth-child(3n + 2) {

                transform: none;

            }

            .restaurant-card:hover,

            .restaurant-card:nth-child(3n + 2):hover {

                transform: translateY(-7px);

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

            .discovery-header {

                padding-top: 60px;

            }

            .header-statistics {

                grid-template-columns: 1fr 1fr;

            }

            .search-panel {

                align-items: stretch;

                flex-wrap: wrap;

            }

            .search-panel input {

                width: calc(100% - 45px);

            }

            .search-button {

                width: 100%;

            }

            .restaurant-grid {

                grid-template-columns: 1fr;

            }

            .results-heading {

                align-items: flex-start;

                flex-direction: column;

            }

            .footer-content {

                align-items: flex-start;

                flex-direction: column;

            }

        }

        @media (max-width: 480px) {

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

            .cart-link {

                padding: 8px 9px;

                font-size: 11px;

            }

            .header-content h1 {

                font-size: 42px;

            }

            .header-statistics {

                grid-template-columns: 1fr;

            }

            .filter-heading {

                align-items: flex-start;

                flex-direction: column;

            }

            .footer-links {

                flex-wrap: wrap;

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

                <a class="cart-link"

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

     DISCOVERY HEADER

========================= -->

<section class="discovery-header">

    <div class="header-content">

        <div>

            <div class="header-label">

                Bengaluru food discovery

            </div>

            <h1>

                Find a kitchen that matches

                <span>your mood.</span>

            </h1>

            <p>

                Browse trusted neighbourhood restaurants,

                explore different cuisines and discover

                something delicious for every craving.

            </p>

        </div>

        <div class="header-statistics">

            <div class="header-statistic">

                <strong>30+</strong>

                <span>Local restaurants</span>

            </div>

            <div class="header-statistic">

                <strong>450+</strong>

                <span>Food choices</span>

            </div>

            <div class="header-statistic">

                <strong>4.5+</strong>

                <span>Top ratings</span>

            </div>

            <div class="header-statistic">

                <strong>30 min</strong>

                <span>Average delivery</span>

            </div>

        </div>

    </div>

</section>

<!-- =========================

     SEARCH PANEL

========================= -->

<div class="search-wrapper">

    <form class="search-panel"

          action="<%= contextPath %>/restaurants"

          method="get">

        <span class="search-icon">⌕</span>

        <input type="text"

               name="search"

               value="<%= escapeHtml(searchText) %>"

               placeholder="Search by restaurant, cuisine or Bengaluru area"

               autocomplete="off">

        <button class="search-button"

                type="submit">

            Find Restaurants

        </button>

    </form>

</div>

<!-- =========================

     FILTERS

========================= -->

<section class="filter-section">

    <div class="filter-heading">

        <h2>Explore by flavour</h2>

        <span>

            Select a cuisine to narrow your discovery

        </span>

    </div>

    <div class="filter-list">

        <a class="filter-button

           <%= selectedCuisine == null

               && searchText == null

               ? "active"

               : "" %>"

           href="<%= contextPath %>/restaurants">

            All Restaurants

        </a>

        <a class="filter-button

           <%= "South Indian".equalsIgnoreCase(

                   selectedCuisine)

               ? "active"

               : "" %>"

           href="<%= contextPath %>/restaurants?cuisine=South%20Indian">

            South Indian

        </a>

        <a class="filter-button

           <%= "North Indian".equalsIgnoreCase(

                   selectedCuisine)

               ? "active"

               : "" %>"

           href="<%= contextPath %>/restaurants?cuisine=North%20Indian">

            North Indian

        </a>

        <a class="filter-button

           <%= "Biryani".equalsIgnoreCase(

                   selectedCuisine)

               ? "active"

               : "" %>"

           href="<%= contextPath %>/restaurants?cuisine=Biryani">

            Biryani

        </a>

        <a class="filter-button

           <%= "Chinese".equalsIgnoreCase(

                   selectedCuisine)

               ? "active"

               : "" %>"

           href="<%= contextPath %>/restaurants?cuisine=Chinese">

            Chinese

        </a>

        <a class="filter-button

           <%= "Fast Food".equalsIgnoreCase(

                   selectedCuisine)

               ? "active"

               : "" %>"

           href="<%= contextPath %>/restaurants?cuisine=Fast%20Food">

            Fast Food

        </a>

        <a class="filter-button

           <%= "Desserts".equalsIgnoreCase(

                   selectedCuisine)

               ? "active"

               : "" %>"

           href="<%= contextPath %>/restaurants?cuisine=Desserts">

            Desserts

        </a>

        <a class="filter-button

           <%= "Pure Veg".equalsIgnoreCase(

                   selectedCuisine)

               ? "active"

               : "" %>"

           href="<%= contextPath %>/restaurants?cuisine=Pure%20Veg">

            Pure Veg

        </a>

    </div>

</section>

<!-- =========================

     RESULTS

========================= -->

<main class="results-section">

    <div class="results-heading">

        <div>

            <p class="results-label">

                Your discovery list

            </p>

            <h2>

                <%= escapeHtml(pageTitle) %>

            </h2>

        </div>

        <span class="result-count">

            <%= resultCount %>

            <%= resultCount == 1

                ? "restaurant"

                : "restaurants" %>

        </span>

    </div>

    <%

        if (restaurants != null

                && !restaurants.isEmpty()) {

    %>

        <div class="restaurant-grid">

            <%

                for (Restaurant restaurant

                        : restaurants) {

            %>

                <a class="restaurant-card"

                   href="<%= contextPath %>/menu?restaurantId=<%= restaurant.getRestaurantId() %>">

                    <div class="restaurant-image-wrapper">

                        <%

                            boolean currentlyOpen =

                                    restaurant.isCurrentlyOpen();

                        %>

                        <span class="restaurant-status <%= currentlyOpen ? "open" : "closed" %>">

                            <%= currentlyOpen

                                    ? "Open now"

                                    : "Closed" %>

                        </span>

                        <img class="restaurant-image"

                             src="<%= escapeHtml(

                                     restaurant.getImagePath()

                             ) %>"

                             alt="<%= escapeHtml(

                                     restaurant.getName()

                             ) %>"

                             onerror="this.src='https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&amp;fit=crop&amp;w=800&amp;q=85'">

                        <span class="image-shade"></span>

                        <span class="restaurant-rating">

                            ★ <%= restaurant.getRating() %>

                        </span>

                        <span class="delivery-time">

                            <%= restaurant.getDeliveryTime() %>

                            minutes

                        </span>

                    </div>

                    <div class="restaurant-information">

                        <h3 class="restaurant-name">

                            <%= escapeHtml(

                                    restaurant.getName()

                            ) %>

                        </h3>

                        <p class="cuisine">

                            <%= escapeHtml(

                                    restaurant.getCuisineType()

                            ) %>

                        </p>

                        <p class="address">

                            <%= escapeHtml(

                                    restaurant.getAddress()

                            ) %>

                        </p>

                        <div class="card-footer">

                            <span>

                                Freshly prepared

                            </span>

                            <span class="view-menu">

                                Explore Menu →

                            </span>

                        </div>

                    </div>

                </a>

            <%

                }

            %>

        </div>

    <%

        } else {

    %>

        <section class="empty-result">

            <div class="empty-symbol">

                ⌕

            </div>

            <h2>

                No matching kitchens found

            </h2>

            <p>

                We could not find a restaurant matching

                your current search. Try another cuisine,

                restaurant name or Bengaluru location.

            </p>

            <a href="<%= contextPath %>/restaurants">

                Explore All Restaurants

            </a>

        </section>

    <%

        }

    %>

</main>

<!-- =========================

     FOOTER

========================= -->

<footer class="footer">

    <div class="footer-content">

        <strong>

            Crave<span>Go</span>

        </strong>

        <span>

            Discover Bengaluru, one meal at a time.

        </span>

        <div class="footer-links">

            <a href="<%= contextPath %>/">

                Home

            </a>

            <a href="<%= contextPath %>/restaurants">

                Restaurants

            </a>

            <% if (loggedInUser != null) { %>

                <a href="<%= contextPath %>/cart">

                    Cart

                </a>

            <% } %>

        </div>

    </div>

</footer>

</body>

</html>
