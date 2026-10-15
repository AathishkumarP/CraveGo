<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.cravego.model.Order" %>
<%@ page import="com.cravego.model.User" %>
<%@ page import="com.cravego.util.RazorpayUtil" %>

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
%>

<%
    response.setHeader("Cache-Control", "no-store");

    String contextPath = request.getContextPath();

    Object userAttribute = session.getAttribute("loggedInUser");

    if (!(userAttribute instanceof User)) {
        response.sendRedirect(contextPath + "/login");
        return;
    }

    Object orderAttribute = request.getAttribute("paymentOrder");
    Object tokenAttribute = session.getAttribute("paymentCsrfToken");

    if (!(orderAttribute instanceof Order)
            || !(tokenAttribute instanceof String)) {
        response.sendRedirect(contextPath + "/my-orders");
        return;
    }

    User user = (User) userAttribute;
    Order order = (Order) orderAttribute;

    if (order.getUserId() != user.getUserId()) {
        response.sendError(403);
        return;
    }

    String csrfToken = (String) tokenAttribute;
    String gatewayOrderId = order.getRazorpayOrderId();

    boolean gatewayReady =
            gatewayOrderId != null && !gatewayOrderId.isBlank();

    boolean reviewRequired = Boolean.TRUE.equals(
            request.getAttribute("paymentReviewRequired")
    );

    Object keyAttribute = request.getAttribute("razorpayKeyId");

    String keyId = keyAttribute instanceof String
            ? (String) keyAttribute
            : "";

    boolean configured = keyId.startsWith("rzp_test_");

    Object errorAttribute = request.getAttribute("errorMessage");

    String errorMessage = errorAttribute instanceof String
            ? (String) errorAttribute
            : null;

    long amountPaise = RazorpayUtil.toPaise(
            BigDecimal.valueOf(order.getTotalAmount())
    );
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Payment | CraveGo</title>

    <style>
        :root {
            --navy: #111827;
            --coral: #ff6647;
            --mint: #29b783;
            --yellow: #ffd166;
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

        button {
            font: inherit;
        }

        .header {
            background: #fffaf4;
            border-bottom: 1px solid #eadfce;
        }

        .navbar {
            max-width: 1100px;
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

        .back-link {
            font-size: 12px;
            font-weight: 700;
        }

        main {
            max-width: 900px;
            padding: 45px 24px 65px;
            margin: auto;
        }

        .payment-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            overflow: hidden;
            border: 1px solid #eadfce;
            border-radius: 22px;
            box-shadow: 0 15px 40px rgba(17, 24, 39, .07);
        }

        .intro {
            padding: 38px 30px;
            background: var(--navy);
            color: #fff;
        }

        .eyebrow {
            color: var(--yellow);
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 2px;
        }

        h1 {
            margin: 18px 0;
            font-family: Georgia, serif;
            font-size: 36px;
            line-height: 1.2;
        }

        .intro p {
            color: #c1cad7;
            font-size: 13px;
            line-height: 1.8;
        }

        .test-badge {
            display: inline-block;
            margin-top: 25px;
            padding: 10px 13px;
            color: #ffe6a1;
            background: #3d3625;
            border: 1px solid #63532b;
            border-radius: 9px;
            font-size: 11px;
            font-weight: 700;
        }

        .panel {
            padding: 38px 30px;
            background: #fffdf8;
        }

        .panel h2 {
            margin: 0 0 24px;
            font-size: 21px;
        }

        .summary {
            padding: 20px;
            background: #eaf6f0;
            border: 1px solid #cee5d8;
            border-radius: 13px;
            margin-bottom: 25px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            font-size: 12px;
            color: #386654;
        }

        .amount {
            margin-top: 18px;
            padding-top: 18px;
            border-top: 1px dashed #b3d3c3;
            align-items: center;
        }

        .amount strong {
            font-size: 25px;
            color: var(--navy);
        }

        .button {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 800;
        }

        .pay-button {
            color: #fff;
            background: #e95234;
        }

        .pay-button:hover {
            background: #cc4226;
        }

        .check-button {
            color: #fff;
            background: var(--navy);
        }

        .check-button:hover {
            background: #263448;
        }

        .check-form {
            margin-top: 13px;
        }

        .button:disabled {
            opacity: .6;
            cursor: wait;
        }

        .message {
            padding: 14px;
            margin-bottom: 20px;
            background: #fff3db;
            color: #74511d;
            border: 1px solid #ead5a9;
            border-radius: 10px;
            font-size: 12px;
            line-height: 1.7;
        }

        .status-text,
        .note {
            color: #626c7a;
            font-size: 11px;
            line-height: 1.8;
        }

        .status-text {
            min-height: 20px;
            margin: 14px 0;
        }

        .details-link {
            display: block;
            margin-top: 20px;
            text-align: center;
            color: #394556;
            font-size: 12px;
            font-weight: 700;
        }

        a:focus-visible,
        button:focus-visible {
            outline: 3px solid var(--mint);
            outline-offset: 4px;
        }

        @media (max-width: 650px) {
            .navbar {
                padding: 18px;
                flex-wrap: wrap;
            }

            main {
                padding: 28px 16px 45px;
            }

            .payment-layout {
                grid-template-columns: 1fr;
            }

            .intro,
            .panel {
                padding: 28px 24px;
            }

            h1 {
                font-size: 30px;
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

        <a class="back-link"
           href="<%= escapeHtml(contextPath + "/my-orders") %>">
            &#8592; My Orders
        </a>
    </nav>
</header>

<main>
    <div class="payment-layout">
        <section class="intro">
            <div class="eyebrow">ONE STEP FROM YOUR NEXT BITE</div>
            <h1>Complete your<br>payment.</h1>

            <p>
                Your order is saved. Payment confirmation
                will update its status automatically.
            </p>

            <div class="test-badge">
                TEST MODE — No real money is transferred
            </div>
        </section>

        <section class="panel">
            <h2>Payment summary</h2>

            <% if (errorMessage != null) { %>
                <div class="message" role="alert">
                    <%= escapeHtml(errorMessage) %>
                </div>
            <% } %>

            <div class="summary">
                <div class="summary-row">
                    <span>CraveGo order</span>
                    <strong>#<%= order.getOrderId() %></strong>
                </div>

                <div class="summary-row amount">
                    <span>Amount to pay</span>
                    <strong>
                        &#8377;<%= String.format(
                                Locale.ENGLISH,
                                "%.2f",
                                order.getTotalAmount()
                        ) %>
                    </strong>
                </div>
            </div>

            <% if (configured && !gatewayReady && !reviewRequired) { %>

                <form action="<%= escapeHtml(contextPath + "/payment") %>"
                      method="post"
                      id="prepare-payment-form">

                    <input type="hidden"
                           name="orderId"
                           value="<%= order.getOrderId() %>">

                    <input type="hidden"
                           name="csrfToken"
                           value="<%= escapeHtml(csrfToken) %>">

                    <button class="button pay-button"
                            id="prepare-button"
                            type="submit">
                        Continue to Payment
                    </button>
                </form>

            <% } else if (configured && gatewayReady && !reviewRequired) { %>

                <button class="button pay-button"
                        id="pay-button"
                        type="button">
                    Pay &#8377;<%= String.format(
                            Locale.ENGLISH,
                            "%.2f",
                            order.getTotalAmount()
                    ) %>
                </button>

                <div id="payment-config"
                     hidden
                     data-local-order="<%= order.getOrderId() %>"
                     data-key="<%= escapeHtml(keyId) %>"
                     data-gateway-order="<%= escapeHtml(gatewayOrderId) %>"
                     data-amount="<%= amountPaise %>"
                     data-name="<%= escapeHtml(user.getUsername()) %>"
                     data-email="<%= escapeHtml(user.getEmail()) %>"
                     data-phone="<%= escapeHtml(user.getPhone()) %>">
                </div>

                <form id="verify-payment-form"
                      action="<%= escapeHtml(contextPath + "/verify-payment") %>"
                      method="post"
                      hidden>

                    <input type="hidden"
                           name="orderId"
                           value="<%= order.getOrderId() %>">

                    <input type="hidden"
                           name="csrfToken"
                           value="<%= escapeHtml(csrfToken) %>">

                    <input type="hidden"
                           id="razorpay-payment-id"
                           name="razorpay_payment_id">

                    <input type="hidden"
                           id="razorpay-order-id"
                           name="razorpay_order_id">

                    <input type="hidden"
                           id="razorpay-signature"
                           name="razorpay_signature">
                </form>

            <% } %>

            <% if (gatewayReady) { %>
                <form class="check-form"
                      id="check-payment-form"
                      action="<%= escapeHtml(contextPath + "/check-payment-status") %>"
                      method="post">

                    <input type="hidden"
                           name="orderId"
                           value="<%= order.getOrderId() %>">

                    <input type="hidden"
                           name="csrfToken"
                           value="<%= escapeHtml(csrfToken) %>">

                    <button class="button check-button" type="submit">
                        Check Payment Status
                    </button>
                </form>
            <% } %>

            <p class="status-text"
               id="payment-status"
               role="status"
               aria-live="polite"></p>

            <p class="note">
                Already completed payment? Check its status before retrying.
                Closing checkout does not cancel your saved order.
            </p>

            <a class="details-link"
               href="<%= escapeHtml(
                       contextPath + "/order-details?orderId="
                       + order.getOrderId()
               ) %>">
                View Order Details
            </a>
        </section>
    </div>
</main>

<% if (configured && gatewayReady && !reviewRequired) { %>
    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<% } %>

<script>
    const prepareForm = document.getElementById("prepare-payment-form");

    if (prepareForm) {
        prepareForm.addEventListener("submit", function () {
            const button = document.getElementById("prepare-button");
            button.disabled = true;
            button.textContent = "Preparing payment...";
        });
    }

    const checkForm = document.getElementById("check-payment-form");

    if (checkForm) {
        checkForm.addEventListener("submit", function () {
            const button = checkForm.querySelector("button");
            button.disabled = true;
            button.textContent = "Checking payment...";
        });
    }

    const payButton = document.getElementById("pay-button");

    if (payButton) {
        const config = document.getElementById("payment-config").dataset;
        const statusText = document.getElementById("payment-status");
        const reviewKey = "cravego-payment-review-" + config.localOrder;

        let submitting = false;

        function rememberReview() {
            try {
                sessionStorage.setItem(reviewKey, "true");
            } catch (error) {
                // Browser storage may be unavailable.
            }
        }

        function reviewRemembered() {
            try {
                return sessionStorage.getItem(reviewKey) === "true";
            } catch (error) {
                return false;
            }
        }

        if (reviewRemembered()) {
            payButton.hidden = true;
            statusText.textContent =
                "A payment response was received. Check payment status before retrying.";
        }

        payButton.addEventListener("click", function () {
            if (submitting) {
                return;
            }

            if (typeof window.Razorpay !== "function") {
                statusText.textContent =
                    "Payment checkout could not load. Refresh and try again.";
                return;
            }

            payButton.disabled = true;
            statusText.textContent = "Opening payment checkout...";

            const options = {
                key: config.key,
                amount: Number(config.amount),
                currency: "INR",
                name: "CraveGo",
                description: "Food order payment",
                order_id: config.gatewayOrder,

                prefill: {
                    name: config.name,
                    email: config.email,
                    contact: config.phone
                },

                theme: {
                    color: "#ff6647"
                },

                handler: function (result) {
                    if (submitting) {
                        return;
                    }

                    rememberReview();

                    if (!result.razorpay_payment_id
                            || !result.razorpay_order_id
                            || !result.razorpay_signature) {

                        payButton.hidden = true;
                        statusText.textContent =
                            "Payment response is incomplete. Use Check Payment Status.";
                        return;
                    }

                    submitting = true;
                    statusText.textContent = "Verifying your payment...";

                    document.getElementById("razorpay-payment-id").value =
                        result.razorpay_payment_id;

                    document.getElementById("razorpay-order-id").value =
                        result.razorpay_order_id;

                    document.getElementById("razorpay-signature").value =
                        result.razorpay_signature;

                    document.getElementById("verify-payment-form").submit();
                },

                modal: {
                    ondismiss: function () {
                        if (!submitting) {
                            payButton.disabled = false;
                            statusText.textContent =
                                "Checkout closed. If you completed payment, check its status.";
                        }
                    }
                }
            };

            try {
                const checkout = new window.Razorpay(options);

                checkout.on("payment.failed", function () {
                    if (!submitting) {
                        statusText.textContent =
                            "This payment attempt failed. You can retry in checkout.";
                    }
                });

                checkout.open();

            } catch (error) {
                payButton.disabled = false;
                statusText.textContent =
                    "Unable to open checkout. Refresh and try again.";
            }
        });
    }
</script>

</body>
</html>