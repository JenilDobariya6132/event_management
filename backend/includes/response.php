<?php
// backend/includes/response.php

function sendResponse($success, $message, $data = null, $httpCode = 200) {
    header("Content-Type: application/json; charset=UTF-8");
    http_response_code($httpCode);
    
    $response = [
        "success" => (bool)$success,
        "message" => $message
    ];
    
    if ($data !== null) {
        $response["data"] = $data;
    }
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit();
}
?>
