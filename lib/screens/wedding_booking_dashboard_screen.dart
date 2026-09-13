// lib/screens/wedding_booking_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import 'payment_screen.dart';

class WeddingBookingDashboardScreen extends StatefulWidget {
  const WeddingBookingDashboardScreen({super.key});

  @override
  State<WeddingBookingDashboardScreen> createState() => _WeddingBookingDashboardScreenState();
}

class _WeddingBookingDashboardScreenState extends State<WeddingBookingDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _tabsScrollController = ScrollController();
  final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  String _selectedFilter = 'All';

  final List<String> _filterTabs = [
    'All',
    'Confirmed',
    'Pending',
    'Paid',
    'Venues & Resorts',
    'Photographers',
    'Makeup & Decor',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterTabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.bookings;

    // Calculate Summary Financials
    double totalBudgetBooked = 0;
    double totalPaidAmount = 0;
    for (var b in bookings) {
      totalBudgetBooked += b.totalPrice;
      if (b.paymentStatus == 'paid') {
        totalPaidAmount += b.totalPrice;
      } else if (b.paymentStatus == 'partial') {
        totalPaidAmount += b.totalPrice * 0.5;
      }
    }

    double remainingDue = totalBudgetBooked - totalPaidAmount;
    if (remainingDue < 0) remainingDue = 0;

    // Filter Bookings according to selected tab
    final filteredBookings = bookings.where((b) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Confirmed') return b.status.toLowerCase() == 'confirmed';
      if (_selectedFilter == 'Pending') return b.status.toLowerCase() == 'pending';
      if (_selectedFilter == 'Paid') return b.paymentStatus.toLowerCase() == 'paid';
      if (_selectedFilter == 'Venues & Resorts') {
        final cat = (b.categoryName ?? '').toLowerCase();
        return cat.contains('venue') || cat.contains('resort') || cat.contains('palace');
      }
      if (_selectedFilter == 'Photographers') {
        return (b.categoryName ?? '').toLowerCase().contains('photo');
      }
      if (_selectedFilter == 'Makeup & Decor') {
        final cat = (b.categoryName ?? '').toLowerCase();
        return cat.contains('makeup') || cat.contains('decor');
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "Wedding Booking Dashboard",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imperial Financial Overview Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.collections_bookmark_rounded, color: AppTheme.accentLight, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "All Wedding Bookings Summary",
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${bookings.length} Total Booked Services & Venues",
                                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppTheme.accentLight),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),

                        // Main Budget Figures Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "TOTAL VALUE",
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currencyFormatter.format(totalBudgetBooked),
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.accentLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(height: 32, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 4)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ADVANCE PAID",
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currencyFormatter.format(totalPaidAmount),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.lightGreenAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(height: 32, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 4)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "BALANCE DUE",
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currencyFormatter.format(remainingDue),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amberAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Filter Chips Bar with Scrollbar
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        "Filter Bookings:",
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 44,
                    child: RawScrollbar(
                      controller: _tabsScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thumbColor: AppTheme.primary,
                      trackColor: AppTheme.accent.withValues(alpha: 0.2),
                      radius: const Radius.circular(10),
                      thickness: 4,
                      padding: const EdgeInsets.only(bottom: 1),
                      child: ListView.builder(
                        controller: _tabsScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: 6),
                        itemCount: _filterTabs.length,
                        itemBuilder: (context, index) {
                          final tab = _filterTabs[index];
                          final isSelected = _selectedFilter == tab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                tab,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppTheme.primary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppTheme.primary,
                              backgroundColor: AppTheme.roseLight,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primary : AppTheme.accent.withValues(alpha: 0.3),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedFilter = tab);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Header section for list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Booked Items (${filteredBookings.length})",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        "Sorted by Date",
                        style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // List of Booked Items
                  filteredBookings.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const Icon(Icons.bookmark_border_rounded, size: 54, color: AppTheme.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                "No bookings match '$_selectedFilter'.",
                                style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredBookings.length,
                          itemBuilder: (context, index) {
                            final b = filteredBookings[index];
                            return _buildBookingCard(context, b);
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel b) {
    final bool isConfirmed = b.status.toLowerCase() == 'confirmed';
    final bool isPaid = b.paymentStatus.toLowerCase() == 'paid';
    final bool isPartial = b.paymentStatus.toLowerCase() == 'partial';

    Color statusBg = isConfirmed ? Colors.green.shade50 : AppTheme.roseLight;
    Color statusFg = isConfirmed ? Colors.green.shade800 : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.glassCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Booking Number & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        b.bookingNumber,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Date: ${b.weddingDate}",
                      style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusFg.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    b.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: statusFg,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Vendor Name & Service Category
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.roseLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(b.categoryName ?? ''),
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.businessName ?? 'Royal Wedding Vendor',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${b.categoryName ?? 'Wedding Service'}  •  ${b.venueLocation}",
                        style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (b.specialRequirements != null && b.specialRequirements!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.roseLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Inclusions: ${b.specialRequirements}",
                        style: GoogleFonts.poppins(fontSize: 11.5, color: AppTheme.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Price & Payment Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BOOKING AMOUNT",
                      style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textMuted, letterSpacing: 0.5),
                    ),
                    Row(
                      children: [
                        Text(
                          currencyFormatter.format(b.totalPrice),
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green.shade50
                                : isPartial
                                    ? Colors.amber.shade50
                                    : AppTheme.roseLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isPaid
                                ? "PAID IN FULL"
                                : isPartial
                                    ? "ADVANCE PAID"
                                    : "PAYMENT PENDING",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPaid
                                  ? Colors.green.shade800
                                  : isPartial
                                      ? Colors.amber.shade900
                                      : AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Row(
                  children: [
                    // View Receipt / Voucher Icon Button
                    IconButton(
                      icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 22),
                      tooltip: "View Voucher",
                      onPressed: () {
                        _showVoucherDialog(context, b);
                      },
                    ),

                    if (!isPaid)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                bookingId: b.id,
                                amount: isPartial ? b.totalPrice * 0.5 : b.totalPrice,
                                title: isPartial ? "Pay Remaining Balance" : "Pay Booking Advance",
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          isPartial ? "Pay Balance" : "Pay Advance",
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('venue') || lower.contains('palace') || lower.contains('resort')) {
      return Icons.castle_outlined;
    }
    if (lower.contains('photo') || lower.contains('camera')) return Icons.camera_outlined;
    if (lower.contains('cater')) return Icons.restaurant_outlined;
    if (lower.contains('decor')) return Icons.palette_outlined;
    if (lower.contains('makeup')) return Icons.brush_outlined;
    if (lower.contains('bridal') || lower.contains('wear')) return Icons.checkroom_outlined;
    if (lower.contains('dj') || lower.contains('music')) return Icons.music_note_outlined;
    return Icons.star_border_rounded;
  }

  void _showVoucherDialog(BuildContext context, BookingModel b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppTheme.cardBg,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.roseLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 36),
            ),
            const SizedBox(height: 10),
            Text(
              "Royal Booking Voucher",
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primary),
            ),
            Text(
              b.bookingNumber,
              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            _voucherRow("Service / Venue", b.businessName ?? ''),
            _voucherRow("Category", b.categoryName ?? 'Wedding Vendor'),
            _voucherRow("Wedding Date", b.weddingDate),
            _voucherRow("Location", b.venueLocation),
            _voucherRow("Guest Count", "${b.guestCount} Guests"),
            _voucherRow("Booking Status", b.status.toUpperCase()),
            _voucherRow("Payment Status", b.paymentStatus.toUpperCase()),
            _voucherRow("Total Amount", currencyFormatter.format(b.totalPrice)),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 6),
            Text(
              "Show this digital voucher upon arrival at the venue or to the vendor representative.",
              style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Close", style: GoogleFonts.poppins(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _voucherRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted)),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
