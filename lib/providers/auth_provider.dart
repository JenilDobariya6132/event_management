// lib/providers/auth_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userString = prefs.getString('user_data');

    if (userString != null && userString.isNotEmpty) {
      try {
        _user = UserModel.fromJson(jsonDecode(userString));
      } catch (e) {
        _user = null;
      }
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.post(ApiConfig.login, {
      'email': email,
      'password': password,
    });

    _isLoading = false;

    if (res['success'] == true && res['data'] != null) {
      _token = res['data']['token'];
      _user = UserModel.fromJson(res['data']['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));
      notifyListeners();
      return res;
    }

    // Check if network error occurred (backend offline/unreachable)
    final msg = (res['message'] ?? '').toString();
    if (msg.contains('Network connection error') || msg.contains('ClientException') || msg.contains('TimeoutException')) {
      final isVendor = email.toLowerCase().contains('vendor') || email == 'grandpalace@vendor.com';
      _token = isVendor ? 'demo_vendor_token_12345' : 'demo_customer_token_12345';
      _user = UserModel(
        id: isVendor ? 2 : 1,
        fullName: isVendor ? 'Royal Palace Events' : 'Aarav Sharma',
        email: email,
        phone: isVendor ? '+91 98765 43210' : '+91 98765 12345',
        role: isVendor ? 'vendor' : 'customer',
        vendorId: isVendor ? 1 : null,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));

      notifyListeners();
      return {
        "success": true,
        "message": "Logged in successfully! (Demo Mode)",
        "data": {
          "token": _token,
          "user": _user!.toJson(),
        }
      };
    }

    notifyListeners();
    return res;
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
    String? businessName,
    int? categoryId,
    String? city,
  }) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> payload = {
      'full_name': fullName,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
    };

    if (role == 'vendor') {
      payload['business_name'] = businessName ?? '$fullName Events';
      payload['category_id'] = categoryId ?? 1;
      payload['city'] = city ?? 'Mumbai';
    }

    final res = await ApiService.post(ApiConfig.register, payload);

    _isLoading = false;

    if (res['success'] == true && res['data'] != null) {
      _token = res['data']['token'];
      _user = UserModel.fromJson(res['data']['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));
      notifyListeners();
      return res;
    }

    // Check if network error occurred (backend offline/unreachable)
    final msg = (res['message'] ?? '').toString();
    if (msg.contains('Network connection error') || msg.contains('ClientException') || msg.contains('TimeoutException')) {
      _token = 'demo_registered_token_12345';
      _user = UserModel(
        id: 99,
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        vendorId: role == 'vendor' ? 1 : null,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));

      notifyListeners();
      return {
        "success": true,
        "message": "Registered successfully! (Demo Mode)",
        "data": {
          "token": _token,
          "user": _user!.toJson(),
        }
      };
    }

    notifyListeners();
    return res;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await ApiService.removeToken();
    notifyListeners();
  }
}
