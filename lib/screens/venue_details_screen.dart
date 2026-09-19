// lib/screens/venue_details_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/destination_model.dart';
import 'payment_screen.dart';

class VenueDetailsScreen extends StatefulWidget {
  final DestinationVenue venue;

  const VenueDetailsScreen({
    super.key,
    required this.venue,
  });

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  late final ScrollController _galleryScrollController;
  late final PageController _pageController;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _galleryScrollController = ScrollController();
    _pageController = PageController();
    _startAutoSlideTimer();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final gallery = widget.venue.getGalleryImages();
        if (gallery.isEmpty) return;
        int nextIndex = (_currentImageIndex + 1) % gallery.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollToThumbnail(int index) {
    if (_galleryScrollController.hasClients) {
      double targetOffset = (index * 110.0).clamp(
        0.0,
        _galleryScrollController.position.maxScrollExtent,
      );
      _galleryScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _galleryScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final gallery = widget.venue.getGalleryImages();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery Slider
                Stack(
                  children: [
                    SizedBox(
                      height: 320,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: gallery.length,
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                          _scrollToThumbnail(index);
                        },
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: gallery[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(color: AppTheme.roseLight),
                            errorWidget: (context, url, error) => Container(color: AppTheme.roseLight),
                          );
                        },
                      ),
                    ),

                    // Image Counter Badge
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.photo_library, color: AppTheme.accentLight, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${_currentImageIndex + 1} / ${gallery.length}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Dot Indicators
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          gallery.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImageIndex == index ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index ? AppTheme.accent : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Venue Header Details Card
                Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
                    boxShadow: AppTheme.luxuryShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: AppTheme.goldGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.venue.category.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: AppTheme.primary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.roseLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.venue.rating} ",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                Text(
                                  "(${widget.venue.totalReviews} reviews)",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.venue.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.accent, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.venue.location,
                              style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Gallery Grid Preview Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Venue Gallery",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 110,
                        child: RawScrollbar(
                          controller: _galleryScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 5,
                          radius: const Radius.circular(10),
                          thumbColor: AppTheme.accent,
                          trackColor: AppTheme.accent.withValues(alpha: 0.2),
                          trackRadius: const Radius.circular(10),
                          padding: const EdgeInsets.only(bottom: 2),
                          child: ListView.builder(
                            controller: _galleryScrollController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: 14),
                            itemCount: gallery.length,
                            itemBuilder: (context, index) {
                              final img = gallery[index];
                              final isSelected = index == _currentImageIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _currentImageIndex = index);
                                  if (_pageController.hasClients) {
                                    _pageController.animateToPage(
                                      index,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                  _startAutoSlideTimer();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.accent : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: img,
                                      width: 100,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Venue Description & About
                      Text(
                        "About Resort & Venue",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.venue.description,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textDark,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Operating & Event Timings Card
                      Text(
                        "Operating Hours & Event Timings",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                          boxShadow: AppTheme.luxuryShadow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.access_time_filled, color: AppTheme.primary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Timings & Visiting Hours",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.venue.getOperatingHours(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textDark,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Premium Amenities & Features
                      Text(
                        "Amenities & Facilities",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: widget.venue.amenities.map((am) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
                              boxShadow: AppTheme.luxuryShadow,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline, color: AppTheme.accent, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  am,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Event Spaces & Capacity
                      Text(
                        "Event Spaces & Capacity",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.venue.getEventSpaces().map((space) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildEventSpaceCard(
                            space.name,
                            space.description,
                            space.capacity,
                            space.icon,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Top Navigation Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isFavorite ? "Added to your Saved Venues!" : "Removed from Saved Venues"),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom Sticky Booking Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: Border(top: BorderSide(color: AppTheme.accent.withValues(alpha: 0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Starting Price",
                        style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      Text(
                        "${currencyFormatter.format(widget.venue.startingPrice)} / day",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            bookingId: widget.venue.id,
                            amount: widget.venue.startingPrice,
                            title: "${widget.venue.name} Venue Booking",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark_add, size: 18),
                    label: Text(
                      "Book Resort / Venue",
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSpaceCard(String title, String desc, String capacity, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.roseLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              capacity,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
