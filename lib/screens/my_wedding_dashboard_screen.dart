// lib/screens/my_wedding_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/wedding_provider.dart';
import 'wedding_budget_screen.dart';
import 'wedding_checklist_screen.dart';
import 'guest_management_screen.dart';

class MyWeddingDashboardScreen extends StatefulWidget {
  const MyWeddingDashboardScreen({super.key});

  @override
  State<MyWeddingDashboardScreen> createState() => _MyWeddingDashboardScreenState();
}

class _MyWeddingDashboardScreenState extends State<MyWeddingDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeddingProvider>(context, listen: false).fetchWeddingDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weddingProvider = Provider.of<WeddingProvider>(context);
    final wedding = weddingProvider.wedding;
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "My Wedding Dashboard",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: weddingProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Royal Countdown Banner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.goldGlowShadow,
                          ),
                          child: const Icon(Icons.favorite_rounded, color: AppTheme.primary, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${wedding?.brideName ?? 'Bride'}  &  ${wedding?.groomName ?? 'Groom'}",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppTheme.accent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${wedding?.weddingDate ?? 'Date TBD'}  •  ${wedding?.location ?? 'Location'}",
                              style: GoogleFonts.poppins(color: AppTheme.accentLight, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Days Remaining Counter Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: AppTheme.goldGlowShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.hourglass_top_rounded, size: 18, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                "${weddingProvider.daysRemaining} DAYS REMAINING",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Quick Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassCardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Invited Guests", style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 12)),
                              const SizedBox(height: 6),
                              Text(
                                "${wedding?.guestCount ?? 0}",
                                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassCardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Confirmed Vendors", style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 12)),
                              const SizedBox(height: 6),
                              Text(
                                "${weddingProvider.confirmedVendors}",
                                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Management Tools Section Header
                  Text(
                    "Wedding Planning Suite",
                    style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 14),

                  // Tool 1: Budget Manager Tile
                  _buildToolCard(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Budget Manager",
                    subtitle: "Spent: ${currencyFormatter.format(weddingProvider.totalSpent)} / ${currencyFormatter.format(wedding?.totalBudget ?? 2500000)}",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WeddingBudgetScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Tool 2: Wedding Checklist Tile
                  _buildToolCard(
                    context: context,
                    icon: Icons.checklist_rtl_rounded,
                    title: "Checklist & Milestones",
                    subtitle: "Completed ${weddingProvider.completedTasks} of ${weddingProvider.totalTasks} tasks",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WeddingChecklistScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Tool 3: Guest Management Tile
                  _buildToolCard(
                    context: context,
                    icon: Icons.groups_outlined,
                    title: "Guest RSVP Management",
                    subtitle: "Track bride & groom family RSVPs & food preferences",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GuestManagementScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildToolCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: AppTheme.glassCardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.roseLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primary),
        onTap: onTap,
      ),
    );
  }
}

