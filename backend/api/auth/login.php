<?php
// backend/api/auth/login.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$input = getJsonInput();

$email = isset($input['email']) ? strtolower(trim($input['email'])) : '';
$password = isset($input['password']) ? $input['password'] : '';

if (empty($email) || empty($password)) {
    sendResponse(false, "Email and password are required.", null, 400);
}

$stmt = $db->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    sendResponse(false, "Invalid email address or password.", null, 401);
}

if ($user['status'] !== 'active') {
    sendResponse(false, "Your account is currently inactive or suspended.", null, 403);
}

$vendorId = null;
if ($user['role'] === 'vendor') {
    $stmtVendor = $db->prepare("SELECT id FROM vendors WHERE user_id = ? LIMIT 1");
    $stmtVendor->execute([$user['id']]);
    $v = $stmtVendor->fetch();
    if ($v) {
        $vendorId = (int)$v['id'];
    }
}

$userData = [
    'id' => (int)$user['id'],
    'full_name' => $user['full_name'],
    'email' => $user['email'],
    'phone' => $user['phone'],
    'role' => $user['role'],
    'profile_image' => $user['profile_image'],
    'vendor_id' => $vendorId
];

$token = generateToken($userData);

sendResponse(true, "Login successful!", [
    "user" => $userData,
    "token" => $token
]);
?>
