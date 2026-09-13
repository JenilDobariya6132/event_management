<?php
// backend/api/budget/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$currentUser = requireRole(['customer', 'admin']);

// Fetch wedding ID for customer
$stmtW = $db->prepare("SELECT id, total_budget FROM weddings WHERE customer_id = ? LIMIT 1");
$stmtW->execute([$currentUser['user_id']]);
$wedding = $stmtW->fetch();

if (!$wedding) {
    sendResponse(false, "No active wedding project found.", null, 404);
}
$weddingId = (int)$wedding['id'];
$totalBudget = (float)$wedding['total_budget'];

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $db->prepare("SELECT * FROM wedding_budget WHERE wedding_id = ? ORDER BY id ASC");
    $stmt->execute([$weddingId]);
    $items = $stmt->fetchAll();

    $totalEstimated = 0.0;
    $totalActual = 0.0;
    foreach ($items as $item) {
        $totalEstimated += (float)$item['estimated_amount'];
        $totalActual += (float)$item['actual_amount'];
    }

    $remainingBudget = $totalBudget - $totalActual;

    sendResponse(true, "Budget breakdown retrieved.", [
        "total_budget" => $totalBudget,
        "total_estimated" => $totalEstimated,
        "total_actual" => $totalActual,
        "remaining_budget" => $remainingBudget,
        "items" => $items
    ]);
}
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = getJsonInput();
    $id = isset($input['id']) ? (int)$input['id'] : 0;
    $categoryName = isset($input['category_name']) ? $input['category_name'] : 'General';
    $estimatedAmount = isset($input['estimated_amount']) ? (float)$input['estimated_amount'] : 0.00;
    $actualAmount = isset($input['actual_amount']) ? (float)$input['actual_amount'] : 0.00;
    $notes = isset($input['notes']) ? $input['notes'] : '';

    if (empty($categoryName)) {
        sendResponse(false, "Category name is required.", null, 400);
    }

    if ($id > 0) {
        $stmt = $db->prepare("UPDATE wedding_budget SET category_name = ?, estimated_amount = ?, actual_amount = ?, notes = ? WHERE id = ? AND wedding_id = ?");
        $stmt->execute([$categoryName, $estimatedAmount, $actualAmount, $notes, $id, $weddingId]);
    } else {
        $stmt = $db->prepare("INSERT INTO wedding_budget (wedding_id, category_name, estimated_amount, actual_amount, notes) VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([$weddingId, $categoryName, $estimatedAmount, $actualAmount, $notes]);
    }

    sendResponse(true, "Budget expense item saved.");
}
else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        sendResponse(false, "Invalid item ID.", null, 400);
    }

    $stmt = $db->prepare("DELETE FROM wedding_budget WHERE id = ? AND wedding_id = ?");
    $stmt->execute([$id, $weddingId]);

    sendResponse(true, "Expense item removed.");
}
?>
