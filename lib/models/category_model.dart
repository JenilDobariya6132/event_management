// lib/models/category_model.dart

class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final String? imageUrl;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.imageUrl,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'celebration',
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }
}
