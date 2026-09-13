<?php
// backend/api/auth/profile.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$currentUser = verifyToken();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $db->prepare("SELECT id, full_name, email, phone, role, profile_image, status, created_at FROM users WHERE id = ? LIMIT 1");
    $stmt->execute([$currentUser['user_id']]);
    $user = $stmt->fetch();
    
    if (!$user) {
        sendResponse(false, "User profile not found.", null, 404);
    }
    
    $vendorData = null;
    if ($user['role'] === 'vendor') {
        $stmtV = $db->prepare("SELECT v.*, c.name as category_name FROM vendors v LEFT JOIN categories c ON v.category_id = c.id WHERE v.user_id = ? LIMIT 1");
        $stmtV->execute([$user['id']]);
        $vendorData = $stmtV->fetch();
    }
    
    sendResponse(true, "Profile retrieved successfully.", [
        "user" => $user,
        "vendor" => $vendorData
    ]);
} 
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = getJsonInput();
    $fullName = isset($input['full_name']) ? $input['full_name'] : '';
    $phone = isset($input['phone']) ? $input['phone'] : '';
    $profileImage = isset($input['profile_image']) ? $input['profile_image'] : '';

    if (empty($fullName)) {
        sendResponse(false, "Full name is required.", null, 400);
    }

    $stmt = $db->prepare("UPDATE users SET full_name = ?, phone = ?, profile_image = IF(? != '', ?, profile_image) WHERE id = ?");
    $stmt->execute([$fullName, $phone, $profileImage, $profileImage, $currentUser['user_id']]);

    if ($currentUser['role'] === 'vendor' && isset($input['business_name'])) {
        $stmtV = $db->prepare("UPDATE vendors SET business_name = ?, city = ?, starting_price = ?, description = ? WHERE user_id = ?");
        $stmtV->execute([
            $input['business_name'],
            isset($input['city']) ? $input['city'] : 'Mumbai',
            isset($input['starting_price']) ? (float)$input['starting_price'] : 10000.00,
            isset($input['description']) ? $input['description'] : '',
            $currentUser['user_id']
        ]);
    }

    sendResponse(true, "Profile updated successfully.");
}
?>
