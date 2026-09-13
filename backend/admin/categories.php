<?php
// backend/admin/categories.php

require_once __DIR__ . "/../config/database.php";
require_once __DIR__ . "/../config/config.php";

$db = (new Database())->getConnection();

// Handle New Category Creation
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_category'])) {
    $name = trim($_POST['name']);
    $icon = trim($_POST['icon']) ?: 'celebration';
    $imageUrl = trim($_POST['image_url']) ?: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=600';
    $description = trim($_POST['description']);

    if (!empty($name)) {
        $stmt = $db->prepare("INSERT INTO categories (name, icon, image_url, description, is_active) VALUES (?, ?, ?, ?, 1)");
        $stmt->execute([$name, $icon, $imageUrl, $description]);
        header("Location: categories.php?msg=Category added successfully");
        exit();
    }
}

$categories = $db->query("SELECT c.*, COUNT(v.id) as total_vendors FROM categories c LEFT JOIN vendors v ON c.id = v.category_id GROUP BY c.id ORDER BY c.id ASC")->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Categories - Royal Wedding</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="sidebar">
        <div class="brand">👑 Royal Wedding</div>
        <nav>
            <a href="index.php">📊 Dashboard</a>
            <a href="vendors.php">🏬 Vendors</a>
            <a href="customers.php">👥 Customers</a>
            <a href="categories.php" class="active">🏷️ Categories</a>
            <a href="bookings.php">📅 Bookings</a>
        </nav>
    </div>

    <div class="main-wrapper">
        <header>
            <h1>Wedding Categories Management</h1>
        </header>

        <div class="content" style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px;">
            <div class="card-table">
                <div class="table-header">
                    <h2>Active Service Categories (<?= count($categories) ?>)</h2>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Icon</th>
                            <th>Category Name</th>
                            <th>Description</th>
                            <th>Vendors Count</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($categories as $c): ?>
                        <tr>
                            <td><span style="font-size: 20px;">📌</span></td>
                            <td><strong><?= htmlspecialchars($c['name']) ?></strong></td>
                            <td><?= htmlspecialchars($c['description']) ?></td>
                            <td><span class="badge badge-approved"><?= $c['total_vendors'] ?> Vendors</span></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <!-- Add Category Form -->
            <div class="card-table" style="padding: 24px; height: fit-content;">
                <h2 style="font-size: 18px; color: var(--primary); margin-bottom: 16px;">Add New Category</h2>
                <form action="categories.php" method="POST" style="display: flex; flex-direction: column; gap: 14px;">
                    <div>
                        <label style="font-size: 13px; font-weight: 600;">Category Name</label>
                        <input type="text" name="name" required style="width: 100%; padding: 8px 12px; border: 1px solid var(--border-color); border-radius: 6px; margin-top: 4px;">
                    </div>
                    <div>
                        <label style="font-size: 13px; font-weight: 600;">Material Icon Name</label>
                        <input type="text" name="icon" placeholder="celebration, camera_alt, face" style="width: 100%; padding: 8px 12px; border: 1px solid var(--border-color); border-radius: 6px; margin-top: 4px;">
                    </div>
                    <div>
                        <label style="font-size: 13px; font-weight: 600;">Cover Image URL</label>
                        <input type="url" name="image_url" placeholder="https://images.unsplash.com/..." style="width: 100%; padding: 8px 12px; border: 1px solid var(--border-color); border-radius: 6px; margin-top: 4px;">
                    </div>
                    <div>
                        <label style="font-size: 13px; font-weight: 600;">Description</label>
                        <textarea name="description" rows="3" style="width: 100%; padding: 8px 12px; border: 1px solid var(--border-color); border-radius: 6px; margin-top: 4px;"></textarea>
                    </div>
                    <button type="submit" name="add_category" class="btn btn-primary" style="margin-top: 8px;">Save Category</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
