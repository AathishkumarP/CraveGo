<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.cravego.model.User" %>
<%@ page import="com.cravego.model.Order" %>
<%@ page import="com.cravego.model.OrderItem" %>
<%@ page import="com.cravego.model.Menu" %>
<%@ page import="com.cravego.model.Restaurant" %>
<%@ page import="java.util.UUID" %>

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

    private String money(double value) {
        return String.format(Locale.ENGLISH, "%.2f", value);
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

    Object orderAttribute = request.getAttribute("order");
    Object itemsAttribute = request.getAttribute("orderItems");
    Object menuAttribute = request.getAttribute("menuMap");

    if (!(orderAttribute instanceof Order)
            || !(itemsAttribute instanceof List<?>)
            || !(menuAttribute instanceof Map<?, ?>)) {
        response.sendRedirect(contextPath + "/my-orders");
        return;
    }

    Order order = (Order) orderAttribute;
    User loggedInUser = (User) sessionUser;

    if (order.getUserId() != loggedInUser.getUserId()) {
        response.sendError(403);
        return;
    }

    List<?> orderItems = (List<?>) itemsAttribute;
    Map<?, ?> menuMap = (Map<?, ?>) menuAttribute;

    Object restaurantAttribute = request.getAttribute("restaurant");

    Restaurant restaurant =
            restaurantAttribute instanceof Restaurant
            ? (Restaurant) restaurantAttribute
            : null;

    String restaurantName =
            restaurant != null
            && restaurant.getName() != null
            && !restaurant.getName().isBlank()
            ? restaurant.getName()
            : "Restaurant unavailable";

    String cuisine =
            restaurant != null && restaurant.getCuisineType() != null
            ? restaurant.getCuisineType()
            : "";

    String restaurantAddress =
            restaurant != null && restaurant.getAddress() != null
            ? restaurant.getAddress()
            : "";

    String status = order.getStatus() == null
            ? ""
            : order.getStatus().trim().toUpperCase(Locale.ROOT);

    boolean delivered = "DELIVERED".equals(status);
    
    boolean canCancel = "PLACED".equals(status);

    if (!(session.getAttribute("orderCsrfToken") instanceof String)) {
        session.setAttribute(
                "orderCsrfToken",
                UUID.randomUUID().toString()
        );
    }

    String orderCsrfToken =
            (String) session.getAttribute("orderCsrfToken");

    Object messageAttribute = session.getAttribute("orderMessage");
    Object messageTypeAttribute =
            session.getAttribute("orderMessageType");

    String orderMessage = messageAttribute instanceof String
            ? (String) messageAttribute
            : null;

    String orderMessageClass =
            "success".equals(messageTypeAttribute)
            ? "success"
            : "error";

    if (orderMessage != null) {
        session.removeAttribute("orderMessage");
        session.removeAttribute("orderMessageType");
    }
    
    boolean cancelled =
            "CANCELLED".equals(status) || "CANCELED".equals(status);

    String statusClass = delivered
            ? "delivered"
            : cancelled ? "cancelled" : "";

    String statusLabel = status.isEmpty()
            ? "Status unavailable"
            : status.replace('_', ' ');

    String paymentMode =
            order.getPaymentMode() == null
            || order.getPaymentMode().isBlank()
            ? "Not specified"
            : order.getPaymentMode().replace('_', ' ');

    String orderDate = order.getOrderDate() == null
            ? "Date unavailable"
            : order.getOrderDate().format(
                    DateTimeFormatter.ofPattern(
                            "dd MMM yyyy, hh:mm a",
                            Locale.ENGLISH
                    )
            );

    BigDecimal itemsTotal = BigDecimal.ZERO;
    int totalQuantity = 0;
    int itemRows = 0;

    for (Object entry : orderItems) {
        if (entry instanceof OrderItem) {
            OrderItem item = (OrderItem) entry;

            if (item.getOrderId() == order.getOrderId()) {
                itemsTotal = itemsTotal.add(
                        BigDecimal.valueOf(item.getTotalAmount())
                );

                totalQuantity += item.getQuantity();
                itemRows++;
            }
        }
    }

    BigDecimal adjustment =
            BigDecimal.valueOf(order.getTotalAmount())
                      .subtract(itemsTotal)
                      .setScale(2, java.math.RoundingMode.HALF_UP);

    String trackingUrl = contextPath
            + "/track-order?orderId="
            + order.getOrderId();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Order #<%= order.getOrderId() %> | CraveGo</title>

    <style>
        :root {
            --navy: #111827;
            --coral: #ff6647;
            --mint: #29b783;
            --yellow: #ffd166;
            --muted: #626c7a;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            color: var(--navy);
            background: #fff8ef;
            font-family: Arial, Helvetica, sans-serif;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        .header {
            background: #fffaf4;
            border-bottom: 1px solid #eadfce;
        }

        .navbar {
            max-width: 1150px;
            min-height: 88px;
            margin: auto;
            padding: 18px 28px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
        }

        .logo {
            display: inline-flex;
            align-items: center;
            gap: 11px;
        }

        .logo-symbol {
            position: relative;
            isolation: isolate;
            width: 43px;
            height: 43px;
            display: grid;
            place-items: center;
            color: #fff;
            background: var(--coral);
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

        .back-link {
            font-size: 12px;
            font-weight: 700;
        }

        main {
            max-width: 1120px;
            margin: auto;
            padding: 30px 28px 65px;
        }

        .breadcrumb {
            margin-bottom: 24px;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            color: var(--muted);
            font-size: 12px;
        }

        .banner {
            padding: 31px 34px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            color: #fff;
            background: linear-gradient(120deg, #111827, #24364b);
            border-radius: 21px;
        }

        .eyebrow {
            color: var(--yellow);
            font-size: 10px;
            letter-spacing: 2px;
            font-weight: 800;
        }

        h1 {
            margin: 12px 0;
            font-family: Georgia, serif;
            font-size: 35px;
        }

        .banner p {
            margin: 0;
            color: #c1cad7;
            font-size: 12px;
            line-height: 1.7;
        }

        .status {
            padding: 10px 14px;
            border-radius: 9px;
            color: #ffda9f;
            background: #4a3825;
            font-size: 11px;
            font-weight: 800;
        }

        .status.delivered {
            color: #b9f3d9;
            background: #214839;
        }

        .status.cancelled {
            color: #ffc2cb;
            background: #512c39;
        }

        .layout {
            margin-top: 25px;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 300px;
            align-items: start;
            gap: 22px;
        }

        .items-card,
        .bill-card {
            overflow: hidden;
            background: #fffdf8;
            border: 1px solid #eadfce;
            border-radius: 17px;
        }

        .restaurant {
            padding: 25px;
            background: #fff0e5;
            border-bottom: 1px solid #f0d7c7;
        }

        .restaurant h2 {
            margin: 0 0 9px;
            font-size: 22px;
            overflow-wrap: anywhere;
        }

        .restaurant p {
            margin: 5px 0 0;
            color: #62605d;
            font-size: 12px;
            line-height: 1.7;
        }

        .items-heading {
            padding: 22px 25px 8px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
        }

        .items-heading h3 {
            margin: 0;
            font-size: 16px;
        }

        .items-heading span {
            color: var(--muted);
            font-size: 11px;
        }

        .item {
            margin: 0 25px;
            padding: 20px 0;
            display: flex;
            align-items: center;
            gap: 15px;
            border-bottom: 1px dashed #e2dfd7;
        }

        .item:last-child {
            border-bottom: none;
        }

        .item-photo {
            position: relative;
            width: 70px;
            height: 70px;
            flex-shrink: 0;
            display: grid;
            place-items: center;
            overflow: hidden;
            background: #fff0e5;
            border-radius: 12px;
        }

        .item-photo span {
            color: #b44930;
            font-family: Georgia, serif;
            font-size: 27px;
        }

        .item-photo img {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .item-info {
            flex: 1;
            min-width: 0;
        }

        .item-info h4 {
            margin: 0 0 8px;
            font-size: 14px;
            line-height: 1.5;
            overflow-wrap: anywhere;
        }

        .item-info p {
            margin: 0;
            color: var(--muted);
            font-size: 11px;
        }

        .item-amount {
            font-size: 14px;
            font-weight: 800;
            white-space: nowrap;
        }

        .bill-card {
            padding: 25px;
            background: #eaf6f0;
            border-color: #cee5d8;
        }

        .bill-card h2 {
            margin: 0 0 24px;
            font-size: 19px;
            color: #14583f;
        }

        .bill-row {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            margin-bottom: 18px;
            color: #386654;
            font-size: 12px;
            line-height: 1.6;
        }

        .bill-row strong {
            color: #172337;
            white-space: nowrap;
        }

        .bill-total {
            padding-top: 20px;
            margin-top: 5px;
            border-top: 1px dashed #b3d3c3;
            font-size: 16px;
            font-weight: 800;
        }

        .payment {
            margin: 23px 0;
            padding: 13px;
            background: #d9ede2;
            border-radius: 10px;
            color: #386654;
            font-size: 11px;
            line-height: 1.7;
        }

        .payment strong {
            display: block;
            color: #172337;
            font-size: 13px;
        }

        .button {
            width: 100%;
            padding: 14px;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            color: #fff;
            background: var(--navy);
            border-radius: 10px;
            font-size: 12px;
            font-weight: 800;
        }

        .button:hover {
            background: #263448;
        }

        .note {
            margin: 17px 0 0;
            color: #53675e;
            font-size: 10px;
            line-height: 1.7;
        }

        .empty {
            padding: 25px;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.7;
        }

        a:focus-visible {
            outline: 3px solid var(--mint);
            outline-offset: 4px;
        }

        @media (max-width: 800px) {
            .layout {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .navbar {
                padding: 18px;
                flex-wrap: wrap;
            }

            main {
                padding: 25px 16px 45px;
            }

            .banner {
                padding: 25px;
                flex-wrap: wrap;
            }

            h1 {
                font-size: 29px;
            }

            .restaurant {
                padding: 21px;
            }

            .items-heading {
                padding: 20px 18px 5px;
            }

            .item {
                margin: 0 18px;
                gap: 12px;
                flex-wrap: wrap;
            }

            .item-photo {
                width: 58px;
                height: 58px;
            }

            .item-amount {
                margin-left: auto;
            }
        }
        
        .order-message {
    margin-top: 20px;
    padding: 16px 20px;
    border-radius: 12px;
    font-size: 13px;
    line-height: 1.7;
}

.order-message.success {
    color: #14583f;
    background: #dff8ef;
    border: 1px solid #b8e4d2;
}

.order-message.error {
    color: #9b2339;
    background: #ffedf0;
    border: 1px solid #f2c8d1;
}

.cancel-form {
    margin-top: 13px;
}

.cancel-button {
    width: 100%;
    padding: 13px;
    color: #a52d42;
    background: #fff0f2;
    border: 1px solid #e7b8c2;
    border-radius: 10px;
    font: inherit;
    font-size: 12px;
    font-weight: 800;
    cursor: pointer;
}

.cancel-button:hover {
    background: #ffe1e7;
}

.cancel-button:focus-visible {
    outline: 3px solid var(--mint);
    outline-offset: 4px;
}

.cancel-hint {
    margin: 10px 0 0;
    color: #53675e;
    font-size: 10px;
    line-height: 1.7;
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

        <a class="back-link"
           href="<%= escapeHtml(contextPath + "/my-orders") %>">
            &#8592; Back to My Orders
        </a>
    </nav>
</header>

<main>
    <div class="breadcrumb">
        <a href="<%= escapeHtml(contextPath + "/profile") %>">
            Account
        </a>
        <span aria-hidden="true">/</span>
        <a href="<%= escapeHtml(contextPath + "/my-orders") %>">
            My Orders
        </a>
        <span aria-hidden="true">/</span>
        <span>Order #<%= order.getOrderId() %></span>
    </div>

    <section class="banner">
        <div>
            <div class="eyebrow">EVERY BITE, ACCOUNTED FOR</div>
            <h1>Order #<%= order.getOrderId() %></h1>
            <p><%= escapeHtml(orderDate) %></p>
        </div>

        <span class="status <%= statusClass %>">
            <%= escapeHtml(statusLabel) %>
        </span>
    </section>
    
    <% if (orderMessage != null) { %>
    <div class="order-message <%= orderMessageClass %>"
         role="<%= "error".equals(orderMessageClass) ? "alert" : "status" %>">
        <%= escapeHtml(orderMessage) %>
    </div>
<% } %>

    <div class="layout">
        <section class="items-card">
            <div class="restaurant">
                <h2><%= escapeHtml(restaurantName) %></h2>

                <% if (!cuisine.isBlank()) { %>
                    <p><%= escapeHtml(cuisine) %></p>
                <% } %>

                <% if (!restaurantAddress.isBlank()) { %>
                    <p><%= escapeHtml(restaurantAddress) %></p>
                <% } %>
            </div>

            <div class="items-heading">
                <h3>Your food items</h3>
                <span>
                    <%= totalQuantity %>
                    <%= totalQuantity == 1 ? "item" : "items" %>
                </span>
            </div>

            <% if (itemRows == 0) { %>
                <p class="empty">
                    Item details are unavailable for this order.
                </p>
            <% } else { %>

                <%
                    for (Object entry : orderItems) {
                        if (!(entry instanceof OrderItem)) {
                            continue;
                        }

                        OrderItem item = (OrderItem) entry;

                        if (item.getOrderId() != order.getOrderId()) {
                            continue;
                        }

                        Object menuEntry = menuMap.get(item.getMenuId());

                        Menu menu = menuEntry instanceof Menu
                                ? (Menu) menuEntry
                                : null;

                        String itemName =
                                menu != null
                                && menu.getItemName() != null
                                && !menu.getItemName().isBlank()
                                ? menu.getItemName()
                                : "Food item #" + item.getMenuId();

                        String photoUrl = menu == null
                                ? ""
                                : imageUrl(menu.getImagePath(), contextPath);
                %>

                <article class="item">
                    <div class="item-photo">
                        <span aria-hidden="true">
                            <%= escapeHtml(itemName.substring(0, 1)) %>
                        </span>

                        <% if (!photoUrl.isEmpty()) { %>
                            <img src="<%= escapeHtml(photoUrl) %>"
                                 alt="<%= escapeHtml(itemName) %>"
                                 loading="lazy"
                                 onerror="this.hidden=true;">
                        <% } %>
                    </div>

                    <div class="item-info">
                        <h4><%= escapeHtml(itemName) %></h4>
                        <p>Quantity: <%= item.getQuantity() %></p>
                    </div>

                    <div class="item-amount">
                        &#8377;<%= money(item.getTotalAmount()) %>
                    </div>
                </article>

                <% } %>
            <% } %>
        </section>

        <aside class="bill-card">
            <h2>Bill summary</h2>

            <% if (itemRows > 0) { %>
                <div class="bill-row">
                    <span>Items total</span>
                    <strong>
                        &#8377;<%= money(itemsTotal.doubleValue()) %>
                    </strong>
                </div>

                <% if (adjustment.signum() != 0) { %>
                    <div class="bill-row">
                        <span>
                            <%= adjustment.signum() > 0
                                    ? "Other charges / adjustments"
                                    : "Discount / adjustment" %>
                        </span>

                        <strong>
                            <%= adjustment.signum() < 0 ? "−" : "" %>&#8377;<%= money(adjustment.abs().doubleValue()) %>
                        </strong>
                    </div>
                <% } %>
            <% } %>

            <div class="bill-row bill-total">
                <span>Order total</span>
                <strong>&#8377;<%= money(order.getTotalAmount()) %></strong>
            </div>

            <div class="payment">
                Payment mode
                <strong><%= escapeHtml(paymentMode) %></strong>
            </div>

            <% if (!cancelled) { %>
                <a class="button"
                   href="<%= escapeHtml(trackingUrl) %>">
                    <%= delivered
                            ? "View Delivery Status"
                            : "Track Order" %>
                    <span aria-hidden="true">&#8594;</span>
                </a>
            <% } %>
            
            <% if (canCancel) { %>
    <form class="cancel-form"
          action="<%= escapeHtml(contextPath + "/cancel-order") %>"
          method="post"
          onsubmit="return confirm('Cancel this order? This action cannot be undone.');">

        <input type="hidden"
               name="orderId"
               value="<%= order.getOrderId() %>">

        <input type="hidden"
               name="csrfToken"
               value="<%= escapeHtml(orderCsrfToken) %>">

        <button class="cancel-button" type="submit">
            Cancel Order
        </button>
    </form>

    <p class="cancel-hint">
        Cancellation is available while the order is in PLACED status.
    </p>
<% } %>

            <p class="note">
                Amounts use your saved order records.
                Restaurant and food information reflect the current menu.
            </p>
        </aside>
    </div>
</main>

</body>
</html>