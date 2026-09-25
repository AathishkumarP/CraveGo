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

    String username =
            (String) request.getAttribute(
                    "username"
            );

    String email =
            (String) request.getAttribute(
                    "email"
            );

    String phone =
            (String) request.getAttribute(
                    "phone"
            );

    String address =
            (String) request.getAttribute(
                    "address"
            );
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Create Account | CraveGo</title>

    <style>

        :root {
            --navy: #111827;
            --navy-light: #1f2937;
            --coral: #ff6647;
            --coral-dark: #e95234;
            --mint: #29b783;
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
        input,
        textarea {
            font-family: inherit;
        }

        .page-layout {
            min-height: 100vh;
            display: grid;
            grid-template-columns: 0.9fr 1.1fr;
        }

        /* =========================
           BRAND SIDE
        ========================= */

        .brand-panel {
            position: relative;
            min-height: 100vh;
            padding: 45px 7%;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            overflow: hidden;
            color: var(--white);
            background-color: var(--navy);
        }

        .brand-panel::before {
            content: "";
            position: absolute;
            top: -170px;
            right: -170px;
            width: 430px;
            height: 430px;
            background-color: rgba(41, 183, 131, 0.18);
            border-radius: 50%;
        }

        .brand-panel::after {
            content: "";
            position: absolute;
            left: -210px;
            bottom: -210px;
            width: 480px;
            height: 480px;
            background-color: rgba(255, 102, 71, 0.16);
            border-radius: 50%;
        }

        .brand-logo {
            position: relative;
            z-index: 2;
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
            color: var(--white);
            font-size: 27px;
            font-weight: 900;
            letter-spacing: -1px;
        }

        .logo-text span {
            color: var(--coral);
        }

        .brand-content {
            position: relative;
            z-index: 2;
            max-width: 550px;
            margin: 70px 0;
        }

        .brand-label {
            width: fit-content;
            padding: 8px 13px;
            color: #baf0dc;
            background-color: rgba(41, 183, 131, 0.13);
            border: 1px solid rgba(41, 183, 131, 0.32);
            border-radius: 50px;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        .brand-content h1 {
            margin-top: 22px;
            font-family: Georgia, "Times New Roman", serif;
            font-size: clamp(42px, 5vw, 65px);
            line-height: 1.08;
            letter-spacing: -1.7px;
        }

        .brand-content h1 span {
            color: var(--coral);
        }

        .brand-content > p {
            margin-top: 20px;
            color: #b1bac8;
            font-size: 16px;
            line-height: 1.8;
        }

        .brand-features {
            margin-top: 32px;
            display: grid;
            gap: 14px;
        }

        .brand-feature {
            display: flex;
            align-items: center;
            gap: 13px;
            color: #d7dce4;
            font-size: 14px;
            font-weight: 700;
        }

        .feature-icon {
            width: 34px;
            height: 34px;
            display: grid;
            place-items: center;
            flex-shrink: 0;
            color: var(--navy);
            background-color: var(--mint);
            border-radius: 10px;
            font-weight: 900;
        }

        .brand-footer {
            position: relative;
            z-index: 2;
            color: #727e91;
            font-size: 12px;
        }

        /* =========================
           FORM SIDE
        ========================= */

        .form-panel {
            min-height: 100vh;
            padding: 42px 8%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--cream);
        }

        .form-container {
            width: min(610px, 100%);
        }

        .back-home {
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

        .form-heading {
            margin-top: 25px;
        }

        .form-heading h2 {
            color: var(--navy);
            font-family: Georgia, "Times New Roman", serif;
            font-size: 39px;
            line-height: 1.2;
        }

        .form-heading p {
            margin-top: 9px;
            color: var(--muted);
            font-size: 14px;
            line-height: 1.6;
        }

        .login-text a {
            color: var(--coral);
            font-weight: 800;
        }

        /* =========================
           ERROR MESSAGE
        ========================= */

        .error-message {
            margin-top: 22px;
            padding: 13px 15px;
            display: flex;
            align-items: flex-start;
            gap: 10px;
            color: var(--error);
            background-color: var(--error-background);
            border: 1px solid #f5c0bb;
            border-radius: 11px;
            font-size: 13px;
            line-height: 1.5;
        }

        .error-icon {
            flex-shrink: 0;
            font-weight: 900;
        }

        /* =========================
           FORM
        ========================= */

        .register-form {
            margin-top: 26px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 17px;
        }

        .form-group {
            margin-bottom: 18px;
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

        .form-group input,
        .form-group textarea {
            width: 100%;
            color: var(--text);
            background-color: var(--white);
            border: 1px solid var(--border);
            border-radius: 12px;
            outline: none;
            font-size: 14px;
            transition:
                border-color 0.2s ease,
                box-shadow 0.2s ease;
        }

        .form-group input {
            height: 51px;
            padding: 0 15px;
        }

        .form-group textarea {
            min-height: 82px;
            padding: 14px 15px;
            resize: vertical;
            line-height: 1.5;
        }

        .password-input {
            padding-right: 52px !important;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            border-color: var(--mint);
            box-shadow: 0 0 0 4px rgba(41, 183, 131, 0.1);
        }

        .form-group input::placeholder,
        .form-group textarea::placeholder {
            color: #a3a9b4;
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
            font-weight: 800;
            cursor: pointer;
        }

        .show-password:hover {
            color: var(--coral);
        }

        .field-help {
            margin-top: 6px;
            color: var(--muted);
            font-size: 10px;
        }

        .terms {
            margin: 3px 0 21px;
            color: var(--muted);
            font-size: 11px;
            line-height: 1.6;
        }

        .terms strong {
            color: var(--navy);
        }

        .register-button {
            width: 100%;
            height: 53px;
            color: var(--white);
            background-color: var(--coral);
            border: none;
            border-radius: 13px;
            font-size: 14px;
            font-weight: 900;
            cursor: pointer;
            box-shadow: 0 12px 25px rgba(255, 102, 71, 0.25);
            transition:
                transform 0.2s ease,
                background-color 0.2s ease;
        }

        .register-button:hover {
            background-color: var(--coral-dark);
            transform: translateY(-2px);
        }

        .secure-note {
            margin-top: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
            color: var(--muted);
            font-size: 11px;
        }

        /* =========================
           RESPONSIVE
        ========================= */

        @media (max-width: 980px) {

            .page-layout {
                grid-template-columns: 1fr;
            }

            .brand-panel {
                min-height: auto;
                padding: 35px 7% 50px;
            }

            .brand-content {
                margin: 65px 0 25px;
            }

            .brand-content h1 {
                max-width: 650px;
            }

            .brand-footer {
                display: none;
            }

            .form-panel {
                min-height: auto;
                padding: 55px 7%;
            }
        }

        @media (max-width: 600px) {

            .brand-content h1 {
                font-size: 42px;
            }

            .form-panel {
                padding: 45px 5%;
            }

            .form-row {
                grid-template-columns: 1fr;
                gap: 0;
            }

            .form-heading h2 {
                font-size: 34px;
            }
        }

    </style>

</head>

<body>

<div class="page-layout">

    <!-- =========================
         BRAND PANEL
    ========================= -->

    <section class="brand-panel">

        <a class="brand-logo"
           href="<%= contextPath %>/">

            <span class="logo-symbol">
                C
            </span>

            <span class="logo-text">
                Crave<span>Go</span>
            </span>

        </a>

        <div class="brand-content">

            <div class="brand-label">
                Join Bengaluru’s food community
            </div>

            <h1>
                Your cravings deserve
                <span>better choices.</span>
            </h1>

            <p>
                Create your CraveGo account to discover local
                restaurants, build your cart and enjoy your
                favourite dishes from anywhere in Bengaluru.
            </p>

            <div class="brand-features">

                <div class="brand-feature">

                    <span class="feature-icon">✓</span>

                    Discover 30+ Bengaluru restaurants

                </div>

                <div class="brand-feature">

                    <span class="feature-icon">✓</span>

                    Choose from more than 450 dishes

                </div>

                <div class="brand-feature">

                    <span class="feature-icon">✓</span>

                    Manage your cart with complete control

                </div>

            </div>

        </div>

        <p class="brand-footer">
            © 2026 CraveGo. Crafted for Bengaluru food lovers.
        </p>

    </section>

    <!-- =========================
         REGISTRATION FORM
    ========================= -->

    <section class="form-panel">

        <div class="form-container">

            <a class="back-home"
               href="<%= contextPath %>/">
                ← Back to home
            </a>

            <div class="form-heading">

                <h2>Create your account</h2>

                <p class="login-text">
                    Already have an account?

                    <a href="<%= contextPath %>/login">
                        Login here
                    </a>
                </p>

            </div>

            <% if (errorMessage != null) { %>

                <div class="error-message">

                    <span class="error-icon">!</span>

                    <span>
                        <%= escapeHtml(errorMessage) %>
                    </span>

                </div>

            <% } %>

            <form class="register-form"
                  action="<%= contextPath %>/register"
                  method="post">

                <div class="form-row">

                    <div class="form-group">

                        <label for="username">
                            Full name
                        </label>

                        <input type="text"
                               id="username"
                               name="username"
                               value="<%= escapeHtml(username) %>"
                               placeholder="Enter your full name"
                               minlength="3"
                               maxlength="50"
                               autocomplete="name"
                               required>

                    </div>

                    <div class="form-group">

                        <label for="phone">
                            Phone number
                        </label>

                        <input type="tel"
                               id="phone"
                               name="phone"
                               value="<%= escapeHtml(phone) %>"
                               placeholder="10-digit phone number"
                               pattern="[0-9]{10}"
                               maxlength="10"
                               autocomplete="tel"
                               required>

                    </div>

                </div>

                <div class="form-group">

                    <label for="email">
                        Email address
                    </label>

                    <input type="email"
                           id="email"
                           name="email"
                           value="<%= escapeHtml(email) %>"
                           placeholder="Enter your email address"
                           maxlength="100"
                           autocomplete="email"
                           required>

                </div>

                <div class="form-group">

                    <label for="address">
                        Delivery address
                    </label>

                    <textarea id="address"
                              name="address"
                              placeholder="House number, street, area and Bengaluru location"
                              maxlength="255"
                              autocomplete="street-address"
                              required><%= escapeHtml(address) %></textarea>

                </div>

                <div class="form-row">

                    <div class="form-group">

                        <label for="password">
                            Password
                        </label>

                        <div class="input-wrapper">

                            <input class="password-input"
                                   type="password"
                                   id="password"
                                   name="password"
                                   placeholder="Create a password"
                                   minlength="6"
                                   autocomplete="new-password"
                                   required>

                            <button class="show-password"
                                    type="button"
                                    data-target="password">
                                SHOW
                            </button>

                        </div>

                        <p class="field-help">
                            Minimum 6 characters
                        </p>

                    </div>

                    <div class="form-group">

                        <label for="confirmPassword">
                            Confirm password
                        </label>

                        <div class="input-wrapper">

                            <input class="password-input"
                                   type="password"
                                   id="confirmPassword"
                                   name="confirmPassword"
                                   placeholder="Enter password again"
                                   minlength="6"
                                   autocomplete="new-password"
                                   required>

                            <button class="show-password"
                                    type="button"
                                    data-target="confirmPassword">
                                SHOW
                            </button>

                        </div>

                    </div>

                </div>

                <p class="terms">
                    By creating an account, you confirm that the
                    information entered is correct and agree to use
                    CraveGo responsibly. <strong>Your delivery address
                    can be updated later.</strong>
                </p>

                <button class="register-button"
                        type="submit">
                    Create CraveGo Account
                </button>

                <p class="secure-note">
                    🔒 Your account information is kept private.
                </p>

            </form>

        </div>

    </section>

</div>

<script>

    const passwordButtons =
            document.querySelectorAll(
                ".show-password"
            );

    passwordButtons.forEach(
        function (button) {

            button.addEventListener(
                "click",
                function () {

                    const targetId =
                            button.getAttribute(
                                "data-target"
                            );

                    const passwordInput =
                            document.getElementById(
                                targetId
                            );

                    if (passwordInput.type
                            === "password") {

                        passwordInput.type = "text";

                        button.textContent = "HIDE";

                    } else {

                        passwordInput.type = "password";

                        button.textContent = "SHOW";
                    }
                }
            );
        }
    );

</script>

</body>

</html>