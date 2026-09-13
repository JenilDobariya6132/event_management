// lib/screens/vendor_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import 'login_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final user = authProvider.user;
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    double totalEarnings = 0;
    int pendingCount = 0;
    for (var b in bookingProvider.bookings) {
      if (b.status == 'Confirmed' || b.status == 'Completed') {
        totalEarnings += b.totalPrice;
      }
      if (b.status == 'Pending') {
        pendingCount++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Studio Portal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Welcome Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome, ${user?.fullName ?? 'Vendor'}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Manage customer booking inquiries & business profile", style: TextStyle(color: AppTheme.accentLight, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Revenue", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(currencyFormatter.format(totalEarnings), style: const TextStyle(color: AppTheme.accentLight, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Pending Requests", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text("$pendingCount Inquiries", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Customer Booking Inquiries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const SizedBox(height: 12),

            // Inquiries List with Accept / Reject Actions
            bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookingProvider.bookings.isEmpty
                    ? const Center(child: Text("No booking requests received yet."))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookingProvider.bookings.length,
                        itemBuilder: (context, index) {
                          final b = bookingProvider.bookings[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Booking #${b.bookingNumber}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(b.status, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Client: ${b.customerName ?? 'Customer'} (${b.customerPhone ?? 'N/A'})"),
                                  Text("Event Date: ${b.weddingDate} • Guests: ${b.guestCount}"),
                                  Text("Total Amount: ${currencyFormatter.format(b.totalPrice)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent)),
                                  const SizedBox(height: 12),
                                  if (b.status == 'Pending')
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => bookingProvider.updateBookingStatus(b.id, 'Accepted'),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            child: const Text("Accept Request"),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => bookingProvider.updateBookingStatus(b.id, 'Rejected'),
                                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                            child: const Text("Reject"),
                                          ),
                                        ),
                                      ],
                                    )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
