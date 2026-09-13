<?php
// backend/includes/auth.php

require_once __DIR__ . "/../config/config.php";

function generateToken($user) {
    $header = base64_encode(json_encode(['typ' => 'JWT', 'alg' => 'HS256']));
    $payload = base64_encode(json_encode([
        'user_id' => $user['id'],
        'email' => $user['email'],
        'role' => $user['role'],
        'full_name' => $user['full_name'],
        'exp' => time() + (30 * 24 * 60 * 60) // 30 days valid
    ]));
    $signature = base64_encode(hash_hmac('sha256', "$header.$payload", JWT_SECRET, true));
    return "$header.$payload.$signature";
}

function verifyToken() {
    $headers = getallheaders();
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : (isset($headers['authorization']) ? $headers['authorization'] : '');
    
    if (!$authHeader && isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
    }

    if (!$authHeader) {
        sendResponse(false, "Authorization header missing", null, 401);
    }

    $token = str_replace('Bearer ', '', $authHeader);
    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        sendResponse(false, "Invalid token structure", null, 401);
    }

    list($header, $payload, $signature) = $parts;
    $validSignature = base64_encode(hash_hmac('sha256', "$header.$payload", JWT_SECRET, true));
    
    if ($signature !== $validSignature) {
        sendResponse(false, "Token signature verification failed", null, 401);
    }

    $data = json_decode(base64_decode($payload), true);
    if (isset($data['exp']) && $data['exp'] < time()) {
        sendResponse(false, "Token has expired. Please login again.", null, 401);
    }

    return $data;
}

function requireRole($allowedRoles) {
    $userData = verifyToken();
    if (!in_array($userData['role'], (array)$allowedRoles)) {
        sendResponse(false, "Unauthorized access for user role", null, 403);
    }
    return $userData;
}
?>
