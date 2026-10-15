package com.cravego.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

import org.json.JSONObject;

import com.razorpay.Payment;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.Utils;

public final class RazorpayUtil {

    public static final String CURRENCY = "INR";

    private RazorpayUtil() {
    }

    /*
     * Only the Key ID can be passed to the checkout page.
     * The Key Secret stays on the server.
     */
    public static String getKeyId() {
        String keyId = requireEnvironment("RAZORPAY_KEY_ID");

        // Keep this integration in Test Mode for now.
        if (!keyId.startsWith("rzp_test_")) {
            throw new IllegalStateException(
                    "Configure a Razorpay Test Mode Key ID."
            );
        }

        return keyId;
    }

    public static void validateConfiguration() {
        getKeyId();
        requireEnvironment("RAZORPAY_KEY_SECRET");
    }

    private static RazorpayClient createClient()
            throws RazorpayException {

        return new RazorpayClient(
                getKeyId(),
                requireEnvironment("RAZORPAY_KEY_SECRET")
        );
    }

    /*
     * Convert rupees to paise without silently rounding
     * an amount containing more than two decimal places.
     */
    public static long toPaise(BigDecimal amountRupees) {

        if (amountRupees == null
                || amountRupees.signum() <= 0) {

            throw new IllegalArgumentException(
                    "Payment amount must be greater than zero."
            );
        }

        return amountRupees
                .setScale(2, RoundingMode.UNNECESSARY)
                .movePointRight(2)
                .longValueExact();
    }

    /*
     * Use only the saved, server-calculated order total.
     * Never use an amount supplied by the browser.
     */
    public static com.razorpay.Order createGatewayOrder(
            int localOrderId,
            BigDecimal amountRupees)
            throws RazorpayException {

        if (localOrderId <= 0) {
            throw new IllegalArgumentException(
                    "A valid CraveGo order ID is required."
            );
        }

        JSONObject notes = new JSONObject();
        notes.put("cravego_order_id", String.valueOf(localOrderId));

        JSONObject orderRequest = new JSONObject();

        orderRequest.put("amount", toPaise(amountRupees));
        orderRequest.put("currency", CURRENCY);
        orderRequest.put("receipt", "cravego_" + localOrderId);
        orderRequest.put("partial_payment", false);
        orderRequest.put("notes", notes);

        return createClient().orders.create(orderRequest);
    }

    public static com.razorpay.Order fetchGatewayOrder(
            String gatewayOrderId)
            throws RazorpayException {

        requireId(gatewayOrderId, "order_");

        return createClient().orders.fetch(gatewayOrderId);
    }

    /*
     * savedGatewayOrderId must come from the database,
     * not directly from the submitted checkout response.
     */
    public static boolean verifyCheckoutSignature(
            String savedGatewayOrderId,
            String paymentId,
            String signature)
            throws RazorpayException {

        requireId(savedGatewayOrderId, "order_");
        requireId(paymentId, "pay_");

        if (signature == null
                || !signature.matches("^[a-fA-F0-9]{64}$")) {
            return false;
        }

        JSONObject attributes = new JSONObject();

        attributes.put(
                "razorpay_order_id",
                savedGatewayOrderId
        );

        attributes.put(
                "razorpay_payment_id",
                paymentId
        );

        attributes.put(
                "razorpay_signature",
                signature
        );

        return Utils.verifyPaymentSignature(
                attributes,
                requireEnvironment("RAZORPAY_KEY_SECRET")
        );
    }

    /*
     * Fetch payment directly from Razorpay.
     * Signature verification alone does not establish capture.
     */
    public static boolean isCapturedPayment(
            String paymentId,
            String savedGatewayOrderId,
            BigDecimal expectedAmountRupees)
            throws RazorpayException {

        requireId(paymentId, "pay_");
        requireId(savedGatewayOrderId, "order_");

        Payment payment = createClient().payments.fetch(paymentId);

        String fetchedPaymentId = payment.get("id");
        String fetchedOrderId = payment.get("order_id");
        String status = payment.get("status");
        String currency = payment.get("currency");

        Object amountValue = payment.get("amount");

        if (!(amountValue instanceof Number)) {
            return false;
        }

        long amountPaise = new BigDecimal(
                amountValue.toString()
        ).longValueExact();

        Object refundedValue = payment.get("amount_refunded");

        if (!(refundedValue instanceof Number)) {
            return false;
        }

        long refundedPaise = new BigDecimal(
                refundedValue.toString()
        ).longValueExact();

        return paymentId.equals(fetchedPaymentId)
                && savedGatewayOrderId.equals(fetchedOrderId)
                && "captured".equals(status)
                && CURRENCY.equals(currency)
                && amountPaise == toPaise(expectedAmountRupees)
                && refundedPaise == 0;
    }

    
    public static java.util.List<Payment> fetchOrderPayments(
            String savedGatewayOrderId)
            throws RazorpayException {

        requireId(savedGatewayOrderId, "order_");

        return createClient().orders.fetchPayments(savedGatewayOrderId);
    }
    
    private static String requireEnvironment(String name) {

        String value = System.getenv(name);

        if (value == null || value.isBlank()) {
            throw new IllegalStateException(
                    "Missing environment variable: " + name
            );
        }

        return value.trim();
    }

    private static void requireId(String value, String prefix) {

        if (value == null
                || !value.startsWith(prefix)
                || value.length() <= prefix.length()
                || value.length() > 100) {

            throw new IllegalArgumentException(
                    "Invalid Razorpay identifier."
            );
        }
    }
}