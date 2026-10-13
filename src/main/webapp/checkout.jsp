<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="java.util.Map" %>
<%@ page import="com.cravego.model.Menu" %>
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

    User loggedInUser =
            (User) session.getAttribute(
                    "loggedInUser"
            );

    Restaurant restaurant =
            (Restaurant) request.getAttribute(
                    "restaurant"
            );

    Map<Menu, Integer> cartItems =
            (Map<Menu, Integer>)
            request.getAttribute("cartItems");

    Double subtotal =
            (Double) request.getAttribute(
                    "subtotal"
            );

    Double deliveryFee =
            (Double) request.getAttribute(
                    "deliveryFee"
            );

    Double platformFee =
            (Double) request.getAttribute(
                    "platformFee"
            );

    Double totalAmount =
            (Double) request.getAttribute(
                    "totalAmount"
            );

    Integer totalQuantity =
            (Integer) request.getAttribute(
                    "totalQuantity"
            );

    String errorMessage =
            (String) request.getAttribute(
                    "errorMessage"
            );

    if (loggedInUser == null) {

        response.sendRedirect(
                contextPath + "/login"
        );

        return;
    }

    subtotal =
            subtotal == null
            ? 0.0
            : subtotal;

    deliveryFee =
            deliveryFee == null
            ? 0.0
            : deliveryFee;

    platformFee =
            platformFee == null
            ? 0.0
            : platformFee;

    totalAmount =
            totalAmount == null
            ? 0.0
            : totalAmount;

    totalQuantity =
            totalQuantity == null
            ? 0
            : totalQuantity;
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Checkout | CraveGo</title>

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
            color: var(--navy);
            background:
                radial-gradient(
                    circle at top left,
                    rgba(255, 200, 87, 0.14),
                    transparent 25%
                ),
                var(--cream);
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
            padding: 13px 5%;
            background-color: rgba(255, 250, 242, 0.92);
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
            font-size: 13px;
            font-weight: 800;
        }

        .nav-link:hover {
            color: var(--coral);
        }

        .logout-button {
            padding: 11px 15px;
            color: var(--white);
            background-color: var(--navy);
            border-radius: 11px;
            font-size: 12px;
            font-weight: 900;
        }

        /* =========================
           HEADER
        ========================= */

        .checkout-header {
            width: min(1240px, 90%);
            margin: 12px auto 25px;
            padding: 32px 38px;

            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 25px;

            color: var(--white);
            background-color: var(--navy);
            border-radius: 27px;
            box-shadow: 0 18px 38px rgba(17, 24, 39, 0.16);
        }

        .header-label {
            margin-bottom: 8px;
            color: var(--mint);
            font-size: 10px;
            font-weight: 900;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        .checkout-header h1 {
            font-family: Georgia, "Times New Roman", serif;
            font-size: clamp(34px, 5vw, 52px);
            line-height: 1;
        }

        .checkout-header p {
            margin-top: 10px;
            color: #cbd2de;
            font-size: 13px;
        }

        .secure-badge {
            padding: 13px 17px;
            color: var(--navy);
            background-color: var(--yellow);
            border-radius: 13px;
            font-size: 12px;
            font-weight: 900;
            white-space: nowrap;
        }

        /* =========================
           ERROR MESSAGE
        ========================= */

        .error-message {
            width: min(1240px, 90%);
            margin: 0 auto 18px;
            padding: 14px 18px;

            color: var(--danger);
            background-color: var(--danger-light);
            border: 1px solid #ffc9c1;
            border-radius: 13px;

            font-size: 13px;
            font-weight: 800;
        }

        /* =========================
           LAYOUT
        ========================= */

        .checkout-layout {
            width: min(1240px, 90%);
            margin: 0 auto 60px;

            display: grid;
            grid-template-columns: minmax(0, 1fr) 360px;
            align-items: start;
            gap: 24px;
        }

        .checkout-left {
            display: grid;
            gap: 20px;
        }

        .checkout-card {
            padding: 25px;
            background-color: var(--white);
            border: 1px solid var(--border);
            border-radius: 24px;
            box-shadow: 0 10px 30px rgba(17, 24, 39, 0.07);
        }

        .section-heading {
            margin-bottom: 19px;
            display: flex;
            align-items: center;
            gap: 13px;
        }

        .step-number {
            width: 35px;
            height: 35px;

            display: grid;
            place-items: center;

            color: var(--white);
            background-color: var(--coral);
            border-radius: 11px;

            font-size: 13px;
            font-weight: 900;
        }

        .section-heading h2 {
            font-family: Georgia, "Times New Roman", serif;
            font-size: 24px;
        }

        .section-heading p {
            margin-top: 3px;
            color: var(--muted);
            font-size: 11px;
        }

        /* =========================
           DELIVERY DETAILS
        ========================= */

        .delivery-profile {
            padding: 18px;

            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;

            background-color: #fffdf8;
            border: 1px solid var(--border);
            border-radius: 17px;
        }

        .profile-field {
            min-width: 0;
        }

        .profile-field.full-width {
            grid-column: 1 / -1;
        }

        .field-label {
            display: block;
            margin-bottom: 6px;
            color: var(--muted);
            font-size: 9px;
            font-weight: 900;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        .field-value {
            overflow-wrap: anywhere;
            font-size: 13px;
            font-weight: 800;
            line-height: 1.5;
        }

        .delivery-note {
            margin-top: 14px;
            padding: 12px 14px;
            color: var(--mint-dark);
            background-color: var(--mint-light);
            border-radius: 11px;
            font-size: 11px;
            font-weight: 700;
            line-height: 1.5;
        }

        /* =========================
           PAYMENT
        ========================= */

        .payment-options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        .payment-option {
            position: relative;
            cursor: pointer;
        }

        .payment-option input {
            position: absolute;
            opacity: 0;
            pointer-events: none;
        }

        .payment-content {
            min-height: 135px;
            padding: 18px;

            display: flex;
            flex-direction: column;
            justify-content: space-between;

            background-color: #fffdf8;
            border: 2px solid var(--border);
            border-radius: 17px;

            transition:
                border-color 0.2s ease,
                background-color 0.2s ease,
                transform 0.2s ease;
        }

        .payment-option:hover .payment-content {
            transform: translateY(-3px);
        }

        .payment-option input:checked
        + .payment-content {
            background-color: var(--mint-light);
            border-color: var(--mint);
        }

        .payment-icon {
            width: 42px;
            height: 42px;

            display: grid;
            place-items: center;

            background-color: var(--white);
            border-radius: 12px;
            font-size: 22px;
        }

        .payment-title {
            margin-top: 14px;
            font-size: 14px;
            font-weight: 900;
        }

        .payment-description {
            margin-top: 5px;
            color: var(--muted);
            font-size: 10px;
            line-height: 1.5;
        }

        .payment-check {
            position: absolute;
            top: 13px;
            right: 13px;

            width: 22px;
            height: 22px;

            display: grid;
            place-items: center;

            color: transparent;
            background-color: var(--white);
            border: 2px solid #cfd4dc;
            border-radius: 50%;

            font-size: 12px;
            font-weight: 900;
        }

        .payment-option input:checked
        ~ .payment-check {
            color: var(--white);
            background-color: var(--mint);
            border-color: var(--mint);
        }

        /* =========================
           RESTAURANT ITEMS
        ========================= */

        .restaurant-summary {
            margin-bottom: 15px;
            padding: 14px;

            display: grid;
            grid-template-columns: 55px minmax(0, 1fr);
            align-items: center;
            gap: 13px;

            color: var(--white);
            background-color: var(--navy);
            border-radius: 15px;
        }

        .restaurant-summary img {
            width: 55px;
            height: 55px;
            object-fit: cover;
            border: 2px solid var(--yellow);
            border-radius: 13px;
        }

        .restaurant-summary h3 {
            overflow: hidden;
            font-size: 15px;
            white-space: nowrap;
            text-overflow: ellipsis;
        }

        .restaurant-summary p {
            margin-top: 5px;
            color: #b9c1ce;
            font-size: 10px;
        }

        .checkout-items {
            display: grid;
            gap: 11px;
        }

        .checkout-item {
            padding: 11px;

            display: grid;
            grid-template-columns: 55px minmax(0, 1fr) auto;
            align-items: center;
            gap: 12px;

            background-color: #fffdf8;
            border: 1px solid var(--border);
            border-radius: 14px;
        }

        .checkout-item img {
            width: 55px;
            height: 55px;
            object-fit: cover;
            border-radius: 12px;
        }

        .checkout-item h4 {
            overflow: hidden;
            font-size: 12px;
            white-space: nowrap;
            text-overflow: ellipsis;
        }

        .checkout-item p {
            margin-top: 5px;
            color: var(--muted);
            font-size: 10px;
        }

        .checkout-item-total {
            font-size: 12px;
            font-weight: 900;
            white-space: nowrap;
        }

        /* =========================
           BILL
        ========================= */

        .bill-card {
            position: sticky;
            top: 108px;
            overflow: hidden;

            background-color: var(--white);
            border: 1px solid var(--border);
            border-radius: 25px;
            box-shadow: 0 10px 30px rgba(17, 24, 39, 0.08);
        }

        .bill-header {
            padding: 23px;
            color: var(--white);
            background-color: var(--navy);
        }

        .bill-header small {
            color: var(--mint);
            font-size: 9px;
            font-weight: 900;
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }

        .bill-header h2 {
            margin-top: 7px;
            font-family: Georgia, "Times New Roman", serif;
            font-size: 26px;
        }

        .bill-body {
            padding: 22px;
        }

        .bill-row {
            margin-bottom: 16px;

            display: flex;
            justify-content: space-between;
            gap: 20px;

            color: var(--muted);
            font-size: 13px;
        }

        .bill-row span:last-child {
            color: var(--navy);
            font-weight: 800;
        }

        .bill-row .free-delivery {
            color: var(--mint-dark);
        }

        .bill-divider {
            margin: 20px 0;
            border: none;
            border-top: 1px dashed #cfd4dc;
        }

        .bill-total {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 18px;
            font-weight: 900;
        }

        .bill-total strong {
            color: var(--coral);
            font-size: 23px;
        }

        .place-order-button {
            width: 100%;
            margin-top: 22px;
            padding: 16px;

            color: var(--white);
            background-color: var(--coral);
            border: none;
            border-radius: 13px;
            cursor: pointer;

            font-size: 12px;
            font-weight: 900;
            text-transform: uppercase;

            box-shadow:
                0 9px 20px
                rgba(255, 102, 71, 0.25);
        }

        .place-order-button:hover {
            background-color: var(--coral-dark);
        }

        .terms {
            margin-top: 13px;
            color: var(--muted);
            font-size: 9px;
            line-height: 1.5;
            text-align: center;
        }

        .back-cart {
            margin-top: 12px;
            padding: 11px;
            display: block;
            color: var(--navy);
            background-color: var(--mint-light);
            border-radius: 11px;
            font-size: 11px;
            font-weight: 900;
            text-align: center;
        }

        /* =========================
           RESPONSIVE
        ========================= */

        @media (max-width: 900px) {

            .checkout-layout {
                grid-template-columns: 1fr;
            }

            .bill-card {
                position: relative;
                top: auto;
            }

            .welcome-text {
                display: none;
            }
        }

        @media (max-width: 650px) {

            .navbar-wrapper {
                padding: 9px 4%;
            }

            .navbar {
                align-items: flex-start;
            }

            .navbar-links {
                justify-content: flex-end;
                flex-wrap: wrap;
            }

            .nav-link,
            .logout-button {
                display: none;
            }

            .logo-text {
                font-size: 20px;
            }

            .checkout-header {
                padding: 27px 22px;
                align-items: flex-start;
                flex-direction: column;
            }

            .checkout-card {
                padding: 19px;
            }

            .delivery-profile,
            .payment-options {
                grid-template-columns: 1fr;
            }

            .profile-field.full-width {
                grid-column: auto;
            }
        }

    </style>

</head>

<body>

<div class="navbar-wrapper">

    <header class="navbar">

        <a class="logo"
           href="<%= contextPath %>/">

            <span class="logo-symbol">
                C
            </span>

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

            <span class="welcome-text">
                Hi, <%= escapeHtml(
                        loggedInUser.getUsername()
                ) %>
            </span>

            <a class="logout-button"
               href="<%= contextPath %>/logout">
                Logout
            </a>

        </nav>

    </header>

</div>

<section class="checkout-header">

    <div>

        <div class="header-label">
            Final checkout
        </div>

        <h1>
            One step from delicious.
        </h1>

        <p>
            Confirm your delivery details and payment method.
        </p>

    </div>

    <div class="secure-badge">
        ✓ Secure checkout
    </div>

</section>

<%
    if (errorMessage != null
            && !errorMessage.isBlank()) {
%>

    <div class="error-message">
        <%= escapeHtml(errorMessage) %>
    </div>

<%
    }
%>

<form action="<%= contextPath %>/checkout"
      method="post">

    <main class="checkout-layout">

        <div class="checkout-left">

            <!-- DELIVERY DETAILS -->

            <section class="checkout-card">

                <div class="section-heading">

                    <span class="step-number">
                        1
                    </span>

                    <div>

                        <h2>Delivery details</h2>

                        <p>
                            Your order will be delivered here.
                        </p>

                    </div>

                </div>

                <div class="delivery-profile">

                    <div class="profile-field">

                        <span class="field-label">
                            Customer name
                        </span>

                        <span class="field-value">
                            <%= escapeHtml(
                                    loggedInUser.getUsername()
                            ) %>
                        </span>

                    </div>

                    <div class="profile-field">

                        <span class="field-label">
                            Phone number
                        </span>

                        <span class="field-value">
                            <%= escapeHtml(
                                    loggedInUser.getPhone()
                            ) %>
                        </span>

                    </div>

                    <div class="profile-field">

                        <span class="field-label">
                            Email
                        </span>

                        <span class="field-value">
                            <%= escapeHtml(
                                    loggedInUser.getEmail()
                            ) %>
                        </span>

                    </div>

                    <div class="profile-field full-width">

                        <span class="field-label">
                            Delivery address
                        </span>

                        <span class="field-value">
                            <%= escapeHtml(
                                    loggedInUser.getAddress()
                            ) %>
                        </span>

                    </div>

                </div>

                <div class="delivery-note">
                    Please ensure your phone number and delivery
                    address are correct before placing the order.
                </div>

            </section>

            <!-- PAYMENT METHOD -->

            <section class="checkout-card">

                <div class="section-heading">

                    <span class="step-number">
                        2
                    </span>

                    <div>

                        <h2>Payment method</h2>

                        <p>
                            Select how you want to pay.
                        </p>

                    </div>

                </div>

                <div class="payment-options">

                    <label class="payment-option">

                        <input type="radio"
                               name="paymentMode"
                               value="COD"
                               checked
                               required>

                        <span class="payment-content">

                            <span class="payment-icon">
                                💵
                            </span>

                            <span>

                                <span class="payment-title">
                                    Cash on Delivery
                                </span>

                                <span class="payment-description">
                                    Pay when your food arrives.
                                </span>

                            </span>

                        </span>

                        <span class="payment-check">
                            ✓
                        </span>

                    </label>

                    <label class="payment-option">

                        <input type="radio"
                               name="paymentMode"
                               value="UPI"
                               required>

                        <span class="payment-content">

                            <span class="payment-icon">
                                📱
                            </span>

                            <span>

                                <span class="payment-title">
                                    UPI Payment
                                </span>

                                <span class="payment-description">
                                    Select UPI for the first-version
                                    simulated payment flow.
                                </span>

                            </span>

                        </span>

                        <span class="payment-check">
                            ✓
                        </span>

                    </label>

                </div>

            </section>

            <!-- ORDER ITEMS -->

            <section class="checkout-card">

                <div class="section-heading">

                    <span class="step-number">
                        3
                    </span>

                    <div>

                        <h2>Review your order</h2>

                        <p>
                            <%= totalQuantity %>
                            <%= totalQuantity == 1
                                    ? "item"
                                    : "items" %>
                            selected
                        </p>

                    </div>

                </div>

                <% if (restaurant != null) { %>

                    <div class="restaurant-summary">

                        <img
                            src="<%= escapeHtml(
                                    restaurant.getImagePath()
                            ) %>"
                            alt="<%= escapeHtml(
                                    restaurant.getName()
                            ) %>"
                            onerror="this.src='https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&amp;fit=crop&amp;w=400&amp;q=80'">

                        <div>

                            <h3>
                                <%= escapeHtml(
                                        restaurant.getName()
                                ) %>
                            </h3>

                            <p>
                                Estimated delivery:
                                <%= restaurant.getDeliveryTime() %>
                                minutes
                            </p>

                        </div>

                    </div>

                <% } %>

                <div class="checkout-items">

                    <%
                        if (cartItems != null) {

                            for (
                                Map.Entry<Menu, Integer> entry
                                    : cartItems.entrySet()
                            ) {

                                Menu menu =
                                        entry.getKey();

                                int quantity =
                                        entry.getValue();

                                double itemTotal =
                                        menu.getPrice()
                                        * quantity;
                    %>

                        <div class="checkout-item">

                            <img
                                src="<%= escapeHtml(
                                        menu.getImagePath()
                                ) %>"
                                alt="<%= escapeHtml(
                                        menu.getItemName()
                                ) %>"
                                onerror="this.src='https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&amp;fit=crop&amp;w=300&amp;q=80'">

                            <div>

                                <h4>
                                    <%= escapeHtml(
                                            menu.getItemName()
                                    ) %>
                                </h4>

                                <p>
                                    ₹<%= String.format(
                                            "%.2f",
                                            menu.getPrice()
                                    ) %>
                                    × <%= quantity %>
                                </p>

                            </div>

                            <span class="checkout-item-total">
                                ₹<%= String.format(
                                        "%.2f",
                                        itemTotal
                                ) %>
                            </span>

                        </div>

                    <%
                            }
                        }
                    %>

                </div>

            </section>

        </div>

        <!-- BILL DETAILS -->

        <aside class="bill-card">

            <div class="bill-header">

                <small>
                    Payment summary
                </small>

                <h2>
                    Bill details
                </h2>

            </div>

            <div class="bill-body">

                <div class="bill-row">

                    <span>
                        Item total
                    </span>

                    <span>
                        ₹<%= String.format(
                                "%.2f",
                                subtotal
                        ) %>
                    </span>

                </div>

                <div class="bill-row">

                    <span>
                        Delivery fee
                    </span>

                    <% if (deliveryFee == 0.0) { %>

                        <span class="free-delivery">
                            FREE
                        </span>

                    <% } else { %>

                        <span>
                            ₹<%= String.format(
                                    "%.2f",
                                    deliveryFee
                            ) %>
                        </span>

                    <% } %>

                </div>

                <div class="bill-row">

                    <span>
                        Platform fee
                    </span>

                    <span>
                        ₹<%= String.format(
                                "%.2f",
                                platformFee
                        ) %>
                    </span>

                </div>

                <hr class="bill-divider">

                <div class="bill-total">

                    <span>
                        To Pay
                    </span>

                    <strong>
                        ₹<%= String.format(
                                "%.2f",
                                totalAmount
                        ) %>
                    </strong>

                </div>

                <button class="place-order-button"
                        type="submit">

                    Place Order •
                    ₹<%= String.format(
                            "%.2f",
                            totalAmount
                    ) %>

                </button>

                <p class="terms">
                    By placing this order, you confirm your
                    delivery details and payment selection.
                </p>

                <a class="back-cart"
                   href="<%= contextPath %>/cart">

                    ← Return to cart

                </a>

            </div>

        </aside>

    </main>

</form>

</body>

</html>