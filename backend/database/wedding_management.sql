-- Wedding Event Management Database Schema
-- Database Name: wedding_management

CREATE DATABASE IF NOT EXISTS `wedding_management` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `wedding_management`;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `role` ENUM('customer', 'vendor', 'admin') NOT NULL DEFAULT 'customer',
  `profile_image` VARCHAR(255) DEFAULT NULL,
  `status` ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Admins Table
CREATE TABLE IF NOT EXISTS `admins` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `role_title` VARCHAR(50) DEFAULT 'Super Admin',
  `permissions` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Categories Table
CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `icon` VARCHAR(50) DEFAULT 'celebration',
  `image_url` VARCHAR(255) DEFAULT NULL,
  `description` TEXT DEFAULT NULL,
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Vendors Table
CREATE TABLE IF NOT EXISTS `vendors` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `business_name` VARCHAR(150) NOT NULL,
  `category_id` INT NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `address` TEXT DEFAULT NULL,
  `starting_price` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `description` TEXT DEFAULT NULL,
  `rating` DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
  `total_reviews` INT NOT NULL DEFAULT 0,
  `status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Vendor Documents Table
CREATE TABLE IF NOT EXISTS `vendor_documents` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `vendor_id` INT NOT NULL,
  `document_type` VARCHAR(100) NOT NULL,
  `document_path` VARCHAR(255) NOT NULL,
  `verified` TINYINT(1) DEFAULT 0,
  `uploaded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`vendor_id`) REFERENCES `vendors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Services Table
CREATE TABLE IF NOT EXISTS `services` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `category_id` INT NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT DEFAULT NULL,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Vendor Services Table
CREATE TABLE IF NOT EXISTS `vendor_services` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `vendor_id` INT NOT NULL,
  `service_id` INT NOT NULL,
  `price` DECIMAL(10, 2) NOT NULL,
  `description` TEXT DEFAULT NULL,
  FOREIGN KEY (`vendor_id`) REFERENCES `vendors`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`service_id`) REFERENCES `services`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Vendor Packages Table
CREATE TABLE IF NOT EXISTS `vendor_packages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `vendor_id` INT NOT NULL,
  `title` VARCHAR(150) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `price` DECIMAL(10, 2) NOT NULL,
  `features_json` TEXT DEFAULT NULL,
  `image_url` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`vendor_id`) REFERENCES `vendors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Vendor Images Table
CREATE TABLE IF NOT EXISTS `vendor_images` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `vendor_id` INT NOT NULL,
  `image_url` VARCHAR(255) NOT NULL,
  `caption` VARCHAR(150) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`vendor_id`) REFERENCES `vendors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. Destinations Table
CREATE TABLE IF NOT EXISTS `destinations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(150) NOT NULL,
  `location` VARCHAR(100) NOT NULL,
  `image_url` VARCHAR(255) DEFAULT NULL,
  `description` TEXT DEFAULT NULL,
  `starting_price` DECIMAL(10, 2) NOT NULL,
  `is_popular` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. Destination Packages Table
CREATE TABLE IF NOT EXISTS `destination_packages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `destination_id` INT NOT NULL,
  `package_name` VARCHAR(150) NOT NULL,
  `price` DECIMAL(10, 2) NOT NULL,
  `duration` VARCHAR(50) DEFAULT '3 Days / 2 Nights',
  `inclusions_json` TEXT DEFAULT NULL,
  `image_url` VARCHAR(255) DEFAULT NULL,
  FOREIGN KEY (`destination_id`) REFERENCES `destinations`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. Weddings Table
CREATE TABLE IF NOT EXISTS `weddings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` INT NOT NULL,
  `bride_name` VARCHAR(100) NOT NULL,
  `groom_name` VARCHAR(100) NOT NULL,
  `wedding_date` DATE NOT NULL,
  `location` VARCHAR(150) NOT NULL,
  `guest_count` INT NOT NULL DEFAULT 100,
  `total_budget` DECIMAL(12, 2) NOT NULL DEFAULT 500000.00,
  `style` VARCHAR(100) DEFAULT 'Royal Traditional',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13. Wedding Tasks Table
CREATE TABLE IF NOT EXISTS `wedding_tasks` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `wedding_id` INT NOT NULL,
  `task_title` VARCHAR(200) NOT NULL,
  `category` VARCHAR(100) DEFAULT 'General',
  `due_date` DATE DEFAULT NULL,
  `priority` ENUM('low', 'medium', 'high') DEFAULT 'medium',
  `status` ENUM('pending', 'completed') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`wedding_id`) REFERENCES `weddings`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 14. Wedding Budget Table
CREATE TABLE IF NOT EXISTS `wedding_budget` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `wedding_id` INT NOT NULL,
  `category_name` VARCHAR(100) NOT NULL,
  `estimated_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `actual_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`wedding_id`) REFERENCES `weddings`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 15. Guests Table
CREATE TABLE IF NOT EXISTS `guests` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `wedding_id` INT NOT NULL,
  `guest_name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `family_tag` VARCHAR(100) DEFAULT 'Family',
  `side` ENUM('bride', 'groom') DEFAULT 'bride',
  `member_count` INT NOT NULL DEFAULT 1,
  `invitation_status` ENUM('invited', 'not_invited') DEFAULT 'not_invited',
  `rsvp_status` ENUM('attending', 'declined', 'pending') DEFAULT 'pending',
  `food_preference` ENUM('veg', 'non_veg', 'jain') DEFAULT 'veg',
  `accommodation_needed` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`wedding_id`) REFERENCES `weddings`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 16. Favorites Table
CREATE TABLE IF NOT EXISTS `favorites` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` INT NOT NULL,
  `vendor_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_fav` (`customer_id`, `vendor_id`),
  FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`vendor_id`) REFERENCES `vendors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 17. Bookings Table
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_number` VARCHAR(50) NOT NULL UNIQUE,
  `customer_id` INT NOT NULL,
  `vendor_id` INT NOT NULL,
  `package_id` INT DEFAULT NULL,
  `destination_package_id` INT DEFAULT NULL,
  `wedding_date` DATE NOT NULL,
  `venue_location` VARCHAR(255) NOT NULL,
  `guest_count` INT DEFAULT 100,
  `special_requirements` TEXT DEFAULT NULL,
  `total_price` DECIMAL(10, 2) NOT NULL,
  `status` ENUM('Pending', 'Accepted', 'Rejected', 'Confirmed', 'Completed', 'Cancelled') DEFAULT 'Pending',
  `payment_status` ENUM('pending', 'paid', 'partial', 'refunded') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`vendor_id`) REFERENCES `vendors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 18. Booking Details Table
CREATE TABLE IF NOT EXISTS `booking_details` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT NOT NULL,
  `service_name` VARCHAR(150) NOT NULL,
  `quantity` INT DEFAULT 1,
  `unit_price` DECIMAL(10, 2) NOT NULL,
  `subtotal` DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 19. Payments Table
CREATE TABLE IF NOT EXISTS `payments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT NOT NULL,
  `transaction_id` VARCHAR(100) NOT NULL UNIQUE,
  `payment_gateway` VARCHAR(50) DEFAULT 'Razorpay',
  `amount` DECIMAL(10, 2) NOT NULL,
  `payment_method` VARCHAR(50) DEFAULT 'Card / UPI',
  `payment_status` ENUM('completed', 'failed', 'refunded') DEFAULT 'completed',
  `payment_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 20. Reviews Table
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT NOT NULL,
  `customer_id` INT NOT NULL,
  `vendor_id` INT NOT NULL,
  `rating` INT NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
  `comment` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`vendor_id`) REFERENCES `vendors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 21. Notifications Table
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `title` VARCHAR(150) NOT NULL,
  `message` TEXT NOT NULL,
  `type` VARCHAR(50) DEFAULT 'general',
  `is_read` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 22. Vendor Availability Table
CREATE TABLE IF NOT EXISTS `vendor_availability` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `vendor_id` INT NOT NULL,
  `date` DATE NOT NULL,
  `is_available` TINYINT(1) DEFAULT 1,
  `notes` VARCHAR(255) DEFAULT NULL,
  FOREIGN KEY (`vendor_id`) REFERENCES `vendors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 23. Contact Requests Table
CREATE TABLE IF NOT EXISTS `contact_requests` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` INT NOT NULL,
  `vendor_id` INT NOT NULL,
  `message` TEXT NOT NULL,
  `status` ENUM('pending', 'replied') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`vendor_id`) REFERENCES `vendors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 24. Complaints Table
CREATE TABLE IF NOT EXISTS `complaints` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `booking_id` INT DEFAULT NULL,
  `subject` VARCHAR(150) NOT NULL,
  `description` TEXT NOT NULL,
  `status` ENUM('open', 'in_progress', 'resolved') DEFAULT 'open',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 25. Offers Table
CREATE TABLE IF NOT EXISTS `offers` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(50) NOT NULL UNIQUE,
  `title` VARCHAR(150) NOT NULL,
  `discount_percentage` DECIMAL(5, 2) NOT NULL,
  `max_discount` DECIMAL(10, 2) DEFAULT 5000.00,
  `valid_until` DATE NOT NULL,
  `image_url` VARCHAR(255) DEFAULT NULL,
  `is_active` TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 26. Banners Table
CREATE TABLE IF NOT EXISTS `banners` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(150) NOT NULL,
  `image_url` VARCHAR(255) NOT NULL,
  `link_type` VARCHAR(50) DEFAULT 'category',
  `link_id` INT DEFAULT NULL,
  `is_active` TINYINT(1) DEFAULT 1,
  `display_order` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- SEED DATA INSERTIONS --

-- Password for all seed users is: Password123 (bcrypt hashed)
-- Hash: $2y$10$4n9/dF7E41WpXg.R09G51uG98b3cQ.J52uLw45xS1R1u3y8E71f3m

INSERT INTO `users` (`id`, `full_name`, `email`, `password_hash`, `phone`, `role`, `profile_image`, `status`) VALUES
(1, 'Admin User', 'admin@wedding.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFv3k8vS4D4sX4Ww9R/O/8u0s7E9mK.m', '9876543210', 'admin', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400', 'active'),
(2, 'Aarav Sharma', 'aarav@gmail.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFv3k8vS4D4sX4Ww9R/O/8u0s7E9mK.m', '9876543211', 'customer', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', 'active'),
(3, 'Grand Palace Venue', 'grandpalace@vendor.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFv3k8vS4D4sX4Ww9R/O/8u0s7E9mK.m', '9876543212', 'vendor', 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400', 'active'),
(4, 'Royal Royal Caterers', 'royalcatering@vendor.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFv3k8vS4D4sX4Ww9R/O/8u0s7E9mK.m', '9876543213', 'vendor', 'https://images.unsplash.com/photo-1555244162-803834f70033?w=400', 'active'),
(5, 'Glamour Studio Makeup', 'glamour@vendor.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFv3k8vS4D4sX4Ww9R/O/8u0s7E9mK.m', '9876543214', 'vendor', 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400', 'active'),
(6, 'Candid Moments Photography', 'candid@vendor.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFv3k8vS4D4sX4Ww9R/O/8u0s7E9mK.m', '9876543215', 'vendor', 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=400', 'active'),
(7, 'BeatBlaster DJ Services', 'beatblaster@vendor.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFv3k8vS4D4sX4Ww9R/O/8u0s7E9mK.m', '9876543216', 'vendor', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400', 'active'),
(8, 'Dream Floral Decorators', 'dreamdecor@vendor.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHeFv3k8vS4D4sX4Ww9R/O/8u0s7E9mK.m', '9876543217', 'vendor', 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=400', 'active');

INSERT INTO `admins` (`user_id`, `role_title`) VALUES (1, 'Super Admin');

-- Seed Categories (22 Categories)
INSERT INTO `categories` (`id`, `name`, `icon`, `image_url`, `description`) VALUES
(1, 'Venue', 'location_city', 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=600', 'Luxury banquets, royal palaces, beach resorts, and open lawns'),
(2, 'Catering', 'restaurant', 'https://images.unsplash.com/photo-1555244162-803834f70033?w=600', 'Multi-cuisine catering, live food counters & dessert bars'),
(3, 'Decoration', 'local_florist', 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=600', 'Mandap decor, floral arrangements, fairy lights & themes'),
(4, 'Makeup', 'face', 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=600', 'Bridal makeup, airbrush makeup, family makeover & hair styling'),
(5, 'Photography', 'camera_alt', 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=600', 'Pre-wedding shoot, candid wedding photography & traditional shoots'),
(6, 'Videography', 'videocam', 'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?w=600', 'Cinematic wedding film, drone coverage & 4K live streaming'),
(7, 'DJ & Music', 'headset', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600', 'Bollywood DJs, live band performance, dhol & sangeet setup'),
(8, 'Destination Wedding', 'flight_takeoff', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=600', 'Complete end-to-end destination wedding management packages'),
(9, 'Wedding Planner', 'assignment', 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=600', 'Full wedding coordination, theme design & execution'),
(10, 'Mehndi', 'brush', 'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=600', 'Bridal henna, designer organic mehndi & guest mehndi artist'),
(11, 'Invitation Cards', 'mail', 'https://images.unsplash.com/photo-1520854221256-17451cc331bf?w=600', 'E-invites, royal paper invitations, video invites & gift hampers'),
(12, 'Wedding Cake', 'cake', 'https://images.unsplash.com/photo-1535141192574-5d4897c13136?w=600', 'Multi-tier wedding cakes, custom toppers & dessert tables'),
(13, 'Bridal Wear', 'woman', 'https://images.unsplash.com/photo-1594552072238-b8a33785b261?w=600', 'Designer lehengas, bridal sarees & sangeet gowns'),
(14, 'Groom Wear', 'man', 'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=600', 'Sherwanis, Indo-western suits, tuxedoes & accessories'),
(15, 'Jewellery', 'diamond', 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600', 'Kundan, Polki, Diamond bridal sets & rental jewellery'),
(16, 'Transportation', 'directions_car', 'https://images.unsplash.com/photo-1563720223185-11003d516935?w=600', 'Vintage cars, luxury sedans & guest Volvo bus coaches'),
(17, 'Hotel & Stay', 'hotel', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600', 'Luxury hotel accommodation for wedding guests'),
(18, 'Priest / Pandit', 'menu_book', 'https://images.unsplash.com/photo-1609102026400-0255375d3159?w=600', 'Vedic Pandits & priests for all rituals and ceremonies'),
(19, 'Choreographer', 'music_note', 'https://images.unsplash.com/photo-1545959570-a94467d022b7?w=600', 'Sangeet dance choreography for family & couples'),
(20, 'Lighting', 'lightbulb', 'https://images.unsplash.com/photo-1508997449629-303059a039c0?w=600', 'Architectural lighting, LED displays & cold pyros'),
(21, 'Florist', 'local_florist', 'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?w=600', 'Exotic flower garlands, car decoration & Varmala designs'),
(22, 'Other Services', 'more_horiz', 'https://images.unsplash.com/photo-1529636798458-92182e662485?w=600', 'Trousseau packing, security, fireworks & vintage buggi');

-- Seed Vendors
INSERT INTO `vendors` (`id`, `user_id`, `business_name`, `category_id`, `city`, `address`, `starting_price`, `description`, `rating`, `total_reviews`, `status`) VALUES
(1, 3, 'Grand Imperial Palace & Lawns', 1, 'Udaipur', 'Fateh Sagar Lake Road, Udaipur', 250000.00, 'A majestic heritage palace offering lakeside wedding lawns, luxury dining halls, and 100+ guest suites with royal Rajasthani hospitality.', 4.9, 38, 'approved'),
(2, 4, 'Royal Heritage Caterers', 2, 'Mumbai', 'Juhu Tara Road, Mumbai', 1200.00, 'Exquisite North Indian, Italian, Continental, and authentic Gujarati Thali options served with silver cutlery.', 4.8, 45, 'approved'),
(3, 5, 'Glamour Artistry by Ananya', 4, 'Delhi', 'South Extension II, New Delhi', 25000.00, 'Celebrity bridal makeup artist specializing in HD Airbrush makeup, hair styling, and saree draping.', 4.9, 52, 'approved'),
(4, 6, 'Candid Moments & Films', 5, 'Jaipur', 'C-Scheme, Jaipur', 85000.00, 'Award-winning wedding photography collective capturing timeless candid emotions and pre-wedding stories worldwide.', 4.7, 29, 'approved'),
(5, 7, 'BeatBlaster DJ & Sound System', 7, 'Goa', 'Baga Beach Road, Goa', 35000.00, 'High-energy DJ with Intelligent LED lighting setup, CO2 cannons, and live percussionist support.', 4.6, 21, 'approved'),
(6, 8, 'Dream Floral & Mandap Decorators', 3, 'Udaipur', 'City Palace Circle, Udaipur', 150000.00, 'Luxury floral installations, crystal chandelier mandaps, and customized thematic entryways.', 4.9, 34, 'approved');

-- Seed Vendor Packages
INSERT INTO `vendor_packages` (`vendor_id`, `title`, `description`, `price`, `features_json`, `image_url`) VALUES
(1, 'Royal Palace Wedding Package', 'Exclusive 2-day booking of main banquet hall, lakeside lawns, and 50 luxury rooms.', 500000.00, '["2-Day Full Property Access", "50 Deluxe Guest Rooms", "Bridal Suite complimentary", "24x7 Power Backup", "Valet Parking"]', 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=600'),
(2, 'Grand Royal Buffet (500 Guests)', 'Multi-cuisine 40+ item lavish buffet spread with live counter stations.', 600000.00, '["4 Starters", "3 Live Food Stations", "12 Main Course Dishes", "5 Dessert Counter", "Mocktail Bar"]', 'https://images.unsplash.com/photo-1555244162-803834f70033?w=600'),
(3, 'Bridal HD Makeover Package', 'Complete HD Airbrush makeup with trial, hair styling, extensions & draping.', 35000.00, '["HD Airbrush Makeup", "Hair Styling & Extensions", "Saree / Lehenga Draping", "Eyelashes & Nails", "Touchup Kit"]', 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=600'),
(4, 'Complete Candid & Cinematic Package', 'Full 3-day wedding coverage with 2 candid photographers, 2 cinematographers, and drone.', 150000.00, '["3-Day Coverage", "Candid & Traditional Photo", "4K Cinematic Film (3-5 min teaser + 45 min film)", "Drone Shots", "Hardbound Album (50 pages)"]', 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=600');

-- Seed Vendor Images
INSERT INTO `vendor_images` (`vendor_id`, `image_url`, `caption`) VALUES
(1, 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800', 'Lakeside Lawn Evening Setup'),
(1, 'https://images.unsplash.com/photo-1544078751-58fee2d8a03b?w=800', 'Grand Banquet Interior'),
(3, 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800', 'Bridal Glamour Glow'),
(4, 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800', 'Pre-wedding Romance Shoot');

-- Seed Destinations
INSERT INTO `destinations` (`id`, `title`, `location`, `image_url`, `description`, `starting_price`, `is_popular`) VALUES
(1, 'Royal Udaipur Lakeside Wedding', 'Udaipur, Rajasthan', 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800', 'Experience unmatched royal majesty with palace venues, boat entries, and fireworks over Lake Pichola.', 2500000.00, 1),
(2, 'Jaipur Pink City Heritage', 'Jaipur, Rajasthan', 'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=800', 'The Pink City Royal Heritage with fort venues and grand elephant welcome.', 2000000.00, 1),
(3, 'Beachfront Sunset Wedding in Goa', 'North Goa', 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800', 'Exchange vows on white sand beaches with sunset ocean views, tropical decor, and beach bonfire parties.', 1800000.00, 1),
(4, 'Kerala Backwater Houseboat', 'Alleppey, Kerala', 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=800', 'Serene backwater weddings with houseboat processions & traditional Sadya feast.', 1600000.00, 1),
(5, 'Mussoorie Cloud Misty Hills', 'Mussoorie, Uttarakhand', 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800', 'Romantic hill station wedding surrounded by pine valleys and Himalayan sunsets.', 1900000.00, 1),
(6, 'Jodhpur Mehrangarh Fort', 'Jodhpur, Rajasthan', 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800', 'Grand fort celebration with royal cannons, desert dune pre-wedding gala, and illuminations.', 2800000.00, 1),
(7, 'Andaman Crystal Beach Paradise', 'Havelock Island, Andaman', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800', 'Exotic island weddings featuring turquoise waters, coral beach ceremonies, and beach BBQ.', 2200000.00, 1),
(8, 'Rishikesh Holy Ganges Retreat', 'Rishikesh, Uttarakhand', 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800', 'Spiritual and serene riverside wedding with traditional Vedic chants and Ganga Aarti ceremony.', 1500000.00, 0),
(9, 'Statue of Unity Tent City', 'Kevadia, Gujarat', 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800', 'Grand Narmada riverfront wedding surrounded by Vindhyachal hills and luxury tented resorts.', 1700000.00, 1),
(10, 'Rann of Kutch White Desert', 'Kutch, Gujarat', 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800', 'Enchanting white desert full-moon mandap under starry skies with Kutchi folk music.', 2100000.00, 1),
(11, 'Gir Forest Eco Resort', 'Sasan Gir, Gujarat', 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800', 'Royal wilderness wedding surrounded by lush teak forests & luxury jungle safari lodges.', 1650000.00, 1),
(12, 'Dwarka Ocean Temple & Beach', 'Dwarka, Gujarat', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800', 'Sacred coastal temple blessing ceremony with Arabian Sea sunset mandap and seaside banquet.', 1400000.00, 0),
(13, 'Vadodara Laxmi Vilas Palace', 'Vadodara, Gujarat', 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800', 'Majestic Indo-Saracenic royal palace lawns four times the size of Buckingham Palace.', 3000000.00, 1),
(14, 'Surat Tapi Riverfront Resort', 'Surat, Gujarat', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 'Modern riverfront resort with diamond-inspired decor, floating stage & lavish Surti sweets.', 1850000.00, 1),
(15, 'Diu Island Portuguese Coast', 'Diu Coast, Gujarat', 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800', 'Colonial Portuguese fort ruins & quiet sandy beach mandap with European coastal charm.', 1750000.00, 0),
(16, 'Shimla Heritage Snow Ridge', 'Shimla, Himachal Pradesh', 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800', 'Colonial luxury estate wedding amidst pine valleys & snow-capped Himalayan peaks.', 1850000.00, 1),
(17, 'Manali Alpine Valley Resort', 'Manali, Himachal Pradesh', 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800', 'Alpine riverfront mandap with pine forest backdrop, snow peaks, and cozy chalets.', 1750000.00, 1),
(18, 'Srinagar Dal Lake Palace', 'Srinagar, Kashmir', 'https://images.unsplash.com/photo-1595815771614-ade9d652a65d?w=800', 'Paradise wedding on floating Shikaras & Shalimar Bagh Mughal Gardens with saffron feast.', 2600000.00, 1),
(19, 'Amritsar Punjabi Farmhouse', 'Amritsar, Punjab', 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800', 'Traditional vibrant Punjabi wedding with live Dhol, Gidda dancers & mustard field views.', 1550000.00, 1),
(20, 'Mahabaleshwar Foggy Hills', 'Mahabaleshwar, Maharashtra', 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800', 'Strawberry farm sunset mandap in lush foggy Western Ghats mountain resorts.', 1600000.00, 0),
(21, 'Alibaug Seaside Private Villa', 'Alibaug, Maharashtra', 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800', 'Chic beachside villa wedding with speedboat arrival, private infinity pool mandap & lounge.', 1950000.00, 1),
(22, 'Coorg Coffee Estate Haven', 'Coorg, Karnataka', 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800', 'Misty coffee plantation wedding with Kodava traditions, aromatic garden mandap & lawns.', 1700000.00, 1),
(23, 'Bengaluru Palace Grounds', 'Bengaluru, Karnataka', 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800', 'Tudor-style royal palace grounds with grand floral arches, vintage carriages & royal dining.', 2400000.00, 1),
(24, 'Mahabalipuram Shore Beach', 'Mahabalipuram, Tamil Nadu', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800', 'UNESCO granite temple backdrop with golden beach Mandap, Carnatic violin & ocean breeze.', 1800000.00, 0),
(25, 'Darjeeling Kanchenjunga Estate', 'Darjeeling, West Bengal', 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800', 'Panoramic views of Mt. Kanchenjunga with colonial tea estate luxury & flower decor.', 1600000.00, 0);

-- Seed Destination Packages
INSERT INTO `destination_packages` (`destination_id`, `package_name`, `price`, `duration`, `inclusions_json`, `image_url`) VALUES
(1, 'Lake Palace Heritage Package', 2500000.00, '3 Days / 2 Nights', '["Palace Venue Rental", "Royal Feast Catering for 300 Guests", "Folk Dance & Sangeet Decor", "2 Night Luxury Suite Stay"]', 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800'),
(2, 'Fort Heritage Royal Package', 2000000.00, '3 Days / 2 Nights', '["Fort Mandap Rental", "Traditional Shehnai Welcome", "Royal Buffet Catering", "Decor & Lighting"]', 'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=800'),
(3, 'Sunset Beachfront Package', 1800000.00, '2 Days / 2 Nights', '["Beach Altar & Floral Mandap", "Seafood & Cocktail Bar", "Live Acoustic Band", "Beach DJ Night"]', 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800'),
(4, 'Backwater Luxury Houseboat Experience', 1600000.00, '3 Days / 2 Nights', '["Luxury Houseboat Bride Entry", "Lakeside Floral Mandap", "Traditional Kerala Sadya Feast", "Kathakali & Chenda Melam Performance"]', 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=800'),
(5, 'Himalayan Ridge Royal Wedding', 1900000.00, '3 Days / 2 Nights', '["Pine Ridge Valley Outdoor Mandap", "Cozy Bonfire & Acoustic Night", "Himalayan Gourmet Buffet", "Luxury Mountain Resort Stay for 150 Guests"]', 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800'),
(6, 'Mehrangarh Fort & Royal Courtyard', 2800000.00, '3 Days / 2 Nights', '["Fort Rampart Fireworks & Illumination", "Royal Marwari Feast Catering", "Desert Safari Sangeet Party", "Vintage Car Groom Procession"]', 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800'),
(7, 'Exotic Island Coral Paradise', 2200000.00, '3 Days / 2 Nights', '["Private Coral Beach Mandap", "Seafood & Tropical Barbecue", "Speedboat Guest Transfers", "Scuba Pre-Wedding Photography Session"]', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800'),
(8, 'Vedic Riverside Ganga Blessing', 1500000.00, '2 Days / 2 Nights', '["Ganga Ghat Floral Mandap", "Vedic Priest & Live Shehnai Ensemble", "Pure Sattvik Organic Feast", "Evening Ganga Aarti Celebration"]', 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800'),
(9, 'Narmada Royal Tent City Experience', 1700000.00, '3 Days / 2 Nights', '["Grand Narmada Riverfront Mandap", "Luxury AC Tent Stay for 150 Guests", "Authentic Gujarati Thali & Global Buffet", "Laser Light Show & Sangeet Setup"]', 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800'),
(10, 'Kutch Moonlit White Desert Package', 2100000.00, '3 Days / 2 Nights', '["White Desert Glass Mandap", "Camel Safari Procession for Groom", "Kutchi Garba & Folk Night", "Traditional Kutchi Buffet & Handicrafts"]', 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800'),
(11, 'Gir Lion Wilderness Eco Package', 1650000.00, '3 Days / 2 Nights', '["Jungle Canopy Floral Mandap", "Open-Air Campfire Acoustic Night", "Organic Kathiyawadi & Continental Feast", "Safari Tour for Wedding Guests"]', 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800'),
(12, 'Dwarka Coastal Holy Vows Package', 1400000.00, '2 Days / 2 Nights', '["Seaside Temple Altar Setup", "Traditional Shehnai & Vedic Chants", "Pure Jain & Pure Veg Feast", "Sunset Beach Reception"]', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800'),
(13, 'Laxmi Vilas Royal Palace Grandeur', 3000000.00, '3 Days / 2 Nights', '["Palace Courtyard Mandap Rental", "Royal Maratha Elephant Welcome", "Lavish 50+ Item Gourmet Spread", "Chandelier Lighting & Royal Guard"]', 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'),
(14, 'Surat Tapi Riverfront Diamond Package', 1850000.00, '3 Days / 2 Nights', '["Tapi Riverfront Floating Stage", "Surti Gourmet Catered Feast", "Grand LED Sangeet Stage", "Luxury Suite Stay for Family"]', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800'),
(15, 'Diu Fort Colonial Beach Package', 1750000.00, '2 Days / 2 Nights', '["Cliffside Sea View Mandap", "Beachside Sunset Bar & Grill", "Live Jazz & Portuguese Music", "Vintage Car Bride Entry"]', 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800'),
(16, 'Shimla Colonial Snow Estate', 1850000.00, '3 Days / 2 Nights', '["Pine Ridge Valley Outdoor Mandap", "Cozy Bonfire & Acoustic Night", "Himachali Dham Gourmet Buffet", "Luxury Mountain Resort Stay"]', 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800'),
(17, 'Manali Alpine Riverfront Delight', 1750000.00, '3 Days / 2 Nights', '["Beas Riverbank Floral Mandap", "Snow Valley Pre-Wedding Shoot", "Multi-Cuisine Buffet", "Chalet Lodging for Guests"]', 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800'),
(18, 'Kashmir Mughal Garden & Shikara Royal', 2600000.00, '3 Days / 2 Nights', '["Shikara Grand Procession Entry", "Mughal Garden Floral Mandap", "Authentic Kashmiri Wazwan Feast", "Live Rabab & Folk Ensemble"]', 'https://images.unsplash.com/photo-1595815771614-ade9d652a65d?w=800'),
(19, 'Grand Royal Punjabi Farm Package', 1550000.00, '2 Days / 2 Nights', '["Sarson Field Farmhouse Mandap", "Live Punjabi Dhol & Bhangra Troupe", "Amritsari Gourmet Feast", "Vintage Tractor & Horse Entry"]', 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800'),
(20, 'Mahabaleshwar Strawberry Valley Package', 1600000.00, '2 Days / 2 Nights', '["Strawberry Valley Sunset Lawn", "Maharashtrian & Continental Buffet", "Live Saxophone & Acoustic Band", "Luxury Valley View Rooms"]', 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800'),
(21, 'Alibaug Speedboat & Villa Glamour', 1950000.00, '2 Days / 2 Nights', '["Speedboat Entry for Couple", "Infinity Poolside Mandap", "Seafood & Global Fusion Buffet", "Sundowner DJ Party"]', 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800'),
(22, 'Coorg Plantation Green Haven', 1700000.00, '3 Days / 2 Nights', '["Coffee Plantation Open Lawn Mandap", "Kodava Valaga Music & Dance", "South Indian & Global Feast", "Ecolodge Stay for 120 Guests"]', 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800'),
(23, 'Bengaluru Tudor Palace Experience', 2400000.00, '3 Days / 2 Nights', '["Tudor Palace Lawn Rental", "Grand Glasshouse Sangeet Stage", "South & North Gourmet Buffet", "Royal Carriage Entrance"]', 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'),
(24, 'Mahabalipuram Shore Temple Heritage', 1800000.00, '2 Days / 2 Nights', '["Shore Temple View Beach Mandap", "Carnatic Live Ensemble & Nadaswaram", "Traditional Banana Leaf Feast", "Beachfire Sunset Reception"]', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800'),
(25, 'Darjeeling Kanchenjunga Tea Resort', 1600000.00, '2 Days / 2 Nights', '["Tea Estate Valley View Mandap", "Darjeeling Heritage Toy Train Entry", "Bengali & Nepalese Gourmet Spread", "Folk Dance & Acoustic Night"]', 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800');

-- Seed Sample Wedding Project for Customer ID 2
INSERT INTO `weddings` (`id`, `customer_id`, `bride_name`, `groom_name`, `wedding_date`, `location`, `guest_count`, `total_budget`, `style`) VALUES
(1, 2, 'Ananya Sharma', 'Aarav Patel', DATE_ADD(CURDATE(), INTERVAL 90 DAY), 'Udaipur, Rajasthan', 250, 1500000.00, 'Royal Rajasthani Heritage');

-- Seed Wedding Tasks
INSERT INTO `wedding_tasks` (`wedding_id`, `task_title`, `category`, `due_date`, `priority`, `status`) VALUES
(1, 'Finalize Palace Venue Booking', 'Venue', DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'high', 'completed'),
(1, 'Book Makeup Artist for Sangeet & Wedding', 'Makeup', DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'high', 'completed'),
(1, 'Finalize Multi-Cuisine Menu with Caterer', 'Catering', DATE_ADD(CURDATE(), INTERVAL 20 DAY), 'medium', 'pending'),
(1, 'Send Digital Save-The-Date Cards', 'Invitation Cards', DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'medium', 'pending'),
(1, 'Schedule Choreography Sessions for Sangeet', 'Choreographer', DATE_ADD(CURDATE(), INTERVAL 40 DAY), 'low', 'pending');

-- Seed Wedding Budget Items
INSERT INTO `wedding_budget` (`wedding_id`, `category_name`, `estimated_amount`, `actual_amount`, `notes`) VALUES
(1, 'Venue', 500000.00, 500000.00, 'Grand Imperial Palace deposit paid'),
(1, 'Catering', 400000.00, 380000.00, 'Royal Heritage Caterers confirmed'),
(1, 'Photography', 150000.00, 150000.00, 'Candid Moments & Films advance'),
(1, 'Decoration', 200000.00, 180000.00, 'Floral & mandap design finalized'),
(1, 'Makeup', 50000.00, 35000.00, 'HD Makeup package booked'),
(1, 'Clothing & Jewellery', 150000.00, 120000.00, 'Bridal lehenga shopping'),
(1, 'Transportation', 50000.00, 0.00, 'Vintage car & guest coaches');

-- Seed Guests
INSERT INTO `guests` (`wedding_id`, `guest_name`, `phone`, `family_tag`, `side`, `member_count`, `invitation_status`, `rsvp_status`, `food_preference`, `accommodation_needed`) VALUES
(1, 'Rajesh Sharma (Unc.)', '9822011223', 'Close Family', 'bride', 4, 'invited', 'attending', 'veg', 1),
(1, 'Priya Verma', '9822011224', 'College Friends', 'bride', 2, 'invited', 'attending', 'veg', 0),
(1, 'Siddharth Patel', '9822011225', 'Immediate Family', 'groom', 5, 'invited', 'attending', 'veg', 1),
(1, 'Karan Mehta', '9822011226', 'Corporate Office', 'groom', 1, 'invited', 'pending', 'non_veg', 0);

-- Seed Favorites
INSERT INTO `favorites` (`customer_id`, `vendor_id`) VALUES
(2, 1),
(2, 3),
(2, 4);

-- Seed Bookings
INSERT INTO `bookings` (`id`, `booking_number`, `customer_id`, `vendor_id`, `package_id`, `wedding_date`, `venue_location`, `guest_count`, `special_requirements`, `total_price`, `status`, `payment_status`) VALUES
(1, 'BK-2026-001', 2, 1, 1, DATE_ADD(CURDATE(), INTERVAL 90 DAY), 'Udaipur, Rajasthan', 250, 'Lakeside fireworks and red carpet welcome', 500000.00, 'Confirmed', 'paid'),
(2, 'BK-2026-002', 2, 3, 3, DATE_ADD(CURDATE(), INTERVAL 90 DAY), 'Udaipur, Rajasthan', 1, 'Need early morning 5 AM start for Muhurat', 35000.00, 'Accepted', 'paid');

-- Seed Payments
INSERT INTO `payments` (`booking_id`, `transaction_id`, `payment_gateway`, `amount`, `payment_method`, `payment_status`) VALUES
(1, 'PAY-RZP-9921001', 'Razorpay', 500000.00, 'UPI / Credit Card', 'completed'),
(2, 'PAY-RZP-9921002', 'Razorpay', 35000.00, 'NetBanking', 'completed');

-- Seed Reviews
INSERT INTO `reviews` (`booking_id`, `customer_id`, `vendor_id`, `rating`, `comment`) VALUES
(1, 2, 1, 5, 'Absolute perfection! The lakeside view and royal hospitality made our wedding unforgettable.'),
(2, 2, 3, 5, 'Ananya is a genius! My bridal makeup stayed flawless all day and looked stunning in photos.');

-- Seed Notifications
INSERT INTO `notifications` (`user_id`, `title`, `message`, `type`) VALUES
(2, 'Booking Confirmed!', 'Grand Imperial Palace has confirmed your venue booking for BK-2026-001.', 'booking'),
(2, 'Payment Received', 'Your payment of ₹500,000 via Razorpay was successful.', 'payment'),
(2, 'Wedding Checklist Reminder', '3 pending tasks due in the next 15 days.', 'reminder');

-- Seed Banners
INSERT INTO `banners` (`title`, `image_url`, `link_type`, `link_id`, `display_order`) VALUES
(1, 'Royal Palace Weddings in Udaipur', 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=1000', 'category', 1, 1),
(2, 'Flat 20% Off Destination Beach Packages', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=1000', 'destination', 1, 2),
(3, 'Top Celebrity Bridal Makeup Artists', 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=1000', 'category', 4, 3);

-- Seed Offers
INSERT INTO `offers` (`code`, `title`, `discount_percentage`, `max_discount`, `valid_until`, `image_url`) VALUES
('ROYAL2026', 'Early Bird Wedding Discount', 15.00, 10000.00, '2026-12-31', 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=600'),
('BEACHVIBES', 'Goa Destination Special', 20.00, 15000.00, '2026-11-30', 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=600');
