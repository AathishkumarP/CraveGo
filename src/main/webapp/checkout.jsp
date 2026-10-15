<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.cravego.model.Menu" %>
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

    private String money(double value) {
        return String.format(Locale.ENGLISH, "%.2f", value);
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

    User user = (User) userAttribute;

    Restaurant restaurant =
            (Restaurant) request.getAttribute("restaurant");

    @SuppressWarnings("unchecked")
    Map<Menu, Integer> cartItems =
            (Map<Menu, Integer>) request.getAttribute("cartItems");

    Object tokenAttribute = session.getAttribute("checkoutCsrfToken");

    if (restaurant == null
            || cartItems == null
            || cartItems.isEmpty()
            || !(tokenAttribute instanceof String)) {

        response.sendRedirect(contextPath + "/checkout");
        return;
    }

    String checkoutToken = (String) tokenAttribute;

    Number subtotalValue = (Number) request.getAttribute("subtotal");
    Number deliveryValue = (Number) request.getAttribute("deliveryFee");
    Number platformValue = (Number) request.getAttribute("platformFee");
    Number totalValue = (Number) request.getAttribute("totalAmount");

    double subtotal = subtotalValue == null
            ? 0 : subtotalValue.doubleValue();

    double deliveryFee = deliveryValue == null
            ? 0 : deliveryValue.doubleValue();

    double platformFee = platformValue == null
            ? 0 : platformValue.doubleValue();

    double totalAmount = totalValue == null
            ? 0 : totalValue.doubleValue();

    String errorMessage =
            (String) request.getAttribute("errorMessage");
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
            --coral: #ff6647;
            --mint: #29b783;
            --cream: #fffaf2;
            --border: #e7e1d8;
            --muted: #687385;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: var(--cream);
            color: var(--navy);
            font-family: Arial, Helvetica, sans-serif;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        button, input {
            font: inherit;
        }

        [hidden] {
            display: none !important;
        }

        .navbar {
            width: min(1240px, 90%);
            margin: 20px auto;
            padding: 15px 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            background: white;
            border: 1px solid #f0ece5;
            border-radius: 22px;
            box-shadow: 0 10px 30px #11182708;
        }

        .logo {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 25px;
            font-weight: 900;
            letter-spacing: -1px;
        }

        .logo-symbol {
            position: relative;
            display: grid;
            place-items: center;
            width: 42px;
            height: 42px;
            overflow: hidden;
            color: white;
            background: var(--coral);
            border-radius: 13px 13px 13px 4px;
        }

        .logo-symbol::after {
            content: "";
            position: absolute;
            right: -6px;
            bottom: -6px;
            width: 19px;
            height: 19px;
            border-radius: 50%;
            background: #ffc857;
        }

        .logo-word span {
            color: var(--coral);
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 22px;
            font-size: 13px;
            font-weight: 800;
        }

        .hero, .layout, .server-error {
            width: min(1240px, 90%);
            margin: 0 auto 24px;
        }

        .hero {
            padding: 30px 35px;
            background: var(--navy);
            color: white;
            border-radius: 26px;
        }

        .eyebrow {
            color: var(--mint);
            font-size: 10px;
            font-weight: 900;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        h1 {
            margin: 12px 0;
            font-family: Georgia, serif;
            font-size: 40px;
        }

        .hero p {
            margin: 0;
            color: #cbd2de;
            font-size: 13px;
            line-height: 1.7;
        }

        .layout {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 350px;
            gap: 24px;
            align-items: start;
            margin-bottom: 60px;
        }

        .left {
            display: grid;
            gap: 20px;
        }

        .card {
            padding: 25px;
            border: 1px solid var(--border);
            border-radius: 24px;
            background: white;
        }

        .heading {
            display: flex;
            align-items: center;
            gap: 13px;
            margin-bottom: 20px;
        }

        .step {
            display: grid;
            place-items: center;
            flex-shrink: 0;
            width: 36px;
            height: 36px;
            border-radius: 11px;
            color: white;
            background: var(--coral);
            font-weight: 900;
        }

        h2 {
            margin: 0;
            font: bold 25px Georgia, serif;
        }

        .muted {
            color: var(--muted);
            font-size: 12px;
            line-height: 1.7;
        }

        .customer {
            padding: 18px;
            border: 1px solid var(--border);
            border-radius: 15px;
            background: #fffdf8;
            overflow-wrap: anywhere;
        }

        .customer strong {
            display: block;
            margin-bottom: 9px;
        }

        .customer p {
            margin: 5px 0;
        }

        .options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        .option {
            cursor: pointer;
        }

        .option input {
            position: absolute;
            opacity: 0;
        }

        .option-body {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 150px;
            padding: 20px;
            border: 2px solid var(--border);
            border-radius: 17px;
            background: #fffdf8;
        }

        .option input:checked + .option-body {
            background: #dff8ef;
            border-color: var(--mint);
        }

        .option input:focus-visible + .option-body {
            outline: 3px solid var(--navy);
            outline-offset: 3px;
        }

        .option-icon {
            margin-bottom: 18px;
            font-size: 26px;
        }

        .option strong {
            display: block;
            margin-bottom: 6px;
            font-size: 14px;
        }

        .option small {
            color: var(--muted);
            font-size: 11px;
            line-height: 1.6;
        }

        .restaurant {
            padding: 17px;
            margin-bottom: 15px;
            background: var(--navy);
            color: white;
            border-radius: 15px;
            font-weight: 800;
        }

        .item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            padding: 16px 0;
            border-bottom: 1px solid #f0ece5;
        }

        .item:last-child {
            border-bottom: 0;
        }

        .item strong {
            font-size: 13px;
        }

        .item p {
            margin: 6px 0 0;
        }

        .bill {
            overflow: hidden;
            padding: 0;
        }

        .bill-header {
            padding: 28px 24px;
            color: white;
            background: var(--navy);
        }

        .bill-header h2 {
            margin-top: 12px;
            font-size: 30px;
        }

        .bill-body {
            padding: 25px;
        }

        .row {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            margin-bottom: 20px;
            font-size: 13px;
        }

        .row span {
            color: var(--muted);
        }

        .total {
            padding-top: 22px;
            margin-top: 24px;
            border-top: 1px dashed #cfd4dc;
            font-size: 22px;
            font-weight: 900;
        }

        .total span {
            color: var(--navy);
        }

        .total strong {
            color: var(--coral);
        }

        .button {
            display: block;
            width: 100%;
            padding: 16px;
            border: 0;
            border-radius: 13px;
            text-align: center;
            cursor: pointer;
            font-size: 12px;
            font-weight: 900;
        }

        .primary {
            color: white;
            background: var(--coral);
        }

        .secondary {
            margin-top: 12px;
            color: var(--navy);
            background: #dff8ef;
        }

        .button:disabled {
            opacity: .6;
            cursor: wait;
        }

        .status {
            margin: 15px 0 0;
            font-size: 12px;
            line-height: 1.7;
            overflow-wrap: anywhere;
        }

        .server-error {
            padding: 16px;
            color: #9f2633;
            background: #fff0ee;
            border: 1px solid #ffc9c1;
            border-radius: 12px;
        }

        .test-note {
            margin: 18px 0;
            color: var(--muted);
            font-size: 11px;
            line-height: 1.7;
        }

        @media (max-width: 850px) {
            .layout {
                grid-template-columns: 1fr;
            }

            .nav-links {
                gap: 13px;
            }

            .welcome {
                display: none;
            }
        }

        @media (max-width: 500px) {
            .options {
                grid-template-columns: 1fr;
            }

            .navbar {
                flex-wrap: wrap;
            }

            .card {
                padding: 20px;
            }

            .bill {
                padding: 0;
            }

            h1 {
                font-size: 32px;
            }
        }
    </style>
</head>

<body>

<nav class="navbar" aria-label="Main navigation">
    <a class="logo"
       href="<%= escapeHtml(contextPath + "/") %>">
        <span class="logo-symbol" aria-hidden="true">C</span>
        <span class="logo-word">Crave<span>Go</span></span>
    </a>

    <div class="nav-links">
        <a href="<%= escapeHtml(contextPath + "/restaurants") %>">
            Restaurants
        </a>

        <a href="<%= escapeHtml(contextPath + "/my-orders") %>">
            My Orders
        </a>

        <span class="welcome">
            Hi, <%= escapeHtml(user.getUsername()) %>
        </span>
    </div>
</nav>

<header class="hero">
    <div class="eyebrow">Your next bite is almost here</div>
    <h1>Finish your order.</h1>
    <p>Review your food and choose how you would like to pay.</p>
</header>

<% if (errorMessage != null) { %>
    <div class="server-error" role="alert">
        <%= escapeHtml(errorMessage) %>
    </div>
<% } %>

<form id="checkout-form"
      class="layout"
      action="<%= escapeHtml(contextPath + "/checkout") %>"
      method="post">

    <input type="hidden"
           name="csrfToken"
           value="<%= escapeHtml(checkoutToken) %>">

    <div class="left">
        <section class="card">
            <div class="heading">
                <span class="step">1</span>
                <h2>Your details</h2>
            </div>

            <div class="customer">
                <strong><%= escapeHtml(user.getUsername()) %></strong>
                <p class="muted"><%= escapeHtml(user.getPhone()) %></p>
                <p class="muted"><%= escapeHtml(user.getEmail()) %></p>
            </div>
        </section>

        <section class="card">
            <div class="heading">
                <span class="step">2</span>
                <h2>Payment method</h2>
            </div>

            <div class="options">
                <label class="option">
                    <input type="radio"
                           name="paymentMode"
                           value="COD"
                           checked>

                    <span class="option-body">
                        <span class="option-icon" aria-hidden="true">
                            &#128181;
                        </span>

                        <span>
                            <strong>Cash on Delivery</strong>
                            <small>Pay when your food arrives.</small>
                        </span>
                    </span>
                </label>

                <label class="option">
                    <input type="radio"
                           id="online-payment"
                           name="paymentMode"
                           value="RAZORPAY">

                    <span class="option-body">
                        <span class="option-icon" aria-hidden="true">
                            &#128241;
                        </span>

                        <span>
                            <strong>Online Payment</strong>
                            <small>
                                Open payment options and choose
                                an available method.
                            </small>
                        </span>
                    </span>
                </label>
            </div>

            <p class="muted">
                Selecting Online Payment saves a pending order
                and opens secure checkout here.
            </p>
        </section>

        <section class="card">
            <div class="heading">
                <span class="step">3</span>
                <h2>Review your order</h2>
            </div>

            <div class="restaurant">
                <%= escapeHtml(restaurant.getName()) %>
            </div>

            <% for (Map.Entry<Menu, Integer> entry
                    : cartItems.entrySet()) {
                Menu menu = entry.getKey();
                int quantity = entry.getValue();
            %>
                <div class="item">
                    <div>
                        <strong>
                            <%= escapeHtml(menu.getItemName()) %>
                        </strong>

                        <p class="muted">
                            Quantity: <%= quantity %>
                        </p>
                    </div>

                    <strong>
                        &#8377;<%= money(menu.getPrice() * quantity) %>
                    </strong>
                </div>
            <% } %>
        </section>
    </div>

    <aside class="card bill">
        <div class="bill-header">
            <div class="eyebrow">Payment summary</div>
            <h2>Bill details</h2>
        </div>

        <div class="bill-body">
            <div class="row">
                <span>Item total</span>
                <strong>&#8377;<%= money(subtotal) %></strong>
            </div>

            <div class="row">
                <span>Delivery fee</span>
                <strong>&#8377;<%= money(deliveryFee) %></strong>
            </div>

            <div class="row">
                <span>Platform fee</span>
                <strong>&#8377;<%= money(platformFee) %></strong>
            </div>

            <div class="row total">
                <span>To Pay</span>
                <strong>&#8377;<%= money(totalAmount) %></strong>
            </div>

            <button id="place-order-button"
                    class="button primary"
                    type="submit">
                Place Order · &#8377;<%= money(totalAmount) %>
            </button>

            <p id="payment-status"
               class="status"
               role="status"
               aria-live="polite"></p>

            <button id="check-payment-button"
                    class="button secondary"
                    type="button"
                    hidden>
                Check Payment Status
            </button>

            <p class="test-note">
                Use Razorpay test payment options while your
                account is in Test Mode.
            </p>

            <a class="button secondary"
               href="<%= escapeHtml(contextPath + "/cart") %>">
                &#8592; Return to cart
            </a>
        </div>
    </aside>
</form>

<div id="checkout-config"
     hidden
     data-context="<%= escapeHtml(contextPath) %>">
</div>

<form id="verify-payment-form"
      action="<%= escapeHtml(contextPath + "/verify-payment") %>"
      method="post"
      hidden>
    <input name="orderId">
    <input name="csrfToken">
    <input name="razorpay_payment_id">
    <input name="razorpay_order_id">
    <input name="razorpay_signature">
</form>

<form id="check-payment-form"
      action="<%= escapeHtml(contextPath + "/check-payment-status") %>"
      method="post"
      hidden>
    <input name="orderId">
    <input name="csrfToken">
</form>

<script src="https://checkout.razorpay.com/v1/checkout.js"></script>

<script>
(function () {
    "use strict";

    const context =
        document.getElementById("checkout-config").dataset.context;

    const form = document.getElementById("checkout-form");
    const online = document.getElementById("online-payment");
    const button = document.getElementById("place-order-button");
    const status = document.getElementById("payment-status");
    const checkButton = document.getElementById("check-payment-button");
    const verifyForm = document.getElementById("verify-payment-form");
    const checkForm = document.getElementById("check-payment-form");
    const originalButtonText = button.textContent.trim();

    let busy = false;
    let reviewRequired = false;
    let paymentOrder = null;

    function setBusy(value) {
        busy = value;
        button.disabled = value || reviewRequired;

        form.querySelectorAll('input[name="paymentMode"]')
            .forEach(function (input) {
                input.disabled = value || reviewRequired;
            });
    }

    function showReview(message) {
        reviewRequired = true;
        status.textContent = message;
        checkButton.hidden = !paymentOrder;
        setBusy(false);
        button.textContent = "Check payment status";
    }

    function rememberReview(orderId) {
        try {
            sessionStorage.setItem(
                "cravego-payment-review-" + orderId,
                "true"
            );
        } catch (error) {
            // Server verification remains authoritative.
        }
    }

    function reviewRemembered(orderId) {
        try {
            return sessionStorage.getItem(
                "cravego-payment-review-" + orderId
            ) === "true";
        } catch (error) {
            return false;
        }
    }

    async function postJson(path, body) {
        const response = await fetch(context + path, {
            method: "POST",
            credentials: "same-origin",
            headers: {
                "Accept": "application/json"
            },
            body: body
        });

        const contentType =
            response.headers.get("content-type") || "";

        if (!contentType.includes("application/json")) {
            throw new Error(
                "The server did not return payment details. "
                + "Refresh checkout or check My Orders."
            );
        }

        const result = await response.json();

        if (!response.ok || result.error) {
            throw new Error(
                result.error || "Unable to prepare payment."
            );
        }

        return result;
    }

    function submitVerification(result) {
        if (reviewRequired) {
            return;
        }

        rememberReview(paymentOrder.orderId);
        reviewRequired = true;
        setBusy(true);
        status.textContent = "Verifying your payment...";

        if (!result.razorpay_payment_id
                || !result.razorpay_order_id
                || !result.razorpay_signature) {

            showReview(
                "Payment response is incomplete. "
                + "Check Payment Status before trying again."
            );
            return;
        }

        verifyForm.elements.namedItem("orderId").value =
            paymentOrder.orderId;

        verifyForm.elements.namedItem("csrfToken").value =
            paymentOrder.csrfToken;

        verifyForm.elements.namedItem("razorpay_payment_id").value =
            result.razorpay_payment_id;

        verifyForm.elements.namedItem("razorpay_order_id").value =
            result.razorpay_order_id;

        verifyForm.elements.namedItem("razorpay_signature").value =
            result.razorpay_signature;

        verifyForm.submit();
    }

    async function startOnlinePayment() {
        if (busy || reviewRequired) {
            return;
        }

        if (typeof window.Razorpay !== "function") {
            status.textContent =
                "Payment checkout could not load. Refresh and try again.";
            return;
        }

        // Read the selected radio before disabling the controls.
        const checkoutBody = new URLSearchParams(
    new FormData(form)
);
        checkoutBody.set("paymentMode", "RAZORPAY");
        checkoutBody.set("inlinePayment", "true");

        setBusy(true);
        button.textContent = "Preparing payment...";
        status.textContent = "Saving your order...";

        try {
            const order = await postJson("/checkout", checkoutBody);

            if (order.paid) {
                window.location.assign(order.redirectUrl);
                return;
            }

            paymentOrder = order;
            checkButton.hidden = false;

            if (reviewRemembered(order.orderId)) {
                showReview(
                    "A payment response was already received. "
                    + "Check Payment Status before trying again."
                );
                return;
            }

            const prepareBody = new URLSearchParams();

            prepareBody.set("orderId", String(order.orderId));
            prepareBody.set("csrfToken", order.csrfToken);
            prepareBody.set("inlinePayment", "true");

            const config = await postJson("/payment", prepareBody);

            if (config.paid) {
                window.location.assign(config.redirectUrl);
                return;
            }

            paymentOrder = config;

            if (!config.key
                    || !config.gatewayOrderId
                    || !Number.isSafeInteger(config.amount)
                    || config.amount <= 0) {

                throw new Error("Payment configuration is incomplete.");
            }

            const checkout = new window.Razorpay({
                key: config.key,
                amount: config.amount,
                currency: config.currency,
                name: "CraveGo",
                description: "Food order payment",
                order_id: config.gatewayOrderId,
                prefill: config.prefill,
                theme: {
                    color: "#ff6647"
                },
                handler: submitVerification,
                modal: {
                    ondismiss: function () {
                        if (!reviewRequired) {
                            setBusy(false);
                            button.textContent = "Continue Online Payment";
                            status.textContent =
                                "Checkout closed. Your order is saved. "
                                + "If you completed payment, check its status.";
                        }
                    }
                }
            });

            checkout.on("payment.failed", function () {
                if (!reviewRequired) {
                    status.textContent =
                        "This attempt failed. You can retry inside checkout.";
                }
            });

            status.textContent = "Choose your payment method.";
            button.textContent = "Payment checkout open";
            checkout.open();

        } catch (error) {
            setBusy(false);
            button.textContent = "Continue Online Payment";
            status.textContent =
                error.message || "Unable to open payment checkout.";
        }
    }

    online.addEventListener("change", function () {
        if (online.checked) {
            startOnlinePayment();
        }
    });

    form.querySelectorAll('input[name="paymentMode"]')
        .forEach(function (input) {
            input.addEventListener("change", function () {
                if (!online.checked && !busy && !reviewRequired) {
                    button.textContent = originalButtonText;
                }
            });
        });

    form.addEventListener("submit", function (event) {
        if (busy || reviewRequired) {
            event.preventDefault();
            return;
        }

        if (online.checked) {
            event.preventDefault();
            startOnlinePayment();
            return;
        }

        // Allow the normal COD form submission.
        busy = true;
        button.disabled = true;
        button.textContent = "Placing your order...";
    });

    checkButton.addEventListener("click", function () {
        if (!paymentOrder || busy) {
            return;
        }

        checkForm.elements.namedItem("orderId").value =
            paymentOrder.orderId;

        checkForm.elements.namedItem("csrfToken").value =
            paymentOrder.csrfToken;

        checkButton.disabled = true;
        checkButton.textContent = "Checking payment...";
        checkForm.submit();
    });
})();
</script>

</body>
</html>