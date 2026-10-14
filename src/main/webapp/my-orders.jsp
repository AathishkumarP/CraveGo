<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.cravego.model.Order" %>
<%@ page import="com.cravego.model.Restaurant" %>
<%@ page import="com.cravego.model.User" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String imageUrl(String path, String contextPath) {
        if (path == null || path.isBlank()) {
            return "";
        }

        String value = path.trim();

        if (value.startsWith("https://")
                || value.startsWith("http://")) {
            return value;
        }

        // Reject other URL schemes and protocol-relative URLs.
        if (value.startsWith("//")
                || value.contains(":")
                || value.contains("\\")) {
            return "";
        }

        if (!contextPath.isEmpty()
                && value.startsWith(contextPath + "/")) {
            return value;
        }

        return contextPath
                + (value.startsWith("/") ? "" : "/")
                + value;
    }
%>

<%
    response.setHeader("Cache-Control", "no-store");

    String contextPath = request.getContextPath();

    Object sessionUser = session.getAttribute("loggedInUser");

    if (!(sessionUser instanceof User)) {
        response.sendRedirect(contextPath + "/login");
        return;
    }

    User loggedInUser = (User) sessionUser;

    Object ordersAttribute = request.getAttribute("orders");
    Object restaurantsAttribute =
            request.getAttribute("restaurantMap");

    if (!(ordersAttribute instanceof List<?>)
            || !(restaurantsAttribute instanceof Map<?, ?>)) {
        response.sendRedirect(contextPath + "/my-orders");
        return;
    }

    List<?> orders = (List<?>) ordersAttribute;
    Map<?, ?> restaurantMap = (Map<?, ?>) restaurantsAttribute;

    int orderCount = 0;

    for (Object entry : orders) {
        if (entry instanceof Order
                && ((Order) entry).getUserId()
                        == loggedInUser.getUserId()) {
            orderCount++;
        }
    }

    DateTimeFormatter dateFormatter =
            DateTimeFormatter.ofPattern(
                    "dd MMM yyyy",
                    Locale.ENGLISH
            );

    DateTimeFormatter timeFormatter =
            DateTimeFormatter.ofPattern(
                    "hh:mm a",
                    Locale.ENGLISH
            );
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>My Orders | CraveGo</title>

    <style>
        :root {
            --navy: #111827;
            --coral: #ff6647;
            --coral-dark: #e95234;
            --mint: #29b783;
            --mint-light: #dff8ef;
            --cream: #fffaf2;
            --yellow: #ffd166;
            --muted: #75808e;
            --border: #e8ebef;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #f8f9fb;
            color: var(--navy);
            font-family: Arial, Helvetica, sans-serif;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        button {
            font: inherit;
        }

        .header {
            background: #fff;
            border-bottom: 1px solid var(--border);
        }

        .navbar {
            max-width: 1200px;
            min-height: 88px;
            padding: 18px 28px;
            margin: auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 25px;
        }

        .logo {
            display: inline-flex;
            align-items: center;
            gap: 11px;
            flex-shrink: 0;
        }

        .logo-symbol {
            position: relative;
            isolation: isolate;
            width: 43px;
            height: 43px;
            display: grid;
            place-items: center;
            background: var(--coral);
            color: #fff;
            border-radius: 13px;
            font-size: 29px;
            font-weight: 900;
            transform: rotate(-8deg);
        }

        .logo-symbol::after {
            content: "";
            position: absolute;
            z-index: -1;
            width: 20px;
            height: 20px;
            right: -5px;
            bottom: -4px;
            background: var(--yellow);
            border-radius: 50%;
        }

        .logo-text {
            font-size: 25px;
            font-weight: 900;
            letter-spacing: -1px;
        }

        .logo-text span {
            color: var(--coral);
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .nav-link {
            padding: 11px 14px;
            font-size: 13px;
            font-weight: 700;
            border-radius: 10px;
        }

        .nav-link:hover,
        .nav-link.active {
            color: var(--coral-dark);
            background: #fff1ec;
        }

        .cart-link {
            background: var(--mint-light);
            color: #147451;
        }

        main {
            max-width: 1120px;
            margin: auto;
            padding: 35px 28px 70px;
        }

        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 25px;
            color: var(--muted);
            font-size: 12px;
        }

        .breadcrumb a:hover {
            color: var(--coral);
        }

        .intro {
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 24px;
            padding: 35px 38px;
            background: var(--navy);
            border-radius: 22px;
            color: #fff;
        }

        .intro::after {
            content: "";
            position: absolute;
            width: 220px;
            height: 220px;
            border: 38px solid rgba(255, 255, 255, .035);
            border-radius: 50%;
            right: -70px;
            top: -85px;
            pointer-events: none;
        }

        .eyebrow {
            color: var(--yellow);
            font-size: 10px;
            letter-spacing: 2.4px;
            font-weight: 800;
        }

        h1 {
            margin: 12px 0;
            font-family: Georgia, "Times New Roman", serif;
            font-size: 42px;
            letter-spacing: -1px;
        }

        .intro p {
            margin: 0;
            color: #bec5d0;
            font-size: 14px;
            line-height: 1.7;
        }

        .order-count {
            position: relative;
            z-index: 1;
            min-width: 115px;
            padding: 20px;
            text-align: center;
            border: 1px solid #374151;
            background: #1b2433;
            border-radius: 16px;
        }

        .order-count strong {
            display: block;
            margin-bottom: 7px;
            color: var(--yellow);
            font-size: 32px;
        }

        .order-count span {
            font-size: 11px;
            color: #c7cdd6;
        }

        .list-heading {
            margin: 32px 0 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
        }

        .list-heading h2 {
            margin: 0;
            font-size: 18px;
        }

        .list-heading span {
            color: var(--muted);
            font-size: 12px;
        }

        .order-list {
            display: grid;
            gap: 20px;
        }

        .order-card {
            overflow: hidden;
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 18px;
            box-shadow: 0 4px 15px rgba(17, 24, 39, .025);
        }

        .card-top {
            padding: 15px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            border-bottom: 1px solid var(--border);
            background: #fcfcfd;
        }

        .order-id {
            font-size: 12px;
            font-weight: 800;
            letter-spacing: .3px;
        }

        .status {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 7px 11px;
            color: #b35d18;
            background: #fff1df;
            border-radius: 7px;
            font-size: 10px;
            font-weight: 800;
        }

        .status::before {
            content: "";
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: currentColor;
            flex-shrink: 0;
        }

        .status.delivered {
            color: #148057;
            background: var(--mint-light);
        }

        .status.cancelled {
            color: #bb394c;
            background: #ffedf0;
        }

        .card-body {
            padding: 25px 24px;
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .restaurant-photo {
            width: 94px;
            height: 94px;
            flex-shrink: 0;
            position: relative;
            overflow: hidden;
            border-radius: 14px;
            background: var(--cream);
            border: 1px solid #f1e8da;
            display: grid;
            place-items: center;
        }

        .photo-fallback {
            font-family: Georgia, serif;
            color: var(--coral);
            font-size: 38px;
            font-weight: bold;
        }

        .restaurant-photo img {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .restaurant-info {
            flex: 1;
            min-width: 0;
        }

        .restaurant-info h3 {
            margin: 0 0 8px;
            font-size: 21px;
            letter-spacing: -.4px;
            overflow-wrap: anywhere;
        }

        .cuisine {
            margin: 0 0 13px;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.5;
        }

        .order-date {
            display: flex;
            flex-wrap: wrap;
            gap: 7px;
            color: #596474;
            font-size: 11px;
        }

        .total {
            text-align: right;
            flex-shrink: 0;
        }

        .total span {
            display: block;
            margin-bottom: 8px;
            color: var(--muted);
            font-size: 11px;
        }

        .total strong {
            font-size: 24px;
            letter-spacing: -.7px;
        }

        .card-footer {
            margin: 0 24px;
            padding: 17px 0;
            border-top: 1px dashed #e1e5eb;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }

        .payment {
            color: var(--muted);
            font-size: 11px;
            line-height: 1.6;
        }

        .payment strong {
            margin-left: 5px;
            color: #475365;
        }

        .track-button,
        .explore-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            padding: 12px 19px;
            background: var(--coral);
            color: #fff;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 800;
            transition: background .15s ease;
        }

        .track-button:hover,
        .explore-button:hover {
            background: var(--coral-dark);
        }

        .track-button.completed {
            color: var(--navy);
            background: #f1f3f6;
        }

        .track-button.completed:hover {
            background: #e5e9ef;
        }

        .cancelled-note {
            font-size: 11px;
            color: #bb394c;
        }

        .empty-state {
            padding: 55px 24px;
            text-align: center;
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 18px;
        }

        .empty-symbol {
            width: 85px;
            height: 85px;
            margin: 0 auto 22px;
            display: grid;
            place-items: center;
            background: var(--cream);
            color: var(--coral);
            border-radius: 24px;
            font-size: 38px;
        }

        .empty-state h3 {
            margin: 0 0 12px;
            font-size: 23px;
        }

        .empty-state p {
            max-width: 340px;
            margin: 0 auto 25px;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.8;
        }

        .page-footer {
            margin-top: 35px;
            text-align: center;
            color: var(--muted);
            font-size: 11px;
        }

        a:focus-visible {
            outline: 3px solid var(--mint);
            outline-offset: 4px;
        }

        @media (max-width: 650px) {
            .navbar {
                padding: 17px 18px;
                flex-wrap: wrap;
                gap: 18px;
            }

            .nav-links {
                flex-wrap: wrap;
                gap: 5px;
            }

            .nav-link {
                font-size: 11px;
                padding: 9px 10px;
            }

            main {
                padding: 25px 16px 45px;
            }

            .intro {
                padding: 28px 23px;
                gap: 15px;
            }

            h1 {
                font-size: 31px;
            }

            .intro p {
                font-size: 12px;
            }

            .order-count {
                min-width: 78px;
                padding: 15px 10px;
            }

            .order-count strong {
                font-size: 26px;
            }

            .card-top {
                padding: 14px 17px;
                flex-wrap: wrap;
            }

            .card-body {
                padding: 20px 17px;
                flex-wrap: wrap;
                gap: 14px;
            }

            .restaurant-photo {
                width: 72px;
                height: 72px;
            }

            .restaurant-info h3 {
                font-size: 17px;
            }

            .total {
                width: 100%;
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding-top: 15px;
                border-top: 1px solid var(--border);
                text-align: left;
            }

            .total span {
                margin: 0;
            }

            .total strong {
                font-size: 21px;
            }

            .card-footer {
                margin: 0 17px;
                flex-wrap: wrap;
            }

            .list-heading span {
                font-size: 10px;
            }
        }

        @media (max-width: 380px) {
            .intro {
                flex-direction: column;
                align-items: flex-start;
            }

            .order-count {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 10px 15px;
            }

            .order-count strong {
                margin: 0;
            }
        }
    </style>
</head>

<body>

<header class="header">
    <nav class="navbar" aria-label="Main navigation">
        <a class="logo"
           href="<%= escapeHtml(contextPath + "/") %>">
            <span class="logo-symbol" aria-hidden="true">C</span>
            <span class="logo-text">Crave<span>Go</span></span>
        </a>

        <div class="nav-links">
            <a class="nav-link"
               href="<%= escapeHtml(contextPath + "/") %>">
                Home
            </a>

            <a class="nav-link"
               href="<%= escapeHtml(contextPath + "/restaurants") %>">
                Restaurants
            </a>

            <a class="nav-link active"
               href="<%= escapeHtml(contextPath + "/my-orders") %>"
               aria-current="page">
                My Orders
            </a>

            <a class="nav-link cart-link"
               href="<%= escapeHtml(contextPath + "/cart") %>">
                Cart
            </a>
        </div>
    </nav>
</header>

<main>
    <div class="breadcrumb">
        <a href="<%= escapeHtml(contextPath + "/") %>">Home</a>
        <span aria-hidden="true">/</span>
        <span>My Orders</span>
    </div>

    <section class="intro" aria-labelledby="page-title">
        <div>
            <div class="eyebrow">GOOD FOOD. GREAT MEMORIES.</div>
            <h1 id="page-title">Your cravings, revisited.</h1>
            <p>All your orders, with delivery updates in one place.</p>
        </div>

        <div class="order-count">
            <strong><%= orderCount %></strong>
            <span><%= orderCount == 1 ? "Order placed" : "Orders placed" %></span>
        </div>
    </section>

    <div class="list-heading">
        <h2>Order history</h2>
        <span>Latest orders first</span>
    </div>

    <% if (orderCount == 0) { %>

        <section class="empty-state">
            <div class="empty-symbol" aria-hidden="true">&#127869;</div>
            <h3>Something delicious is waiting.</h3>
            <p>
                Your order history starts with your first bite.
                Explore restaurants and find your next favourite meal.
            </p>

            <a class="explore-button"
               href="<%= escapeHtml(contextPath + "/restaurants") %>">
                Explore Restaurants
                <span aria-hidden="true">&#8594;</span>
            </a>
        </section>

    <% } else { %>

        <div class="order-list">
            <%
                for (Object entry : orders) {
                    if (!(entry instanceof Order)) {
                        continue;
                    }

                    Order order = (Order) entry;

                    if (order.getUserId() != loggedInUser.getUserId()) {
                        continue;
                    }

                    Object restaurantEntry =
                            restaurantMap.get(order.getRestaurantId());

                    Restaurant restaurant =
                            restaurantEntry instanceof Restaurant
                            ? (Restaurant) restaurantEntry
                            : null;

                    String restaurantName =
                            restaurant != null
                            && restaurant.getName() != null
                            && !restaurant.getName().isBlank()
                            ? restaurant.getName()
                            : "Restaurant unavailable";

                    String cuisine =
                            restaurant != null
                            && restaurant.getCuisineType() != null
                            ? restaurant.getCuisineType()
                            : "";

                    String photoUrl = restaurant == null
                            ? ""
                            : imageUrl(
                                    restaurant.getImagePath(),
                                    contextPath
                            );

                    String initial =
                            restaurantName.substring(0, 1)
                                          .toUpperCase(Locale.ROOT);

                    String status = order.getStatus() == null
                            ? ""
                            : order.getStatus().trim()
                                   .toUpperCase(Locale.ROOT);

                    boolean delivered = "DELIVERED".equals(status);
                    boolean cancelled =
                            "CANCELLED".equals(status)
                            || "CANCELED".equals(status);

                    String statusClass = delivered
                            ? "delivered"
                            : cancelled ? "cancelled" : "";

                    String statusLabel = status.isEmpty()
                            ? "Status unavailable"
                            : status.replace('_', ' ');

                    String date = order.getOrderDate() == null
                            ? "Date unavailable"
                            : order.getOrderDate().format(dateFormatter);

                    String time = order.getOrderDate() == null
                            ? ""
                            : order.getOrderDate().format(timeFormatter);

                    String payment = order.getPaymentMode() == null
                            || order.getPaymentMode().isBlank()
                            ? "Not specified"
                            : order.getPaymentMode().replace('_', ' ');

                    String trackingUrl = contextPath
                            + "/track-order?orderId="
                            + order.getOrderId();
            %>

            <article class="order-card">
                <div class="card-top">
                    <span class="order-id">
                        ORDER #<%= order.getOrderId() %>
                    </span>

                    <span class="status <%= statusClass %>">
                        <%= escapeHtml(statusLabel) %>
                    </span>
                </div>

                <div class="card-body">
                    <div class="restaurant-photo">
                        <span class="photo-fallback" aria-hidden="true">
                            <%= escapeHtml(initial) %>
                        </span>

                        <% if (!photoUrl.isEmpty()) { %>
                            <img src="<%= escapeHtml(photoUrl) %>"
                                 alt="<%= escapeHtml(restaurantName) %>"
                                 loading="lazy"
                                 onerror="this.hidden=true;">
                        <% } %>
                    </div>

                    <div class="restaurant-info">
                        <h3><%= escapeHtml(restaurantName) %></h3>

                        <% if (!cuisine.isBlank()) { %>
                            <p class="cuisine">
                                <%= escapeHtml(cuisine) %>
                            </p>
                        <% } %>

                        <div class="order-date">
                            <span><%= escapeHtml(date) %></span>

                            <% if (!time.isEmpty()) { %>
                                <span aria-hidden="true">&#183;</span>
                                <span><%= escapeHtml(time) %></span>
                            <% } %>
                        </div>
                    </div>

                    <div class="total">
                        <span>Total paid / payable</span>
                        <strong>
                            &#8377;<%= String.format(
                                    Locale.ENGLISH,
                                    "%.2f",
                                    order.getTotalAmount()
                            ) %>
                        </strong>
                    </div>
                </div>

                <div class="card-footer">
                    <div class="payment">
                        Payment mode
                        <strong><%= escapeHtml(payment) %></strong>
                    </div>
                    
				<a class="track-button completed"
				   href="<%= escapeHtml(
				           contextPath + "/order-details?orderId="
				           + order.getOrderId()
				   ) %>">
				    View Details
				</a>

                    <% if (cancelled) { %>
                        <span class="cancelled-note">
                            This order was cancelled
                        </span>
                    <% } else { %>
                        <a class="track-button <%= delivered ? "completed" : "" %>"
                           href="<%= escapeHtml(trackingUrl) %>"
                           aria-label="View delivery status for order <%= order.getOrderId() %>">
                            <%= delivered ? "View Delivery Status" : "Track Order" %>
                            <span aria-hidden="true">&#8594;</span>
                        </a>
                    <% } %>
                </div>
            </article>

            <% } %>
        </div>

    <% } %>

    <div class="page-footer">
        Made for your cravings. Delivered with care.
    </div>
</main>

</body>
</html>