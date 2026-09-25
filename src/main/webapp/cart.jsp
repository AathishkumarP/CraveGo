<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.cravego.model.Menu" %>
<%@ page import="com.cravego.model.Restaurant" %>
<%@ page import="com.cravego.model.User" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    String contextPath = request.getContextPath();
    Map<Menu, Integer> cartItems =
            (Map<Menu, Integer>) request.getAttribute("cartItems");
    Restaurant restaurant =
            (Restaurant) request.getAttribute("restaurant");
    User loggedInUser =
            (User) session.getAttribute("loggedInUser");
    Double subtotal = (Double) request.getAttribute("subtotal");
    Double deliveryFee = (Double) request.getAttribute("deliveryFee");
    Double platformFee = (Double) request.getAttribute("platformFee");
    Double totalAmount = (Double) request.getAttribute("totalAmount");
    Integer totalQuantity = (Integer) request.getAttribute("totalQuantity");

    subtotal = subtotal == null ? 0.0 : subtotal;
    deliveryFee = deliveryFee == null ? 0.0 : deliveryFee;
    platformFee = platformFee == null ? 0.0 : platformFee;
    totalAmount = totalAmount == null ? 0.0 : totalAmount;
    totalQuantity = totalQuantity == null ? 0 : totalQuantity;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Cart | CraveGo</title>

    <style>
        :root {
            --navy: #111827;
            --navy-light: #202838;
            --coral: #ff6647;
            --coral-dark: #e95234;
            --mint: #29b783;
            --mint-dark: #218d67;
            --mint-light: #dff8ef;
            --cream: #fffaf2;
            --white: #ffffff;
            --yellow: #ffc857;
            --muted: #687385;
            --border: #e7e1d8;
            --danger: #dc3545;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }
        html { scroll-behavior: smooth; }
        body {
            min-height: 100vh;
            color: var(--navy);
            background:
                radial-gradient(circle at top left, rgba(255,200,87,.13), transparent 25%),
                var(--cream);
            font-family: Arial, Helvetica, sans-serif;
        }
        a { color: inherit; text-decoration: none; }
        button { font: inherit; }

        .navbar-wrapper {
            position: sticky;
            top: 0;
            z-index: 100;
            padding: 13px 5%;
            background: rgba(255,250,242,.92);
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
            gap: 20px;
            background: var(--white);
            border: 1px solid rgba(17,24,39,.06);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(17,24,39,.08);
        }
        .logo { display: flex; align-items: center; gap: 10px; }
        .logo-symbol {
            position: relative;
            width: 41px;
            height: 41px;
            display: grid;
            place-items: center;
            overflow: hidden;
            color: var(--white);
            background: var(--coral);
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
            background: var(--yellow);
            border-radius: 50%;
        }
        .logo-text { font-size: 24px; font-weight: 900; letter-spacing: -1px; }
        .logo-text span { color: var(--coral); }
        .navbar-links { display: flex; align-items: center; gap: 9px; }
        .nav-link, .welcome-text {
            padding: 9px 11px;
            font-size: 13px;
            font-weight: 800;
        }
        .nav-link:hover { color: var(--coral); }
        .cart-pill {
            padding: 9px 13px;
            display: flex;
            align-items: center;
            gap: 8px;
            background: var(--mint-light);
            border-radius: 11px;
            font-size: 13px;
            font-weight: 900;
        }
        .cart-pill span {
            min-width: 24px;
            height: 24px;
            padding: 0 6px;
            display: grid;
            place-items: center;
            color: var(--white);
            background: var(--mint);
            border-radius: 20px;
            font-size: 11px;
        }
        .logout-button {
            padding: 11px 15px;
            color: var(--white);
            background: var(--navy);
            border-radius: 11px;
            font-size: 12px;
            font-weight: 900;
        }

        .page-header {
            width: min(1240px, 90%);
            margin: 12px auto 25px;
            padding: 32px 38px;
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 25px;
            color: var(--white);
            background: var(--navy);
            border-radius: 27px;
            box-shadow: 0 18px 38px rgba(17,24,39,.16);
        }
        .eyebrow {
            margin-bottom: 8px;
            color: var(--mint);
            font-size: 10px;
            font-weight: 900;
            letter-spacing: 2px;
            text-transform: uppercase;
        }
        .page-header h1 {
            font-family: Georgia, "Times New Roman", serif;
            font-size: clamp(34px, 5vw, 52px);
            line-height: 1;
        }
        .page-header p { margin-top: 9px; color: #cbd2de; font-size: 13px; }
        .selection-badge {
            padding: 13px 17px;
            color: var(--navy);
            background: var(--yellow);
            border-radius: 13px;
            font-size: 12px;
            font-weight: 900;
            white-space: nowrap;
        }

        .cart-layout {
            width: min(1240px, 90%);
            margin: 0 auto 60px;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 350px;
            align-items: start;
            gap: 24px;
        }
        .cart-panel {
            overflow: hidden;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 25px;
            box-shadow: 0 10px 30px rgba(17,24,39,.07);
        }
        .restaurant-strip {
            padding: 18px;
            display: grid;
            grid-template-columns: 74px minmax(0,1fr) auto;
            align-items: center;
            gap: 16px;
            background: var(--navy);
            color: var(--white);
        }
        .restaurant-image {
            width: 74px;
            height: 74px;
            object-fit: cover;
            border: 3px solid var(--yellow);
            border-radius: 17px;
        }
        .restaurant-details { min-width: 0; }
        .restaurant-details small {
            color: var(--mint);
            font-size: 9px;
            font-weight: 900;
            letter-spacing: 1.3px;
            text-transform: uppercase;
        }
        .restaurant-details h2 {
            margin: 5px 0 6px;
            overflow: hidden;
            font-family: Georgia, "Times New Roman", serif;
            font-size: 23px;
            white-space: nowrap;
            text-overflow: ellipsis;
        }
        .restaurant-details p {
            overflow: hidden;
            color: #b9c1ce;
            font-size: 11px;
            white-space: nowrap;
            text-overflow: ellipsis;
        }
        .view-menu {
            padding: 11px 14px;
            color: var(--navy);
            background: var(--yellow);
            border-radius: 11px;
            font-size: 10px;
            font-weight: 900;
            text-transform: uppercase;
        }

        .cart-list { padding: 5px 18px; }
        .cart-item {
            min-height: 145px;
            padding: 17px 0;
            display: grid;
            grid-template-columns: 120px minmax(0,1fr) 155px;
            align-items: center;
            gap: 18px;
            border-bottom: 1px solid var(--border);
        }
        .cart-item:last-child { border-bottom: none; }
        .item-image {
            width: 120px;
            height: 110px;
            object-fit: cover;
            border-radius: 17px 40px 17px 17px;
        }
        .item-details { min-width: 0; }
        .item-details h3 {
            margin-bottom: 8px;
            overflow: hidden;
            font-size: 18px;
            white-space: nowrap;
            text-overflow: ellipsis;
        }
        .item-price { color: var(--muted); font-size: 12px; }
        .item-total { margin-top: 10px; font-size: 14px; font-weight: 900; }
        .item-actions {
            display: flex;
            align-items: center;
            flex-direction: column;
            gap: 10px;
        }
        .quantity-control {
            width: 128px;
            height: 42px;
            padding: 4px;
            display: grid;
            grid-template-columns: 34px 1fr 34px;
            align-items: center;
            background: var(--mint-light);
            border: 1px solid #a8e3d0;
            border-radius: 12px;
        }
        .quantity-form { width: 34px; height: 32px; }
        .quantity-button {
            width: 34px;
            height: 32px;
            color: var(--navy);
            background: var(--white);
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 18px;
            font-weight: 900;
        }
        .quantity-button:hover { color: var(--white); background: var(--mint); }
        .quantity-button:disabled { cursor: not-allowed; opacity: .4; }
        .quantity { text-align: center; font-size: 14px; font-weight: 900; }
        .remove-button {
            padding: 5px 9px;
            color: var(--danger);
            background: transparent;
            border: none;
            cursor: pointer;
            font-size: 11px;
            font-weight: 800;
        }
        .remove-button:hover { text-decoration: underline; }

        .cart-footer {
            padding: 17px 19px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            background: #fffdf8;
            border-top: 1px solid var(--border);
        }
        .add-more { color: var(--mint-dark); font-size: 12px; font-weight: 900; }
        .clear-button {
            padding: 10px 13px;
            color: var(--danger);
            background: #fff0ee;
            border: 1px solid #ffd1ca;
            border-radius: 10px;
            cursor: pointer;
            font-size: 11px;
            font-weight: 900;
        }

        .bill-panel {
            position: sticky;
            top: 108px;
            overflow: hidden;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 25px;
            box-shadow: 0 10px 30px rgba(17,24,39,.08);
        }
        .bill-top { padding: 23px 23px 18px; background: var(--navy); color: var(--white); }
        .bill-top small {
            color: var(--mint);
            font-size: 9px;
            font-weight: 900;
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }
        .bill-top h2 {
            margin-top: 7px;
            font-family: Georgia, "Times New Roman", serif;
            font-size: 26px;
        }
        .bill-body { padding: 22px; }
        .bill-row {
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            gap: 20px;
            color: var(--muted);
            font-size: 13px;
        }
        .bill-row span:last-child { color: var(--navy); font-weight: 800; }
        .bill-row .free { color: var(--mint-dark); }
        .bill-divider { margin: 20px 0; border: none; border-top: 1px dashed #cfd4dc; }
        .bill-total {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 18px;
            font-weight: 900;
        }
        .bill-total strong { color: var(--coral); font-size: 23px; }
        .checkout-button {
            margin-top: 22px;
            padding: 15px;
            display: block;
            color: var(--white);
            background: var(--coral);
            border-radius: 13px;
            text-align: center;
            font-size: 12px;
            font-weight: 900;
            text-transform: uppercase;
            box-shadow: 0 9px 20px rgba(255,102,71,.25);
        }
        .checkout-button:hover { background: var(--coral-dark); }
        .delivery-message {
            margin-top: 14px;
            padding: 12px;
            color: var(--mint-dark);
            background: var(--mint-light);
            border-radius: 11px;
            font-size: 11px;
            font-weight: 700;
            line-height: 1.5;
            text-align: center;
        }

        .empty-cart {
            width: min(650px, 90%);
            margin: 45px auto 80px;
            padding: 65px 30px;
            text-align: center;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 28px;
            box-shadow: 0 14px 35px rgba(17,24,39,.08);
        }
        .empty-icon {
            width: 82px;
            height: 82px;
            margin: 0 auto 20px;
            display: grid;
            place-items: center;
            background: var(--mint-light);
            border-radius: 25px;
            font-size: 38px;
        }
        .empty-cart h2 {
            font-family: Georgia, "Times New Roman", serif;
            font-size: 31px;
        }
        .empty-cart p { margin: 12px 0 24px; color: var(--muted); line-height: 1.6; }
        .browse-button {
            padding: 14px 20px;
            display: inline-block;
            color: var(--white);
            background: var(--coral);
            border-radius: 12px;
            font-size: 12px;
            font-weight: 900;
        }

        @media (max-width: 900px) {
            .cart-layout { grid-template-columns: 1fr; }
            .bill-panel { position: relative; top: auto; }
            .welcome-text { display: none; }
        }
        @media (max-width: 650px) {
            .navbar-wrapper { padding: 9px 4%; }
            .navbar { align-items: flex-start; }
            .navbar-links { justify-content: flex-end; flex-wrap: wrap; }
            .nav-link { display: none; }
            .logo-text { font-size: 20px; }
            .page-header { padding: 27px 22px; align-items: flex-start; flex-direction: column; }
            .cart-layout { width: 92%; }
            .restaurant-strip { grid-template-columns: 62px minmax(0,1fr); }
            .restaurant-image { width: 62px; height: 62px; }
            .view-menu { grid-column: 1 / -1; text-align: center; }
            .cart-item {
                grid-template-columns: 95px minmax(0,1fr);
                min-height: 0;
            }
            .item-image { width: 95px; height: 95px; }
            .item-actions {
                grid-column: 1 / -1;
                align-items: center;
                justify-content: space-between;
                flex-direction: row;
            }
        }
    </style>
</head>

<body>
<div class="navbar-wrapper">
    <header class="navbar">
        <a class="logo" href="<%= contextPath %>/">
            <span class="logo-symbol">C</span>
            <span class="logo-text">Crave<span>Go</span></span>
        </a>

        <nav class="navbar-links">
            <a class="nav-link" href="<%= contextPath %>/">Home</a>
            <a class="nav-link" href="<%= contextPath %>/restaurants">Restaurants</a>

            <% if (loggedInUser != null) { %>
                <span class="welcome-text">
                    Hi, <%= escapeHtml(loggedInUser.getUsername()) %>
                </span>
                <a class="cart-pill" href="<%= contextPath %>/cart">
                    Cart <span><%= totalQuantity %></span>
                </a>
                <a class="logout-button" href="<%= contextPath %>/logout">Logout</a>
            <% } %>
        </nav>
    </header>
</div>

<section class="page-header">
    <div>
        <div class="eyebrow">Your CraveGo basket</div>
        <h1>Your meal, almost ready.</h1>
        <p>Review your dishes and quantities before checkout.</p>
    </div>
    <div class="selection-badge">
        <%= totalQuantity %> <%= totalQuantity == 1 ? "item" : "items" %> selected
    </div>
</section>

<% if (cartItems != null && !cartItems.isEmpty()) { %>
    <main class="cart-layout">
        <section class="cart-panel">
            <% if (restaurant != null) { %>
                <div class="restaurant-strip">
                    <img class="restaurant-image"
                         src="<%= escapeHtml(restaurant.getImagePath()) %>"
                         alt="<%= escapeHtml(restaurant.getName()) %>"
                         onerror="this.src='https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&amp;fit=crop&amp;w=400&amp;q=80'">
                    <div class="restaurant-details">
                        <small>Prepared by</small>
                        <h2><%= escapeHtml(restaurant.getName()) %></h2>
                        <p><%= escapeHtml(restaurant.getAddress()) %></p>
                    </div>
                    <a class="view-menu"
                       href="<%= contextPath %>/menu?restaurantId=<%= restaurant.getRestaurantId() %>">
                        View Menu
                    </a>
                </div>
            <% } %>

            <div class="cart-list">
                <% for (Map.Entry<Menu, Integer> entry : cartItems.entrySet()) {
                    Menu menu = entry.getKey();
                    int quantity = entry.getValue();
                    double itemTotal = menu.getPrice() * quantity;
                %>
                    <article class="cart-item">
                        <img class="item-image"
                             src="<%= escapeHtml(menu.getImagePath()) %>"
                             alt="<%= escapeHtml(menu.getItemName()) %>"
                             onerror="this.src='https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&amp;fit=crop&amp;w=400&amp;q=80'">

                        <div class="item-details">
                            <h3><%= escapeHtml(menu.getItemName()) %></h3>
                            <p class="item-price">
                                ₹<%= String.format("%.2f", menu.getPrice()) %> each
                            </p>
                            <p class="item-total">
                                Item total: ₹<%= String.format("%.2f", itemTotal) %>
                            </p>
                        </div>

                        <div class="item-actions">
                            <div class="quantity-control">
                                <form class="quantity-form" action="<%= contextPath %>/cart" method="post">
                                    <input type="hidden" name="action" value="decrease">
                                    <input type="hidden" name="menuId" value="<%= menu.getMenuId() %>">
                                    <button class="quantity-button" type="submit" aria-label="Decrease quantity">−</button>
                                </form>

                                <span class="quantity"><%= quantity %></span>

                                <form class="quantity-form" action="<%= contextPath %>/cart" method="post">
                                    <input type="hidden" name="action" value="increase">
                                    <input type="hidden" name="menuId" value="<%= menu.getMenuId() %>">
                                    <button class="quantity-button" type="submit"
                                            aria-label="Increase quantity"
                                            <%= quantity >= 10 ? "disabled" : "" %>>+</button>
                                </form>
                            </div>

                            <form action="<%= contextPath %>/cart" method="post">
                                <input type="hidden" name="action" value="remove">
                                <input type="hidden" name="menuId" value="<%= menu.getMenuId() %>">
                                <button class="remove-button" type="submit">Remove item</button>
                            </form>
                        </div>
                    </article>
                <% } %>
            </div>

            <div class="cart-footer">
                <% if (restaurant != null) { %>
                    <a class="add-more"
                       href="<%= contextPath %>/menu?restaurantId=<%= restaurant.getRestaurantId() %>">
                        + Add more items
                    </a>
                <% } else { %>
                    <a class="add-more" href="<%= contextPath %>/restaurants">+ Add more items</a>
                <% } %>

                <form action="<%= contextPath %>/cart" method="post"
                      onsubmit="return confirm('Remove all items from your cart?');">
                    <input type="hidden" name="action" value="clear">
                    <button class="clear-button" type="submit">Clear Cart</button>
                </form>
            </div>
        </section>

        <aside class="bill-panel">
            <div class="bill-top">
                <small>Order summary</small>
                <h2>Bill details</h2>
            </div>

            <div class="bill-body">
                <div class="bill-row">
                    <span>Item total</span>
                    <span>₹<%= String.format("%.2f", subtotal) %></span>
                </div>
                <div class="bill-row">
                    <span>Delivery fee</span>
                    <% if (deliveryFee == 0.0) { %>
                        <span class="free">FREE</span>
                    <% } else { %>
                        <span>₹<%= String.format("%.2f", deliveryFee) %></span>
                    <% } %>
                </div>
                <div class="bill-row">
                    <span>Platform fee</span>
                    <span>₹<%= String.format("%.2f", platformFee) %></span>
                </div>

                <hr class="bill-divider">

                <div class="bill-total">
                    <span>To Pay</span>
                    <strong>₹<%= String.format("%.2f", totalAmount) %></strong>
                </div>

                <a class="checkout-button" href="<%= contextPath %>/checkout">
                    Proceed to Checkout
                </a>

                <% if (subtotal < 499.0) { %>
                    <div class="delivery-message">
                        Add ₹<%= String.format("%.2f", 499.0 - subtotal) %> more to receive free delivery.
                    </div>
                <% } else { %>
                    <div class="delivery-message">You have received free delivery on this order.</div>
                <% } %>
            </div>
        </aside>
    </main>
<% } else { %>
    <section class="empty-cart">
        <div class="empty-icon">🛒</div>
        <h2>Your cart is waiting.</h2>
        <p>You have not added any dishes yet. Explore Bengaluru restaurants and build your meal.</p>
        <a class="browse-button" href="<%= contextPath %>/restaurants">Explore Restaurants</a>
    </section>
<% } %>
</body>
</html>
