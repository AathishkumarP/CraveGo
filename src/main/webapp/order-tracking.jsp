<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.cravego.model.Order" %>
<%@ page import="com.cravego.model.OrderItem" %>
<%@ page import="com.cravego.model.Restaurant" %>

<%!
    private int getTrackingStep(String status) {

        if (status == null) {
            return 1;
        }

        switch (status.toUpperCase()) {

            case "PREPARING":
                return 2;

            case "PICKED_UP":
                return 3;

            case "ON_THE_WAY":
                return 4;

            case "DELIVERED":
                return 5;

            case "CANCELLED":
                return 0;

            case "PLACED":
            default:
                return 1;
        }
    }

    private String getFriendlyStatus(String status) {

        if (status == null) {
            return "Order placed";
        }

        switch (status.toUpperCase()) {

            case "PREPARING":
                return "Your food is being prepared";

            case "PICKED_UP":
                return "Delivery partner picked up your order";

            case "ON_THE_WAY":
                return "Your order is on the way";

            case "DELIVERED":
                return "Your order has been delivered";

            case "CANCELLED":
                return "Your order was cancelled";

            case "PLACED":
            default:
                return "Your order has been placed";
        }
    }
%>

<%
    String contextPath = request.getContextPath();

    Order order =
            (Order) request.getAttribute("order");

    Restaurant restaurant =
            (Restaurant) request.getAttribute("restaurant");

    List<OrderItem> orderItems =
            (List<OrderItem>) request.getAttribute("orderItems");

    if (order == null) {
        response.sendRedirect(contextPath + "/restaurants");
        return;
    }

    String status = order.getStatus();
    int currentStep = getTrackingStep(status);

    boolean cancelled =
            status != null
            && "CANCELLED".equalsIgnoreCase(status);

    boolean delivered =
            status != null
            && "DELIVERED".equalsIgnoreCase(status);

    int progressPercentage = 0;

    if (currentStep == 2) {
        progressPercentage = 25;
    } else if (currentStep == 3) {
        progressPercentage = 50;
    } else if (currentStep == 4) {
        progressPercentage = 75;
    } else if (currentStep == 5) {
        progressPercentage = 100;
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <% if (!delivered && !cancelled) { %>
        <meta http-equiv="refresh" content="15">
    <% } %>

    <title>
        Track Order #<%= order.getOrderId() %> | CraveGo
    </title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --navy: #111827;
            --coral: #ff6647;
            --mint: #29b783;
            --cream: #fffaf2;
            --yellow: #ffc857;
            --white: #ffffff;
            --grey: #667085;
            --light-grey: #e8eaf0;
            --danger: #dc3545;
        }

        body {
            min-height: 100vh;
            font-family: Arial, Helvetica, sans-serif;
            color: var(--navy);
            background:
                radial-gradient(circle at top left,
                    rgba(255, 200, 87, 0.18),
                    transparent 34%),
                radial-gradient(circle at bottom right,
                    rgba(41, 183, 131, 0.13),
                    transparent 36%),
                var(--cream);
        }

        .navbar {
            min-height: 76px;
            padding: 15px 7%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: rgba(255, 255, 255, 0.92);
            border-bottom: 1px solid rgba(17, 24, 39, 0.08);
            backdrop-filter: blur(12px);
        }

        .logo {
            color: var(--coral);
            font-family: Georgia, serif;
            font-size: 30px;
            font-weight: 800;
            text-decoration: none;
        }

        .navbar-link {
            padding: 11px 18px;
            color: var(--navy);
            border: 1px solid var(--light-grey);
            border-radius: 12px;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            transition: 0.2s ease;
        }

        .navbar-link:hover {
            color: var(--white);
            background: var(--navy);
            border-color: var(--navy);
        }

        .page-container {
            width: min(1120px, 90%);
            margin: 42px auto 65px;
        }

        .page-heading {
            margin-bottom: 28px;
        }

        .eyebrow {
            margin-bottom: 8px;
            color: var(--coral);
            font-size: 13px;
            font-weight: 800;
            letter-spacing: 1.8px;
            text-transform: uppercase;
        }

        .page-heading h1 {
            margin-bottom: 8px;
            font-family: Georgia, serif;
            font-size: clamp(32px, 5vw, 48px);
        }

        .page-heading p {
            color: var(--grey);
            line-height: 1.6;
        }

        .tracking-layout {
            display: grid;
            grid-template-columns: minmax(0, 1.65fr) minmax(280px, 0.75fr);
            gap: 25px;
            align-items: start;
        }

        .tracking-card,
        .summary-card {
            background: rgba(255, 255, 255, 0.96);
            border: 1px solid rgba(17, 24, 39, 0.08);
            border-radius: 24px;
            box-shadow: 0 16px 45px rgba(17, 24, 39, 0.08);
        }

        .tracking-card {
            padding: 32px;
        }

        .status-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 20px;
            margin-bottom: 30px;
        }

        .status-header h2 {
            margin-bottom: 8px;
            font-family: Georgia, serif;
            font-size: 27px;
        }

        .status-header p {
            color: var(--grey);
            line-height: 1.5;
        }

        .live-badge {
            flex-shrink: 0;
            padding: 9px 14px;
            color: var(--mint);
            background: rgba(41, 183, 131, 0.12);
            border-radius: 999px;
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
        }

        .live-badge::before {
            content: "";
            width: 8px;
            height: 8px;
            display: inline-block;
            margin-right: 7px;
            background: var(--mint);
            border-radius: 50%;
            animation: pulse 1.4s infinite;
        }

        .cancelled-badge {
            color: var(--danger);
            background: rgba(220, 53, 69, 0.1);
        }

        .cancelled-badge::before {
            background: var(--danger);
            animation: none;
        }

        .delivered-badge {
            color: var(--white);
            background: var(--mint);
        }

        .delivered-badge::before {
            background: var(--white);
            animation: none;
        }

        @keyframes pulse {

            0% {
                box-shadow: 0 0 0 0 rgba(41, 183, 131, 0.45);
            }

            70% {
                box-shadow: 0 0 0 8px rgba(41, 183, 131, 0);
            }

            100% {
                box-shadow: 0 0 0 0 rgba(41, 183, 131, 0);
            }
        }

        .road-area {
            position: relative;
            margin: 35px 5px 45px;
            padding-top: 45px;
        }

        .scooter {
            position: absolute;
            top: -9px;
            left: calc(<%= progressPercentage %>% - 24px);
            z-index: 4;
            font-size: 43px;
            filter: drop-shadow(0 6px 6px rgba(17, 24, 39, 0.2));
            transform: scaleX(-1);
            transition: left 1.2s ease;
            animation: scooterBounce 1.1s ease-in-out infinite;
        }

        @keyframes scooterBounce {

            0%, 100% {
                margin-top: 0;
            }

            50% {
                margin-top: -5px;
            }
        }

        .road {
            position: relative;
            height: 12px;
            overflow: hidden;
            background: var(--light-grey);
            border-radius: 50px;
        }

        .road-progress {
            width: <%= progressPercentage %>%;
            height: 100%;
            background: linear-gradient(
                90deg,
                var(--coral),
                var(--yellow),
                var(--mint)
            );
            border-radius: 50px;
            transition: width 1.2s ease;
        }

        .road-lines {
            position: absolute;
            top: 4px;
            left: 0;
            width: 100%;
            height: 4px;
            opacity: 0.8;
            background: repeating-linear-gradient(
                90deg,
                transparent 0,
                transparent 18px,
                rgba(255, 255, 255, 0.9) 18px,
                rgba(255, 255, 255, 0.9) 35px
            );
        }

        .tracking-steps {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 12px;
        }

        .step {
            position: relative;
            text-align: center;
        }

        .step-circle {
            width: 43px;
            height: 43px;
            margin: 0 auto 11px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #98a2b3;
            background: #f2f4f7;
            border: 2px solid var(--light-grey);
            border-radius: 50%;
            font-size: 17px;
            font-weight: 800;
        }

        .step.completed .step-circle,
        .step.active .step-circle {
            color: var(--white);
            background: var(--mint);
            border-color: var(--mint);
        }

        .step.active .step-circle {
            box-shadow: 0 0 0 7px rgba(41, 183, 131, 0.14);
        }

        .step h3 {
            margin-bottom: 4px;
            font-size: 13px;
        }

        .step p {
            color: var(--grey);
            font-size: 11px;
            line-height: 1.4;
        }

        .cancelled-message {
            padding: 26px;
            color: var(--danger);
            background: rgba(220, 53, 69, 0.08);
            border: 1px solid rgba(220, 53, 69, 0.2);
            border-radius: 18px;
            text-align: center;
        }

        .cancelled-message h3 {
            margin-bottom: 8px;
            font-family: Georgia, serif;
            font-size: 23px;
        }

        .refresh-note {
            margin-top: 30px;
            padding: 14px 17px;
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--grey);
            background: #f8fafc;
            border-radius: 13px;
            font-size: 13px;
            line-height: 1.5;
        }

        .refresh-icon {
            display: inline-block;
            font-size: 18px;
            animation: rotate 2s linear infinite;
        }

        @keyframes rotate {
            to {
                transform: rotate(360deg);
            }
        }

        .summary-card {
            position: sticky;
            top: 25px;
            overflow: hidden;
        }

        .restaurant-cover {
            height: 155px;
            position: relative;
            background: var(--navy);
        }

        .restaurant-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .restaurant-cover::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(
                to top,
                rgba(17, 24, 39, 0.78),
                transparent
            );
        }

        .restaurant-name {
            position: absolute;
            left: 20px;
            right: 20px;
            bottom: 17px;
            z-index: 2;
            color: var(--white);
            font-family: Georgia, serif;
            font-size: 22px;
        }

        .summary-content {
            padding: 23px;
        }

        .order-number {
            margin-bottom: 20px;
            padding-bottom: 17px;
            border-bottom: 1px dashed #d8dce5;
        }

        .order-number span {
            display: block;
            margin-bottom: 5px;
            color: var(--grey);
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .order-number strong {
            font-size: 21px;
        }

        .detail-row {
            margin-bottom: 14px;
            display: flex;
            justify-content: space-between;
            gap: 15px;
            font-size: 14px;
        }

        .detail-row span {
            color: var(--grey);
        }

        .detail-row strong {
            text-align: right;
        }

        .total-row {
            margin-top: 18px;
            padding-top: 18px;
            border-top: 1px solid var(--light-grey);
            font-size: 18px;
        }

        .total-row strong {
            color: var(--coral);
        }

        .home-button {
            width: 100%;
            margin-top: 20px;
            padding: 14px;
            display: block;
            color: var(--white);
            background: var(--navy);
            border-radius: 13px;
            font-size: 14px;
            font-weight: 800;
            text-align: center;
            text-decoration: none;
            transition: 0.2s ease;
        }

        .home-button:hover {
            background: var(--coral);
            transform: translateY(-2px);
        }

        @media (max-width: 850px) {

            .tracking-layout {
                grid-template-columns: 1fr;
            }

            .summary-card {
                position: static;
            }
        }

        @media (max-width: 620px) {

            .navbar {
                padding: 14px 5%;
            }

            .tracking-card {
                padding: 24px 16px;
            }

            .status-header {
                flex-direction: column;
            }

            .tracking-steps {
                grid-template-columns: 1fr;
                gap: 17px;
            }

            .step {
                display: grid;
                grid-template-columns: 48px 1fr;
                column-gap: 13px;
                text-align: left;
            }

            .step-circle {
                grid-row: 1 / 3;
                margin: 0;
            }

            .step h3 {
                align-self: end;
            }

            .road-area {
                display: none;
            }
        }

    </style>

</head>

<body>

<header class="navbar">

    <a class="logo" href="<%= contextPath %>/">
        CraveGo
    </a>

    <a class="navbar-link"
       href="<%= contextPath %>/restaurants">
        Explore Restaurants
    </a>

</header>

<main class="page-container">

    <section class="page-heading">

        <p class="eyebrow">Live delivery journey</p>

        <h1>Track your order</h1>

        <p>
            Follow your food from the restaurant kitchen
            all the way to your doorstep.
        </p>

    </section>

    <div class="tracking-layout">

        <section class="tracking-card">

            <div class="status-header">

                <div>

                    <h2>
                        <%= getFriendlyStatus(status) %>
                    </h2>

                    <p>
                        <% if (delivered) { %>
                            We hope you enjoy your delicious meal.
                        <% } else if (cancelled) { %>
                            Please contact us if you need any assistance.
                        <% } else { %>
                            This page automatically checks for new updates.
                        <% } %>
                    </p>

                </div>

                <% if (cancelled) { %>

                    <span class="live-badge cancelled-badge">
                        Cancelled
                    </span>

                <% } else if (delivered) { %>

                    <span class="live-badge delivered-badge">
                        Delivered
                    </span>

                <% } else { %>

                    <span class="live-badge">
                        Live tracking
                    </span>

                <% } %>

            </div>

            <% if (cancelled) { %>

                <div class="cancelled-message">

                    <h3>Order cancelled</h3>

                    <p>
                        This delivery journey has been stopped.
                    </p>

                </div>

            <% } else { %>

                <div class="road-area">

                    <div class="scooter">🛵</div>

                    <div class="road">

                        <div class="road-progress"></div>

                        <div class="road-lines"></div>

                    </div>

                </div>

                <div class="tracking-steps">

                    <div class="step
                         <%= currentStep > 1
                                 ? "completed"
                                 : currentStep == 1
                                 ? "active" : "" %>">

                        <div class="step-circle">✓</div>

                        <h3>Order placed</h3>

                        <p>Restaurant received your order</p>

                    </div>

                    <div class="step
                         <%= currentStep > 2
                                 ? "completed"
                                 : currentStep == 2
                                 ? "active" : "" %>">

                        <div class="step-circle">2</div>

                        <h3>Preparing</h3>

                        <p>Your meal is being prepared</p>

                    </div>

                    <div class="step
                         <%= currentStep > 3
                                 ? "completed"
                                 : currentStep == 3
                                 ? "active" : "" %>">

                        <div class="step-circle">3</div>

                        <h3>Picked up</h3>

                        <p>Delivery partner collected it</p>

                    </div>

                    <div class="step
                         <%= currentStep > 4
                                 ? "completed"
                                 : currentStep == 4
                                 ? "active" : "" %>">

                        <div class="step-circle">4</div>

                        <h3>On the way</h3>

                        <p>Your food is travelling to you</p>

                    </div>

                    <div class="step
                         <%= currentStep == 5
                                 ? "completed active" : "" %>">

                        <div class="step-circle">5</div>

                        <h3>Delivered</h3>

                        <p>Your order reached the destination</p>

                    </div>

                </div>

                <% if (!delivered) { %>

                    <div class="refresh-note">

                        <span class="refresh-icon">↻</span>

                        <span>
                            Tracking information refreshes automatically
                            every 15 seconds.
                        </span>

                    </div>

                <% } %>

            <% } %>

        </section>

        <aside class="summary-card">

            <% if (restaurant != null) { %>

                <div class="restaurant-cover">

                    <img src="<%= restaurant.getImagePath() %>"
                         alt="<%= restaurant.getName() %>">

                    <h2 class="restaurant-name">
                        <%= restaurant.getName() %>
                    </h2>

                </div>

            <% } %>

            <div class="summary-content">

                <div class="order-number">

                    <span>Order number</span>

                    <strong>
                        #CG<%= order.getOrderId() %>
                    </strong>

                </div>

                <div class="detail-row">

                    <span>Status</span>

                    <strong>
                        <%= status == null
                                ? "PLACED"
                                : status.replace("_", " ") %>
                    </strong>

                </div>

                <div class="detail-row">

                    <span>Items</span>

                    <strong>
                        <%= orderItems == null
                                ? 0
                                : orderItems.size() %>
                    </strong>

                </div>

                <div class="detail-row">

                    <span>Payment</span>

                    <strong>
                        <%= order.getPaymentMode() %>
                    </strong>

                </div>

                <div class="detail-row">

                    <span>Ordered at</span>

                    <strong>
                        <%= order.getOrderDate() %>
                    </strong>

                </div>

                <div class="detail-row total-row">

                    <span>Total paid</span>

                    <strong>
                        ₹<%= String.format("%.2f",
                                order.getTotalAmount()) %>
                    </strong>

                </div>

                <a class="home-button"
                   href="<%= contextPath %>/restaurants">
                    Order Something More
                </a>

            </div>

        </aside>

    </div>

</main>

</body>

</html>