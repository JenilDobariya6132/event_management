// lib/screens/explore_screen.dart

import 'package:flutter/material.dart';
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
  String _selectedCity = 'All';
  final int _selectedCategoryId = 0;
  final double _minRating = 0.0;

  final List<String> _cities = ['All', 'Udaipur', 'Mumbai', 'Delhi', 'Jaipur', 'Goa', 'Bengaluru'];

  @override
  void initState() {
    super.initState();
    _applyFilter();
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
      appBar: AppBar(
        title: const Text("Explore & Filter Vendors"),
      ),
      body: Column(
        children: [
          // Search & Filter Header Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilter(),
                  decoration: InputDecoration(
                    hintText: "Search vendor name, category, location...",
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

                // Cities Filter Horizontal Chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cities.length,
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      final isSelected = _selectedCity == city;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(city),
                          selected: isSelected,
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textDark,
                            fontSize: 12,
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
              ],
            ),
          ),

          const Divider(height: 1),

          // Vendors Grid Result
          Expanded(
            child: vendorProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vendorProvider.vendors.isEmpty
                    ? const Center(
                        child: Text("No vendors match your search criteria."),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
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
