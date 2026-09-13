<?php
// backend/api/destinations/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";

$db = (new Database())->getConnection();

$stmt = $db->query("SELECT * FROM destinations ORDER BY is_popular DESC, id ASC");
$destinations = $stmt->fetchAll();

foreach ($destinations as &$dest) {
    $stmtPkg = $db->prepare("SELECT * FROM destination_packages WHERE destination_id = ?");
    $stmtPkg->execute([$dest['id']]);
    $pkgs = $stmtPkg->fetchAll();
    foreach ($pkgs as &$p) {
        $p['inclusions'] = $p['inclusions_json'] ? json_decode($p['inclusions_json'], true) : [];
    }
    $dest['packages'] = $pkgs;
}

sendResponse(true, "Destination packages fetched.", $destinations);
?>
