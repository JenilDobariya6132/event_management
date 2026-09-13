<?php
// backend/api/guests/index.php

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
    $search = isset($_GET['search']) ? trim($_GET['search']) : '';
    $side = isset($_GET['side']) ? trim($_GET['side']) : '';
    $rsvp = isset($_GET['rsvp_status']) ? trim($_GET['rsvp_status']) : '';

    $query = "SELECT * FROM guests WHERE wedding_id = ?";
    $params = [$weddingId];

    if (!empty($search)) {
        $query .= " AND (guest_name LIKE ? OR phone LIKE ? OR family_tag LIKE ?)";
        $params[] = "%$search%";
        $params[] = "%$search%";
        $params[] = "%$search%";
    }

    if (!empty($side)) {
        $query .= " AND side = ?";
        $params[] = $side;
    }

    if (!empty($rsvp)) {
        $query .= " AND rsvp_status = ?";
        $params[] = $rsvp;
    }

    $query .= " ORDER BY id DESC";

    $stmt = $db->prepare($query);
    $stmt->execute($params);
    $guests = $stmt->fetchAll();

    // Statistics summary
    $stmtStats = $db->prepare("SELECT 
        COUNT(*) as total_entries,
        SUM(member_count) as total_headcount,
        SUM(CASE WHEN rsvp_status='attending' THEN member_count ELSE 0 END) as attending_headcount,
        SUM(CASE WHEN rsvp_status='pending' THEN member_count ELSE 0 END) as pending_headcount,
        SUM(CASE WHEN rsvp_status='declined' THEN member_count ELSE 0 END) as declined_headcount,
        SUM(CASE WHEN food_preference='veg' THEN member_count ELSE 0 END) as veg_count,
        SUM(CASE WHEN food_preference='non_veg' THEN member_count ELSE 0 END) as non_veg_count,
        SUM(CASE WHEN accommodation_needed=1 THEN member_count ELSE 0 END) as accommodation_count
        FROM guests WHERE wedding_id = ?");
    $stmtStats->execute([$weddingId]);
    $stats = $stmtStats->fetch();

    sendResponse(true, "Guest list retrieved.", [
        "stats" => $stats,
        "guests" => $guests
    ]);
}
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = getJsonInput();
    $id = isset($input['id']) ? (int)$input['id'] : 0;
    $guestName = isset($input['guest_name']) ? $input['guest_name'] : '';
    $phone = isset($input['phone']) ? $input['phone'] : '';
    $familyTag = isset($input['family_tag']) ? $input['family_tag'] : 'Family';
    $side = isset($input['side']) ? strtolower($input['side']) : 'bride';
    $memberCount = isset($input['member_count']) ? (int)$input['member_count'] : 1;
    $invitationStatus = isset($input['invitation_status']) ? strtolower($input['invitation_status']) : 'invited';
    $rsvpStatus = isset($input['rsvp_status']) ? strtolower($input['rsvp_status']) : 'pending';
    $foodPreference = isset($input['food_preference']) ? strtolower($input['food_preference']) : 'veg';
    $accommodationNeeded = isset($input['accommodation_needed']) ? (int)$input['accommodation_needed'] : 0;

    if (empty($guestName)) {
        sendResponse(false, "Guest name is required.", null, 400);
    }

    if ($id > 0) {
        $stmt = $db->prepare("UPDATE guests SET guest_name = ?, phone = ?, family_tag = ?, side = ?, member_count = ?, invitation_status = ?, rsvp_status = ?, food_preference = ?, accommodation_needed = ? WHERE id = ? AND wedding_id = ?");
        $stmt->execute([$guestName, $phone, $familyTag, $side, $memberCount, $invitationStatus, $rsvpStatus, $foodPreference, $accommodationNeeded, $id, $weddingId]);
    } else {
        $stmt = $db->prepare("INSERT INTO guests (wedding_id, guest_name, phone, family_tag, side, member_count, invitation_status, rsvp_status, food_preference, accommodation_needed) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$weddingId, $guestName, $phone, $familyTag, $side, $memberCount, $invitationStatus, $rsvpStatus, $foodPreference, $accommodationNeeded]);
    }

    sendResponse(true, "Guest saved successfully.");
}
else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        sendResponse(false, "Invalid guest ID.", null, 400);
    }

    $stmt = $db->prepare("DELETE FROM guests WHERE id = ? AND wedding_id = ?");
    $stmt->execute([$id, $weddingId]);

    sendResponse(true, "Guest removed successfully.");
}
?>
