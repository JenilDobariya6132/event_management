// lib/screens/destination_wedding_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/state_model.dart';
import '../providers/vendor_provider.dart';
import '../widgets/state_card.dart';
import 'destination_details_screen.dart';

class DestinationWeddingScreen extends StatefulWidget {
  final String? initialState;

  const DestinationWeddingScreen({
    super.key,
    this.initialState,
  });

  @override
  State<DestinationWeddingScreen> createState() => _DestinationWeddingScreenState();
}

class _DestinationWeddingScreenState extends State<DestinationWeddingScreen> {
  late String _selectedRegion;
  final ScrollController _stateScrollController = ScrollController();

  final List<String> _regions = [
    'All',
    'Gujarat',
    'Rajasthan',
    'Goa',
    'Kerala',
    'Uttarakhand',
    'Himachal',
    'Andaman',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.initialState ?? 'All';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false).fetchDestinations();
    });
  }

  @override
  void dispose() {
    _stateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 768;
    final int gridColumns = isDesktop ? 3 : 1;

    final String cleanSelectedRegion = _selectedRegion.replaceAll('✨', '').trim();

    final filteredDestinations = vendorProvider.destinations.where((d) {
      if (cleanSelectedRegion == 'All') return true;
      final regionQuery = cleanSelectedRegion.toLowerCase();
      return d.location.toLowerCase().contains(regionQuery) ||
             d.title.toLowerCase().contains(regionQuery);
    }).toList();

    // Find state info if selected
    StateModel? selectedStateModel;
    if (cleanSelectedRegion != 'All') {
      try {
        selectedStateModel = StateModel.defaultStates.firstWhere(
          (s) => s.stateName.toLowerCase() == cleanSelectedRegion.toLowerCase(),
        );
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          cleanSelectedRegion == 'All'
              ? "Destination Weddings"
              : "$cleanSelectedRegion Wedding Destinations",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
      ),
      body: vendorProvider.destinations.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // State Choice Filter Bar with Visible Scrollbar
                  SizedBox(
                    height: 50,
                    child: RawScrollbar(
                      controller: _stateScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thumbColor: AppTheme.primary,
                      trackColor: AppTheme.accent.withValues(alpha: 0.2),
                      radius: const Radius.circular(10),
                      thickness: 4,
                      padding: const EdgeInsets.only(bottom: 1, left: 16, right: 16),
                      child: ListView.builder(
                        controller: _stateScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: _regions.length,
                        itemBuilder: (context, index) {
                          final reg = _regions[index];
                          final isSelected = cleanSelectedRegion.toLowerCase() == reg.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                reg == 'Gujarat' ? 'Gujarat ✨' : reg,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppTheme.primary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppTheme.primary,
                              backgroundColor: AppTheme.roseLight,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primary : AppTheme.accent.withValues(alpha: 0.3),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedRegion = reg);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // If ALL is selected, show State Cards Grid section first!
                  if (cleanSelectedRegion == 'All') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.map_outlined, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Select State Destination",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridColumns,
                          mainAxisExtent: 196,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: StateModel.defaultStates.length,
                        itemBuilder: (context, index) {
                          final stateItem = StateModel.defaultStates[index];
                          return StateCard(
                            stateItem: stateItem,
                            onTap: () {
                              setState(() {
                                _selectedRegion = stateItem.stateName;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // If specific State selected, show Header Info Banner
                  if (cleanSelectedRegion != 'All') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.luxuryShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_city_rounded, color: AppTheme.accentLight, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedStateModel?.displayName ?? cleanSelectedRegion,
                                    style: GoogleFonts.playfairDisplay(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedStateModel?.subtitle ?? "Showing all luxury destination venues in $cleanSelectedRegion",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white),
                              onPressed: () {
                                setState(() => _selectedRegion = 'All');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Destination List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      cleanSelectedRegion == 'All'
                          ? "All Popular Destinations (${filteredDestinations.length})"
                          : "$cleanSelectedRegion Destinations (${filteredDestinations.length})",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Destination Cards List
                  filteredDestinations.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: Text(
                            "No destinations found in $cleanSelectedRegion.",
                            style: GoogleFonts.poppins(color: AppTheme.textMuted),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredDestinations.length,
                          itemBuilder: (context, index) {
                            final dest = filteredDestinations[index];
                            final venuesCount = dest.getVenuesAndResorts().length;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 1),
                                boxShadow: AppTheme.luxuryShadow,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => DestinationDetailsScreen(destination: dest)),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Image
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                          child: CachedNetworkImage(
                                            imageUrl: dest.imageUrl ?? 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
                                            height: 190,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 12,
                                          left: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: AppTheme.goldGradient,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "$venuesCount+ LUXURY RESORTS & VENUES",
                                              style: GoogleFonts.poppins(
                                                color: AppTheme.primary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  dest.title,
                                                  style: GoogleFonts.playfairDisplay(
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primary,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.roseLight,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                                                ),
                                                child: Text(
                                                  dest.location,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            dest.description ?? '',
                                            style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 13),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(builder: (_) => DestinationDetailsScreen(destination: dest)),
                                                );
                                              },
                                              icon: const Icon(Icons.hotel_class, size: 18),
                                              label: Text(
                                                "Explore Resorts, Venues & Packages",
                                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
