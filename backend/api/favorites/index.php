<?php
// backend/api/favorites/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$currentUser = requireRole(['customer', 'admin']);
$customerId = $currentUser['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $db->prepare("SELECT v.*, c.name as category_name, u.profile_image 
                          FROM favorites f 
                          JOIN vendors v ON f.vendor_id = v.id 
                          JOIN categories c ON v.category_id = c.id 
                          JOIN users u ON v.user_id = u.id 
                          WHERE f.customer_id = ? ORDER BY f.id DESC");
    $stmt->execute([$customerId]);
    $favorites = $stmt->fetchAll();

    sendResponse(true, "Favorites list fetched.", $favorites);
}
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = getJsonInput();
    $vendorId = isset($input['vendor_id']) ? (int)$input['vendor_id'] : 0;

    if ($vendorId <= 0) {
        sendResponse(false, "Vendor ID is required.", null, 400);
    }

    $stmtCheck = $db->prepare("SELECT id FROM favorites WHERE customer_id = ? AND vendor_id = ? LIMIT 1");
    $stmtCheck->execute([$customerId, $vendorId]);
    if ($stmtCheck->fetch()) {
        // Toggle OFF (Remove)
        $stmtDel = $db->prepare("DELETE FROM favorites WHERE customer_id = ? AND vendor_id = ?");
        $stmtDel->execute([$customerId, $vendorId]);
        sendResponse(true, "Removed from favorites.", ["is_favorite" => false]);
    } else {
        // Toggle ON (Add)
        $stmtAdd = $db->prepare("INSERT INTO favorites (customer_id, vendor_id) VALUES (?, ?)");
        $stmtAdd->execute([$customerId, $vendorId]);
        sendResponse(true, "Added to favorites.", ["is_favorite" => true]);
    }
}
?>
