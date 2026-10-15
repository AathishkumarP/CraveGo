package com.cravego.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.util.HexFormat;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.json.JSONException;
import org.json.JSONObject;

import com.cravego.dao.OrderDAO;
import com.cravego.daoimpl.OrderDAOImpl;
import com.cravego.model.Order;
import com.cravego.util.RazorpayUtil;
import com.razorpay.RazorpayException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/razorpay-webhook")
public class RazorpayWebhookServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int MAX_BODY_BYTES = 262144;

    private OrderDAO orderDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAOImpl();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-store");

        String webhookSecret =
                System.getenv("RAZORPAY_WEBHOOK_SECRET");

        if (webhookSecret == null || webhookSecret.isBlank()) {
            response.sendError(
                    HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Webhook is not configured."
            );
            return;
        }

        String signature =
                request.getHeader("X-Razorpay-Signature");

        byte[] rawBody = request.getInputStream()
                .readNBytes(MAX_BODY_BYTES + 1);

        if (rawBody.length > MAX_BODY_BYTES) {
            response.sendError(413, "Request body is too large.");
            return;
        }

        try {
            if (!verifySignature(rawBody, signature, webhookSecret)) {
                response.sendError(400, "Invalid webhook signature.");
                return;
            }

        } catch (GeneralSecurityException e) {
            response.sendError(500, "Signature validation unavailable.");
            return;
        }

        try {
            JSONObject event = new JSONObject(
                    new String(rawBody, StandardCharsets.UTF_8)
            );

            String eventName = event.optString("event");

            // Only captured payments can confirm food orders.
            if (!"payment.captured".equals(eventName)) {
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            }

            JSONObject payment = event.getJSONObject("payload")
                    .getJSONObject("payment")
                    .getJSONObject("entity");

            String gatewayOrderId = payment.getString("order_id");
            String paymentId = payment.getString("id");

            if (!"captured".equals(payment.getString("status"))
                    || !"INR".equals(payment.getString("currency"))) {

                response.sendError(400, "Unexpected payment state.");
                return;
            }

            Order order =
                    orderDAO.getOrderByRazorpayOrderId(gatewayOrderId);

            /*
             * Do not acknowledge a missing order as successful.
             * A temporary database/linking failure may need a retry.
             */
            if (order == null) {
                response.sendError(
                        503,
                        "Local payment order is unavailable."
                );
                return;
            }

            if (!"RAZORPAY".equals(order.getPaymentMode())) {
                response.sendError(409, "Payment mode mismatch.");
                return;
            }

            // Repeated delivery of the same confirmation is harmless.
            if (order.isPaid()) {
                if (paymentId.equals(order.getRazorpayPaymentId())) {
                    response.setStatus(HttpServletResponse.SC_OK);
                } else {
                    response.sendError(409, "Payment ID mismatch.");
                }
                return;
            }

            long expectedAmount = RazorpayUtil.toPaise(
                    BigDecimal.valueOf(order.getTotalAmount())
            );

            if (payment.getLong("amount") != expectedAmount) {
                response.sendError(409, "Payment amount mismatch.");
                return;
            }

            /*
             * Verify current capture, amount, currency and gateway
             * order association directly with Razorpay as well.
             */
            boolean verified = RazorpayUtil.isCapturedPayment(
                    paymentId,
                    gatewayOrderId,
                    BigDecimal.valueOf(order.getTotalAmount())
            );

            if (!verified) {
                response.sendError(
                        409,
                        "Captured payment could not be confirmed."
                );
                return;
            }

            boolean confirmed = orderDAO.confirmOnlinePayment(
                    order.getOrderId(),
                    gatewayOrderId,
                    paymentId
            );

            if (!confirmed) {
                response.sendError(
                        503,
                        "Payment confirmation could not be saved."
                );
                return;
            }

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (JSONException | IllegalArgumentException e) {
            response.sendError(400, "Invalid webhook payload.");

        } catch (RazorpayException | IllegalStateException e) {
            getServletContext().log(
                    "Razorpay webhook payment verification unavailable."
            );

            response.sendError(
                    503,
                    "Payment verification is temporarily unavailable."
            );
        }
    }

    private boolean verifySignature(
            byte[] rawBody,
            String signature,
            String secret)
            throws GeneralSecurityException {

        if (signature == null
                || !signature.matches("^[a-fA-F0-9]{64}$")) {
            return false;
        }

        Mac mac = Mac.getInstance("HmacSHA256");

        mac.init(new SecretKeySpec(
                secret.getBytes(StandardCharsets.UTF_8),
                "HmacSHA256"
        ));

        byte[] expected = mac.doFinal(rawBody);
        byte[] received = HexFormat.of().parseHex(signature);

        return MessageDigest.isEqual(expected, received);
    }
}