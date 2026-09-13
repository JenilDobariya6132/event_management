<?php
// backend/api/categories/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";

$db = (new Database())->getConnection();

$stmt = $db->query("SELECT id, name, icon, image_url, description, is_active FROM categories WHERE is_active = 1 ORDER BY id ASC");
$categories = $stmt->fetchAll();

sendResponse(true, "Categories list fetched.", $categories);
?>
