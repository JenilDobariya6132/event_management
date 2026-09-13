<?php
// backend/config/config.php

define("SITE_NAME", "Royal Wedding Events");
define("BASE_URL", "http://localhost/wedding_api/");
define("UPLOAD_PATH", __DIR__ . "/../uploads/");
define("UPLOAD_URL", BASE_URL . "uploads/");

define("JWT_SECRET", "WeddingEventSecretKey_2026_Luxury_Planner");
define("RAZORPAY_KEY_ID", "rzp_test_wedding_key_12345");
define("RAZORPAY_KEY_SECRET", "rzp_test_wedding_secret_67890");

// Enable CORS for mobile application and web admin panel
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>
