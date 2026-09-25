<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

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

    String errorMessage =
            (String) request.getAttribute(
                    "errorMessage"
            );

    String email =
            (String) request.getAttribute(
                    "email"
            );

    boolean registered =
            "true".equalsIgnoreCase(
                request.getParameter("registered")
            );
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Login | CraveGo</title>

    <style>

        :root {
            --navy: #111827;
            --navy-light: #1f2937;
            --coral: #ff6647;
            --coral-dark: #e95234;
            --mint: #29b783;
            --mint-dark: #21966c;
            --mint-light: #dff8ef;
            --cream: #fffaf2;
            --white: #ffffff;
            --text: #18212f;
            --muted: #687385;
            --border: #e4e7ec;
            --error: #d92d20;
            --error-background: #fff1f0;
            --yellow: #ffc857;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
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

        .page-layout {
            min-height: 100vh;
            display: grid;
            grid-template-columns: 1fr 1fr;
        }

        /* =========================
           LOGIN PANEL
        ========================= */

        .login-panel {
            min-height: 100vh;
            padding: 45px 9%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--cream);
        }

        .login-container {
            width: min(500px, 100%);
        }

        .brand-logo {
            width: fit-content;
            display: flex;
            align-items: center;
            gap: 11px;
        }

        .logo-symbol {
            position: relative;
            width: 45px;
            height: 45px;
            display: grid;
            place-items: center;
            overflow: hidden;
            color: var(--white);
            background-color: var(--coral);
            border-radius: 14px 14px 14px 4px;
            font-size: 22px;
            font-weight: 900;
        }

        .logo-symbol::after {
            content: "";
            position: absolute;
            right: -6px;
            bottom: -6px;
            width: 19px;
            height: 19px;
            background-color: var(--yellow);
            border-radius: 50%;
        }

        .logo-text {
            color: var(--navy);
            font-size: 27px;
            font-weight: 900;
            letter-spacing: -1px;
        }

        .logo-text span {
            color: var(--coral);
        }

        .back-home {
            margin-top: 32px;
            display: inline-flex;
            align-items: center;
            gap: 7px;
            color: var(--muted);
            font-size: 13px;
            font-weight: 700;
        }

        .back-home:hover {
            color: var(--coral);
        }

        .heading {
            margin-top: 38px;
        }

        .heading-label {
            color: var(--mint-dark);
            font-size: 11px;
            font-weight: 900;
            letter-spacing: 1.2px;
            text-transform: uppercase;
        }

        .heading h1 {
            margin-top: 9px;
            color: var(--navy);
            font-family: Georgia, "Times New Roman", serif;
            font-size: 44px;
            line-height: 1.15;
        }

        .heading p {
            margin-top: 12px;
            color: var(--muted);
            font-size: 14px;
            line-height: 1.6;
        }

        .heading a {
            color: var(--coral);
            font-weight: 800;
        }

        /* =========================
           MESSAGES
        ========================= */

        .message {
            margin-top: 23px;
            padding: 14px 16px;
            display: flex;
            align-items: flex-start;
            gap: 11px;
            border-radius: 11px;
            font-size: 13px;
            line-height: 1.5;
        }

        .error-message {
            color: var(--error);
            background-color: var(--error-background);
            border: 1px solid #f4c0bb;
        }

        .success-message {
            color: #147353;
            background-color: var(--mint-light);
            border: 1px solid #a8dfcc;
        }

        .message-icon {
            flex-shrink: 0;
            font-weight: 900;
        }

        /* =========================
           LOGIN FORM
        ========================= */

        .login-form {
            margin-top: 28px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: var(--navy);
            font-size: 12px;
            font-weight: 800;
        }

        .input-wrapper {
            position: relative;
        }

        .form-group input {
            width: 100%;
            height: 54px;
            padding: 0 16px;
            color: var(--text);
            background-color: var(--white);
            border: 1px solid var(--border);
            border-radius: 13px;
            outline: none;
            font-size: 14px;
            transition:
                border-color 0.2s ease,
                box-shadow 0.2s ease;
        }

        .form-group input:focus {
            border-color: var(--mint);
            box-shadow: 0 0 0 4px rgba(41, 183, 131, 0.1);
        }

        .form-group input::placeholder {
            color: #a3a9b4;
        }

        .password-input {
            padding-right: 58px !important;
        }

        .show-password {
            position: absolute;
            top: 50%;
            right: 13px;
            transform: translateY(-50%);
            padding: 5px;
            color: var(--muted);
            background: none;
            border: none;
            font-size: 11px;
            font-weight: 900;
            cursor: pointer;
        }

        .show-password:hover {
            color: var(--coral);
        }

        .form-options {
            margin: -5px 0 23px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
        }

        .remember-option {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--muted);
            font-size: 12px;
        }

        .remember-option input {
            width: 15px;
            height: 15px;
            accent-color: var(--mint);
        }

        .account-help {
            color: var(--coral);
            font-size: 12px;
            font-weight: 800;
        }

        .login-button {
            width: 100%;
            height: 54px;
            color: var(--white);
            background-color: var(--coral);
            border: none;
            border-radius: 13px;
            font-size: 14px;
            font-weight: 900;
            cursor: pointer;
            box-shadow: 0 12px 25px rgba(255, 102, 71, 0.25);
            transition:
                background-color 0.2s ease,
                transform 0.2s ease;
        }

        .login-button:hover {
            background-color: var(--coral-dark);
            transform: translateY(-2px);
        }

        .register-card {
            margin-top: 25px;
            padding: 18px;
            color: var(--muted);
            background-color: var(--white);
            border: 1px solid var(--border);
            border-radius: 13px;
            font-size: 13px;
            text-align: center;
        }

        .register-card a {
            color: var(--coral);
            font-weight: 900;
        }

        /* =========================
           VISUAL PANEL
        ========================= */

        .visual-panel {
            position: relative;
            min-height: 100vh;
            padding: 55px;
            display: flex;
            align-items: flex-end;
            overflow: hidden;
            color: var(--white);
            background-color: var(--navy);
        }

        .visual-image {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.52;
        }

        .visual-overlay {
            position: absolute;
            inset: 0;
            background:
                linear-gradient(
                    180deg,
                    rgba(17, 24, 39, 0.17),
                    rgba(17, 24, 39, 0.97)
                );
        }

        .visual-panel::before {
            content: "";
            position: absolute;
            top: -150px;
            right: -150px;
            z-index: 2;
            width: 390px;
            height: 390px;
            background-color: rgba(41, 183, 131, 0.28);
            border-radius: 50%;
        }

        .visual-content {
            position: relative;
            z-index: 3;
            max-width: 620px;
        }

        .visual-badge {
            width: fit-content;
            padding: 9px 14px;
            color: #c7f4e5;
            background-color: rgba(41, 183, 131, 0.18);
            border: 1px solid rgba(41, 183, 131, 0.4);
            border-radius: 50px;
            font-size: 11px;
            font-weight: 900;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        .visual-content h2 {
            margin-top: 20px;
            font-family: Georgia, "Times New Roman", serif;
            font-size: clamp(40px, 5vw, 64px);
            line-height: 1.08;
        }

        .visual-content h2 span {
            color: var(--coral);
        }

        .visual-content p {
            margin-top: 18px;
            color: #c1c8d3;
            font-size: 16px;
            line-height: 1.75;
        }

        .visual-stats {
            margin-top: 30px;
            display: flex;
            gap: 35px;
            flex-wrap: wrap;
        }

        .visual-stat strong {
            display: block;
            color: var(--white);
            font-size: 21px;
        }

        .visual-stat span {
            display: block;
            margin-top: 4px;
            color: #9ca6b6;
            font-size: 11px;
        }

        /* =========================
           RESPONSIVE
        ========================= */

        @media (max-width: 900px) {

            .page-layout {
                grid-template-columns: 1fr;
            }

            .login-panel {
                min-height: auto;
                padding: 55px 8%;
            }

            .visual-panel {
                min-height: 560px;
            }
        }

        @media (max-width: 520px) {

            .login-panel {
                padding: 40px 5%;
            }

            .heading h1 {
                font-size: 37px;
            }

            .form-options {
                align-items: flex-start;
                flex-direction: column;
                gap: 13px;
            }

            .visual-panel {
                min-height: 480px;
                padding: 35px 25px;
            }

            .visual-content h2 {
                font-size: 40px;
            }
        }

    </style>

</head>

<body>

<div class="page-layout">

    <!-- =========================
         LOGIN FORM
    ========================= -->

    <section class="login-panel">

        <div class="login-container">

            <a class="brand-logo"
               href="<%= contextPath %>/">

                <span class="logo-symbol">
                    C
                </span>

                <span class="logo-text">
                    Crave<span>Go</span>
                </span>

            </a>

            <a class="back-home"
               href="<%= contextPath %>/">
                ← Back to home
            </a>

            <div class="heading">

                <p class="heading-label">
                    Welcome back
                </p>

                <h1>
                    Continue your food journey.
                </h1>

                <p>
                    New to CraveGo?

                    <a href="<%= contextPath %>/register">
                        Create an account
                    </a>
                </p>

            </div>

            <% if (registered) { %>

                <div class="message success-message">

                    <span class="message-icon">✓</span>

                    <span>
                        Registration successful. You can now
                        log in using your email and password.
                    </span>

                </div>

            <% } %>

            <% if (errorMessage != null) { %>

                <div class="message error-message">

                    <span class="message-icon">!</span>

                    <span>
                        <%= escapeHtml(errorMessage) %>
                    </span>

                </div>

            <% } %>

            <form class="login-form"
                  action="<%= contextPath %>/login"
                  method="post">

                <div class="form-group">

                    <label for="email">
                        Email address
                    </label>

                    <input type="email"
                           id="email"
                           name="email"
                           value="<%= escapeHtml(email) %>"
                           placeholder="Enter your registered email"
                           maxlength="100"
                           autocomplete="email"
                           required>

                </div>

                <div class="form-group">

                    <label for="password">
                        Password
                    </label>

                    <div class="input-wrapper">

                        <input class="password-input"
                               type="password"
                               id="password"
                               name="password"
                               placeholder="Enter your password"
                               autocomplete="current-password"
                               required>

                        <button class="show-password"
                                id="showPassword"
                                type="button">
                            SHOW
                        </button>

                    </div>

                </div>

                <div class="form-options">

                    <label class="remember-option">

                        <input type="checkbox"
                               name="rememberMe">

                        Keep me signed in

                    </label>

                    <a class="account-help"
                       href="<%= contextPath %>/register">
                        Need a new account?
                    </a>

                </div>

                <button class="login-button"
                        type="submit">
                    Login to CraveGo
                </button>

            </form>

            <div class="register-card">

                Don’t have an account yet?

                <a href="<%= contextPath %>/register">
                    Join CraveGo
                </a>

            </div>

        </div>

    </section>

    <!-- =========================
         VISUAL PANEL
    ========================= -->

    <section class="visual-panel">

        <img class="visual-image"
             src="https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&amp;fit=crop&amp;w=1300&amp;q=85"
             alt="Indian meal">

        <div class="visual-overlay"></div>

        <div class="visual-content">

            <div class="visual-badge">
                Made for Bengaluru cravings
            </div>

            <h2>
                Great food makes every day
                <span>feel better.</span>
            </h2>

            <p>
                Return to your favourite restaurants, discover
                new dishes and manage your cart with a simple,
                comfortable ordering experience.
            </p>

            <div class="visual-stats">

                <div class="visual-stat">

                    <strong>30+</strong>

                    <span>Restaurants</span>

                </div>

                <div class="visual-stat">

                    <strong>450+</strong>

                    <span>Fresh dishes</span>

                </div>

                <div class="visual-stat">

                    <strong>30 min</strong>

                    <span>Average delivery</span>

                </div>

            </div>

        </div>

    </section>

</div>

<script>

    const passwordInput =
            document.getElementById("password");

    const showPasswordButton =
            document.getElementById("showPassword");

    showPasswordButton.addEventListener(
        "click",
        function () {

            if (passwordInput.type === "password") {

                passwordInput.type = "text";

                showPasswordButton.textContent = "HIDE";

            } else {

                passwordInput.type = "password";

                showPasswordButton.textContent = "SHOW";
            }
        }
    );

</script>

</body>

</html>