// lib/providers/wedding_provider.dart

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/wedding_model.dart';
import '../services/api_service.dart';

class WeddingProvider with ChangeNotifier {
  WeddingModel? _wedding;
  int _daysRemaining = 90;
  double _totalSpent = 0.0;
  double _totalEstimated = 0.0;
  int _completedTasks = 0;
  int _totalTasks = 0;
  int _confirmedVendors = 0;
  bool _isLoading = false;

  WeddingModel? get wedding => _wedding;
  int get daysRemaining => _daysRemaining;
  double get totalSpent => _totalSpent;
  double get totalEstimated => _totalEstimated;
  int get completedTasks => _completedTasks;
  int get totalTasks => _totalTasks;
  int get confirmedVendors => _confirmedVendors;
  bool get isLoading => _isLoading;

  Future<void> fetchWeddingDetails() async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.get(ApiConfig.weddings);

    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      if (data['wedding'] != null) {
        _wedding = WeddingModel.fromJson(data['wedding']);
      }
      _daysRemaining = data['days_remaining'] ?? 90;
      _totalSpent = (data['total_spent'] ?? 0.0).toDouble();
      _totalEstimated = (data['total_estimated'] ?? 0.0).toDouble();
      _completedTasks = data['completed_tasks'] ?? 0;
      _totalTasks = data['total_tasks'] ?? 0;
      _confirmedVendors = data['confirmed_vendors'] ?? 0;
    } else if (_wedding == null) {
      _wedding = WeddingModel(
        id: 1,
        customerId: 1,
        brideName: 'Ananya',
        groomName: 'Aarav',
        weddingDate: '2026-12-15',
        location: 'Udaipur, Rajasthan',
        guestCount: 450,
        totalBudget: 2500000.0,
        style: 'Royal Rajasthani Heritage',
      );
      _daysRemaining = 92;
      _totalSpent = 1250000.0;
      _totalEstimated = 2500000.0;
      _completedTasks = 12;
      _totalTasks = 28;
      _confirmedVendors = 4;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateWedding({
    required String brideName,
    required String groomName,
    required String weddingDate,
    required String location,
    required int guestCount,
    required double totalBudget,
    required String style,
  }) async {
    _isLoading = true;
    notifyListeners();

    await ApiService.post(ApiConfig.weddings, {
      'bride_name': brideName,
      'groom_name': groomName,
      'wedding_date': weddingDate,
      'location': location,
      'guest_count': guestCount,
      'total_budget': totalBudget,
      'style': style,
    });

    _isLoading = false;
    
    // Always update local memory model even if offline
    _wedding = WeddingModel(
      id: _wedding?.id ?? 1,
      customerId: _wedding?.customerId ?? 1,
      brideName: brideName,
      groomName: groomName,
      weddingDate: weddingDate,
      location: location,
      guestCount: guestCount,
      totalBudget: totalBudget,
      style: style,
    );
    _totalEstimated = totalBudget;

    notifyListeners();
    return true;
  }
}
