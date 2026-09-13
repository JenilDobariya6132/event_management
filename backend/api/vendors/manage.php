<?php
// backend/api/vendors/manage.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$currentUser = requireRole('vendor');

// Get vendor_id for logged in user
$stmtV = $db->prepare("SELECT id FROM vendors WHERE user_id = ? LIMIT 1");
$stmtV->execute([$currentUser['user_id']]);
$vendor = $stmtV->fetch();

if (!$vendor) {
    sendResponse(false, "Vendor business record not found.", null, 404);
}
$vendorId = (int)$vendor['id'];

$action = isset($_GET['action']) ? $_GET['action'] : '';
$input = getJsonInput();

if ($action === 'add_package') {
    $title = isset($input['title']) ? $input['title'] : '';
    $price = isset($input['price']) ? (float)$input['price'] : 0;
    $description = isset($input['description']) ? $input['description'] : '';
    $features = isset($input['features']) ? json_encode($input['features']) : json_encode([]);
    $imageUrl = isset($input['image_url']) ? $input['image_url'] : 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=600';

    if (empty($title) || $price <= 0) {
        sendResponse(false, "Package title and valid price are required.", null, 400);
    }

    $stmt = $db->prepare("INSERT INTO vendor_packages (vendor_id, title, description, price, features_json, image_url) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$vendorId, $title, $description, $price, $features, $imageUrl]);

    sendResponse(true, "Package created successfully.", ["package_id" => $db->lastInsertId()]);
} 
else if ($action === 'add_image') {
    $imageUrl = isset($input['image_url']) ? $input['image_url'] : '';
    $caption = isset($input['caption']) ? $input['caption'] : 'Portfolio Image';

    if (empty($imageUrl)) {
        sendResponse(false, "Image URL is required.", null, 400);
    }

    $stmt = $db->prepare("INSERT INTO vendor_images (vendor_id, image_url, caption) VALUES (?, ?, ?)");
    $stmt->execute([$vendorId, $imageUrl, $caption]);

    sendResponse(true, "Gallery image uploaded successfully.");
}
else if ($action === 'set_availability') {
    $date = isset($input['date']) ? $input['date'] : '';
    $isAvailable = isset($input['is_available']) ? (int)$input['is_available'] : 1;
    $notes = isset($input['notes']) ? $input['notes'] : '';

    if (empty($date)) {
        sendResponse(false, "Date is required.", null, 400);
    }

    $stmt = $db->prepare("INSERT INTO vendor_availability (vendor_id, date, is_available, notes) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE is_available = VALUES(is_available), notes = VALUES(notes)");
    $stmt->execute([$vendorId, $date, $isAvailable, $notes]);

    sendResponse(true, "Vendor availability updated for date: $date.");
}
else {
    sendResponse(false, "Invalid manage action specified.", null, 400);
}
?>
