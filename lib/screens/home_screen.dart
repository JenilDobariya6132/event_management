// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/section_header.dart';
import '../widgets/category_card.dart';
import '../widgets/vendor_card.dart';
import '../widgets/destination_card.dart';
import 'notifications_screen.dart';
import 'vendor_listing_screen.dart';
import 'vendor_details_screen.dart';
import 'destination_wedding_screen.dart';
import 'destination_details_screen.dart';
import 'explore_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _categoriesScrollController = ScrollController();
  final ScrollController _vendorsScrollController = ScrollController();
  final ScrollController _destinationsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
      vendorProvider.fetchCategories();
      vendorProvider.fetchBannersAndOffers();
      vendorProvider.fetchVendors();
      vendorProvider.fetchDestinations();
      vendorProvider.fetchFavorites();
    });
  }

  @override
  void dispose() {
    _categoriesScrollController.dispose();
    _vendorsScrollController.dispose();
    _destinationsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final vendorProvider = Provider.of<VendorProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            await vendorProvider.fetchCategories();
            await vendorProvider.fetchVendors();
            await vendorProvider.fetchDestinations();
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imperial Hero Header Card
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      // User Greeting & Notification
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.goldGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppTheme.roseLight,
                                  backgroundImage: CachedNetworkImageProvider(
                                    user?.profileImage ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Namaste, ${user?.fullName ?? 'Royal Guest'} ✨",
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Planning Your Dream Royal Wedding",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.accentLight.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 1),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none_rounded, size: 24, color: AppTheme.accentLight),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Luxury Search Input Bar
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ExploreScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Search venues, caterers, makeup artists...",
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textMuted.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.roseLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.tune_rounded, size: 18, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Promotional Banner Carousel
                if (vendorProvider.banners.isNotEmpty)
                  SizedBox(
                    height: 170,
                    child: PageView.builder(
                      itemCount: vendorProvider.banners.length,
                      controller: PageController(viewportFraction: 0.92),
                      itemBuilder: (context, index) {
                        final banner = vendorProvider.banners[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 1),
                            boxShadow: AppTheme.luxuryShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: banner.imageUrl,
                                  height: 170,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        AppTheme.primaryDark.withValues(alpha: 0.85),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 20,
                                  bottom: 24,
                                  right: 130,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        banner.title,
                                        style: GoogleFonts.playfairDisplay(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.goldGradient,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: AppTheme.goldGlowShadow,
                                        ),
                                        child: Text(
                                          "EXPLORE NOW",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),

                // Categories Grid Header & Horizontal Cards
                SectionHeader(
                  title: "Wedding Categories",
                  subtitle: "Browse 20+ specialized wedding vendors",
                  actionLabel: "View All",
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExploreScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 124,
                  child: RawScrollbar(
                    controller: _categoriesScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thumbColor: AppTheme.primary,
                    trackColor: AppTheme.accent.withValues(alpha: 0.2),
                    radius: const Radius.circular(10),
                    thickness: 5,
                    padding: const EdgeInsets.only(bottom: 2, left: 16, right: 16),
                    child: ListView.builder(
                      controller: _categoriesScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      itemCount: vendorProvider.categories.length,
                      itemBuilder: (context, index) {
                        final category = vendorProvider.categories[index];
                        return CategoryCard(
                          category: category,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VendorListingScreen(
                                  categoryId: category.id,
                                  categoryName: category.name,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Featured / Popular Vendors
                SectionHeader(
                  title: "Popular Vendors",
                  subtitle: "Highest rated wedding services & artists",
                  actionLabel: "See All",
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VendorListingScreen(categoryName: "Popular Vendors")),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 236,
                  child: vendorProvider.vendors.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                      : RawScrollbar(
                          controller: _vendorsScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thumbColor: AppTheme.primary,
                          trackColor: AppTheme.accent.withValues(alpha: 0.2),
                          radius: const Radius.circular(10),
                          thickness: 5,
                          padding: const EdgeInsets.only(bottom: 2, left: 16, right: 16),
                          child: ListView.builder(
                            controller: _vendorsScrollController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            itemCount: vendorProvider.vendors.length,
                            itemBuilder: (context, index) {
                              final vendor = vendorProvider.vendors[index];
                              return VendorCard(
                                vendor: vendor,
                                isFavorite: vendorProvider.isFavorite(vendor.id),
                                onFavoriteToggle: () => vendorProvider.toggleFavorite(vendor.id),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => VendorDetailsScreen(vendorId: vendor.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // Destination Weddings Section
                SectionHeader(
                  title: "Destination Weddings",
                  subtitle: "Royal palaces, beach resorts & luxury stays",
                  actionLabel: "Explore All",
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DestinationWeddingScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 202,
                  child: vendorProvider.destinations.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                      : RawScrollbar(
                          controller: _destinationsScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thumbColor: AppTheme.primary,
                          trackColor: AppTheme.accent.withValues(alpha: 0.2),
                          radius: const Radius.circular(10),
                          thickness: 5,
                          padding: const EdgeInsets.only(bottom: 2, left: 16, right: 16),
                          child: ListView.builder(
                            controller: _destinationsScrollController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            itemCount: vendorProvider.destinations.length,
                            itemBuilder: (context, index) {
                              final dest = vendorProvider.destinations[index];
                              return DestinationCard(
                                destination: dest,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => DestinationDetailsScreen(destination: dest)),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

