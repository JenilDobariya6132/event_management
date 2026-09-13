// lib/config/api_config.dart

import 'package:flutter/foundation.dart';

class ApiConfig {
  // Base URL for PHP REST API
  // Automatically uses 'localhost' on Web & Desktop, '10.0.2.2' on Android Emulator
  static String get host {
    if (kIsWeb) {
      return "localhost";
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "10.0.2.2";
    }
    return "localhost";
  }

  static String get baseUrl => "http://$host/wedding_api/api/";
  static String get adminUrl => "http://$host/wedding_api/admin/";

  // API Endpoints
  static String get register => "${baseUrl}auth/register.php";
  static String get login => "${baseUrl}auth/login.php";
  static String get profile => "${baseUrl}auth/profile.php";
  
  static String get categories => "${baseUrl}categories/index.php";
  static String get vendors => "${baseUrl}vendors/index.php";
  static String get vendorDetails => "${baseUrl}vendors/details.php";
  static String get vendorManage => "${baseUrl}vendors/manage.php";
  static String get destinations => "${baseUrl}destinations/index.php";

  static String get weddings => "${baseUrl}weddings/index.php";
  static String get budget => "${baseUrl}budget/index.php";
  static String get checklist => "${baseUrl}checklist/index.php";
  static String get guests => "${baseUrl}guests/index.php";
  static String get favorites => "${baseUrl}favorites/index.php";

  static String get bookings => "${baseUrl}bookings/index.php";
  static String get payments => "${baseUrl}payments/process.php";
  static String get reviews => "${baseUrl}reviews/index.php";
  static String get notifications => "${baseUrl}notifications/index.php";
  static String get banners => "${baseUrl}banners/index.php";

  // Standard API Headers
  static Map<String, String> getHeaders([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
