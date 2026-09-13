<?php
// backend/api/reviews/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $vendorId = isset($_GET['vendor_id']) ? (int)$_GET['vendor_id'] : 0;
    if ($vendorId <= 0) {
        sendResponse(false, "Vendor ID is required.", null, 400);
    }

    $stmt = $db->prepare("SELECT r.*, u.full_name as customer_name, u.profile_image as customer_image 
                          FROM reviews r 
                          JOIN users u ON r.customer_id = u.id 
                          WHERE r.vendor_id = ? ORDER BY r.id DESC");
    $stmt->execute([$vendorId]);
    $reviews = $stmt->fetchAll();

    sendResponse(true, "Reviews fetched.", $reviews);
}
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $currentUser = requireRole(['customer', 'admin']);
    $input = getJsonInput();

    $bookingId = isset($input['booking_id']) ? (int)$input['booking_id'] : 0;
    $vendorId = isset($input['vendor_id']) ? (int)$input['vendor_id'] : 0;
    $rating = isset($input['rating']) ? (int)$input['rating'] : 5;
    $comment = isset($input['comment']) ? $input['comment'] : '';

    if ($vendorId <= 0 || $rating < 1 || $rating > 5) {
        sendResponse(false, "Valid vendor ID and star rating (1-5) are required.", null, 400);
    }

    try {
        $db->beginTransaction();

        $stmt = $db->prepare("INSERT INTO reviews (booking_id, customer_id, vendor_id, rating, comment) VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([$bookingId, $currentUser['user_id'], $vendorId, $rating, $comment]);

        // Automatically recalculate vendor average rating and total reviews count
        $stmtAvg = $db->prepare("SELECT AVG(rating) as avg_rating, COUNT(*) as review_count FROM reviews WHERE vendor_id = ?");
        $stmtAvg->execute([$vendorId]);
        $stats = $stmtAvg->fetch();

        $newRating = round((float)($stats['avg_rating'] ?? 0), 2);
        $newTotal = (int)($stats['review_count'] ?? 0);

        $stmtUpdateVendor = $db->prepare("UPDATE vendors SET rating = ?, total_reviews = ? WHERE id = ?");
        $stmtUpdateVendor->execute([$newRating, $newTotal, $vendorId]);

        $db->commit();

        sendResponse(true, "Thank you! Your review has been submitted successfully.", [
            "new_rating" => $newRating,
            "total_reviews" => $newTotal
        ]);

    } catch (Exception $e) {
        $db->rollBack();
        sendResponse(false, "Review submission failed: " . $e->getMessage(), null, 500);
    }
}
?>
