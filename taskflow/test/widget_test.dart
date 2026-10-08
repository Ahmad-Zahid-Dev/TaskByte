import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:taskflow/services/task_service.dart';
import 'package:taskflow/providers/task_provider.dart';

void main() {
  group('TaskModel', () {
    test('copyWith updates fields correctly', () {
      final now = DateTime.now();
      final task = TaskModel(
        id: '1',
        title: 'Original Title',
        description: 'Original Desc',
        dueDate: now,
        priority: Priority.medium,
        category: 'Work',
        isCompleted: false,
        createdAt: now,
      );

      final updated = task.copyWith(title: 'Updated Title', isCompleted: true);

      expect(updated.id, '1');
      expect(updated.title, 'Updated Title');
      expect(updated.isCompleted, true);
      expect(updated.priority, Priority.medium);
    });

    test('toMap and fromMap serialize symmetrically', () {
      final now = DateTime.now();
      final task = TaskModel(
        id: 't-123',
        title: 'Delivery for Gig',
        description: 'Drop off groceries',
        dueDate: now,
        priority: Priority.high,
        category: 'Gig',
        isCompleted: false,
        createdAt: now,
      );

      final map = task.toMap();
      final revived = TaskModel.fromMap(map);

      expect(revived.id, task.id);
      expect(revived.title, task.title);
      expect(revived.priority, Priority.high);
      expect(revived.category, 'Gig');
    });
  });

  group('TaskProvider', () {
    late TaskService service;
    late TaskProvider provider;

    setUp(() async {
      service = TaskService.inMemory();
      provider = TaskProvider(service);
      provider.bindUser('test_user');
      // Wait for stream to emit initial seed
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    test('initializes with seed tasks', () {
      expect(provider.tasks.isNotEmpty, true);
    });

    test('filters tasks by status and priority', () {
      provider.setStatusFilter('Pending');
      expect(provider.filtered.every((t) => !t.isCompleted), true);

      provider.setPriorityFilter('High');
      expect(provider.filtered.every((t) => t.priority == Priority.high), true);
    });

    test('creates and removes tasks with undo capability', () async {
      final now = DateTime.now();
      final newTask = TaskModel(
        id: 'new-1',
        title: 'Brand new task',
        description: 'Test description',
        dueDate: now.add(const Duration(days: 1)),
        priority: Priority.low,
        isCompleted: false,
        createdAt: now,
      );

      await provider.addTask(newTask);
      expect(provider.tasks.any((t) => t.id == 'new-1'), true);

      await provider.deleteTask('new-1');
      expect(provider.tasks.any((t) => t.id == 'new-1'), false);

      await provider.undoDelete();
      expect(provider.tasks.any((t) => t.id == 'new-1'), true);
    });
  });
}
