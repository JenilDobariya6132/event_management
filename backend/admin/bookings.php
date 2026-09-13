<?php
// backend/admin/bookings.php

require_once __DIR__ . "/../config/database.php";
require_once __DIR__ . "/../config/config.php";

$db = (new Database())->getConnection();

$query = "SELECT b.*, u.full_name as customer_name, u.phone as customer_phone, v.business_name, c.name as category_name 
          FROM bookings b 
          JOIN users u ON b.customer_id = u.id 
          JOIN vendors v ON b.vendor_id = v.id 
          JOIN categories c ON v.category_id = c.id 
          ORDER BY b.id DESC";

$bookings = $db->query($query)->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bookings - Royal Wedding</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="sidebar">
        <div class="brand">👑 Royal Wedding</div>
        <nav>
            <a href="index.php">📊 Dashboard</a>
            <a href="vendors.php">🏬 Vendors</a>
            <a href="customers.php">👥 Customers</a>
            <a href="categories.php">🏷️ Categories</a>
            <a href="bookings.php" class="active">📅 Bookings</a>
        </nav>
    </div>

    <div class="main-wrapper">
        <header>
            <h1>All Wedding Bookings</h1>
        </header>

        <div class="content">
            <div class="card-table">
                <div class="table-header">
                    <h2>Bookings Transactions (<?= count($bookings) ?>)</h2>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Booking #</th>
                            <th>Customer</th>
                            <th>Vendor</th>
                            <th>Category</th>
                            <th>Wedding Date</th>
                            <th>Venue Location</th>
                            <th>Total Price</th>
                            <th>Booking Status</th>
                            <th>Payment</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($bookings as $b): ?>
                        <tr>
                            <td><strong><?= htmlspecialchars($b['booking_number']) ?></strong></td>
                            <td><?= htmlspecialchars($b['customer_name']) ?><br><small><?= htmlspecialchars($b['customer_phone']) ?></small></td>
                            <td><?= htmlspecialchars($b['business_name']) ?></td>
                            <td><?= htmlspecialchars($b['category_name']) ?></td>
                            <td><?= htmlspecialchars($b['wedding_date']) ?></td>
                            <td><?= htmlspecialchars($b['venue_location']) ?></td>
                            <td><strong>₹<?= number_format($b['total_price'], 2) ?></strong></td>
                            <td><span class="badge badge-<?= strtolower($b['status']) ?>"><?= $b['status'] ?></span></td>
                            <td><span class="badge badge-<?= strtolower($b['payment_status']) ?>"><?= ucfirst($b['payment_status']) ?></span></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
