<?php
// backend/api/weddings/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$currentUser = requireRole(['customer', 'admin']);

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $db->prepare("SELECT * FROM weddings WHERE customer_id = ? ORDER BY id DESC LIMIT 1");
    $stmt->execute([$currentUser['user_id']]);
    $wedding = $stmt->fetch();

    if (!$wedding) {
        // Auto-create initial wedding project if missing
        $defaultDate = date('Y-m-d', strtotime('+90 days'));
        $stmtCreate = $db->prepare("INSERT INTO weddings (customer_id, bride_name, groom_name, wedding_date, location, guest_count, total_budget) VALUES (?, 'Bride Name', 'Groom Name', ?, 'Udaipur, Rajasthan', 200, 500000.00)");
        $stmtCreate->execute([$currentUser['user_id'], $defaultDate]);
        $weddingId = $db->lastInsertId();

        $stmt = $db->prepare("SELECT * FROM weddings WHERE id = ?");
        $stmt->execute([$weddingId]);
        $wedding = $stmt->fetch();
    }

    // Days remaining calculation
    $today = new DateTime();
    $targetDate = new DateTime($wedding['wedding_date']);
    $interval = $today->diff($targetDate);
    $daysRemaining = $interval->invert ? 0 : $interval->days;

    // Spending summary
    $stmtBudget = $db->prepare("SELECT SUM(estimated_amount) as total_estimated, SUM(actual_amount) as total_spent FROM wedding_budget WHERE wedding_id = ?");
    $stmtBudget->execute([$wedding['id']]);
    $budgetSummary = $stmtBudget->fetch();

    // Tasks summary
    $stmtTasks = $db->prepare("SELECT COUNT(*) as total_tasks, SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) as completed_tasks FROM wedding_tasks WHERE wedding_id = ?");
    $stmtTasks->execute([$wedding['id']]);
    $taskSummary = $stmtTasks->fetch();

    // Confirmed bookings count
    $stmtBookings = $db->prepare("SELECT COUNT(*) as confirmed_count FROM bookings WHERE customer_id = ? AND status IN ('Confirmed', 'Accepted')");
    $stmtBookings->execute([$currentUser['user_id']]);
    $bookingSummary = $stmtBookings->fetch();

    sendResponse(true, "Wedding project details fetched.", [
        "wedding" => $wedding,
        "days_remaining" => $daysRemaining,
        "total_spent" => (float)($budgetSummary['total_spent'] ?? 0),
        "total_estimated" => (float)($budgetSummary['total_estimated'] ?? 0),
        "completed_tasks" => (int)($taskSummary['completed_tasks'] ?? 0),
        "total_tasks" => (int)($taskSummary['total_tasks'] ?? 0),
        "confirmed_vendors" => (int)($bookingSummary['confirmed_count'] ?? 0)
    ]);
}
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = getJsonInput();
    $brideName = isset($input['bride_name']) ? $input['bride_name'] : '';
    $groomName = isset($input['groom_name']) ? $input['groom_name'] : '';
    $weddingDate = isset($input['wedding_date']) ? $input['wedding_date'] : '';
    $location = isset($input['location']) ? $input['location'] : '';
    $guestCount = isset($input['guest_count']) ? (int)$input['guest_count'] : 200;
    $totalBudget = isset($input['total_budget']) ? (float)$input['total_budget'] : 500000.00;
    $style = isset($input['style']) ? $input['style'] : 'Royal Traditional';

    if (empty($brideName) || empty($groomName) || empty($weddingDate)) {
        sendResponse(false, "Bride name, groom name, and wedding date are required.", null, 400);
    }

    $stmtCheck = $db->prepare("SELECT id FROM weddings WHERE customer_id = ? LIMIT 1");
    $stmtCheck->execute([$currentUser['user_id']]);
    $existing = $stmtCheck->fetch();

    if ($existing) {
        $stmt = $db->prepare("UPDATE weddings SET bride_name = ?, groom_name = ?, wedding_date = ?, location = ?, guest_count = ?, total_budget = ?, style = ? WHERE id = ?");
        $stmt->execute([$brideName, $groomName, $weddingDate, $location, $guestCount, $totalBudget, $style, $existing['id']]);
    } else {
        $stmt = $db->prepare("INSERT INTO weddings (customer_id, bride_name, groom_name, wedding_date, location, guest_count, total_budget, style) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$currentUser['user_id'], $brideName, $groomName, $weddingDate, $location, $guestCount, $totalBudget, $style]);
    }

    sendResponse(true, "Wedding details saved successfully.");
}
?>
