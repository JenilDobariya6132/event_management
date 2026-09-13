// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Network connection error: ${e.toString()}"
      };
    }
  }

  static Future<Map<String, dynamic>> get(String url) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(token),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Network connection error: ${e.toString()}"
      };
    }
  }

  static Future<Map<String, dynamic>> delete(String url) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(token),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Network connection error: ${e.toString()}"
      };
    }
  }
}
