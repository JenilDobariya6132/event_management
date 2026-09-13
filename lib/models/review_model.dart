// lib/models/review_model.dart

class ReviewModel {
  final int id;
  final int bookingId;
  final int customerId;
  final int vendorId;
  final int rating;
  final String? comment;
  final String? customerName;
  final String? customerImage;
  final String? createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.vendorId,
    required this.rating,
    this.comment,
    this.customerName,
    this.customerImage,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      bookingId: json['booking_id'] is int ? json['booking_id'] : int.parse(json['booking_id'].toString()),
      customerId: json['customer_id'] is int ? json['customer_id'] : int.parse(json['customer_id'].toString()),
      vendorId: json['vendor_id'] is int ? json['vendor_id'] : int.parse(json['vendor_id'].toString()),
      rating: json['rating'] != null ? int.parse(json['rating'].toString()) : 5,
      comment: json['comment'],
      customerName: json['customer_name'],
      customerImage: json['customer_image'],
      createdAt: json['created_at'],
    );
  }
}
