<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="com.cravego.model.Order" %>
<%@ page import="com.cravego.model.Restaurant" %>

<%
    String contextPath = request.getContextPath();

    Order placedOrder =
            (Order) session.getAttribute("lastPlacedOrder");

    Restaurant restaurant =
            (Restaurant) session.getAttribute("lastRestaurant");

    if (placedOrder == null) {
        response.sendRedirect(contextPath + "/restaurants");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Order Placed | CraveGo</title>

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
        }

        body {
            min-height: 100vh;
            overflow-x: hidden;

            font-family:
                Arial, Helvetica, sans-serif;

            color: var(--navy);

            background:
                radial-gradient(
                    circle at top left,
                    rgba(255, 200, 87, 0.24),
                    transparent 35%
                ),
                radial-gradient(
                    circle at bottom right,
                    rgba(41, 183, 131, 0.18),
                    transparent 35%
                ),
                var(--cream);
        }

        #confettiCanvas {
            position: fixed;
            inset: 0;
            z-index: 10;

            width: 100%;
            height: 100%;

            pointer-events: none;
        }

        /* =========================
           NAVBAR
           ========================= */

        .navbar {
            width: min(1710px, 92%);
            min-height: 100px;

            margin: 20px auto 0;
            padding: 18px 30px;

            display: flex;
            align-items: center;
            justify-content: space-between;

            background: var(--white);

            border:
                1px solid rgba(17, 24, 39, 0.06);

            border-radius: 30px;

            box-shadow:
                0 14px 35px
                rgba(17, 24, 39, 0.08);
        }

        /* =========================
           CRAVEGO LOGO
           ========================= */

        .logo {
            display: inline-flex;
            align-items: center;

            gap: 14px;

            text-decoration: none;
        }

        .logo-icon {
            position: relative;

            width: 60px;
            height: 56px;

            display: flex;
            align-items: center;
            justify-content: center;

            overflow: hidden;

            color: var(--white);
            background: var(--coral);

            border-radius: 11px;
        }

        .logo-letter {
            position: relative;
            z-index: 2;

            font-family:
                Arial, Helvetica, sans-serif;

            font-size: 27px;
            font-weight: 900;
            line-height: 1;
        }

        .logo-letter::after {
            content: "";

            position: absolute;
            top: 50%;
            right: -2px;

            width: 7px;
            height: 7px;

            background: #ffb39f;

            border-radius: 50%;

            transform:
                translateY(-50%);
        }

        .logo-corner {
            position: absolute;
            right: -10px;
            bottom: -10px;

            width: 30px;
            height: 30px;

            background: var(--yellow);

            border-radius: 50%;
        }

        .logo-name {
            color: var(--navy);

            font-family:
                Arial, Helvetica, sans-serif;

            font-size: 31px;
            font-weight: 900;
            letter-spacing: -1.8px;
            line-height: 1;
        }

        .logo-go {
            color: var(--coral);
        }

        .logo-icon {
            transition:
                transform 0.2s ease,
                box-shadow 0.2s ease;
        }

        .logo:hover .logo-icon {
            transform:
                translateY(-2px);

            box-shadow:
                0 8px 18px
                rgba(255, 102, 71, 0.25);
        }

        .navbar-actions {
            display: flex;
            align-items: center;

            gap: 15px;
        }

        .nav-link {
            padding: 12px 18px;

            color: var(--navy);

            border:
                1px solid rgba(17, 24, 39, 0.1);

            border-radius: 12px;

            font-size: 14px;
            font-weight: 800;

            text-decoration: none;

            transition:
                color 0.2s ease,
                background 0.2s ease,
                transform 0.2s ease;
        }

        .nav-link:hover {
            color: var(--white);
            background: var(--navy);

            transform:
                translateY(-2px);
        }

        /* =========================
           PAGE
           ========================= */

        .page-container {
            width: min(880px, 91%);

            margin:
                42px auto 70px;
        }

        .success-card {
            position: relative;

            overflow: hidden;

            padding:
                48px 50px;

            background:
                rgba(255, 255, 255, 0.96);

            border:
                1px solid
                rgba(17, 24, 39, 0.08);

            border-radius: 30px;

            box-shadow:
                0 22px 60px
                rgba(17, 24, 39, 0.1);

            text-align: center;
        }

        .success-card::before {
            content: "";

            position: absolute;
            top: -85px;
            right: -85px;

            width: 210px;
            height: 210px;

            background:
                rgba(41, 183, 131, 0.12);

            border-radius: 50%;
        }

        .success-card::after {
            content: "";

            position: absolute;
            left: -90px;
            bottom: -110px;

            width: 230px;
            height: 230px;

            background:
                rgba(255, 102, 71, 0.08);

            border-radius: 50%;
        }

        .card-content {
            position: relative;
            z-index: 2;
        }

        /* =========================
           SUCCESS MESSAGE
           ========================= */

        .success-icon {
            width: 90px;
            height: 90px;

            margin:
                0 auto 25px;

            display: flex;
            align-items: center;
            justify-content: center;

            color: var(--white);
            background: var(--mint);

            border-radius: 50%;

            box-shadow:
                0 12px 28px
                rgba(41, 183, 131, 0.3);

            font-size: 43px;
            font-weight: 800;

            animation:
                successPop 0.7s ease;
        }

        @keyframes successPop {

            0% {
                opacity: 0;

                transform:
                    scale(0.3)
                    rotate(-20deg);
            }

            70% {
                transform:
                    scale(1.12)
                    rotate(4deg);
            }

            100% {
                opacity: 1;

                transform:
                    scale(1)
                    rotate(0);
            }
        }

        .eyebrow {
            margin-bottom: 10px;

            color: var(--coral);

            font-size: 13px;
            font-weight: 800;
            letter-spacing: 1.7px;

            text-transform: uppercase;
        }

        h1 {
            margin-bottom: 14px;

            font-family:
                Georgia, serif;

            font-size:
                clamp(34px, 6vw, 52px);
        }

        .success-message {
            max-width: 590px;

            margin: 0 auto;

            color: var(--grey);

            font-size: 16px;
            line-height: 1.7;
        }

        /* =========================
           ORDER INFORMATION
           ========================= */

        .order-info {
            max-width: 620px;

            margin: 32px auto;
            padding: 24px;

            background: #f8fafc;

            border:
                1px solid #eaecf0;

            border-radius: 20px;

            text-align: left;
        }

        .info-row {
            padding: 13px 0;

            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 18px;

            border-bottom:
                1px dashed #d6dae2;
        }

        .info-row:last-child {
            border-bottom: none;
        }

        .info-row span {
            color: var(--grey);

            font-size: 14px;
        }

        .info-row strong {
            text-align: right;
        }

        .order-status {
            padding: 6px 11px;

            color: var(--mint);

            background:
                rgba(41, 183, 131, 0.1);

            border-radius: 50px;

            font-size: 12px;
        }

        .total-amount {
            color: var(--coral);

            font-size: 19px;
        }

        /* =========================
           DELIVERY PREVIEW
           ========================= */

        .delivery-preview {
            max-width: 620px;

            margin:
                0 auto 30px;

            padding: 24px;

            display: flex;
            align-items: center;

            gap: 22px;

            color: var(--white);
            background: var(--navy);

            border-radius: 20px;

            text-align: left;
        }

        .scooter {
            flex-shrink: 0;

            font-size: 50px;

            animation:
                scooterMove
                1.4s ease-in-out infinite;
        }

        @keyframes scooterMove {

            0%,
            100% {
                transform:
                    translateY(0)
                    rotate(-2deg);
            }

            50% {
                transform:
                    translateY(-6px)
                    rotate(2deg);
            }
        }

        .delivery-preview h2 {
            margin-bottom: 7px;

            font-family:
                Georgia, serif;

            font-size: 21px;
        }

        .delivery-preview p {
            color: #cbd5e1;

            font-size: 13px;
            line-height: 1.5;
        }

        /* =========================
           BUTTONS
           ========================= */

        .button-group {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;

            gap: 14px;
        }

        .button {
            min-width: 190px;

            padding: 15px 23px;

            display: inline-block;

            border-radius: 13px;

            font-size: 14px;
            font-weight: 800;

            text-decoration: none;

            transition:
                transform 0.2s ease,
                box-shadow 0.2s ease,
                background 0.2s ease;
        }

        .track-button {
            color: var(--white);
            background: var(--coral);

            box-shadow:
                0 10px 22px
                rgba(255, 102, 71, 0.26);
        }

        .track-button:hover {
            background: #eb5337;

            transform:
                translateY(-3px);
        }

        .restaurant-button {
            color: var(--navy);
            background: var(--white);

            border:
                1px solid #d8dde7;
        }

        .restaurant-button:hover {
            color: var(--white);
            background: var(--navy);

            transform:
                translateY(-3px);
        }

        /* =========================
           MOBILE
           ========================= */

        @media (max-width: 650px) {

            .navbar {
                width: 94%;
                min-height: 78px;

                margin-top: 12px;
                padding: 12px 15px;

                border-radius: 20px;
            }

            .logo {
                gap: 9px;
            }

            .logo-icon {
                width: 46px;
                height: 44px;

                border-radius: 9px;
            }

            .logo-letter {
                font-size: 22px;
            }

            .logo-name {
                font-size: 24px;
            }

            .nav-link {
                padding: 9px 11px;

                font-size: 11px;
            }

            .page-container {
                margin-top: 28px;
            }

            .success-card {
                padding: 38px 18px;

                border-radius: 23px;
            }

            .success-icon {
                width: 78px;
                height: 78px;

                font-size: 37px;
            }

            .info-row {
                align-items: flex-start;
                flex-direction: column;

                gap: 5px;
            }

            .info-row strong {
                text-align: left;
            }

            .delivery-preview {
                flex-direction: column;

                text-align: center;
            }

            .button {
                width: 100%;
            }
        }

    </style>

</head>

<body>

<canvas id="confettiCanvas"></canvas>

<header class="navbar">

    <a class="logo"
       href="<%= contextPath %>/">

        <span class="logo-icon">

            <span class="logo-letter">
                C
            </span>

            <span class="logo-corner"></span>

        </span>

        <span class="logo-name">
            Crave<span class="logo-go">Go</span>
        </span>

    </a>

    <div class="navbar-actions">

        <a class="nav-link"
           href="<%= contextPath %>/restaurants">

            Restaurants

        </a>

    </div>

</header>

<main class="page-container">

    <section class="success-card">

        <div class="card-content">

            <div class="success-icon">
                ✓
            </div>

            <p class="eyebrow">
                Order confirmed
            </p>

            <h1>
                Let the feast begin!
            </h1>

            <p class="success-message">

                Your order has been placed successfully.
                The restaurant will start preparing your food shortly.

            </p>

            <div class="order-info">

                <div class="info-row">

                    <span>
                        Order number
                    </span>

                    <strong>
                        #CG<%= placedOrder.getOrderId() %>
                    </strong>

                </div>

                <% if (restaurant != null) { %>

                    <div class="info-row">

                        <span>
                            Restaurant
                        </span>

                        <strong>
                            <%= restaurant.getName() %>
                        </strong>

                    </div>

                <% } %>

                <div class="info-row">

                    <span>
                        Payment method
                    </span>

                    <strong>
                        <%= placedOrder.getPaymentMode() %>
                    </strong>

                </div>

                <div class="info-row">

                    <span>
                        Order status
                    </span>

                    <strong class="order-status">
                        <%= placedOrder.getStatus() %>
                    </strong>

                </div>

                <div class="info-row">

                    <span>
                        Total amount
                    </span>

                    <strong class="total-amount">

                        ₹<%= String.format(
                                "%.2f",
                                placedOrder.getTotalAmount()
                        ) %>

                    </strong>

                </div>

            </div>

            <div class="delivery-preview">

                <div class="scooter">
                    🛵
                </div>

                <div>

                    <h2>
                        Your delivery journey is ready
                    </h2>

                    <p>
                        Track preparation, pickup and
                        live delivery progress from one place.
                    </p>

                </div>

            </div>

            <div class="button-group">

                <a class="button track-button"
                   href="<%= contextPath %>/track-order?orderId=<%= placedOrder.getOrderId() %>">

                    Track Your Order

                </a>

                <a class="button restaurant-button"
                   href="<%= contextPath %>/restaurants">

                    Explore Restaurants

                </a>

            </div>

        </div>

    </section>

</main>

<script>

    const canvas =
        document.getElementById("confettiCanvas");

    const context =
        canvas.getContext("2d");

    const colors = [
        "#ff1744",
        "#ffea00",
        "#00e676",
        "#00b0ff",
        "#d500f9",
        "#ff6d00",
        "#ffffff"
    ];

    let confetti = [];
    let animationFrame;
    let celebrationStartedAt = Date.now();

    function resizeCanvas() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }

    function randomBetween(minimum, maximum) {
        return Math.random() * (maximum - minimum)
                + minimum;
    }

    function createConfettiPiece(
            startX,
            startY,
            direction) {

        const speed =
                randomBetween(8, 18);

        const horizontalVelocity =
                direction * speed
                * randomBetween(0.65, 1.15);

        const verticalVelocity =
                randomBetween(-17, -7);

        return {
            x: startX,
            y: startY,

            velocityX: horizontalVelocity,
            velocityY: verticalVelocity,

            width: randomBetween(5, 12),
            height: randomBetween(10, 22),

            color:
                colors[
                    Math.floor(
                        Math.random() * colors.length
                    )
                ],

            rotation:
                randomBetween(0, Math.PI * 2),

            rotationSpeed:
                randomBetween(-0.25, 0.25),

            tilt:
                randomBetween(0, Math.PI * 2),

            tiltSpeed:
                randomBetween(0.08, 0.18),

            gravity:
                randomBetween(0.12, 0.22),

            drag:
                randomBetween(0.982, 0.993),

            opacity: 1,

            shape:
                Math.random() > 0.15
                    ? "rectangle"
                    : "circle"
        };
    }

    function launchCannon(
            startX,
            startY,
            direction,
            amount) {

        for (let index = 0;
             index < amount;
             index++) {

            const piece =
                    createConfettiPiece(
                        startX,
                        startY,
                        direction
                    );

            /*
             * Spread the pieces so the burst looks
             * natural instead of releasing together.
             */
            piece.x += randomBetween(-20, 20);
            piece.y += randomBetween(-35, 35);

            confetti.push(piece);
        }
    }

    function launchCelebration() {

        const leftY =
                canvas.height * 0.55;

        const rightY =
                canvas.height * 0.55;

        /*
         * Main explosion from both sides.
         */
        launchCannon(
            -10,
            leftY,
            1,
            230
        );

        launchCannon(
            canvas.width + 10,
            rightY,
            -1,
            230
        );

        /*
         * Second smaller burst creates the
         * thick celebration effect from the video.
         */
        setTimeout(function() {

            launchCannon(
                -5,
                canvas.height * 0.68,
                1,
                120
            );

            launchCannon(
                canvas.width + 5,
                canvas.height * 0.68,
                -1,
                120
            );

        }, 350);
    }

    function updateConfetti() {

        confetti.forEach(function(piece) {

            piece.velocityX *= piece.drag;

            piece.velocityY += piece.gravity;

            /*
             * Limit falling speed so pieces float
             * naturally near the end.
             */
            if (piece.velocityY > 7) {
                piece.velocityY = 7;
            }

            piece.x += piece.velocityX;
            piece.y += piece.velocityY;

            piece.rotation +=
                    piece.rotationSpeed;

            piece.tilt +=
                    piece.tiltSpeed;

            /*
             * Slight side movement while falling.
             */
            if (piece.velocityY > 0) {

                piece.x +=
                        Math.sin(piece.tilt)
                        * 0.8;
            }

            /*
             * Slowly fade only near the bottom.
             */
            if (piece.y >
                    canvas.height * 0.82) {

                piece.opacity -= 0.012;
            }
        });

        confetti = confetti.filter(
            function(piece) {

                return piece.opacity > 0
                        && piece.y
                        < canvas.height + 50
                        && piece.x > -150
                        && piece.x
                        < canvas.width + 150;
            }
        );
    }

    function drawConfetti() {

        context.clearRect(
            0,
            0,
            canvas.width,
            canvas.height
        );

        confetti.forEach(function(piece) {

            context.save();

            context.globalAlpha =
                    Math.max(piece.opacity, 0);

            context.translate(
                piece.x,
                piece.y
            );

            context.rotate(
                piece.rotation
            );

            /*
             * This scaling creates the flipping
             * three-dimensional paper effect.
             */
            context.scale(
                Math.cos(piece.tilt),
                1
            );

            context.fillStyle =
                    piece.color;

            if (piece.shape === "circle") {

                context.beginPath();

                context.arc(
                    0,
                    0,
                    piece.width / 2,
                    0,
                    Math.PI * 2
                );

                context.fill();

            } else {

                context.fillRect(
                    -piece.width / 2,
                    -piece.height / 2,
                    piece.width,
                    piece.height
                );
            }

            context.restore();
        });
    }

    function animate() {

        updateConfetti();
        drawConfetti();

        const runningTime =
                Date.now()
                - celebrationStartedAt;

        if (confetti.length > 0
                && runningTime < 10000) {

            animationFrame =
                    requestAnimationFrame(
                        animate
                    );

        } else {

            cancelAnimationFrame(
                animationFrame
            );

            context.clearRect(
                0,
                0,
                canvas.width,
                canvas.height
            );
        }
    }

    resizeCanvas();
    launchCelebration();
    animate();

    window.addEventListener(
        "resize",
        resizeCanvas
    );

</script>

</body>

</html>