<?php
// backend/api/checklist/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$currentUser = requireRole(['customer', 'admin']);

$stmtW = $db->prepare("SELECT id FROM weddings WHERE customer_id = ? LIMIT 1");
$stmtW->execute([$currentUser['user_id']]);
$wedding = $stmtW->fetch();

if (!$wedding) {
    sendResponse(false, "No active wedding project found.", null, 404);
}
$weddingId = (int)$wedding['id'];

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $db->prepare("SELECT * FROM wedding_tasks WHERE wedding_id = ? ORDER BY due_date ASC, priority DESC");
    $stmt->execute([$weddingId]);
    $tasks = $stmt->fetchAll();

    $completedCount = 0;
    foreach ($tasks as $t) {
        if ($t['status'] === 'completed') $completedCount++;
    }
    $totalCount = count($tasks);

    sendResponse(true, "Checklist tasks fetched.", [
        "total_tasks" => $totalCount,
        "completed_tasks" => $completedCount,
        "tasks" => $tasks
    ]);
}
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = getJsonInput();
    $id = isset($input['id']) ? (int)$input['id'] : 0;
    $taskTitle = isset($input['task_title']) ? $input['task_title'] : '';
    $category = isset($input['category']) ? $input['category'] : 'General';
    $dueDate = isset($input['due_date']) ? $input['due_date'] : date('Y-m-d');
    $priority = isset($input['priority']) ? strtolower($input['priority']) : 'medium';
    $status = isset($input['status']) ? strtolower($input['status']) : 'pending';

    if (empty($taskTitle)) {
        sendResponse(false, "Task title is required.", null, 400);
    }

    if ($id > 0) {
        $stmt = $db->prepare("UPDATE wedding_tasks SET task_title = ?, category = ?, due_date = ?, priority = ?, status = ? WHERE id = ? AND wedding_id = ?");
        $stmt->execute([$taskTitle, $category, $dueDate, $priority, $status, $id, $weddingId]);
    } else {
        $stmt = $db->prepare("INSERT INTO wedding_tasks (wedding_id, task_title, category, due_date, priority, status) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->execute([$weddingId, $taskTitle, $category, $dueDate, $priority, $status]);
    }

    sendResponse(true, "Checklist task saved.");
}
else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        sendResponse(false, "Invalid task ID.", null, 400);
    }

    $stmt = $db->prepare("DELETE FROM wedding_tasks WHERE id = ? AND wedding_id = ?");
    $stmt->execute([$id, $weddingId]);

    sendResponse(true, "Task removed successfully.");
}
?>
