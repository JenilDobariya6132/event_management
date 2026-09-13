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
      case 'venue':
        return Icons.castle_outlined;
      case 'camera_alt':
      case 'photo':
        return Icons.camera_outlined;
      case 'restaurant':
      case 'caterer':
        return Icons.restaurant_outlined;
      case 'brush':
      case 'makeup':
        return Icons.brush_outlined;
      case 'palette':
      case 'decorator':
        return Icons.palette_outlined;
      case 'checkroom':
      case 'bridal':
        return Icons.checkroom_outlined;
      case 'styler':
      case 'groom':
      case 'dry_cleaning':
      case 'suit':
        return Icons.dry_cleaning_outlined;
      case 'music_note':
      case 'dj':
        return Icons.music_note_outlined;
      case 'back_hand':
      case 'hand':
      case 'mehndi':
        return Icons.back_hand_outlined;
      case 'event':
      case 'planner':
        return Icons.event_available_outlined;
      case 'card_giftcard':
      case 'invitation':
        return Icons.mark_email_read_outlined;
      case 'diamond':
      case 'jewelry':
        return Icons.diamond_outlined;
      case 'auto_awesome':
      case 'pandit':
        return Icons.auto_awesome_outlined;
      case 'directions_run':
      case 'dance':
      case 'choreography':
        return Icons.accessibility_new_outlined;
      case 'cake':
      case 'sweets':
        return Icons.cake_outlined;
      case 'local_bar':
      case 'bar':
        return Icons.local_bar_outlined;
      case 'directions_car':
      case 'car':
        return Icons.directions_car_outlined;
      case 'gift':
      case 'favors':
        return Icons.card_giftcard_outlined;
      case 'flight_takeoff':
      case 'honeymoon':
        return Icons.flight_takeoff_outlined;
      case 'celebration':
      case 'artist':
      case 'entertainment':
        return Icons.celebration_outlined;
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
              width: 72,
              height: 72,
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
            const SizedBox(height: 6),
            SizedBox(
              width: 86,
              height: 34,
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                  height: 1.15,
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
