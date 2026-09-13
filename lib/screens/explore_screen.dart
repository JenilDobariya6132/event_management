// lib/screens/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/vendor_provider.dart';
import '../widgets/vendor_card.dart';
import 'vendor_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _citiesScrollController = ScrollController();
  final ScrollController _categoriesScrollController = ScrollController();

  String _selectedCity = 'All';
  int _selectedCategoryId = 0;
  final double _minRating = 0.0;

  final List<String> _cities = [
    'All',
    'Udaipur',
    'Mumbai',
    'Delhi',
    'Jaipur',
    'Goa',
    'Ahmedabad',
    'Surat',
    'Kevadia',
    'Kutch',
    'Vadodara',
    'Bengaluru',
    'Varanasi'
  ];

  @override
  void initState() {
    super.initState();
    _applyFilter();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _citiesScrollController.dispose();
    _categoriesScrollController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final provider = Provider.of<VendorProvider>(context, listen: false);
    provider.fetchVendors(
      categoryId: _selectedCategoryId,
      city: _selectedCity,
      search: _searchController.text.trim(),
      minRating: _minRating,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "Explore & Filter Vendors",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilter(),
                  decoration: InputDecoration(
                    hintText: "Search vendor name, category, location...",
                    hintStyle: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilter();
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter Horizontal Scrollbar
                Row(
                  children: [
                    const Icon(Icons.category_outlined, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      "Category:",
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 40,
                  child: RawScrollbar(
                    controller: _categoriesScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thumbColor: AppTheme.primary,
                    trackColor: AppTheme.accent.withValues(alpha: 0.2),
                    radius: const Radius.circular(10),
                    thickness: 4,
                    padding: const EdgeInsets.only(bottom: 1),
                    child: ListView.builder(
                      controller: _categoriesScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: vendorProvider.categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = _selectedCategoryId == 0;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                "All Categories",
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppTheme.primary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppTheme.primary,
                              backgroundColor: AppTheme.roseLight,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primary : AppTheme.accent.withValues(alpha: 0.3),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedCategoryId = 0);
                                  _applyFilter();
                                }
                              },
                            ),
                          );
                        }
                        final cat = vendorProvider.categories[index - 1];
                        final isSelected = _selectedCategoryId == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              cat.name,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : AppTheme.primary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppTheme.primary,
                            backgroundColor: AppTheme.roseLight,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primary : AppTheme.accent.withValues(alpha: 0.3),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategoryId = cat.id);
                                _applyFilter();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Cities Filter Horizontal Scrollbar
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      "Location:",
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 40,
                  child: RawScrollbar(
                    controller: _citiesScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thumbColor: AppTheme.primary,
                    trackColor: AppTheme.accent.withValues(alpha: 0.2),
                    radius: const Radius.circular(10),
                    thickness: 4,
                    padding: const EdgeInsets.only(bottom: 1),
                    child: ListView.builder(
                      controller: _citiesScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: _cities.length,
                      itemBuilder: (context, index) {
                        final city = _cities[index];
                        final isSelected = _selectedCity == city;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              city,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : AppTheme.primary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppTheme.primary,
                            backgroundColor: AppTheme.roseLight,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primary : AppTheme.accent.withValues(alpha: 0.3),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCity = city);
                                _applyFilter();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Vendors Grid Result
          Expanded(
            child: vendorProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : vendorProvider.vendors.isEmpty
                    ? Center(
                        child: Text(
                          "No vendors match your search criteria.",
                          style: GoogleFonts.poppins(color: AppTheme.textMuted),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 340,
                          mainAxisExtent: 216,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: vendorProvider.vendors.length,
                        itemBuilder: (context, index) {
                          final vendor = vendorProvider.vendors[index];
                          return VendorCard(
                            vendor: vendor,
                            width: null,
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
        ],
      ),
    );
  }
}
