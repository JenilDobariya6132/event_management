<?php
// backend/api/vendors/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";

$db = (new Database())->getConnection();

$categoryId = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
$city = isset($_GET['city']) ? trim($_GET['city']) : '';
$search = isset($_GET['search']) ? trim($_GET['search']) : '';
$minPrice = isset($_GET['min_price']) ? (float)$_GET['min_price'] : 0;
$maxPrice = isset($_GET['max_price']) ? (float)$_GET['max_price'] : 0;
$minRating = isset($_GET['min_rating']) ? (float)$_GET['min_rating'] : 0;

$query = "SELECT v.*, c.name as category_name, u.profile_image 
          FROM vendors v 
          JOIN categories c ON v.category_id = c.id 
          JOIN users u ON v.user_id = u.id 
          WHERE v.status = 'approved'";

$params = [];

if ($categoryId > 0) {
    $query .= " AND v.category_id = ?";
    $params[] = $categoryId;
}

if (!empty($city)) {
    $query .= " AND v.city LIKE ?";
    $params[] = "%$city%";
}

if (!empty($search)) {
    $query .= " AND (v.business_name LIKE ? OR c.name LIKE ? OR v.description LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

if ($minPrice > 0) {
    $query .= " AND v.starting_price >= ?";
    $params[] = $minPrice;
}

if ($maxPrice > 0) {
    $query .= " AND v.starting_price <= ?";
    $params[] = $maxPrice;
}

if ($minRating > 0) {
    $query .= " AND v.rating >= ?";
    $params[] = $minRating;
}

$query .= " ORDER BY v.rating DESC, v.total_reviews DESC";

$stmt = $db->prepare($query);
$stmt->execute($params);
$vendors = $stmt->fetchAll();

sendResponse(true, "Vendors list fetched.", $vendors);
?>
