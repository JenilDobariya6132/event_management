// lib/screens/vendor_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/vendor_provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/rating_stars.dart';
import 'payment_screen.dart';

class VendorDetailsScreen extends StatefulWidget {
  final int vendorId;

  const VendorDetailsScreen({
    super.key,
    required this.vendorId,
  });

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false).fetchVendorDetails(widget.vendorId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBookingModal(BuildContext context, double packagePrice, int? packageId) {
    final dateController = TextEditingController(text: DateTime.now().add(const Duration(days: 60)).toString().split(' ')[0]);
    final locationController = TextEditingController(text: 'Udaipur Palace Lawns');
    final guestsController = TextEditingController(text: '200');
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Book Service / Package", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Wedding Event Date (YYYY-MM-DD)"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Venue Address / Location"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: guestsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Expected Guest Count"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: "Special Requirements / Notes"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                    final res = await bookingProvider.createBooking(
                      vendorId: widget.vendorId,
                      packageId: packageId,
                      weddingDate: dateController.text,
                      venueLocation: locationController.text,
                      guestCount: int.tryParse(guestsController.text) ?? 100,
                      specialRequirements: notesController.text,
                      totalPrice: packagePrice,
                    );

                    if (!context.mounted) return;

                    if (res['success'] == true) {
                      final bookingId = res['data']['booking_id'];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking request created! Proceed to payment."), backgroundColor: AppTheme.success),
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            bookingId: bookingId,
                            amount: packagePrice,
                            title: "Wedding Booking Advance",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Proceed to Payment"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);
    final vendor = vendorProvider.selectedVendor;
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    if (vendorProvider.isLoading || vendor == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isFav = vendorProvider.isFavorite(vendor.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver AppBar with Image Gallery Carousel
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.white),
                onPressed: () => vendorProvider.toggleFavorite(vendor.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: vendor.profileImage ?? 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Info Details Box
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.roseLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vendor.categoryName ?? 'Category',
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppTheme.accent, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${vendor.rating} (${vendor.totalReviews} reviews)",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vendor.businessName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(vendor.city, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Starting Price: ${currencyFormatter.format(vendor.startingPrice)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accent),
                  ),
                  const SizedBox(height: 16),

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.accent,
                    tabs: const [
                      Tab(text: "Overview"),
                      Tab(text: "Packages"),
                      Tab(text: "Gallery"),
                      Tab(text: "Reviews"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Content View
          SliverFillRemaining(
            hasScrollBody: true,
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Overview Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("About Business", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      const SizedBox(height: 8),
                      Text(
                        vendor.description ?? 'No description provided.',
                        style: const TextStyle(color: AppTheme.textDark, height: 1.4),
                      ),
                    ],
                  ),
                ),

                // 2. Packages Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vendorProvider.selectedPackages.length,
                  itemBuilder: (context, index) {
                    final pkg = vendorProvider.selectedPackages[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pkg.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            const SizedBox(height: 4),
                            Text(currencyFormatter.format(pkg.price), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                            const SizedBox(height: 8),
                            Text(pkg.description ?? '', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _showBookingModal(context, pkg.price, pkg.id),
                              child: const Text("Select Package"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 3. Gallery Tab
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: vendorProvider.selectedGallery.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: vendorProvider.selectedGallery[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),

                // 4. Reviews Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vendorProvider.selectedReviews.length,
                  itemBuilder: (context, index) {
                    final rev = vendorProvider.selectedReviews[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            rev.customerImage ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
                          ),
                        ),
                        title: Text(rev.customerName ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RatingStars(rating: rev.rating.toDouble(), size: 14),
                            const SizedBox(height: 4),
                            Text(rev.comment ?? ''),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Sticky Booking Button Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Quote request sent to vendor!")),
                  );
                },
                child: const Text("Request Quote"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showBookingModal(context, vendor.startingPrice, null),
                child: const Text("Book Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
