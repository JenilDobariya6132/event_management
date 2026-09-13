<?php
// backend/includes/validation.php

function sanitizeInput($data) {
    if (is_array($data)) {
        return array_map('sanitizeInput', $data);
    }
    return htmlspecialchars(strip_tags(trim($data)));
}

function isValidEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

function isValidPhone($phone) {
    return preg_match('/^[0-9]{10,15}$/', $phone);
}

function getJsonInput() {
    $input = file_get_contents("php://input");
    $data = json_decode($input, true);
    if (json_last_error() === JSON_ERROR_NONE && is_array($data)) {
        return sanitizeInput($data);
    }
    return sanitizeInput($_POST);
}
?>
