// lib/models/user_model.dart

class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final String? profileImage;
  final int? vendorId;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.profileImage,
    this.vendorId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      profileImage: json['profile_image'],
      vendorId: json['vendor_id'] != null ? (json['vendor_id'] is int ? json['vendor_id'] : int.tryParse(json['vendor_id'].toString())) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'profile_image': profileImage,
      'vendor_id': vendorId,
    };
  }
}
