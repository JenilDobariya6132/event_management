// lib/screens/wedding_checklist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/checklist_provider.dart';

class WeddingChecklistScreen extends StatefulWidget {
  const WeddingChecklistScreen({super.key});

  @override
  State<WeddingChecklistScreen> createState() => _WeddingChecklistScreenState();
}

class _WeddingChecklistScreenState extends State<WeddingChecklistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChecklistProvider>(context, listen: false).fetchChecklist();
    });
  }

  void _showAddTaskModal(BuildContext context) {
    final titleController = TextEditingController();
    final catController = TextEditingController(text: 'General');
    final dateController = TextEditingController(text: DateTime.now().add(const Duration(days: 30)).toString().split(' ')[0]);
    String priority = 'medium';

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
              const Text("Add Checklist Task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Task Title"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: catController,
                decoration: const InputDecoration(labelText: "Category (e.g. Venue, Makeup, Attire)"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Due Date (YYYY-MM-DD)"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final provider = Provider.of<ChecklistProvider>(context, listen: false);
                    await provider.saveTask(
                      taskTitle: titleController.text,
                      category: catController.text,
                      dueDate: dateController.text,
                      priority: priority,
                      status: 'pending',
                    );
                  },
                  child: const Text("Save Task"),
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
    final checklistProvider = Provider.of<ChecklistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wedding Checklist"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Task", style: TextStyle(color: Colors.white)),
      ),
      body: checklistProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Progress Summary Card
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Checklist Progress", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          Text(
                            "${checklistProvider.completedTasksCount} / ${checklistProvider.totalTasksCount} Completed",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: checklistProvider.completionPercentage,
                          minHeight: 8,
                          backgroundColor: AppTheme.roseLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Task Items List
                Expanded(
                  child: checklistProvider.tasks.isEmpty
                      ? const Center(child: Text("No tasks in your checklist yet."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: checklistProvider.tasks.length,
                          itemBuilder: (context, index) {
                            final task = checklistProvider.tasks[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  activeColor: AppTheme.primary,
                                  onChanged: (_) => checklistProvider.toggleTaskStatus(task),
                                ),
                                title: Text(
                                  task.taskTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    color: task.isCompleted ? Colors.grey : AppTheme.textDark,
                                  ),
                                ),
                                subtitle: Text("${task.category} • Due: ${task.dueDate ?? 'N/A'}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                  onPressed: () => checklistProvider.deleteTask(task.id),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
