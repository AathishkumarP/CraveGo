<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="com.cravego.model.User" %>
<%@ page import="java.util.Map" %>

<%
    String contextPath =
            request.getContextPath();

    User loggedInUser =
            (User) session.getAttribute(
                    "loggedInUser"
            );

    Map<Integer, Integer> cart =
            (Map<Integer, Integer>)
            session.getAttribute("cart");

    int cartCount = 0;

    if (cart != null) {

        for (Integer quantity : cart.values()) {

            if (quantity != null) {
                cartCount += quantity;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>CraveGo | Bengaluru Food Delivery</title>

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
            --border: #e7e9ed;
            --yellow: #ffc857;
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

        img {
            display: block;
        }

        /* =========================
           NAVBAR
        ========================= */

        .navbar-wrapper {
            position: absolute;
            top: 0;
            left: 0;
            z-index: 100;
            width: 100%;
            padding: 22px 5%;
        }

        .navbar {
            width: min(1240px, 100%);
            min-height: 72px;
            margin: auto;
            padding: 12px 15px 12px 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 25px;
            background-color: rgba(255, 255, 255, 0.96);
            border: 1px solid rgba(255, 255, 255, 0.8);
            border-radius: 22px;
            box-shadow: 0 15px 40px rgba(17, 24, 39, 0.13);
            backdrop-filter: blur(13px);
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 11px;
        }

        .logo-symbol {
            position: relative;
            width: 43px;
            height: 43px;
            display: grid;
            place-items: center;
            overflow: hidden;
            color: var(--white);
            background-color: var(--coral);
            border-radius: 14px 14px 14px 4px;
            font-size: 21px;
            font-weight: 900;
        }

        .logo-symbol::after {
            content: "";
            position: absolute;
            right: -7px;
            bottom: -7px;
            width: 20px;
            height: 20px;
            background-color: var(--yellow);
            border-radius: 50%;
        }

        .logo-text {
            color: var(--navy);
            font-size: 25px;
            font-weight: 900;
            letter-spacing: -1px;
        }

        .logo-text span {
            color: var(--coral);
        }

        .navbar-links {
            display: flex;
            align-items: center;
            gap: 13px;
        }

        .nav-link,
        .welcome-text {
            padding: 10px 13px;
            color: var(--navy);
            font-size: 14px;
            font-weight: 700;
        }

        .nav-link:hover {
            color: var(--coral);
        }

        .login-link {
            padding: 11px 19px;
            color: var(--navy);
            border: 1px solid var(--border);
            border-radius: 12px;
            font-size: 14px;
            font-weight: 800;
        }

        .login-link:hover {
            border-color: var(--coral);
        }

        .signup-link,
        .logout-link {
            padding: 12px 20px;
            color: var(--white);
            background-color: var(--navy);
            border-radius: 12px;
            font-size: 14px;
            font-weight: 800;
        }

        .signup-link:hover,
        .logout-link:hover {
            background-color: var(--coral);
        }

        .cart-link {
            padding: 10px 15px;
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--navy);
            background-color: var(--mint-light);
            border-radius: 12px;
            font-size: 14px;
            font-weight: 800;
        }

        .cart-count {
            min-width: 23px;
            height: 23px;
            padding: 0 6px;
            display: grid;
            place-items: center;
            color: var(--white);
            background-color: var(--mint);
            border-radius: 50px;
            font-size: 11px;
        }

        /* =========================
           HERO SECTION
        ========================= */

        .hero {
            position: relative;
            min-height: 760px;
            overflow: hidden;
            background-color: var(--navy);
        }

        .hero::before {
            content: "";
            position: absolute;
            top: -200px;
            right: -80px;
            width: 600px;
            height: 600px;
            background-color: rgba(41, 183, 131, 0.15);
            border-radius: 50%;
            filter: blur(5px);
        }

        .hero::after {
            content: "";
            position: absolute;
            left: -230px;
            bottom: -280px;
            width: 580px;
            height: 580px;
            background-color: rgba(255, 102, 71, 0.14);
            border-radius: 50%;
        }

        .hero-inner {
            position: relative;
            z-index: 2;
            width: min(1240px, 90%);
            min-height: 760px;
            margin: auto;
            padding-top: 135px;
            display: grid;
            grid-template-columns: 1.05fr 0.95fr;
            align-items: center;
            gap: 65px;
        }

        .hero-label {
            width: fit-content;
            padding: 9px 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            color: #dff8ef;
            background-color: rgba(41, 183, 131, 0.14);
            border: 1px solid rgba(41, 183, 131, 0.35);
            border-radius: 50px;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.8px;
            text-transform: uppercase;
        }

        .hero-label-dot {
            width: 8px;
            height: 8px;
            background-color: var(--mint);
            border-radius: 50%;
            box-shadow: 0 0 0 5px rgba(41, 183, 131, 0.15);
        }

        .hero-content h1 {
            max-width: 680px;
            margin-top: 25px;
            color: var(--white);
            font-family: Georgia, "Times New Roman", serif;
            font-size: clamp(48px, 6vw, 77px);
            font-weight: 700;
            line-height: 1.04;
            letter-spacing: -2.5px;
        }

        .hero-content h1 span {
            color: var(--coral);
        }

        .hero-description {
            max-width: 590px;
            margin-top: 22px;
            color: #b9c1cf;
            font-size: 18px;
            line-height: 1.7;
        }

        /* =========================
           SEARCH PANEL
        ========================= */

        .search-panel {
            max-width: 650px;
            margin-top: 32px;
            padding: 10px;
            display: grid;
            grid-template-columns: 0.75fr 1.25fr;
            gap: 8px;
            background-color: var(--white);
            border-radius: 18px;
            box-shadow: 0 20px 45px rgba(0, 0, 0, 0.25);
        }

        .location-box {
            padding: 0 14px;
            display: flex;
            align-items: center;
            gap: 9px;
            border-right: 1px solid var(--border);
        }

        .location-icon {
            color: var(--coral);
            font-size: 21px;
        }

        .location-text {
            overflow: hidden;
        }

        .location-text small {
            display: block;
            color: var(--muted);
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .location-text strong {
            display: block;
            margin-top: 3px;
            overflow: hidden;
            color: var(--navy);
            font-size: 13px;
            white-space: nowrap;
            text-overflow: ellipsis;
        }

        .search-form {
            min-height: 54px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .search-form input {
            width: 100%;
            padding: 0 8px;
            color: var(--navy);
            background: transparent;
            border: none;
            outline: none;
            font-size: 14px;
        }

        .search-button {
            height: 46px;
            padding: 0 20px;
            color: var(--white);
            background-color: var(--coral);
            border: none;
            border-radius: 12px;
            font-weight: 800;
            cursor: pointer;
        }

        .search-button:hover {
            background-color: var(--coral-dark);
        }

        /* =========================
           HERO STATISTICS
        ========================= */

        .hero-statistics {
            margin-top: 37px;
            display: flex;
            align-items: center;
            gap: 32px;
            flex-wrap: wrap;
        }

        .statistic strong {
            display: block;
            color: var(--white);
            font-size: 22px;
        }

        .statistic span {
            display: block;
            margin-top: 4px;
            color: #8e99aa;
            font-size: 12px;
        }

        .statistic-divider {
            width: 1px;
            height: 38px;
            background-color: rgba(255, 255, 255, 0.15);
        }

        /* =========================
           IMAGE COLLAGE
        ========================= */

        .hero-visual {
            position: relative;
            height: 570px;
        }

        .image-card {
            position: absolute;
            overflow: hidden;
            border: 5px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 25px 55px rgba(0, 0, 0, 0.3);
        }

        .image-card img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .image-one {
            top: 25px;
            right: 10px;
            width: 340px;
            height: 390px;
            border-radius: 110px 28px 90px 28px;
        }

        .image-two {
            left: 10px;
            bottom: 25px;
            width: 265px;
            height: 270px;
            border-radius: 32px 90px 28px 85px;
        }

        .image-three {
            right: 35px;
            bottom: 15px;
            width: 210px;
            height: 190px;
            border-radius: 80px 25px 25px 25px;
        }

        .delivery-card {
            position: absolute;
            top: 80px;
            left: -15px;
            width: 205px;
            padding: 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            background-color: var(--white);
            border-radius: 16px;
            box-shadow: 0 18px 35px rgba(0, 0, 0, 0.22);
        }

        .delivery-icon {
            width: 43px;
            height: 43px;
            display: grid;
            place-items: center;
            flex-shrink: 0;
            color: var(--white);
            background-color: var(--mint);
            border-radius: 12px;
            font-size: 20px;
        }

        .delivery-card strong {
            display: block;
            color: var(--navy);
            font-size: 13px;
        }

        .delivery-card span {
            display: block;
            margin-top: 4px;
            color: var(--muted);
            font-size: 11px;
        }

        .rating-card {
            position: absolute;
            right: -5px;
            top: 390px;
            padding: 12px 17px;
            color: var(--navy);
            background-color: var(--yellow);
            border-radius: 14px;
            font-size: 13px;
            font-weight: 900;
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
        }

        /* =========================
           SECTION COMMON
        ========================= */

        .section {
            width: min(1240px, 90%);
            margin: auto;
            padding: 90px 0;
        }

        .section-top {
            margin-bottom: 32px;
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 25px;
        }

        .eyebrow {
            color: var(--coral);
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
            text-transform: uppercase;
        }

        .section-title {
            margin-top: 9px;
            color: var(--navy);
            font-family: Georgia, "Times New Roman", serif;
            font-size: clamp(31px, 4vw, 44px);
            line-height: 1.15;
        }

        .section-description {
            max-width: 470px;
            color: var(--muted);
            font-size: 14px;
            line-height: 1.7;
        }

        /* =========================
           CUISINE SLIDER
        ========================= */

        .cuisine-section {
            background-color: var(--cream);
        }

        .slider-navigation {
            display: flex;
            gap: 9px;
        }

        .slider-button {
            width: 42px;
            height: 42px;
            display: grid;
            place-items: center;
            color: var(--navy);
            background-color: var(--white);
            border: 1px solid var(--border);
            border-radius: 13px;
            font-size: 19px;
            cursor: pointer;
            transition: 0.2s ease;
        }

        .slider-button:hover {
            color: var(--white);
            background-color: var(--navy);
            border-color: var(--navy);
        }

        .slider-button:disabled {
            opacity: 0.35;
            cursor: default;
        }

        .cuisine-slider {
            width: 100%;
            padding: 5px 0 20px;
            overflow-x: auto;
            scroll-behavior: smooth;
            scrollbar-width: none;
            cursor: grab;
            user-select: none;
        }

        .cuisine-slider::-webkit-scrollbar {
            display: none;
        }

        .cuisine-slider.dragging {
            cursor: grabbing;
            scroll-behavior: auto;
        }

        .cuisine-track {
            width: max-content;
            display: flex;
            gap: 20px;
        }

        .cuisine-card {
            position: relative;
            width: 230px;
            height: 290px;
            flex-shrink: 0;
            overflow: hidden;
            background-color: var(--navy);
            border-radius: 24px;
            box-shadow: 0 12px 28px rgba(17, 24, 39, 0.12);
            transition:
                transform 0.25s ease,
                box-shadow 0.25s ease;
        }

        .cuisine-card:nth-child(even) {
            height: 255px;
            margin-top: 35px;
        }

        .cuisine-card:hover {
            transform: translateY(-7px);
            box-shadow: 0 18px 34px rgba(17, 24, 39, 0.2);
        }

        .cuisine-card img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            pointer-events: none;
            transition: transform 0.4s ease;
        }

        .cuisine-card:hover img {
            transform: scale(1.08);
        }

        .cuisine-overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(
                transparent 40%,
                rgba(8, 15, 27, 0.92)
            );
        }

        .cuisine-details {
            position: absolute;
            left: 20px;
            right: 20px;
            bottom: 19px;
            color: var(--white);
        }

        .cuisine-details span {
            color: #d8dce3;
            font-size: 11px;
            font-weight: 700;
        }

        .cuisine-details h3 {
            margin-top: 5px;
            font-family: Georgia, "Times New Roman", serif;
            font-size: 24px;
        }

        /* =========================
           EXPERIENCE SECTION
        ========================= */

        .experience-section {
            background-color: var(--white);
        }

        .experience-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 70px;
            align-items: center;
        }

        .experience-image {
            position: relative;
            min-height: 500px;
        }

        .experience-image-main {
            width: 82%;
            height: 470px;
            object-fit: cover;
            border-radius: 30px 130px 30px 30px;
        }

        .experience-small-image {
            position: absolute;
            right: 0;
            bottom: -20px;
            width: 230px;
            height: 230px;
            object-fit: cover;
            border: 10px solid var(--white);
            border-radius: 50%;
            box-shadow: 0 15px 35px rgba(17, 24, 39, 0.18);
        }

        .experience-content h2 {
            margin-top: 10px;
            color: var(--navy);
            font-family: Georgia, "Times New Roman", serif;
            font-size: clamp(36px, 4vw, 53px);
            line-height: 1.13;
        }

        .experience-content > p {
            margin-top: 20px;
            color: var(--muted);
            font-size: 16px;
            line-height: 1.8;
        }

        .benefit-list {
            margin-top: 30px;
            display: grid;
            gap: 16px;
        }

        .benefit {
            padding: 15px 17px;
            display: flex;
            align-items: center;
            gap: 14px;
            background-color: var(--cream);
            border-radius: 14px;
        }

        .benefit-icon {
            width: 39px;
            height: 39px;
            display: grid;
            place-items: center;
            flex-shrink: 0;
            color: var(--white);
            background-color: var(--mint);
            border-radius: 11px;
            font-weight: 900;
        }

        .benefit strong {
            color: var(--navy);
            font-size: 14px;
        }

        .benefit p {
            margin-top: 3px;
            color: var(--muted);
            font-size: 12px;
        }

        .explore-button {
            margin-top: 30px;
            padding: 15px 24px;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            color: var(--white);
            background-color: var(--coral);
            border-radius: 13px;
            font-weight: 800;
        }

        .explore-button:hover {
            background-color: var(--coral-dark);
        }

        /* =========================
           FEATURED RESTAURANTS
        ========================= */

        .restaurant-section {
            background-color: #f0f7f5;
        }

        .restaurant-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
        }

        .restaurant-card {
            overflow: hidden;
            background-color: var(--white);
            border-radius: 22px;
            box-shadow: 0 8px 25px rgba(17, 24, 39, 0.08);
            transition:
                transform 0.25s ease,
                box-shadow 0.25s ease;
        }

        .restaurant-card:hover {
            transform: translateY(-7px);
            box-shadow: 0 17px 35px rgba(17, 24, 39, 0.14);
        }

        .restaurant-photo {
            position: relative;
            height: 235px;
            overflow: hidden;
        }

        .restaurant-photo img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.4s ease;
        }

        .restaurant-card:hover .restaurant-photo img {
            transform: scale(1.07);
        }

        .restaurant-number {
            position: absolute;
            top: 15px;
            left: 15px;
            width: 42px;
            height: 42px;
            display: grid;
            place-items: center;
            color: var(--navy);
            background-color: var(--yellow);
            border-radius: 13px;
            font-size: 13px;
            font-weight: 900;
        }

        .restaurant-rating {
            position: absolute;
            right: 15px;
            bottom: 15px;
            padding: 8px 11px;
            color: var(--white);
            background-color: var(--mint);
            border-radius: 9px;
            font-size: 12px;
            font-weight: 900;
        }

        .restaurant-content {
            padding: 22px;
        }

        .restaurant-content h3 {
            color: var(--navy);
            font-size: 20px;
        }

        .restaurant-content p {
            margin-top: 8px;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.5;
        }

        .restaurant-footer {
            margin-top: 18px;
            padding-top: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-top: 1px solid var(--border);
        }

        .delivery-time {
            color: var(--navy);
            font-size: 12px;
            font-weight: 800;
        }

        .view-menu {
            color: var(--coral);
            font-size: 12px;
            font-weight: 900;
        }

        /* =========================
           CALL TO ACTION
        ========================= */

        .cta-wrapper {
            padding: 90px 5%;
            background-color: var(--white);
        }

        .cta {
            position: relative;
            width: min(1240px, 100%);
            margin: auto;
            padding: 65px;
            overflow: hidden;
            color: var(--white);
            background-color: var(--navy);
            border-radius: 35px;
        }

        .cta::after {
            content: "";
            position: absolute;
            right: -80px;
            top: -130px;
            width: 390px;
            height: 390px;
            background-color: var(--coral);
            border-radius: 50%;
            opacity: 0.18;
        }

        .cta-content {
            position: relative;
            z-index: 2;
            max-width: 730px;
        }

        .cta h2 {
            font-family: Georgia, "Times New Roman", serif;
            font-size: clamp(35px, 5vw, 55px);
            line-height: 1.15;
        }

        .cta p {
            margin-top: 16px;
            color: #b8c0ce;
            line-height: 1.7;
        }

        .cta-button {
            margin-top: 27px;
            padding: 15px 23px;
            display: inline-block;
            color: var(--navy);
            background-color: var(--yellow);
            border-radius: 12px;
            font-weight: 900;
        }

        /* =========================
           FOOTER
        ========================= */

        .footer {
            padding: 60px 6% 25px;
            color: #aab3c2;
            background-color: #0b101b;
        }

        .footer-content {
            width: min(1240px, 100%);
            margin: auto;
            display: grid;
            grid-template-columns: 1.4fr repeat(3, 1fr);
            gap: 50px;
        }

        .footer-brand h2 {
            color: var(--white);
            font-size: 27px;
        }

        .footer-brand h2 span {
            color: var(--coral);
        }

        .footer-brand p {
            max-width: 330px;
            margin-top: 15px;
            font-size: 13px;
            line-height: 1.8;
        }

        .footer-column h3 {
            margin-bottom: 17px;
            color: var(--white);
            font-size: 14px;
        }

        .footer-column a {
            display: block;
            margin-top: 11px;
            color: #909aab;
            font-size: 13px;
        }

        .footer-column a:hover {
            color: var(--coral);
        }

        .copyright {
            width: min(1240px, 100%);
            margin: 45px auto 0;
            padding-top: 23px;
            border-top: 1px solid #222b39;
            font-size: 12px;
            text-align: center;
        }

        /* =========================
           RESPONSIVE
        ========================= */

        @media (max-width: 1000px) {

            .hero-inner {
                grid-template-columns: 1fr;
                padding-top: 150px;
                padding-bottom: 80px;
            }

            .hero-visual {
                width: min(600px, 100%);
                margin: auto;
            }

            .experience-grid {
                grid-template-columns: 1fr;
            }

            .experience-image {
                width: min(650px, 100%);
            }

            .restaurant-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .footer-content {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 700px) {

            .navbar-wrapper {
                padding: 13px 4%;
            }

            .navbar {
                align-items: flex-start;
            }

            .navbar-links {
                justify-content: flex-end;
                flex-wrap: wrap;
            }

            .welcome-text {
                display: none;
            }

            .hero-inner {
                width: 91%;
                padding-top: 175px;
            }

            .search-panel {
                grid-template-columns: 1fr;
            }

            .location-box {
                padding: 11px 13px;
                border-right: none;
                border-bottom: 1px solid var(--border);
            }

            .hero-visual {
                height: 490px;
            }

            .image-one {
                width: 290px;
                height: 340px;
            }

            .image-two {
                width: 230px;
                height: 235px;
            }

            .image-three {
                width: 175px;
                height: 160px;
            }

            .delivery-card {
                left: 0;
            }

            .section-top {
                align-items: flex-start;
                flex-direction: column;
            }

            .restaurant-grid {
                grid-template-columns: 1fr;
            }

            .cta {
                padding: 45px 30px;
            }
        }

        @media (max-width: 520px) {

            .logo-text {
                font-size: 20px;
            }

            .logo-symbol {
                width: 38px;
                height: 38px;
            }

            .nav-link,
            .login-link,
            .signup-link,
            .logout-link,
            .cart-link {
                padding: 8px 10px;
                font-size: 12px;
            }

            .hero-content h1 {
                font-size: 45px;
            }

            .hero-description {
                font-size: 15px;
            }

            .hero-statistics {
                gap: 15px;
            }

            .statistic-divider {
                display: none;
            }

            .hero-visual {
                height: 420px;
            }

            .image-one {
                right: 0;
                width: 235px;
                height: 290px;
            }

            .image-two {
                width: 185px;
                height: 205px;
            }

            .image-three {
                right: 5px;
                width: 150px;
                height: 135px;
            }

            .delivery-card {
                top: 35px;
                width: 175px;
            }

            .rating-card {
                top: 285px;
            }

            .cuisine-card {
                width: 190px;
                height: 250px;
            }

            .cuisine-card:nth-child(even) {
                height: 225px;
                margin-top: 25px;
            }

            .experience-image-main {
                width: 100%;
                height: 400px;
            }

            .experience-small-image {
                width: 170px;
                height: 170px;
            }

            .footer-content {
                grid-template-columns: 1fr;
            }
        }

    </style>

</head>

<body>

<!-- =========================
     NAVIGATION
========================= -->

<div class="navbar-wrapper">

    <header class="navbar">

        <a class="logo"
           href="<%= contextPath %>/">

            <span class="logo-symbol">C</span>

            <span class="logo-text">
                Crave<span>Go</span>
            </span>

        </a>

        <nav class="navbar-links">

            <% if (loggedInUser == null) { %>

                <a class="login-link"
                   href="<%= contextPath %>/login">
                    Login
                </a>

                <a class="signup-link"
                   href="<%= contextPath %>/register">
                    Create Account
                </a>

            <% } else { %>

                <span class="welcome-text">
                    Hi, <%= loggedInUser.getUsername() %>
                </span>

                <a class="nav-link"
                   href="<%= contextPath %>/restaurants">
                    Restaurants
                </a>

                <a class="cart-link"
                   href="<%= contextPath %>/cart">

                    Cart

                    <span class="cart-count">
                        <%= cartCount %>
                    </span>

                </a>

                <a class="logout-link"
                   href="<%= contextPath %>/logout">
                    Logout
                </a>

            <% } %>

        </nav>

    </header>

</div>

<!-- =========================
     HERO
========================= -->

<section class="hero">

    <div class="hero-inner">

        <div class="hero-content">

            <div class="hero-label">

                <span class="hero-label-dot"></span>

                Delivering across Bengaluru

            </div>

            <h1>
                Bengaluru’s flavours,
                <span>one craving away.</span>
            </h1>

            <p class="hero-description">
                Discover trusted neighbourhood kitchens,
                comforting classics and exciting new flavours—
                delivered wherever your day takes you.
            </p>

            <div class="search-panel">

                <div class="location-box">

                    <span class="location-icon">⌖</span>

                    <div class="location-text">

                        <small>Delivering to</small>

                        <strong>
                            Bengaluru, Karnataka
                        </strong>

                    </div>

                </div>

                <form class="search-form"
                      action="<%= contextPath %>/restaurants"
                      method="get">

                    <input type="text"
                           name="search"
                           placeholder="What are you craving today?"
                           autocomplete="off">

                    <button class="search-button"
                            type="submit">
                        Find Food
                    </button>

                </form>

            </div>

            <div class="hero-statistics">

                <div class="statistic">

                    <strong>30+</strong>

                    <span>Local restaurants</span>

                </div>

                <span class="statistic-divider"></span>

                <div class="statistic">

                    <strong>450+</strong>

                    <span>Fresh dishes</span>

                </div>

                <span class="statistic-divider"></span>

                <div class="statistic">

                    <strong>30 min</strong>

                    <span>Average delivery</span>

                </div>

            </div>

        </div>

        <div class="hero-visual">

            <div class="image-card image-one">

                <img
                    src="https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&amp;fit=crop&amp;w=900&amp;q=85"
                    alt="Colourful Indian meal">

            </div>

            <div class="image-card image-two">

                <img
                    src="https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&amp;fit=crop&amp;w=700&amp;q=85"
                    alt="Indian biryani">

            </div>

            <div class="image-card image-three">

                <img
                    src="https://images.unsplash.com/photo-1630383249896-424e482df921?auto=format&amp;fit=crop&amp;w=600&amp;q=85"
                    alt="South Indian breakfast">

            </div>

            <div class="delivery-card">

                <span class="delivery-icon">✓</span>

                <div>

                    <strong>Freshly prepared</strong>

                    <span>From kitchen to doorstep</span>

                </div>

            </div>

            <div class="rating-card">
                ★ 4.8 food lovers’ choice
            </div>

        </div>

    </div>

</section>

<!-- =========================
     CUISINE DISCOVERY
========================= -->

<section class="cuisine-section"
         id="cuisines">

    <div class="section">

        <div class="section-top">

            <div>

                <p class="eyebrow">
                    Choose your mood
                </p>

                <h2 class="section-title">
                    Flavours worth exploring
                </h2>

            </div>

            <div class="slider-navigation">

                <button class="slider-button"
                        id="cuisinePrevious"
                        type="button"
                        aria-label="Previous cuisines">
                    ←
                </button>

                <button class="slider-button"
                        id="cuisineNext"
                        type="button"
                        aria-label="Next cuisines">
                    →
                </button>

            </div>

        </div>

        <div class="cuisine-slider"
             id="cuisineSlider">

            <div class="cuisine-track">

                <a class="cuisine-card"
                   href="<%= contextPath %>/restaurants?cuisine=Biryani">

                    <img
                        src="https://images.unsplash.com/photo-1563379926898-05f4575a45d8?auto=format&amp;fit=crop&amp;w=600&amp;q=85"
                        alt="Biryani">

                    <span class="cuisine-overlay"></span>

                    <div class="cuisine-details">

                        <span>Rich and aromatic</span>

                        <h3>Biryani</h3>

                    </div>

                </a>

                <a class="cuisine-card"
                   href="<%= contextPath %>/restaurants?cuisine=South%20Indian">

                    <img
                        src="https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&amp;fit=crop&amp;w=600&amp;q=85"
                        alt="South Indian food">

                    <span class="cuisine-overlay"></span>

                    <div class="cuisine-details">

                        <span>Comfort on a plate</span>

                        <h3>South Indian</h3>

                    </div>

                </a>

                <a class="cuisine-card"
                   href="<%= contextPath %>/restaurants?cuisine=North%20Indian">

                    <img
                        src="https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&amp;fit=crop&amp;w=600&amp;q=85"
                        alt="North Indian food">

                    <span class="cuisine-overlay"></span>

                    <div class="cuisine-details">

                        <span>Bold and satisfying</span>

                        <h3>North Indian</h3>

                    </div>

                </a>

                <a class="cuisine-card"
                   href="<%= contextPath %>/restaurants?cuisine=Chinese">

                    <img
                        src="https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&amp;fit=crop&amp;w=600&amp;q=85"
                        alt="Chinese noodles">

                    <span class="cuisine-overlay"></span>

                    <div class="cuisine-details">

                        <span>Wok-tossed favourites</span>

                        <h3>Chinese</h3>

                    </div>

                </a>

                <a class="cuisine-card"
                   href="<%= contextPath %>/restaurants?cuisine=Fast%20Food">

                    <img
                        src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&amp;fit=crop&amp;w=600&amp;q=85"
                        alt="Burger">

                    <span class="cuisine-overlay"></span>

                    <div class="cuisine-details">

                        <span>Quick and delicious</span>

                        <h3>Fast Food</h3>

                    </div>

                </a>

                <a class="cuisine-card"
                   href="<%= contextPath %>/restaurants?cuisine=Pizza">

                    <img
                        src="https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&amp;fit=crop&amp;w=600&amp;q=85"
                        alt="Pizza">

                    <span class="cuisine-overlay"></span>

                    <div class="cuisine-details">

                        <span>Cheesy crowd-pleasers</span>

                        <h3>Pizza</h3>

                    </div>

                </a>

                <a class="cuisine-card"
                   href="<%= contextPath %>/restaurants?cuisine=Desserts">

                    <img
                        src="https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&amp;fit=crop&amp;w=600&amp;q=85"
                        alt="Desserts">

                    <span class="cuisine-overlay"></span>

                    <div class="cuisine-details">

                        <span>A sweet finish</span>

                        <h3>Desserts</h3>

                    </div>

                </a>

                <a class="cuisine-card"
                   href="<%= contextPath %>/restaurants?cuisine=Pure%20Veg">

                    <img
                        src="https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&amp;fit=crop&amp;w=600&amp;q=85"
                        alt="Vegetarian food">

                    <span class="cuisine-overlay"></span>

                    <div class="cuisine-details">

                        <span>Fresh and wholesome</span>

                        <h3>Pure Veg</h3>

                    </div>

                </a>

                <a class="cuisine-card"
                   href="<%= contextPath %>/restaurants?cuisine=Kebab">

                    <img
                        src="https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?auto=format&amp;fit=crop&amp;w=600&amp;q=85"
                        alt="Kebabs">

                    <span class="cuisine-overlay"></span>

                    <div class="cuisine-details">

                        <span>Smoky and tender</span>

                        <h3>Kebabs</h3>

                    </div>

                </a>

            </div>

        </div>

    </div>

</section>

<!-- =========================
     CRAVEGO EXPERIENCE
========================= -->

<section class="experience-section">

    <div class="section experience-grid">

        <div class="experience-image">

            <img class="experience-image-main"
                 src="https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&amp;fit=crop&amp;w=900&amp;q=85"
                 alt="Restaurant dining space">

            <img class="experience-small-image"
                 src="https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&amp;fit=crop&amp;w=500&amp;q=85"
                 alt="Freshly prepared food">

        </div>

        <div class="experience-content">

            <p class="eyebrow">
                More than delivery
            </p>

            <h2>
                Good food should feel personal.
            </h2>

            <p>
                CraveGo connects you with Bengaluru restaurants
                that care about flavour, freshness and a reliable
                delivery experience.
            </p>

            <div class="benefit-list">

                <div class="benefit">

                    <span class="benefit-icon">1</span>

                    <div>

                        <strong>Discover nearby favourites</strong>

                        <p>
                            Explore trusted kitchens across Bengaluru.
                        </p>

                    </div>

                </div>

                <div class="benefit">

                    <span class="benefit-icon">2</span>

                    <div>

                        <strong>Build your perfect meal</strong>

                        <p>
                            Add, remove and update dishes easily.
                        </p>

                    </div>

                </div>

                <div class="benefit">

                    <span class="benefit-icon">3</span>

                    <div>

                        <strong>Enjoy doorstep convenience</strong>

                        <p>
                            Simple ordering with transparent pricing.
                        </p>

                    </div>

                </div>

            </div>

            <a class="explore-button"
               href="<%= contextPath %>/restaurants">

                Explore Restaurants

                <span>→</span>

            </a>

        </div>

    </div>

</section>

<!-- =========================
     FEATURED RESTAURANTS
========================= -->

<section class="restaurant-section">

    <div class="section">

        <div class="section-top">

            <div>

                <p class="eyebrow">
                    Neighbourhood favourites
                </p>

                <h2 class="section-title">
                    Find your next favourite kitchen
                </h2>

            </div>

            <p class="section-description">
                From comforting South Indian breakfasts to
                rich biryanis and modern Bengaluru cafés,
                there is something for every craving.
            </p>

        </div>

        <div class="restaurant-grid">

            <a class="restaurant-card"
               href="<%= contextPath %>/restaurants?cuisine=South%20Indian">

                <div class="restaurant-photo">

                    <img
                        src="https://images.unsplash.com/photo-1630383249896-424e482df921?auto=format&amp;fit=crop&amp;w=800&amp;q=85"
                        alt="South Indian restaurant">

                    <span class="restaurant-number">01</span>

                    <span class="restaurant-rating">
                        ★ 4.7
                    </span>

                </div>

                <div class="restaurant-content">

                    <h3>Namma Bengaluru Kitchen</h3>

                    <p>
                        South Indian • Dosa • Traditional breakfast
                    </p>

                    <div class="restaurant-footer">

                        <span class="delivery-time">
                            25–30 minutes
                        </span>

                        <span class="view-menu">
                            Discover →
                        </span>

                    </div>

                </div>

            </a>

            <a class="restaurant-card"
               href="<%= contextPath %>/restaurants?cuisine=Biryani">

                <div class="restaurant-photo">

                    <img
                        src="https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&amp;fit=crop&amp;w=800&amp;q=85"
                        alt="Biryani restaurant">

                    <span class="restaurant-number">02</span>

                    <span class="restaurant-rating">
                        ★ 4.6
                    </span>

                </div>

                <div class="restaurant-content">

                    <h3>Royal Biryani Courtyard</h3>

                    <p>
                        Biryani • Kebabs • North Indian
                    </p>

                    <div class="restaurant-footer">

                        <span class="delivery-time">
                            30–35 minutes
                        </span>

                        <span class="view-menu">
                            Discover →
                        </span>

                    </div>

                </div>

            </a>

            <a class="restaurant-card"
               href="<%= contextPath %>/restaurants?cuisine=North%20Indian">

                <div class="restaurant-photo">

                    <img
                        src="https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&amp;fit=crop&amp;w=800&amp;q=85"
                        alt="North Indian restaurant">

                    <span class="restaurant-number">03</span>

                    <span class="restaurant-rating">
                        ★ 4.8
                    </span>

                </div>

                <div class="restaurant-content">

                    <h3>The Spice Story</h3>

                    <p>
                        North Indian • Curries • Tandoor
                    </p>

                    <div class="restaurant-footer">

                        <span class="delivery-time">
                            35–40 minutes
                        </span>

                        <span class="view-menu">
                            Discover →
                        </span>

                    </div>

                </div>

            </a>

        </div>

    </div>

</section>

<!-- =========================
     CALL TO ACTION
========================= -->

<section class="cta-wrapper">

    <div class="cta">

        <div class="cta-content">

            <h2>
                Your next great meal is closer than you think.
            </h2>

            <p>
                Browse restaurants across Bengaluru and discover
                dishes prepared for every mood, moment and craving.
            </p>

            <a class="cta-button"
               href="<%= contextPath %>/restaurants">
                Start Exploring
            </a>

        </div>

    </div>

</section>

<!-- =========================
     FOOTER
========================= -->

<footer class="footer">

    <div class="footer-content">

        <div class="footer-brand">

            <h2>
                Crave<span>Go</span>
            </h2>

            <p>
                A Bengaluru-focused food discovery and delivery
                experience built to bring local flavours closer
                to your doorstep.
            </p>

        </div>

        <div class="footer-column">

            <h3>Explore</h3>

            <a href="<%= contextPath %>/">
                Home
            </a>

            <a href="<%= contextPath %>/restaurants">
                Restaurants
            </a>

            <a href="#cuisines">
                Cuisines
            </a>

        </div>

        <div class="footer-column">

            <h3>My Account</h3>

            <% if (loggedInUser == null) { %>

                <a href="<%= contextPath %>/login">
                    Login
                </a>

                <a href="<%= contextPath %>/register">
                    Create Account
                </a>

            <% } else { %>

                <a href="<%= contextPath %>/cart">
                    View Cart
                </a>

                <a href="<%= contextPath %>/logout">
                    Logout
                </a>

            <% } %>

        </div>

        <div class="footer-column">

            <h3>Popular Areas</h3>

            <a href="<%= contextPath %>/restaurants?search=BTM">
                BTM Layout
            </a>

            <a href="<%= contextPath %>/restaurants?search=Koramangala">
                Koramangala
            </a>

            <a href="<%= contextPath %>/restaurants?search=Jayanagar">
                Jayanagar
            </a>

            <a href="<%= contextPath %>/restaurants?search=Indiranagar">
                Indiranagar
            </a>

        </div>

    </div>

    <div class="copyright">
        © 2026 CraveGo. Crafted for Bengaluru food lovers.
    </div>

</footer>

<script>

    const cuisineSlider =
            document.getElementById("cuisineSlider");

    const previousButton =
            document.getElementById("cuisinePrevious");

    const nextButton =
            document.getElementById("cuisineNext");

    function getScrollDistance() {

        return Math.max(
            cuisineSlider.clientWidth * 0.75,
            450
        );
    }

    function updateNavigationButtons() {

        const maximumScroll =
                cuisineSlider.scrollWidth
                - cuisineSlider.clientWidth;

        previousButton.disabled =
                cuisineSlider.scrollLeft <= 5;

        nextButton.disabled =
                cuisineSlider.scrollLeft
                >= maximumScroll - 5;
    }

    previousButton.addEventListener(
        "click",
        function () {

            cuisineSlider.scrollBy({
                left: -getScrollDistance(),
                behavior: "smooth"
            });
        }
    );

    nextButton.addEventListener(
        "click",
        function () {

            cuisineSlider.scrollBy({
                left: getScrollDistance(),
                behavior: "smooth"
            });
        }
    );

    cuisineSlider.addEventListener(
        "scroll",
        updateNavigationButtons
    );

    window.addEventListener(
        "resize",
        updateNavigationButtons
    );

    let isDragging = false;
    let dragStartedAt = 0;
    let initialScrollPosition = 0;
    let hasMoved = false;

    cuisineSlider.addEventListener(
        "mousedown",
        function (event) {

            isDragging = true;
            hasMoved = false;

            dragStartedAt = event.pageX;

            initialScrollPosition =
                    cuisineSlider.scrollLeft;

            cuisineSlider.classList.add(
                    "dragging"
            );
        }
    );

    cuisineSlider.addEventListener(
        "mousemove",
        function (event) {

            if (!isDragging) {
                return;
            }

            event.preventDefault();

            const movement =
                    event.pageX - dragStartedAt;

            if (Math.abs(movement) > 5) {
                hasMoved = true;
            }

            cuisineSlider.scrollLeft =
                    initialScrollPosition
                    - movement;
        }
    );

    function stopDragging() {

        isDragging = false;

        cuisineSlider.classList.remove(
                "dragging"
        );
    }

    cuisineSlider.addEventListener(
        "mouseup",
        stopDragging
    );

    cuisineSlider.addEventListener(
        "mouseleave",
        stopDragging
    );

    cuisineSlider.addEventListener(
        "click",
        function (event) {

            if (hasMoved) {
                event.preventDefault();
            }
        }
    );

    updateNavigationButtons();

</script>

</body>

</html>