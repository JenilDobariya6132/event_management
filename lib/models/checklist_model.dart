// lib/models/checklist_model.dart

class ChecklistTaskModel {
  final int id;
  final int weddingId;
  final String taskTitle;
  final String category;
  final String? dueDate;
  final String priority; // low, medium, high
  final String status;   // pending, completed

  ChecklistTaskModel({
    required this.id,
    required this.weddingId,
    required this.taskTitle,
    required this.category,
    this.dueDate,
    required this.priority,
    required this.status,
  });

  bool get isCompleted => status == 'completed';

  factory ChecklistTaskModel.fromJson(Map<String, dynamic> json) {
    return ChecklistTaskModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      weddingId: json['wedding_id'] is int ? json['wedding_id'] : int.parse(json['wedding_id'].toString()),
      taskTitle: json['task_title'] ?? '',
      category: json['category'] ?? 'General',
      dueDate: json['due_date'],
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
    );
  }
}
