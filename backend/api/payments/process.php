<?php
// backend/api/payments/process.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$currentUser = requireRole(['customer', 'admin']);

$input = getJsonInput();

$bookingId = isset($input['booking_id']) ? (int)$input['booking_id'] : 0;
$amount = isset($input['amount']) ? (float)$input['amount'] : 0.00;
$paymentGateway = isset($input['payment_gateway']) ? $input['payment_gateway'] : 'Razorpay';
$paymentMethod = isset($input['payment_method']) ? $input['payment_method'] : 'UPI / Card';

if ($bookingId <= 0 || $amount <= 0) {
    sendResponse(false, "Valid booking ID and payment amount are required.", null, 400);
}

// Generate unique mock gateway transaction ID
$transactionId = "PAY-" . strtoupper(substr($paymentGateway, 0, 3)) . "-" . time() . rand(100, 999);

try {
    $db->beginTransaction();

    // 1. Insert Payment Record
    $stmt = $db->prepare("INSERT INTO payments (booking_id, transaction_id, payment_gateway, amount, payment_method, payment_status) VALUES (?, ?, ?, ?, ?, 'completed')");
    $stmt->execute([$bookingId, $transactionId, $paymentGateway, $amount, $paymentMethod]);

    // 2. Update Booking Status
    $stmtB = $db->prepare("UPDATE bookings SET payment_status = 'paid', status = 'Confirmed' WHERE id = ?");
    $stmtB->execute([$bookingId]);

    // 3. Notify Customer
    $stmtNotif = $db->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, 'Payment Successful', ?, 'payment')");
    $stmtNotif->execute([
        $currentUser['user_id'],
        "Payment of ₹" . number_format($amount, 2) . " via $paymentGateway was successful. Transaction ID: $transactionId"
    ]);

    $db->commit();

    sendResponse(true, "Payment processed successfully!", [
        "transaction_id" => $transactionId,
        "booking_id" => $bookingId,
        "amount" => $amount,
        "payment_status" => "completed",
        "payment_gateway" => $paymentGateway
    ]);

} catch (Exception $e) {
    $db->rollBack();
    sendResponse(false, "Payment processing failed: " . $e->getMessage(), null, 500);
}
?>
