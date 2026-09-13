<?php
// backend/api/bookings/index.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$currentUser = verifyToken();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $bookingId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    
    if ($bookingId > 0) {
        $stmt = $db->prepare("SELECT b.*, v.business_name, c.name as category_name, u.full_name as customer_name, u.email as customer_email, u.phone as customer_phone 
                              FROM bookings b 
                              JOIN vendors v ON b.vendor_id = v.id 
                              JOIN categories c ON v.category_id = c.id 
                              JOIN users u ON b.customer_id = u.id 
                              WHERE b.id = ? LIMIT 1");
        $stmt->execute([$bookingId]);
        $booking = $stmt->fetch();

        if (!$booking) {
            sendResponse(false, "Booking not found.", null, 404);
        }

        $stmtDetails = $db->prepare("SELECT * FROM booking_details WHERE booking_id = ?");
        $stmtDetails->execute([$bookingId]);
        $booking['details'] = $stmtDetails->fetchAll();

        sendResponse(true, "Booking details fetched.", $booking);
    } 
    else {
        $status = isset($_GET['status']) ? trim($_GET['status']) : '';
        
        if ($currentUser['role'] === 'customer') {
            $query = "SELECT b.*, v.business_name, v.starting_price, c.name as category_name, v.city 
                      FROM bookings b 
                      JOIN vendors v ON b.vendor_id = v.id 
                      JOIN categories c ON v.category_id = c.id 
                      WHERE b.customer_id = ?";
            $params = [$currentUser['user_id']];
        } 
        else if ($currentUser['role'] === 'vendor') {
            $stmtV = $db->prepare("SELECT id FROM vendors WHERE user_id = ? LIMIT 1");
            $stmtV->execute([$currentUser['user_id']]);
            $v = $stmtV->fetch();
            $vendorId = $v ? (int)$v['id'] : 0;

            $query = "SELECT b.*, u.full_name as customer_name, u.phone as customer_phone, u.profile_image 
                      FROM bookings b 
                      JOIN users u ON b.customer_id = u.id 
                      WHERE b.vendor_id = ?";
            $params = [$vendorId];
        } 
        else { // Admin
            $query = "SELECT b.*, v.business_name, u.full_name as customer_name FROM bookings b JOIN vendors v ON b.vendor_id = v.id JOIN users u ON b.customer_id = u.id WHERE 1=1";
            $params = [];
        }

        if (!empty($status)) {
            $query .= " AND b.status = ?";
            $params[] = $status;
        }

        $query .= " ORDER BY b.id DESC";

        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $bookings = $stmt->fetchAll();

        sendResponse(true, "Bookings list fetched.", $bookings);
    }
}
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = getJsonInput();
    $action = isset($_GET['action']) ? $_GET['action'] : 'create';

    if ($action === 'create') {
        $vendorId = isset($input['vendor_id']) ? (int)$input['vendor_id'] : 0;
        $packageId = isset($input['package_id']) ? (int)$input['package_id'] : null;
        $weddingDate = isset($input['wedding_date']) ? $input['wedding_date'] : '';
        $venueLocation = isset($input['venue_location']) ? $input['venue_location'] : '';
        $guestCount = isset($input['guest_count']) ? (int)$input['guest_count'] : 100;
        $specialRequirements = isset($input['special_requirements']) ? $input['special_requirements'] : '';
        $totalPrice = isset($input['total_price']) ? (float)$input['total_price'] : 0.00;

        if ($vendorId <= 0 || empty($weddingDate) || empty($venueLocation) || $totalPrice <= 0) {
            sendResponse(false, "Vendor ID, wedding date, venue location, and total price are required.", null, 400);
        }

        $bookingNumber = "BK-" . date('Y') . "-" . rand(1000, 9999);

        try {
            $db->beginTransaction();

            $stmt = $db->prepare("INSERT INTO bookings (booking_number, customer_id, vendor_id, package_id, wedding_date, venue_location, guest_count, special_requirements, total_price, status, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending', 'pending')");
            $stmt->execute([$bookingNumber, $currentUser['user_id'], $vendorId, $packageId, $weddingDate, $venueLocation, $guestCount, $specialRequirements, $totalPrice]);
            $bookingId = $db->lastInsertId();

            // Insert single detail item
            $stmtDetail = $db->prepare("INSERT INTO booking_details (booking_id, service_name, quantity, unit_price, subtotal) VALUES (?, 'Wedding Booking Package', 1, ?, ?)");
            $stmtDetail->execute([$bookingId, $totalPrice, $totalPrice]);

            // Notify Vendor
            $stmtVendorUser = $db->prepare("SELECT user_id, business_name FROM vendors WHERE id = ? LIMIT 1");
            $stmtVendorUser->execute([$vendorId]);
            $vUser = $stmtVendorUser->fetch();
            if ($vUser) {
                $stmtNotif = $db->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, 'New Booking Request', ?, 'booking')");
                $stmtNotif->execute([$vUser['user_id'], "You have received a new booking request ($bookingNumber) for $weddingDate."]);
            }

            $db->commit();

            sendResponse(true, "Booking request submitted successfully!", [
                "booking_id" => $bookingId,
                "booking_number" => $bookingNumber
            ], 201);

        } catch (Exception $e) {
            $db->rollBack();
            sendResponse(false, "Booking creation failed: " . $e->getMessage(), null, 500);
        }
    }
    else if ($action === 'update_status') {
        $bookingId = isset($input['booking_id']) ? (int)$input['booking_id'] : 0;
        $status = isset($input['status']) ? $input['status'] : '';

        $allowedStatuses = ['Pending', 'Accepted', 'Rejected', 'Confirmed', 'Completed', 'Cancelled'];
        if ($bookingId <= 0 || !in_array($status, $allowedStatuses)) {
            sendResponse(false, "Valid booking ID and status are required.", null, 400);
        }

        $stmt = $db->prepare("UPDATE bookings SET status = ? WHERE id = ?");
        $stmt->execute([$status, $bookingId]);

        // Get customer ID to notify
        $stmtB = $db->prepare("SELECT customer_id, booking_number FROM bookings WHERE id = ? LIMIT 1");
        $stmtB->execute([$bookingId]);
        $b = $stmtB->fetch();

        if ($b) {
            $stmtNotif = $db->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, 'booking')");
            $stmtNotif->execute([
                $b['customer_id'],
                "Booking Status Updated: $status",
                "Your booking request (" . $b['booking_number'] . ") status has been updated to: $status."
            ]);
        }

        sendResponse(true, "Booking status updated to $status successfully.");
    }
}
?>
