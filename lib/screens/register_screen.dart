// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import 'main_navigation_screen.dart';
import 'vendor_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();

  String _selectedRole = 'customer'; // 'customer' or 'vendor'
  int _selectedCategory = 1;
  final String _selectedCity = 'Mumbai';

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final res = await authProvider.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
      businessName: _selectedRole == 'vendor' ? _businessNameController.text.trim() : null,
      categoryId: _selectedRole == 'vendor' ? _selectedCategory : null,
      city: _selectedRole == 'vendor' ? _selectedCity : null,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Registration successful!'), backgroundColor: AppTheme.success),
      );
      if (_selectedRole == 'vendor') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VendorDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Registration failed'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Join Royal Weddings",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Select your account type to get started",
                  style: TextStyle(color: AppTheme.textMuted),
                ),
                const SizedBox(height: 20),

                // Role Segment Selector
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text("Customer / Couple")),
                        selected: _selectedRole == 'customer',
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedRole = 'customer');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text("Wedding Vendor")),
                        selected: _selectedRole == 'vendor',
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedRole = 'vendor');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.primary),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primary),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Email is required" : null,
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Mobile Phone Number",
                    prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primary),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Phone number is required" : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primary),
                  ),
                  validator: (v) => v == null || v.length < 6 ? "Password must be at least 6 characters" : null,
                ),

                // Vendor Specific Fields
                if (_selectedRole == 'vendor') ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text("Vendor Business Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      labelText: "Business / Studio Name",
                      prefixIcon: Icon(Icons.storefront, color: AppTheme.primary),
                    ),
                    validator: (v) => _selectedRole == 'vendor' && (v == null || v.isEmpty) ? "Business name is required" : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Service Category",
                      prefixIcon: Icon(Icons.category_outlined, color: AppTheme.primary),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Venue")),
                      DropdownMenuItem(value: 2, child: Text("Catering")),
                      DropdownMenuItem(value: 3, child: Text("Decoration")),
                      DropdownMenuItem(value: 4, child: Text("Makeup Artist")),
                      DropdownMenuItem(value: 5, child: Text("Photography")),
                      DropdownMenuItem(value: 7, child: Text("DJ & Music")),
                    ],
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                ],

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleRegister,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Create Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
