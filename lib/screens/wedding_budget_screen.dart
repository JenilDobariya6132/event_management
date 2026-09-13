// lib/screens/wedding_budget_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/budget_provider.dart';

class WeddingBudgetScreen extends StatefulWidget {
  const WeddingBudgetScreen({super.key});

  @override
  State<WeddingBudgetScreen> createState() => _WeddingBudgetScreenState();
}

class _WeddingBudgetScreenState extends State<WeddingBudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BudgetProvider>(context, listen: false).fetchBudget();
    });
  }

  void _showAddExpenseModal(BuildContext context, [dynamic item]) {
    final catController = TextEditingController(text: item?.categoryName ?? '');
    final estController = TextEditingController(text: item?.estimatedAmount.toString() ?? '');
    final actController = TextEditingController(text: item?.actualAmount.toString() ?? '');
    final notesController = TextEditingController(text: item?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item == null ? "Add Expense Item" : "Edit Expense Item", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 16),
              TextField(
                controller: catController,
                decoration: const InputDecoration(labelText: "Category Name (e.g. Venue, Catering)"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: estController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Estimated Amount (₹)"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: actController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Actual Paid Amount (₹)"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: "Notes"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final provider = Provider.of<BudgetProvider>(context, listen: false);
                    await provider.saveBudgetItem(
                      id: item?.id ?? 0,
                      categoryName: catController.text,
                      estimatedAmount: double.tryParse(estController.text) ?? 0.0,
                      actualAmount: double.tryParse(actController.text) ?? 0.0,
                      notes: notesController.text,
                    );
                  },
                  child: const Text("Save Expense"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final progress = budgetProvider.totalBudget > 0 ? (budgetProvider.totalActual / budgetProvider.totalBudget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wedding Budget Manager"),
      ),
      body: budgetProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget Overview Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Allocated Budget", style: TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(budgetProvider.totalBudget),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 16),

                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: AppTheme.roseLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress > 0.9 ? Colors.red : AppTheme.accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total Spent", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(currencyFormatter.format(budgetProvider.totalActual), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("Remaining", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(
                                    currencyFormatter.format(budgetProvider.remainingBudget),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: budgetProvider.remainingBudget < 0 ? Colors.red : AppTheme.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Expense Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ElevatedButton.icon(
                        onPressed: () => _showAddExpenseModal(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text("Add"),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Expense Items List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: budgetProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = budgetProvider.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Est: ${currencyFormatter.format(item.estimatedAmount)} • Notes: ${item.notes ?? 'None'}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currencyFormatter.format(item.actualAmount),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                onPressed: () => budgetProvider.deleteBudgetItem(item.id),
                              ),
                            ],
                          ),
                          onTap: () => _showAddExpenseModal(context, item),
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
