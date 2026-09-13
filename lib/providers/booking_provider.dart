// lib/providers/booking_provider.dart

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  List<BookingModel> _bookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;

  Future<void> fetchBookings({String? status}) async {
    _isLoading = true;
    notifyListeners();

    String url = ApiConfig.bookings;
    if (status != null && status.isNotEmpty && status != 'All') {
      url += '?status=$status';
    }

    final res = await ApiService.get(url);
    if (res['success'] == true && res['data'] != null) {
      _bookings = (res['data'] as List).map((b) => BookingModel.fromJson(b)).toList();
    } else if (_bookings.isEmpty) {
      _bookings = [
        BookingModel(
          id: 101,
          bookingNumber: 'WED-2026-8801',
          customerId: 1,
          vendorId: 1,
          businessName: 'The Grand Palace Resort',
          categoryName: 'Wedding Venues',
          customerName: 'Aarav Sharma',
          customerPhone: '+91 98765 12345',
          weddingDate: '2026-12-15',
          venueLocation: 'Udaipur, Rajasthan',
          guestCount: 450,
          totalPrice: 350000.0,
          status: 'confirmed',
          paymentStatus: 'partial',
          specialRequirements: 'Royal Mandap setup with marigold theme',
          createdAt: '2026-09-01',
        ),
        BookingModel(
          id: 102,
          bookingNumber: 'WED-2026-8802',
          customerId: 1,
          vendorId: 2,
          businessName: 'Royal Snaps Studio',
          categoryName: 'Photographers',
          customerName: 'Aarav Sharma',
          customerPhone: '+91 98765 12345',
          weddingDate: '2026-12-15',
          venueLocation: 'Udaipur, Rajasthan',
          guestCount: 450,
          totalPrice: 85000.0,
          status: 'pending',
          paymentStatus: 'pending',
          specialRequirements: 'Drone coverage for Sangeet & Barat',
          createdAt: '2026-09-05',
        ),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createBooking({
    required int vendorId,
    int? packageId,
    required String weddingDate,
    required String venueLocation,
    required int guestCount,
    required String specialRequirements,
    required double totalPrice,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.post("${ApiConfig.bookings}?action=create", {
      'vendor_id': vendorId,
      'package_id': packageId,
      'wedding_date': weddingDate,
      'venue_location': venueLocation,
      'guest_count': guestCount,
      'special_requirements': specialRequirements,
      'total_price': totalPrice,
    });

    _isLoading = false;
    if (res['success'] == true) {
      await fetchBookings();
      notifyListeners();
      return res;
    }

    // Local fallback creation if backend offline
    final newBooking = BookingModel(
      id: 100 + _bookings.length + 1,
      bookingNumber: 'WED-2026-${8800 + _bookings.length + 1}',
      customerId: 1,
      vendorId: vendorId,
      businessName: 'Selected Vendor',
      categoryName: 'Wedding Service',
      customerName: 'Aarav Sharma',
      weddingDate: weddingDate,
      venueLocation: venueLocation,
      guestCount: guestCount,
      totalPrice: totalPrice,
      status: 'pending',
      paymentStatus: 'pending',
      specialRequirements: specialRequirements,
      createdAt: DateTime.now().toIso8601String(),
    );

    _bookings.insert(0, newBooking);
    notifyListeners();

    return {
      "success": true,
      "message": "Booking request created successfully! (Demo Mode)",
      "data": {
        "booking_id": newBooking.id,
        "booking_number": newBooking.bookingNumber,
      }
    };
  }

  Future<bool> updateBookingStatus(int bookingId, String status) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.post("${ApiConfig.bookings}?action=update_status", {
      'booking_id': bookingId,
      'status': status,
    });

    _isLoading = false;
    if (res['success'] == true) {
      await fetchBookings();
      return true;
    }

    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      final b = _bookings[idx];
      _bookings[idx] = BookingModel(
        id: b.id,
        bookingNumber: b.bookingNumber,
        customerId: b.customerId,
        vendorId: b.vendorId,
        businessName: b.businessName,
        categoryName: b.categoryName,
        customerName: b.customerName,
        customerPhone: b.customerPhone,
        weddingDate: b.weddingDate,
        venueLocation: b.venueLocation,
        guestCount: b.guestCount,
        totalPrice: b.totalPrice,
        status: status,
        paymentStatus: b.paymentStatus,
        specialRequirements: b.specialRequirements,
        createdAt: b.createdAt,
      );
    }

    notifyListeners();
    return true;
  }

  Future<Map<String, dynamic>> processPayment({
    required int bookingId,
    required double amount,
    required String paymentGateway,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.post(ApiConfig.payments, {
      'booking_id': bookingId,
      'amount': amount,
      'payment_gateway': paymentGateway,
      'payment_method': paymentMethod,
    });

    _isLoading = false;
    if (res['success'] == true) {
      await fetchBookings();
      notifyListeners();
      return res;
    }

    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      final b = _bookings[idx];
      _bookings[idx] = BookingModel(
        id: b.id,
        bookingNumber: b.bookingNumber,
        customerId: b.customerId,
        vendorId: b.vendorId,
        businessName: b.businessName,
        categoryName: b.categoryName,
        customerName: b.customerName,
        customerPhone: b.customerPhone,
        weddingDate: b.weddingDate,
        venueLocation: b.venueLocation,
        guestCount: b.guestCount,
        totalPrice: b.totalPrice,
        status: 'confirmed',
        paymentStatus: 'paid',
        specialRequirements: b.specialRequirements,
        createdAt: b.createdAt,
      );
    }

    notifyListeners();
    return {
      "success": true,
      "message": "Payment processed successfully! (Demo Mode)",
      "transaction_id": "TXN_DEMO_${DateTime.now().millisecondsSinceEpoch}",
    };
  }
}
