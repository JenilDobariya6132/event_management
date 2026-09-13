<?php
// backend/api/notifications/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$currentUser = verifyToken();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $db->prepare("SELECT * FROM notifications WHERE user_id = ? ORDER BY id DESC");
    $stmt->execute([$currentUser['user_id']]);
    $notifications = $stmt->fetchAll();

    $stmtUnread = $db->prepare("SELECT COUNT(*) as unread_count FROM notifications WHERE user_id = ? AND is_read = 0");
    $stmtUnread->execute([$currentUser['user_id']]);
    $unreadCount = (int)$stmtUnread->fetch()['unread_count'];

    sendResponse(true, "Notifications retrieved.", [
        "unread_count" => $unreadCount,
        "notifications" => $notifications
    ]);
}
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $stmt = $db->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = ?");
    $stmt->execute([$currentUser['user_id']]);

    sendResponse(true, "All notifications marked as read.");
}
?>
