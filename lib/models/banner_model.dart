// lib/models/banner_model.dart

class BannerModel {
  final int id;
  final String title;
  final String imageUrl;
  final String linkType;
  final int? linkId;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkType,
    this.linkId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      linkType: json['link_type'] ?? 'category',
      linkId: json['link_id'] != null ? int.tryParse(json['link_id'].toString()) : null,
    );
  }
}

class OfferModel {
  final int id;
  final String code;
  final String title;
  final double discountPercentage;
  final double maxDiscount;
  final String validUntil;
  final String? imageUrl;

  OfferModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discountPercentage,
    required this.maxDiscount,
    required this.validUntil,
    this.imageUrl,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      discountPercentage: json['discount_percentage'] != null ? double.parse(json['discount_percentage'].toString()) : 0.0,
      maxDiscount: json['max_discount'] != null ? double.parse(json['max_discount'].toString()) : 5000.0,
      validUntil: json['valid_until'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}
