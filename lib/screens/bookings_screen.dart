// lib/screens/bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import 'payment_screen.dart';
import 'wedding_booking_dashboard_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_customize_rounded, color: AppTheme.primary),
            tooltip: "Booking Dashboard",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WeddingBookingDashboardScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.accent,
          onTap: (index) {
            final statuses = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];
            bookingProvider.fetchBookings(status: statuses[index]);
          },
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Pending"),
            Tab(text: "Confirmed"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingProvider.bookings.isEmpty
              ? const Center(child: Text("No bookings recorded yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookingProvider.bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookingProvider.bookings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  b.bookingNumber,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: b.status == 'Confirmed' ? AppTheme.roseLight : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    b.status,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: b.status == 'Confirmed' ? AppTheme.primary : Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              b.businessName ?? 'Vendor Service',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Date: ${b.weddingDate} • Venue: ${b.venueLocation}",
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currencyFormatter.format(b.totalPrice),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent),
                                ),
                                if (b.paymentStatus != 'paid')
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => PaymentScreen(
                                            bookingId: b.id,
                                            amount: b.totalPrice,
                                            title: "Pay Advance Deposit",
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                                    child: const Text("Pay Now"),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text("PAID", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
