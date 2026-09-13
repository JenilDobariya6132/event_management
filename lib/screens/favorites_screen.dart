// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/vendor_card.dart';
import 'vendor_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Vendors"),
      ),
      body: vendorProvider.favorites.isEmpty
          ? const Center(child: Text("You haven't saved any favorite vendors yet."))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: vendorProvider.favorites.length,
              itemBuilder: (context, index) {
                final vendor = vendorProvider.favorites[index];
                return VendorCard(
                  vendor: vendor,
                  isFavorite: true,
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
