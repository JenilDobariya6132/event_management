// lib/screens/vendor_listing_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/vendor_card.dart';
import 'vendor_details_screen.dart';

class VendorListingScreen extends StatefulWidget {
  final int? categoryId;
  final String categoryName;

  const VendorListingScreen({
    super.key,
    this.categoryId,
    required this.categoryName,
  });

  @override
  State<VendorListingScreen> createState() => _VendorListingScreenState();
}

class _VendorListingScreenState extends State<VendorListingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false).fetchVendors(
        categoryId: widget.categoryId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: vendorProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vendorProvider.vendors.isEmpty
              ? const Center(child: Text("No vendors available in this category yet."))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisExtent: 186,
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
    );
  }
}
