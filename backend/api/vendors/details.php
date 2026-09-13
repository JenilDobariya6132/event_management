<?php
// backend/api/vendors/details.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";

$db = (new Database())->getConnection();

$vendorId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
if ($vendorId <= 0) {
    sendResponse(false, "Vendor ID is required.", null, 400);
}

// 1. Vendor Header Details
$stmt = $db->prepare("SELECT v.*, c.name as category_name, u.full_name as owner_name, u.email as owner_email, u.phone as owner_phone, u.profile_image 
                      FROM vendors v 
                      JOIN categories c ON v.category_id = c.id 
                      JOIN users u ON v.user_id = u.id 
                      WHERE v.id = ? LIMIT 1");
$stmt->execute([$vendorId]);
$vendor = $stmt->fetch();

if (!$vendor) {
    sendResponse(false, "Vendor not found.", null, 404);
}

// 2. Packages
$stmtPackages = $db->prepare("SELECT * FROM vendor_packages WHERE vendor_id = ? ORDER BY price ASC");
$stmtPackages->execute([$vendorId]);
$packages = $stmtPackages->fetchAll();
foreach ($packages as &$pkg) {
    $pkg['features'] = $pkg['features_json'] ? json_decode($pkg['features_json'], true) : [];
}

// 3. Services
$stmtServices = $db->prepare("SELECT vs.*, s.name as service_name FROM vendor_services vs JOIN services s ON vs.service_id = s.id WHERE vs.vendor_id = ?");
$stmtServices->execute([$vendorId]);
$services = $stmtServices->fetchAll();

// 4. Gallery Images
$stmtImages = $db->prepare("SELECT * FROM vendor_images WHERE vendor_id = ? ORDER BY id DESC");
$stmtImages->execute([$vendorId]);
$gallery = $stmtImages->fetchAll();

// 5. Reviews
$stmtReviews = $db->prepare("SELECT r.*, u.full_name as customer_name, u.profile_image as customer_image FROM reviews r JOIN users u ON r.customer_id = u.id WHERE r.vendor_id = ? ORDER BY r.id DESC");
$stmtReviews->execute([$vendorId]);
$reviews = $stmtReviews->fetchAll();

// 6. Availability Calendar
$stmtAvailability = $db->prepare("SELECT * FROM vendor_availability WHERE vendor_id = ? AND date >= CURDATE()");
$stmtAvailability->execute([$vendorId]);
$availability = $stmtAvailability->fetchAll();

sendResponse(true, "Vendor details fetched.", [
    "vendor" => $vendor,
    "packages" => $packages,
    "services" => $services,
    "gallery" => $gallery,
    "reviews" => $reviews,
    "availability" => $availability
]);
?>
