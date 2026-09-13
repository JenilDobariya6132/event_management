// lib/models/vendor_model.dart

class VendorModel {
  final int id;
  final int userId;
  final String businessName;
  final int categoryId;
  final String? categoryName;
  final String city;
  final String? address;
  final double startingPrice;
  final String? description;
  final double rating;
  final int totalReviews;
  final String status;
  final String? profileImage;

  VendorModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.categoryId,
    this.categoryName,
    required this.city,
    this.address,
    required this.startingPrice,
    this.description,
    required this.rating,
    required this.totalReviews,
    required this.status,
    this.profileImage,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      businessName: json['business_name'] ?? '',
      categoryId: json['category_id'] is int ? json['category_id'] : int.parse(json['category_id'].toString()),
      categoryName: json['category_name'],
      city: json['city'] ?? '',
      address: json['address'],
      startingPrice: (json['starting_price'] != null) ? double.parse(json['starting_price'].toString()) : 0.0,
      description: json['description'],
      rating: (json['rating'] != null) ? double.parse(json['rating'].toString()) : 0.0,
      totalReviews: (json['total_reviews'] != null) ? int.parse(json['total_reviews'].toString()) : 0,
      status: json['status'] ?? 'pending',
      profileImage: json['profile_image'],
    );
  }
}
