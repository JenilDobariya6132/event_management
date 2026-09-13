// lib/models/wedding_model.dart

class WeddingModel {
  final int id;
  final int customerId;
  final String brideName;
  final String groomName;
  final String weddingDate;
  final String location;
  final int guestCount;
  final double totalBudget;
  final String style;

  WeddingModel({
    required this.id,
    required this.customerId,
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
    required this.location,
    required this.guestCount,
    required this.totalBudget,
    required this.style,
  });

  factory WeddingModel.fromJson(Map<String, dynamic> json) {
    return WeddingModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      customerId: json['customer_id'] is int ? json['customer_id'] : int.parse(json['customer_id'].toString()),
      brideName: json['bride_name'] ?? 'Bride',
      groomName: json['groom_name'] ?? 'Groom',
      weddingDate: json['wedding_date'] ?? '',
      location: json['location'] ?? '',
      guestCount: json['guest_count'] != null ? int.parse(json['guest_count'].toString()) : 100,
      totalBudget: json['total_budget'] != null ? double.parse(json['total_budget'].toString()) : 500000.0,
      style: json['style'] ?? 'Royal Traditional',
    );
  }
}
