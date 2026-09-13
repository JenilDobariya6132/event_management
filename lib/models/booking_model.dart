// lib/models/booking_model.dart

class BookingModel {
  final int id;
  final String bookingNumber;
  final int customerId;
  final int vendorId;
  final String? businessName;
  final String? categoryName;
  final String? customerName;
  final String? customerPhone;
  final String weddingDate;
  final String venueLocation;
  final int guestCount;
  final String? specialRequirements;
  final double totalPrice;
  final String status;        // Pending, Accepted, Rejected, Confirmed, Completed, Cancelled
  final String paymentStatus; // pending, paid, partial, refunded
  final String? createdAt;

  BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.customerId,
    required this.vendorId,
    this.businessName,
    this.categoryName,
    this.customerName,
    this.customerPhone,
    required this.weddingDate,
    required this.venueLocation,
    required this.guestCount,
    this.specialRequirements,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      bookingNumber: json['booking_number'] ?? '',
      customerId: json['customer_id'] is int ? json['customer_id'] : int.parse(json['customer_id'].toString()),
      vendorId: json['vendor_id'] is int ? json['vendor_id'] : int.parse(json['vendor_id'].toString()),
      businessName: json['business_name'],
      categoryName: json['category_name'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      weddingDate: json['wedding_date'] ?? '',
      venueLocation: json['venue_location'] ?? '',
      guestCount: json['guest_count'] != null ? int.parse(json['guest_count'].toString()) : 100,
      specialRequirements: json['special_requirements'],
      totalPrice: json['total_price'] != null ? double.parse(json['total_price'].toString()) : 0.0,
      status: json['status'] ?? 'Pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      createdAt: json['created_at'],
    );
  }
}
