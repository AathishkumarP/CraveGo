<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
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
%>

<%
    response.setHeader("Cache-Control", "no-store");

    String contextPath = request.getContextPath();

    if (!(session.getAttribute("loggedInUser") instanceof User)) {
        response.sendRedirect(contextPath + "/login");
        return;
    }

    Object tokenAttribute = session.getAttribute("passwordCsrfToken");

    if (!Boolean.TRUE.equals(
                request.getAttribute("passwordFormReady")
            )
            || !(tokenAttribute instanceof String)) {

        response.sendRedirect(contextPath + "/change-password");
        return;
    }

    String csrfToken = (String) tokenAttribute;

    Object errorAttribute = request.getAttribute("errorMessage");

    String errorMessage = errorAttribute instanceof String
            ? (String) errorAttribute
            : null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Change Password | CraveGo</title>

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

        button,
        input {
            font: inherit;
        }

        .header {
            background: #fffaf4;
            border-bottom: 1px solid #eadfce;
        }

        .navbar {
            max-width: 1120px;
            min-height: 88px;
            margin: auto;
            padding: 18px 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 22px;
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

        .back-link:hover {
            color: #e95234;
        }

        main {
            max-width: 1000px;
            margin: auto;
            padding: 38px 28px 65px;
        }

        .breadcrumb {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 25px;
            color: #626c7a;
            font-size: 12px;
        }

        .layout {
            display: grid;
            grid-template-columns: 290px minmax(0, 1fr);
            overflow: hidden;
            border: 1px solid #eadfce;
            border-radius: 22px;
            box-shadow: 0 12px 35px rgba(17, 24, 39, .06);
        }

        .intro {
            position: relative;
            overflow: hidden;
            padding: 38px 29px;
            color: #fff;
            background: var(--navy);
        }

        .intro::after {
            content: "";
            position: absolute;
            width: 200px;
            height: 200px;
            right: -90px;
            bottom: -80px;
            border: 35px solid rgba(255, 255, 255, .045);
            border-radius: 50%;
            pointer-events: none;
        }

        .eyebrow {
            color: var(--yellow);
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 2px;
        }

        .intro h1 {
            margin: 18px 0;
            font-family: Georgia, serif;
            font-size: 35px;
            line-height: 1.2;
        }

        .intro p {
            margin: 0;
            color: #c1cad7;
            font-size: 13px;
            line-height: 1.8;
        }

        .intro-note {
            margin-top: 28px;
            padding: 17px;
            color: #dff8ef;
            background: #213b35;
            border: 1px solid #35594d;
            border-radius: 12px;
            font-size: 12px;
            line-height: 1.7;
        }

        .form-panel {
            padding: 35px;
            background: #fffdf8;
        }

        .form-panel h2 {
            margin: 0 0 10px;
            font-size: 23px;
        }

        .description {
            margin: 0 0 27px;
            color: #626c7a;
            font-size: 12px;
            line-height: 1.7;
        }

        .error {
            margin-bottom: 23px;
            padding: 15px;
            color: #9b2339;
            background: #ffedf0;
            border: 1px solid #f2c8d1;
            border-radius: 10px;
            font-size: 13px;
            line-height: 1.6;
        }

        .field {
            margin-bottom: 22px;
        }

        label {
            display: block;
            margin-bottom: 9px;
            color: #394556;
            font-size: 12px;
            font-weight: 700;
        }

        .input-wrapper {
            position: relative;
        }

        input[type="password"],
        input[type="text"] {
            width: 100%;
            padding: 14px 72px 14px 14px;
            color: var(--navy);
            background: #fff;
            border: 1px solid #d8dcd9;
            border-radius: 10px;
            font-size: 14px;
        }

        input:focus {
            outline: 2px solid var(--mint);
            outline-offset: 2px;
        }

        .toggle {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            padding: 8px;
            color: #495668;
            background: transparent;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 11px;
            font-weight: 700;
        }

        .toggle:hover {
            background: #edf0f3;
        }

        .hint {
            margin: 8px 0 0;
            color: #626c7a;
            font-size: 11px;
            line-height: 1.6;
        }

        .actions {
            margin-top: 26px;
            padding-top: 23px;
            border-top: 1px solid #eadfce;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 12px;
        }

        .cancel,
        .save {
            padding: 13px 18px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 800;
        }

        .cancel {
            background: #edf0f3;
        }

        .cancel:hover {
            background: #e0e5ea;
        }

        .save {
            color: #fff;
            background: #e95234;
            border: none;
            cursor: pointer;
        }

        .save:hover {
            background: #cc4226;
        }

        a:focus-visible,
        button:focus-visible {
            outline: 3px solid var(--mint);
            outline-offset: 3px;
        }

        @media (max-width: 720px) {
            .navbar {
                padding: 18px;
                flex-wrap: wrap;
            }

            main {
                padding: 25px 16px 45px;
            }

            .layout {
                grid-template-columns: 1fr;
            }

            .intro {
                padding: 27px 24px;
            }

            .intro h1 {
                font-size: 30px;
            }

            .intro-note {
                margin-top: 18px;
            }

            .form-panel {
                padding: 27px 24px;
            }
        }

        @media (max-width: 430px) {
            .actions {
                flex-wrap: wrap;
            }

            .cancel,
            .save {
                flex: 1;
                text-align: center;
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
           href="<%= escapeHtml(contextPath + "/profile") %>">
            &#8592; Back to My Account
        </a>
    </nav>
</header>

<main>
    <div class="breadcrumb">
        <a href="<%= escapeHtml(contextPath + "/") %>">Home</a>
        <span aria-hidden="true">/</span>

        <a href="<%= escapeHtml(contextPath + "/profile") %>">
            My Account
        </a>

        <span aria-hidden="true">/</span>
        <span>Change Password</span>
    </div>

    <div class="layout">
        <aside class="intro">
            <div class="eyebrow">YOUR ACCOUNT, YOUR KEY</div>
            <h1>A fresh password.<br>A fresh start.</h1>

            <p>
                Enter your current password, then choose
                a new password for your CraveGo account.
            </p>

            <div class="intro-note">
                Choose a unique password with at least
                8 characters. A longer passphrase is easier
                to remember.
            </div>
        </aside>

        <section class="form-panel" aria-labelledby="form-title">
            <h2 id="form-title">Change password</h2>

            <p class="description">
                All three fields are required.
            </p>

            <% if (errorMessage != null) { %>
                <div class="error" role="alert">
                    <%= escapeHtml(errorMessage) %>
                </div>
            <% } %>

            <form id="password-form"
                  action="<%= escapeHtml(contextPath + "/change-password") %>"
                  method="post">

                <input type="hidden"
                       name="csrfToken"
                       value="<%= escapeHtml(csrfToken) %>">

                <div class="field">
                    <label for="currentPassword">Current password</label>

                    <div class="input-wrapper">
                        <input type="password"
                               id="currentPassword"
                               name="currentPassword"
                               autocomplete="current-password"
                               required>

                        <button class="toggle"
                                type="button"
                                data-target="currentPassword"
                                aria-controls="currentPassword"
                                aria-label="Show current password"
                                aria-pressed="false">
                            Show
                        </button>
                    </div>
                </div>

                <div class="field">
                    <label for="newPassword">New password</label>

                    <div class="input-wrapper">
                        <input type="password"
                               id="newPassword"
                               name="newPassword"
                               minlength="8"
                               autocomplete="new-password"
                               aria-describedby="password-hint"
                               required>

                        <button class="toggle"
                                type="button"
                                data-target="newPassword"
                                aria-controls="newPassword"
                                aria-label="Show new password"
                                aria-pressed="false">
                            Show
                        </button>
                    </div>

                    <p class="hint" id="password-hint">
                        At least 8 characters, different from your current password.
                    </p>
                </div>

                <div class="field">
                    <label for="confirmPassword">Confirm new password</label>

                    <div class="input-wrapper">
                        <input type="password"
                               id="confirmPassword"
                               name="confirmPassword"
                               minlength="8"
                               autocomplete="new-password"
                               required>

                        <button class="toggle"
                                type="button"
                                data-target="confirmPassword"
                                aria-controls="confirmPassword"
                                aria-label="Show password confirmation"
                                aria-pressed="false">
                            Show
                        </button>
                    </div>
                </div>

                <div class="actions">
                    <a class="cancel"
                       href="<%= escapeHtml(contextPath + "/profile") %>">
                        Cancel
                    </a>

                    <button class="save" type="submit">
                        Update Password
                    </button>
                </div>
            </form>
        </section>
    </div>
</main>

<script>
    document.querySelectorAll(".toggle").forEach(function (button) {
        const originalLabel = button.getAttribute("aria-label");

        button.addEventListener("click", function () {
            const input = document.getElementById(button.dataset.target);
            const visible = input.type === "password";

            input.type = visible ? "text" : "password";
            button.textContent = visible ? "Hide" : "Show";
            button.setAttribute("aria-pressed", String(visible));
            button.setAttribute(
                "aria-label",
                visible ? originalLabel.replace("Show", "Hide") : originalLabel
            );
        });
    });

    const currentPassword = document.getElementById("currentPassword");
    const newPassword = document.getElementById("newPassword");
    const confirmPassword = document.getElementById("confirmPassword");

    function validatePasswords() {
        newPassword.setCustomValidity(
            newPassword.value
            && newPassword.value === currentPassword.value
                ? "Choose a password different from your current password."
                : ""
        );

        confirmPassword.setCustomValidity(
            confirmPassword.value
            && confirmPassword.value !== newPassword.value
                ? "The new password and confirmation do not match."
                : ""
        );
    }

    [currentPassword, newPassword, confirmPassword].forEach(function (input) {
        input.addEventListener("input", validatePasswords);
    });
</script>

</body>
</html>