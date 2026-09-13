// lib/screens/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import 'main_navigation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final double amount;
  final String title;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.title,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedGateway = 'Razorpay';
  String _selectedMethod = 'UPI / GPay';

  void _handlePayment() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    final res = await bookingProvider.processPayment(
      bookingId: widget.bookingId,
      amount: widget.amount,
      paymentGateway: _selectedGateway,
      paymentMethod: _selectedMethod,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      final txnId = res['data']['transaction_id'];

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Column(
              children: [
                Icon(Icons.check_circle, size: 64, color: AppTheme.success),
                SizedBox(height: 12),
                Text("Payment Successful!", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Transaction ID: $txnId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Text("Amount Paid: ₹${widget.amount.toStringAsFixed(2)}"),
                const SizedBox(height: 4),
                Text("Payment Method: $_selectedGateway ($minMethod)"),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Go to My Bookings"),
              )
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Payment failed'), backgroundColor: AppTheme.error),
      );
    }
  }

  String get minMethod => _selectedMethod;

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Summary Box
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Amount Payable", style: TextStyle(fontSize: 13, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text("Instant Confirmation", style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(
                      currencyFormatter.format(widget.amount),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.accent),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text("Select Payment Gateway", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const SizedBox(height: 12),

            // Gateway Selector Chips
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("Razorpay")),
                    selected: _selectedGateway == 'Razorpay',
                    onSelected: (val) => setState(() => _selectedGateway = 'Razorpay'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("Stripe")),
                    selected: _selectedGateway == 'Stripe',
                    onSelected: (val) => setState(() => _selectedGateway = 'Stripe'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text("Select Payment Option", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const SizedBox(height: 12),

            Column(
              children: [
                'UPI / GPay',
                'Card',
                'NetBanking'
              ].map((method) {
                final isSelected = _selectedMethod == method;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.roseLight : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      method == 'UPI / GPay'
                          ? "UPI / Google Pay / PhonePe"
                          : method == 'Card'
                              ? "Credit / Debit Card (Visa, Mastercard, RuPay)"
                              : "NetBanking / Internet Banking",
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primary : AppTheme.textDark,
                      ),
                    ),
                    trailing: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? AppTheme.primary : Colors.grey,
                    ),
                    onTap: () => setState(() => _selectedMethod = method),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: bookingProvider.isLoading ? null : _handlePayment,
                child: bookingProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Pay ${currencyFormatter.format(widget.amount)} Securely", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
