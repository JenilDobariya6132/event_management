<?php
// backend/api/auth/register.php

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../config/config.php";
require_once __DIR__ . "/../../includes/response.php";
require_once __DIR__ . "/../../includes/validation.php";
require_once __DIR__ . "/../../includes/auth.php";

$db = (new Database())->getConnection();
$input = getJsonInput();

$fullName = isset($input['full_name']) ? $input['full_name'] : '';
$email = isset($input['email']) ? strtolower($input['email']) : '';
$password = isset($input['password']) ? $input['password'] : '';
$phone = isset($input['phone']) ? $input['phone'] : '';
$role = isset($input['role']) ? strtolower($input['role']) : 'customer';

if (empty($fullName) || empty($email) || empty($password)) {
    sendResponse(false, "Full name, email, and password are required.", null, 400);
}

if (!isValidEmail($email)) {
    sendResponse(false, "Invalid email address format.", null, 400);
}

if (!in_array($role, ['customer', 'vendor'])) {
    $role = 'customer';
}

// Check duplicate email
$stmt = $db->prepare("SELECT id FROM users WHERE email = ? LIMIT 1");
$stmt->execute([$email]);
if ($stmt->fetch()) {
    sendResponse(false, "Email address is already registered.", null, 409);
}

$passwordHash = password_hash($password, PASSWORD_BCRYPT);
$profileImage = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400";

try {
    $db->beginTransaction();

    $stmt = $db->prepare("INSERT INTO users (full_name, email, password_hash, phone, role, profile_image, status) VALUES (?, ?, ?, ?, ?, ?, 'active')");
    $stmt->execute([$fullName, $email, $passwordHash, $phone, $role, $profileImage]);
    $userId = $db->lastInsertId();

    $vendorId = null;

    if ($role === 'vendor') {
        $businessName = isset($input['business_name']) ? $input['business_name'] : "$fullName Events";
        $categoryId = isset($input['category_id']) ? (int)$input['category_id'] : 1;
        $city = isset($input['city']) ? $input['city'] : 'Mumbai';
        $startingPrice = isset($input['starting_price']) ? (float)$input['starting_price'] : 10000.00;
        $description = isset($input['description']) ? $input['description'] : 'Premier wedding services provider.';

        $stmt = $db->prepare("INSERT INTO vendors (user_id, business_name, category_id, city, address, starting_price, description, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')");
        $stmt->execute([$userId, $businessName, $categoryId, $city, "Main Street, $city", $startingPrice, $description]);
        $vendorId = $db->lastInsertId();
    }

    // Default Wedding Project for Customers
    if ($role === 'customer') {
        $weddingDate = date('Y-m-d', strtotime('+90 days'));
        $stmt = $db->prepare("INSERT INTO weddings (customer_id, bride_name, groom_name, wedding_date, location, guest_count, total_budget) VALUES (?, 'Bride Name', 'Groom Name', ?, 'Udaipur, Rajasthan', 200, 500000.00)");
        $stmt->execute([$userId, $weddingDate]);
        $weddingId = $db->lastInsertId();

        // Populate default checklist tasks
        $defaultTasks = [
            ['Finalize Wedding Venue', 'Venue', date('Y-m-d', strtotime('+10 days')), 'high'],
            ['Book Bridal Makeup Artist', 'Makeup', date('Y-m-d', strtotime('+15 days')), 'high'],
            ['Select Multi-Cuisine Catering Service', 'Catering', date('Y-m-d', strtotime('+20 days')), 'medium'],
            ['Finalize Candid Photography Team', 'Photography', date('Y-m-d', strtotime('+25 days')), 'high'],
            ['Send Invitation Cards to Guests', 'Invitation Cards', date('Y-m-d', strtotime('+40 days')), 'medium']
        ];
        $stmtTask = $db->prepare("INSERT INTO wedding_tasks (wedding_id, task_title, category, due_date, priority, status) VALUES (?, ?, ?, ?, ?, 'pending')");
        foreach ($defaultTasks as $task) {
            $stmtTask->execute([$weddingId, $task[0], $task[1], $task[2], $task[3]]);
        }
    }

    $db->commit();

    $user = [
        'id' => (int)$userId,
        'full_name' => $fullName,
        'email' => $email,
        'phone' => $phone,
        'role' => $role,
        'profile_image' => $profileImage,
        'vendor_id' => $vendorId
    ];
    $token = generateToken($user);

    sendResponse(true, "Registration successful!", [
        "user" => $user,
        "token" => $token
    ], 201);

} catch (Exception $e) {
    $db->rollBack();
    sendResponse(false, "Registration failed: " . $e->getMessage(), null, 500);
}
?>
