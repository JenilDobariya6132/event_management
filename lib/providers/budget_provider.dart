// lib/providers/budget_provider.dart

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/budget_model.dart';
import '../services/api_service.dart';

class BudgetProvider with ChangeNotifier {
  double _totalBudget = 500000.0;
  double _totalEstimated = 0.0;
  double _totalActual = 0.0;
  double _remainingBudget = 500000.0;
  List<BudgetItemModel> _items = [];
  bool _isLoading = false;

  double get totalBudget => _totalBudget;
  double get totalEstimated => _totalEstimated;
  double get totalActual => _totalActual;
  double get remainingBudget => _remainingBudget;
  List<BudgetItemModel> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchBudget() async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.get(ApiConfig.budget);
    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      _totalBudget = (data['total_budget'] ?? 2500000.0).toDouble();
      _totalEstimated = (data['total_estimated'] ?? 0.0).toDouble();
      _totalActual = (data['total_actual'] ?? 0.0).toDouble();
      _remainingBudget = (data['remaining_budget'] ?? _totalBudget).toDouble();

      if (data['items'] != null) {
        _items = (data['items'] as List).map((i) => BudgetItemModel.fromJson(i)).toList();
      }
    } else if (_items.isEmpty) {
      _totalBudget = 2500000.0;
      _items = [
        BudgetItemModel(id: 1, weddingId: 1, categoryName: 'Venue & Catering', estimatedAmount: 1200000.0, actualAmount: 1150000.0, notes: 'Grand Palace advance paid'),
        BudgetItemModel(id: 2, weddingId: 1, categoryName: 'Photography & Film', estimatedAmount: 200000.0, actualAmount: 185000.0, notes: 'Drone + Candid included'),
        BudgetItemModel(id: 3, weddingId: 1, categoryName: 'Floral Decor & Stage', estimatedAmount: 300000.0, actualAmount: 280000.0, notes: 'Stage & Entry setup'),
        BudgetItemModel(id: 4, weddingId: 1, categoryName: 'Bridal & Groom Attire', estimatedAmount: 250000.0, actualAmount: 220000.0, notes: 'Designer Lehenga & Sherwani'),
        BudgetItemModel(id: 5, weddingId: 1, categoryName: 'Makeup & Hair Styling', estimatedAmount: 80000.0, actualAmount: 75000.0, notes: 'HD Bridal package'),
      ];
      _recalculateTotals();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _recalculateTotals() {
    _totalEstimated = _items.fold(0.0, (sum, i) => sum + i.estimatedAmount);
    _totalActual = _items.fold(0.0, (sum, i) => sum + i.actualAmount);
    _remainingBudget = _totalBudget - _totalActual;
  }

  Future<bool> saveBudgetItem({
    int id = 0,
    required String categoryName,
    required double estimatedAmount,
    required double actualAmount,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.post(ApiConfig.budget, {
      'id': id,
      'category_name': categoryName,
      'estimated_amount': estimatedAmount,
      'actual_amount': actualAmount,
      'notes': notes,
    });

    _isLoading = false;
    if (res['success'] == true) {
      await fetchBudget();
      return true;
    }

    if (id > 0) {
      final idx = _items.indexWhere((i) => i.id == id);
      if (idx >= 0) {
        _items[idx] = BudgetItemModel(
          id: id,
          weddingId: 1,
          categoryName: categoryName,
          estimatedAmount: estimatedAmount,
          actualAmount: actualAmount,
          notes: notes,
        );
      }
    } else {
      _items.add(BudgetItemModel(
        id: _items.length + 1,
        weddingId: 1,
        categoryName: categoryName,
        estimatedAmount: estimatedAmount,
        actualAmount: actualAmount,
        notes: notes,
      ));
    }

    _recalculateTotals();
    notifyListeners();
    return true;
  }

  Future<bool> deleteBudgetItem(int id) async {
    final res = await ApiService.delete("${ApiConfig.budget}?id=$id");
    if (res['success'] == true) {
      await fetchBudget();
      return true;
    }

    _items.removeWhere((i) => i.id == id);
    _recalculateTotals();
    notifyListeners();
    return true;
  }
}
