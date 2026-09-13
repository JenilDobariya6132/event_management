<?php
// backend/admin/index.php

require_once __DIR__ . "/../config/database.php";
require_once __DIR__ . "/../config/config.php";

$db = (new Database())->getConnection();

// Fetch Dashboard Metrics
$totalCustomers = $db->query("SELECT COUNT(*) FROM users WHERE role = 'customer'")->fetchColumn();
$totalVendors = $db->query("SELECT COUNT(*) FROM vendors")->fetchColumn();
$pendingVendors = $db->query("SELECT COUNT(*) FROM vendors WHERE status = 'pending'")->fetchColumn();
$totalBookings = $db->query("SELECT COUNT(*) FROM bookings")->fetchColumn();
$totalRevenue = $db->query("SELECT SUM(amount) FROM payments WHERE payment_status = 'completed'")->fetchColumn() ?: 0.00;

// Fetch Recent Bookings
$recentBookings = $db->query("SELECT b.*, u.full_name as customer_name, v.business_name FROM bookings b JOIN users u ON b.customer_id = u.id JOIN vendors v ON b.vendor_id = v.id ORDER BY b.id DESC LIMIT 5")->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Royal Wedding Events</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="sidebar">
        <div class="brand">👑 Royal Wedding</div>
        <nav>
            <a href="index.php" class="active">📊 Dashboard</a>
            <a href="vendors.php">🏬 Vendors (<?= $pendingVendors > 0 ? "<b>$pendingVendors</b>" : '' ?>)</a>
            <a href="customers.php">👥 Customers</a>
            <a href="categories.php">🏷️ Categories</a>
            <a href="bookings.php">📅 Bookings</a>
        </nav>
    </div>

    <div class="main-wrapper">
        <header>
            <h1>Dashboard Overview</h1>
            <div>Welcome, <strong>Super Admin</strong></div>
        </header>

        <div class="content">
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="title">Total Customers</div>
                    <div class="value"><?= number_format($totalCustomers) ?></div>
                </div>
                <div class="stat-card">
                    <div class="title">Active Vendors</div>
                    <div class="value"><?= number_format($totalVendors) ?></div>
                </div>
                <div class="stat-card">
                    <div class="title">Pending Approvals</div>
                    <div class="value" style="color: #B06000;"><?= number_format($pendingVendors) ?></div>
                </div>
                <div class="stat-card">
                    <div class="title">Total Bookings</div>
                    <div class="value"><?= number_format($totalBookings) ?></div>
                </div>
                <div class="stat-card">
                    <div class="title">Total Revenue</div>
                    <div class="value" style="color: #28A745;">₹<?= number_format($totalRevenue, 2) ?></div>
                </div>
            </div>

            <div class="card-table">
                <div class="table-header">
                    <h2>Recent Booking Activity</h2>
                    <a href="bookings.php" class="btn btn-primary btn-sm">View All Bookings</a>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Booking #</th>
                            <th>Customer</th>
                            <th>Vendor</th>
                            <th>Date</th>
                            <th>Amount</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($recentBookings)): ?>
                            <tr><td colspan="6" style="text-align: center;">No bookings recorded yet.</td></tr>
                        <?php else: ?>
                            <?php foreach ($recentBookings as $b): ?>
                            <tr>
                                <td><strong><?= htmlspecialchars($b['booking_number']) ?></strong></td>
                                <td><?= htmlspecialchars($b['customer_name']) ?></td>
                                <td><?= htmlspecialchars($b['business_name']) ?></td>
                                <td><?= htmlspecialchars($b['wedding_date']) ?></td>
                                <td>₹<?= number_format($b['total_price'], 2) ?></td>
                                <td><span class="badge badge-<?= strtolower($b['status']) ?>"><?= $b['status'] ?></span></td>
                            </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
