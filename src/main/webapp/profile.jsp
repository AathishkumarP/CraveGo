<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="com.cravego.model.User" %>
<%@ page import="java.util.Locale" %>

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

    private String displayValue(String value) {
        return value == null || value.isBlank()
                ? "Not provided"
                : value;
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

    if (!(profileAttribute instanceof User)) {
        response.sendRedirect(contextPath + "/profile");
        return;
    }

    User profileUser = (User) profileAttribute;
    User loggedInUser = (User) sessionUser;

    if (profileUser.getUserId() != loggedInUser.getUserId()) {
        response.sendError(403);
        return;
    }

    String username = displayValue(profileUser.getUsername());

    String initial = profileUser.getUsername() == null
            || profileUser.getUsername().isBlank()
            ? "U"
            : profileUser.getUsername().trim()
                         .substring(0, 1)
                         .toUpperCase(Locale.ROOT);

    Object successAttribute =
            session.getAttribute("profileSuccessMessage");

    String successMessage = successAttribute instanceof String
            ? (String) successAttribute
            : null;

    if (successMessage != null) {
        session.removeAttribute("profileSuccessMessage");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>My Account | CraveGo</title>

    <style>
        :root {
            --navy: #111827;
            --coral: #ff6647;
            --coral-dark: #e95234;
            --mint: #29b783;
            --mint-light: #dff8ef;
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
            max-width: 1200px;
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
            flex-shrink: 0;
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

        .nav-links {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 7px;
        }

        .nav-link {
            padding: 11px 14px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 700;
        }

        .nav-link:hover,
        .nav-link.active {
            color: var(--coral-dark);
            background: #fff1ec;
        }

        .cart-link {
            color: #147451;
            background: var(--mint-light);
        }

        main {
            max-width: 1120px;
            margin: auto;
            padding: 32px 28px 65px;
        }

        .breadcrumb {
            display: flex;
            gap: 10px;
            margin-bottom: 25px;
            color: #626c7a;
            font-size: 12px;
        }

        .breadcrumb a:hover {
            color: var(--coral-dark);
        }

        .account-banner {
            position: relative;
            overflow: hidden;
            padding: 34px 38px;
            color: #fff;
            background: linear-gradient(120deg, #111827, #24364b);
            border-radius: 22px;
            box-shadow: 0 12px 30px rgba(17, 24, 39, .12);
        }

        .account-banner::after {
            content: "";
            position: absolute;
            width: 210px;
            height: 210px;
            top: -85px;
            right: -45px;
            border: 35px solid rgba(255, 255, 255, .04);
            border-radius: 50%;
            pointer-events: none;
        }

        .eyebrow {
            color: var(--yellow);
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 2px;
        }

        h1 {
            margin: 12px 0;
            font-family: Georgia, "Times New Roman", serif;
            font-size: 39px;
            letter-spacing: -.8px;
        }

        .account-banner p {
            margin: 0;
            color: #bec5d0;
            font-size: 13px;
            line-height: 1.7;
        }

        .success-message {
            margin-top: 22px;
            padding: 16px 20px;
            color: #14583f;
            background: var(--mint-light);
            border: 1px solid #b8e4d2;
            border-radius: 12px;
            font-size: 13px;
            line-height: 1.7;
        }

        .account-layout {
            display: grid;
            grid-template-columns: 260px minmax(0, 1fr);
            align-items: start;
            gap: 24px;
            margin-top: 28px;
        }

        .sidebar {
            padding: 25px 16px 16px;
            color: #fff;
            background: var(--navy);
            border: 1px solid #263448;
            border-radius: 18px;
            box-shadow: 0 12px 28px rgba(17, 24, 39, .12);
        }

        .identity {
            padding: 0 10px 24px;
            text-align: center;
            border-bottom: 1px solid #344155;
        }

        .avatar {
            width: 72px;
            height: 72px;
            display: grid;
            place-items: center;
            margin: 0 auto 15px;
            color: #fff;
            background: var(--coral);
            border: 5px solid #354052;
            border-radius: 50%;
            font-size: 29px;
            font-weight: 800;
        }

        .identity h2 {
            margin: 0 0 8px;
            color: #fff;
            font-size: 18px;
            overflow-wrap: anywhere;
        }

        .identity p {
            margin: 0;
            color: #c1cad7;
            font-size: 11px;
            overflow-wrap: anywhere;
            line-height: 1.6;
        }

        .account-menu {
            display: grid;
            gap: 7px;
            margin-top: 18px;
        }

        .menu-link {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px;
            color: #e5eaf1;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 700;
        }

        .menu-link:hover {
            background: #263448;
        }

        .menu-link.selected {
            color: #fff;
            background: var(--coral-dark);
        }

        .menu-link.logout {
            color: #ffb5b5;
        }

        .menu-link.logout:hover {
            background: #392737;
        }

        .content {
            display: grid;
            gap: 20px;
        }

        .profile-card {
            padding: 28px;
            background: #fffdf8;
            border: 1px solid #eadfce;
            border-radius: 18px;
            box-shadow: 0 8px 24px rgba(94, 66, 30, .05);
        }

        .profile-heading {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 20px;
        }

        .section-heading {
            padding-left: 15px;
            border-left: 4px solid var(--coral);
        }

        .section-heading h2 {
            margin: 0 0 9px;
            font-size: 21px;
            letter-spacing: -.4px;
        }

        .section-heading p {
            margin: 0;
            color: #626c7a;
            font-size: 12px;
            line-height: 1.7;
        }

        .details {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
            margin: 27px 0 0;
            padding-top: 25px;
            border-top: 1px solid #eadfce;
        }

        .detail {
            padding: 19px;
            background: #fff0e5;
            border: 1px solid #f0d7c7;
            border-radius: 13px;
        }

        .detail:nth-child(2) {
            background: #eaf6f0;
            border-color: #cee5d8;
        }

        .detail:nth-child(3) {
            background: #fff4d9;
            border-color: #eadcaa;
        }

        .detail:nth-child(4) {
            background: #edf0fb;
            border-color: #d8dff2;
        }

        .detail dt {
            margin-bottom: 10px;
            color: #596474;
            font-size: 11px;
            font-weight: 700;
        }

        .detail dd {
            margin: 0;
            color: #172337;
            font-size: 14px;
            font-weight: 700;
            line-height: 1.7;
            overflow-wrap: anywhere;
        }

        .detail.address {
            grid-column: 1 / -1;
            padding: 20px;
            background: #eaf4f7;
            border-color: #cedfe7;
        }

        .detail.address dd {
            white-space: pre-wrap;
        }

        .orders-card {
            padding: 25px 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 22px;
            background: var(--mint-light);
            border: 1px solid #b8e4d2;
            border-radius: 18px;
            box-shadow: 0 8px 24px rgba(20, 116, 81, .05);
        }

        .orders-card h2 {
            margin: 0 0 9px;
            color: #14583f;
            font-size: 18px;
        }

        .orders-card p {
            margin: 0;
            color: #386654;
            font-size: 12px;
            line-height: 1.7;
        }

        .button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            flex-shrink: 0;
            padding: 13px 18px;
            color: #fff;
            background: var(--coral-dark);
            border-radius: 10px;
            font-size: 12px;
            font-weight: 800;
        }

        .button:hover {
            background: #cc4226;
        }

        .orders-card .button {
            background: var(--navy);
        }

        .orders-card .button:hover {
            background: #263448;
        }

        .footer-note {
            margin-top: 32px;
            text-align: center;
            color: #626c7a;
            font-size: 11px;
        }

        a:focus-visible {
            outline: 3px solid var(--mint);
            outline-offset: 4px;
        }

        @media (max-width: 750px) {
            .navbar {
                flex-wrap: wrap;
                padding: 18px;
            }

            .nav-link {
                padding: 9px 10px;
                font-size: 11px;
            }

            main {
                padding: 25px 16px 45px;
            }

            .account-banner {
                padding: 28px 24px;
            }

            h1 {
                font-size: 32px;
            }

            .account-layout {
                grid-template-columns: 1fr;
                gap: 18px;
            }

            .sidebar {
                padding: 20px 16px 16px;
            }

            .identity {
                padding-bottom: 18px;
            }

            .account-menu {
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 5px;
            }

            .menu-link {
                justify-content: center;
                text-align: center;
                padding: 12px 6px;
                font-size: 11px;
            }

            .menu-link .arrow {
                display: none;
            }

            .profile-card {
                padding: 23px;
            }

            .profile-heading {
                flex-wrap: wrap;
            }

            .orders-card {
                padding: 23px;
                flex-wrap: wrap;
            }
        }

        @media (max-width: 420px) {
            .details {
                grid-template-columns: 1fr;
            }

            .orders-card .button {
                width: 100%;
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

        <div class="nav-links">
            <a class="nav-link"
               href="<%= escapeHtml(contextPath + "/") %>">
                Home
            </a>

            <a class="nav-link"
               href="<%= escapeHtml(contextPath + "/restaurants") %>">
                Restaurants
            </a>

            <a class="nav-link"
               href="<%= escapeHtml(contextPath + "/my-orders") %>">
                My Orders
            </a>

            <a class="nav-link active"
               href="<%= escapeHtml(contextPath + "/profile") %>"
               aria-current="page">
                Account
            </a>

            <a class="nav-link cart-link"
               href="<%= escapeHtml(contextPath + "/cart") %>">
                Cart
            </a>
        </div>
    </nav>
</header>

<main>
    <div class="breadcrumb">
        <a href="<%= escapeHtml(contextPath + "/") %>">Home</a>
        <span aria-hidden="true">/</span>
        <span>My Account</span>
    </div>

    <section class="account-banner" aria-labelledby="page-title">
        <div class="eyebrow">YOUR OWN LITTLE CORNER</div>
        <h1 id="page-title">My Account</h1>
        <p>Your profile, delivery details and favourite food memories.</p>
    </section>

    <% if (successMessage != null) { %>
        <div class="success-message" role="status">
            <%= escapeHtml(successMessage) %>
        </div>
    <% } %>

    <div class="account-layout">

        <aside class="sidebar">
            <div class="identity">
                <div class="avatar" aria-hidden="true">
                    <%= escapeHtml(initial) %>
                </div>

                <h2><%= escapeHtml(username) %></h2>

                <p>
                    <%= escapeHtml(displayValue(
                            profileUser.getEmail()
                    )) %>
                </p>
            </div>

            <nav class="account-menu" aria-label="Account navigation">
                <a class="menu-link selected"
                   href="<%= escapeHtml(contextPath + "/profile") %>"
                   aria-current="page">
                    <span>My Profile</span>
                    <span class="arrow" aria-hidden="true">&#8594;</span>
                </a>

                <a class="menu-link"
                   href="<%= escapeHtml(contextPath + "/my-orders") %>">
                    <span>My Orders</span>
                    <span class="arrow" aria-hidden="true">&#8594;</span>
                </a>
                
				<a class="menu-link"
				   href="<%= escapeHtml(contextPath + "/change-password") %>">
				    <span>Change Password</span>
				    <span class="arrow" aria-hidden="true">&#8594;</span>
				</a>

                <a class="menu-link logout"
                   href="<%= escapeHtml(contextPath + "/logout") %>">
                    <span>Logout</span>
                    <span class="arrow" aria-hidden="true">&#8594;</span>
                </a>
            </nav>
        </aside>

        <div class="content">
            <section class="profile-card"
                     aria-labelledby="profile-heading">

                <div class="profile-heading">
                    <div class="section-heading">
                        <h2 id="profile-heading">Personal details</h2>
                        <p>Your account information and delivery address.</p>
                    </div>

                    <a class="button"
                       href="<%= escapeHtml(contextPath + "/edit-profile") %>">
                        Edit Profile
                    </a>
                </div>

                <dl class="details">
                    <div class="detail">
                        <dt>Username</dt>
                        <dd><%= escapeHtml(username) %></dd>
                    </div>

                    <div class="detail">
                        <dt>Email address</dt>
                        <dd>
                            <%= escapeHtml(displayValue(
                                    profileUser.getEmail()
                            )) %>
                        </dd>
                    </div>

                    <div class="detail">
                        <dt>Phone number</dt>
                        <dd>
                            <%= escapeHtml(displayValue(
                                    profileUser.getPhone()
                            )) %>
                        </dd>
                    </div>

                    <div class="detail">
                        <dt>Account role</dt>
                        <dd>
                            <%= escapeHtml(displayValue(
                                    profileUser.getRole()
                            )) %>
                        </dd>
                    </div>

                    <div class="detail address">
                        <dt>Delivery address</dt>
                        <dd><%= escapeHtml(displayValue(profileUser.getAddress())) %></dd>
                    </div>
                </dl>
            </section>

            <section class="orders-card">
                <div>
                    <h2>Your orders</h2>
                    <p>
                        View previous orders and track your latest delivery.
                    </p>
                </div>

                <a class="button"
                   href="<%= escapeHtml(contextPath + "/my-orders") %>">
                    View My Orders
                    <span aria-hidden="true">&#8594;</span>
                </a>
            </section>
        </div>
    </div>

    <div class="footer-note">
        Made for your cravings. Delivered with care.
    </div>
</main>

</body>
</html>