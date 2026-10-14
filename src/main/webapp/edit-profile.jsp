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

    Object sessionUser = session.getAttribute("loggedInUser");

    if (!(sessionUser instanceof User)) {
        response.sendRedirect(contextPath + "/login");
        return;
    }

    Object profileAttribute = request.getAttribute("profileUser");
    Object tokenAttribute = session.getAttribute("profileCsrfToken");

    if (!(profileAttribute instanceof User)
            || !(tokenAttribute instanceof String)) {
        response.sendRedirect(contextPath + "/edit-profile");
        return;
    }

    User profileUser = (User) profileAttribute;

    if (profileUser.getUserId()
            != ((User) sessionUser).getUserId()) {
        response.sendError(403);
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

    <title>Edit Profile | CraveGo</title>

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
            max-width: 1040px;
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

        .edit-layout {
            display: grid;
            grid-template-columns: 290px minmax(0, 1fr);
            border: 1px solid #eadfce;
            border-radius: 22px;
            overflow: hidden;
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
            font-family: Georgia, "Times New Roman", serif;
            font-size: 36px;
            line-height: 1.15;
        }

        .intro p {
            margin: 0;
            color: #c1cad7;
            font-size: 13px;
            line-height: 1.8;
        }

        .intro-note {
            margin-top: 30px;
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

        .fields {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 21px 18px;
        }

        .field.full {
            grid-column: 1 / -1;
        }

        label {
            display: block;
            margin-bottom: 9px;
            color: #394556;
            font-size: 12px;
            font-weight: 700;
        }

        input,
        textarea {
            width: 100%;
            padding: 13px 14px;
            color: var(--navy);
            background: #fff;
            border: 1px solid #d8dcd9;
            border-radius: 10px;
            font: inherit;
            font-size: 14px;
        }

        textarea {
            min-height: 115px;
            resize: vertical;
            line-height: 1.7;
        }

        input:focus,
        textarea:focus {
            outline: 2px solid var(--mint);
            outline-offset: 2px;
        }

        .hint {
            margin: 8px 0 0;
            color: #626c7a;
            font-size: 11px;
            line-height: 1.5;
        }

        .actions {
            margin-top: 27px;
            padding-top: 23px;
            border-top: 1px solid #eadfce;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 12px;
        }

        .cancel,
        .save {
            padding: 13px 20px;
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
            outline-offset: 4px;
        }

        @media (max-width: 720px) {
            .navbar {
                padding: 18px;
                flex-wrap: wrap;
            }

            main {
                padding: 25px 16px 45px;
            }

            .edit-layout {
                grid-template-columns: 1fr;
            }

            .intro {
                padding: 27px 24px;
            }

            .intro h1 {
                font-size: 31px;
            }

            .intro-note {
                margin-top: 18px;
            }

            .form-panel {
                padding: 27px 24px;
            }
        }

        @media (max-width: 430px) {
            .fields {
                grid-template-columns: 1fr;
            }

            .actions {
                justify-content: stretch;
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
        <span>Edit Profile</span>
    </div>

    <div class="edit-layout">
        <aside class="intro">
            <div class="eyebrow">MAKE IT YOURS</div>
            <h1>A little update.<br>A better delivery.</h1>
            <p>
                Keep your contact information and delivery
                address up to date.
            </p>

            <div class="intro-note">
                Use a phone number where you can be reached
                and include your building and area in the address.
            </div>
        </aside>

        <section class="form-panel" aria-labelledby="form-title">
            <h2 id="form-title">Edit your profile</h2>
            <p class="description">
                All fields are required. Save your changes when ready.
            </p>

            <% if (errorMessage != null) { %>
                <div class="error" role="alert">
                    <%= escapeHtml(errorMessage) %>
                </div>
            <% } %>

            <form action="<%= escapeHtml(contextPath + "/edit-profile") %>"
                  method="post">

                <input type="hidden"
                       name="csrfToken"
                       value="<%= escapeHtml(csrfToken) %>">

                <div class="fields">
                    <div class="field">
                        <label for="username">Username</label>
                        <input type="text"
                               id="username"
                               name="username"
                               value="<%= escapeHtml(profileUser.getUsername()) %>"
                               minlength="2"
                               maxlength="50"
                               autocomplete="nickname"
                               required>
                    </div>

                    <div class="field">
                        <label for="email">Email address</label>
                        <input type="email"
                               id="email"
                               name="email"
                               value="<%= escapeHtml(profileUser.getEmail()) %>"
                               maxlength="100"
                               autocomplete="email"
                               required>
                    </div>

                    <div class="field full">
                        <label for="phone">Phone number</label>
                        <input type="tel"
                               id="phone"
                               name="phone"
                               value="<%= escapeHtml(profileUser.getPhone()) %>"
                               pattern="[6-9][0-9]{9}"
                               minlength="10"
                               maxlength="10"
                               inputmode="numeric"
                               autocomplete="tel-national"
                               aria-describedby="phone-hint"
                               title="Enter a 10-digit Indian mobile number starting with 6, 7, 8 or 9"
                               required>

                        <p class="hint" id="phone-hint">
                            Enter 10 digits without +91 or spaces.
                        </p>
                    </div>

                    <div class="field full">
                        <label for="address">Delivery address</label>
                        <textarea id="address"
                                  name="address"
                                  minlength="5"
                                  maxlength="255"
                                  autocomplete="street-address"
                                  required><%= escapeHtml(profileUser.getAddress()) %></textarea>
                    </div>
                </div>

                <div class="actions">
                    <a class="cancel"
                       href="<%= escapeHtml(contextPath + "/profile") %>">
                        Cancel
                    </a>

                    <button class="save" type="submit">
                        Save Changes
                    </button>
                </div>
            </form>
        </section>
    </div>
</main>

</body>
</html>