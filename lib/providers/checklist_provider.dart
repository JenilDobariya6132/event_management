// lib/providers/checklist_provider.dart

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/checklist_model.dart';
import '../services/api_service.dart';

class ChecklistProvider with ChangeNotifier {
  List<ChecklistTaskModel> _tasks = [];
  int _completedTasksCount = 0;
  int _totalTasksCount = 0;
  bool _isLoading = false;

  List<ChecklistTaskModel> get tasks => _tasks;
  int get completedTasksCount => _completedTasksCount;
  int get totalTasksCount => _totalTasksCount;
  bool get isLoading => _isLoading;

  double get completionPercentage => _totalTasksCount > 0 ? (_completedTasksCount / _totalTasksCount) : 0.0;

  Future<void> fetchChecklist() async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.get(ApiConfig.checklist);
    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      _totalTasksCount = data['total_tasks'] ?? 0;
      _completedTasksCount = data['completed_tasks'] ?? 0;
      if (data['tasks'] != null) {
        _tasks = (data['tasks'] as List).map((t) => ChecklistTaskModel.fromJson(t)).toList();
      }
    } else if (_tasks.isEmpty) {
      _tasks = [
        ChecklistTaskModel(id: 1, weddingId: 1, taskTitle: 'Finalize Wedding Venue & Pay Advance', category: 'Venue', dueDate: '2026-09-20', priority: 'high', status: 'completed'),
        ChecklistTaskModel(id: 2, weddingId: 1, taskTitle: 'Book Candid Photographer & Drone Crew', category: 'Photography', dueDate: '2026-09-25', priority: 'high', status: 'completed'),
        ChecklistTaskModel(id: 3, weddingId: 1, taskTitle: 'Select Bridal Lehenga & Groom Sherwani', category: 'Attire', dueDate: '2026-10-10', priority: 'medium', status: 'pending'),
        ChecklistTaskModel(id: 4, weddingId: 1, taskTitle: 'Finalize Tasting Menu with Caterer', category: 'Catering', dueDate: '2026-10-15', priority: 'high', status: 'pending'),
        ChecklistTaskModel(id: 5, weddingId: 1, taskTitle: 'Send Digital Wedding Invitations', category: 'Invitations', dueDate: '2026-11-01', priority: 'high', status: 'pending'),
      ];
      _recalculateTaskCounts();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _recalculateTaskCounts() {
    _totalTasksCount = _tasks.length;
    _completedTasksCount = _tasks.where((t) => t.isCompleted).length;
  }

  Future<bool> saveTask({
    int id = 0,
    required String taskTitle,
    required String category,
    required String dueDate,
    required String priority,
    required String status,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.post(ApiConfig.checklist, {
      'id': id,
      'task_title': taskTitle,
      'category': category,
      'due_date': dueDate,
      'priority': priority,
      'status': status,
    });

    _isLoading = false;
    if (res['success'] == true) {
      await fetchChecklist();
      return true;
    }

    if (id > 0) {
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx >= 0) {
        _tasks[idx] = ChecklistTaskModel(
          id: id,
          weddingId: 1,
          taskTitle: taskTitle,
          category: category,
          dueDate: dueDate,
          priority: priority,
          status: status,
        );
      }
    } else {
      _tasks.add(ChecklistTaskModel(
        id: _tasks.length + 1,
        weddingId: 1,
        taskTitle: taskTitle,
        category: category,
        dueDate: dueDate,
        priority: priority,
        status: status,
      ));
    }

    _recalculateTaskCounts();
    notifyListeners();
    return true;
  }

  Future<bool> toggleTaskStatus(ChecklistTaskModel task) async {
    final newStatus = task.isCompleted ? 'pending' : 'completed';
    return await saveTask(
      id: task.id,
      taskTitle: task.taskTitle,
      category: task.category,
      dueDate: task.dueDate ?? DateTime.now().toString().split(' ')[0],
      priority: task.priority,
      status: newStatus,
    );
  }

  Future<bool> deleteTask(int id) async {
    final res = await ApiService.delete("${ApiConfig.checklist}?id=$id");
    if (res['success'] == true) {
      await fetchChecklist();
      return true;
    }

    _tasks.removeWhere((t) => t.id == id);
    _recalculateTaskCounts();
    notifyListeners();
    return true;
  }
}
