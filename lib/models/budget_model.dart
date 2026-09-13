// lib/models/budget_model.dart

class BudgetItemModel {
  final int id;
  final int weddingId;
  final String categoryName;
  final double estimatedAmount;
  final double actualAmount;
  final String? notes;

  BudgetItemModel({
    required this.id,
    required this.weddingId,
    required this.categoryName,
    required this.estimatedAmount,
    required this.actualAmount,
    this.notes,
  });

  factory BudgetItemModel.fromJson(Map<String, dynamic> json) {
    return BudgetItemModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      weddingId: json['wedding_id'] is int ? json['wedding_id'] : int.parse(json['wedding_id'].toString()),
      categoryName: json['category_name'] ?? 'General',
      estimatedAmount: json['estimated_amount'] != null ? double.parse(json['estimated_amount'].toString()) : 0.0,
      actualAmount: json['actual_amount'] != null ? double.parse(json['actual_amount'].toString()) : 0.0,
      notes: json['notes'],
    );
  }
}
