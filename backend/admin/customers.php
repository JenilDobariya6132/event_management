<?php
// backend/admin/customers.php

require_once __DIR__ . "/../config/database.php";
require_once __DIR__ . "/../config/config.php";

$db = (new Database())->getConnection();

$customers = $db->query("SELECT u.*, w.bride_name, w.groom_name, w.wedding_date, w.location 
                         FROM users u 
                         LEFT JOIN weddings w ON u.id = w.customer_id 
                         WHERE u.role = 'customer' 
                         ORDER BY u.id DESC")->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customers - Royal Wedding</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="sidebar">
        <div class="brand">👑 Royal Wedding</div>
        <nav>
            <a href="index.php">📊 Dashboard</a>
            <a href="vendors.php">🏬 Vendors</a>
            <a href="customers.php" class="active">👥 Customers</a>
            <a href="categories.php">🏷️ Categories</a>
            <a href="bookings.php">📅 Bookings</a>
        </nav>
    </div>

    <div class="main-wrapper">
        <header>
            <h1>Customer Accounts</h1>
        </header>

        <div class="content">
            <div class="card-table">
                <div class="table-header">
                    <h2>Registered Wedding Clients (<?= count($customers) ?>)</h2>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Customer Name</th>
                            <th>Email Address</th>
                            <th>Phone</th>
                            <th>Bride & Groom</th>
                            <th>Wedding Date</th>
                            <th>Location</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($customers as $c): ?>
                        <tr>
                            <td><strong><?= htmlspecialchars($c['full_name']) ?></strong></td>
                            <td><?= htmlspecialchars($c['email']) ?></td>
                            <td><?= htmlspecialchars($c['phone'] ?: 'N/A') ?></td>
                            <td><?= htmlspecialchars(($c['bride_name'] ?? 'Not set') . ' & ' . ($c['groom_name'] ?? 'Not set')) ?></td>
                            <td><?= htmlspecialchars($c['wedding_date'] ?: 'N/A') ?></td>
                            <td><?= htmlspecialchars($c['location'] ?: 'N/A') ?></td>
                            <td><span class="badge badge-<?= strtolower($c['status']) ?>"><?= ucfirst($c['status']) ?></span></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
