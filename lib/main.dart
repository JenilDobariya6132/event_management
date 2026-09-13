// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/wedding_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/checklist_provider.dart';
import 'providers/guest_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoyalWeddingApp());
}

class RoyalWeddingApp extends StatelessWidget {
  const RoyalWeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WeddingProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => GuestProvider()),
      ],
      child: MaterialApp(
        title: 'Royal Wedding Event Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.luxuryTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
