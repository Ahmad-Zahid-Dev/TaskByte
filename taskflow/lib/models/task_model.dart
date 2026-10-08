import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart' as colors;

enum Priority { low, medium, high }

extension PriorityX on Priority {
  String get label => switch (this) {
    Priority.low => 'Low',
    Priority.medium => 'Medium',
    Priority.high => 'High',
  };

  Color get color => switch (this) {
    Priority.low => colors.AppColors.green,
    Priority.medium => colors.AppColors.amber,
    Priority.high => colors.AppColors.orange,
  };

  Color get softColor => color.withValues(alpha: 0.15);
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    this.category,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final Priority priority;
  final String? category;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
  }) => TaskModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate ?? this.dueDate,
    priority: priority ?? this.priority,
    category: category ?? this.category,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.millisecondsSinceEpoch,
    'priority': priority.name,
    'category': category,
    'isCompleted': isCompleted,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String? ?? '',
    dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
    priority: Priority.values.firstWhere((p) => p.name == map['priority']),
    category: map['category'] as String?,
    isCompleted: map['isCompleted'] as bool,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
  );
}
