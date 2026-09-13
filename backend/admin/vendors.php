<?php
// backend/admin/vendors.php

require_once __DIR__ . "/../config/database.php";
require_once __DIR__ . "/../config/config.php";

$db = (new Database())->getConnection();

// Handle Approve / Reject actions
if (isset($_GET['action']) && isset($_GET['id'])) {
    $vendorId = (int)$_GET['id'];
    $action = $_GET['action'];

    if ($action === 'approve') {
        $stmt = $db->prepare("UPDATE vendors SET status = 'approved' WHERE id = ?");
        $stmt->execute([$vendorId]);
    } else if ($action === 'reject') {
        $stmt = $db->prepare("UPDATE vendors SET status = 'rejected' WHERE id = ?");
        $stmt->execute([$vendorId]);
    }
    header("Location: vendors.php?msg=Status updated successfully");
    exit();
}

$statusFilter = isset($_GET['status']) ? $_GET['status'] : '';
$query = "SELECT v.*, c.name as category_name, u.full_name as owner_name, u.email, u.phone FROM vendors v JOIN categories c ON v.category_id = c.id JOIN users u ON v.user_id = u.id";
if (!empty($statusFilter)) {
    $query .= " WHERE v.status = " . $db->quote($statusFilter);
}
$query .= " ORDER BY v.id DESC";

$vendors = $db->query($query)->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Vendor Management - Royal Wedding</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="sidebar">
        <div class="brand">👑 Royal Wedding</div>
        <nav>
            <a href="index.php">📊 Dashboard</a>
            <a href="vendors.php" class="active">🏬 Vendors</a>
            <a href="customers.php">👥 Customers</a>
            <a href="categories.php">🏷️ Categories</a>
            <a href="bookings.php">📅 Bookings</a>
        </nav>
    </div>

    <div class="main-wrapper">
        <header>
            <h1>Vendor Management</h1>
            <div style="display: flex; gap: 10px;">
                <a href="vendors.php" class="btn btn-primary btn-sm">All</a>
                <a href="vendors.php?status=pending" class="btn btn-sm" style="background:#FFC107; color:black;">Pending</a>
                <a href="vendors.php?status=approved" class="btn btn-success btn-sm">Approved</a>
            </div>
        </header>

        <div class="content">
            <div class="card-table">
                <div class="table-header">
                    <h2>Registered Vendors (<?= count($vendors) ?>)</h2>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Business Name</th>
                            <th>Category</th>
                            <th>Owner Name</th>
                            <th>City</th>
                            <th>Starting Price</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($vendors as $v): ?>
                        <tr>
                            <td><strong><?= htmlspecialchars($v['business_name']) ?></strong></td>
                            <td><?= htmlspecialchars($v['category_name']) ?></td>
                            <td><?= htmlspecialchars($v['owner_name']) ?><br><small><?= htmlspecialchars($v['email']) ?></small></td>
                            <td><?= htmlspecialchars($v['city']) ?></td>
                            <td>₹<?= number_format($v['starting_price'], 2) ?></td>
                            <td><span class="badge badge-<?= strtolower($v['status']) ?>"><?= ucfirst($v['status']) ?></span></td>
                            <td>
                                <?php if ($v['status'] === 'pending'): ?>
                                    <a href="vendors.php?action=approve&id=<?= $v['id'] ?>" class="btn btn-success btn-sm">Approve</a>
                                    <a href="vendors.php?action=reject&id=<?= $v['id'] ?>" class="btn btn-danger btn-sm">Reject</a>
                                <?php else: ?>
                                    <span style="color: var(--text-muted); font-size: 12px;">Verified</span>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
