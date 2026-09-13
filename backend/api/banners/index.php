<?php
// backend/api/banners/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";

$db = (new Database())->getConnection();

$stmtBanners = $db->query("SELECT * FROM banners WHERE is_active = 1 ORDER BY display_order ASC");
$banners = $stmtBanners->fetchAll();

$stmtOffers = $db->query("SELECT * FROM offers WHERE is_active = 1 AND valid_until >= CURDATE() ORDER BY id DESC");
$offers = $stmtOffers->fetchAll();

sendResponse(true, "Banners and active promotional offers fetched.", [
    "banners" => $banners,
    "offers" => $offers
]);
?>
