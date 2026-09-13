// lib/models/package_model.dart

class PackageModel {
  final int id;
  final int vendorId;
  final String title;
  final String? description;
  final double price;
  final List<String> features;
  final String? imageUrl;

  PackageModel({
    required this.id,
    required this.vendorId,
    required this.title,
    this.description,
    required this.price,
    required this.features,
    this.imageUrl,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedFeatures = [];
    if (json['features'] != null && json['features'] is List) {
      parsedFeatures = List<String>.from(json['features']);
    } else if (json['features_json'] != null) {
      // raw json fallback if handled in dart
    }

    return PackageModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      vendorId: json['vendor_id'] is int ? json['vendor_id'] : int.parse(json['vendor_id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      price: (json['price'] != null) ? double.parse(json['price'].toString()) : 0.0,
      features: parsedFeatures,
      imageUrl: json['image_url'],
    );
  }
}
