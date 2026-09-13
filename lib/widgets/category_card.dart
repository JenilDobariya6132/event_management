// lib/widgets/category_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'location_city':
        return Icons.castle_outlined;
      case 'camera_alt':
        return Icons.camera_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'brush':
        return Icons.brush_outlined;
      case 'palette':
        return Icons.palette_outlined;
      case 'checkroom':
        return Icons.checkroom_outlined;
      case 'music_note':
        return Icons.music_note_outlined;
      case 'dry_cleaning':
        return Icons.back_hand_outlined;
      default:
        return Icons.celebration_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              width: 74,
              height: 74,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.goldGradient,
                boxShadow: AppTheme.luxuryShadow,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: category.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: category.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: AppTheme.roseLight),
                          errorWidget: (context, url, error) => _buildIconFallback(),
                        )
                      : _buildIconFallback(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 82,
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconFallback() {
    return Container(
      color: AppTheme.roseLight,
      child: Center(
        child: Icon(
          _getCategoryIcon(category.icon),
          color: AppTheme.primary,
          size: 28,
        ),
      ),
    );
  }
}

