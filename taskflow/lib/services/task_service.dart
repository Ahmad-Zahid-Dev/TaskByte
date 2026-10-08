import '../models/task_model.dart';

class TaskService {
  final List<TaskModel> _tasks = _seedTasks();

  List<TaskModel> getAll() => List.unmodifiable(_tasks);

  Future<TaskModel> add(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tasks.add(task);
    return task;
  }

  Future<TaskModel> update(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx == -1) throw StateError('Task not found: ${task.id}');
    _tasks[idx] = task;
    return task;
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tasks.removeWhere((t) => t.id == id);
  }

  Future<void> restore(TaskModel task) async {
    _tasks.add(task);
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}

List<TaskModel> _seedTasks() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return [
    TaskModel(
      id: 'seed_1',
      title: 'Submit project proposal',
      description: 'Send the Q4 project proposal to the manager.',
      dueDate: today.subtract(const Duration(days: 2)),
      priority: Priority.high,
      category: 'Work',
      isCompleted: false,
      createdAt: today.subtract(const Duration(days: 5)),
    ),
    TaskModel(
      id: 'seed_2',
      title: 'Pay electricity bill',
      description: '',
      dueDate: today.subtract(const Duration(days: 1)),
      priority: Priority.medium,
      category: 'Personal',
      isCompleted: false,
      createdAt: today.subtract(const Duration(days: 3)),
    ),
    TaskModel(
      id: 'seed_3',
      title: 'Schedule dentist appointment',
      description: 'Call Dr. Smith\'s office between 9–11 AM.',
      dueDate: today,
      priority: Priority.low,
      category: 'Personal',
      isCompleted: false,
      createdAt: today.subtract(const Duration(days: 1)),
    ),
    TaskModel(
      id: 'seed_4',
      title: 'Prepare team meeting slides',
      description: 'Quarterly review deck for Monday\'s all-hands.',
      dueDate: today,
      priority: Priority.high,
      category: 'Work',
      isCompleted: true,
      createdAt: today.subtract(const Duration(days: 2)),
    ),
    TaskModel(
      id: 'seed_5',
      title: 'Call Charlotte',
      description: '',
      dueDate: today.add(const Duration(days: 1)),
      priority: Priority.low,
      category: 'Personal',
      isCompleted: false,
      createdAt: today,
    ),
    TaskModel(
      id: 'seed_6',
      title: 'Submit exercise 3.1',
      description: 'Chapter 3 assignments for the online course.',
      dueDate: today.add(const Duration(days: 1)),
      priority: Priority.medium,
      category: 'Study',
      isCompleted: false,
      createdAt: today,
    ),
    TaskModel(
      id: 'seed_7',
      title: 'Prepare A/B test plan',
      description: 'Design A/B test for the new onboarding flow.',
      dueDate: today.add(const Duration(days: 2)),
      priority: Priority.high,
      category: 'App',
      isCompleted: false,
      createdAt: today,
    ),
    TaskModel(
      id: 'seed_8',
      title: 'Submit exercise 3.2',
      description: '',
      dueDate: today.add(const Duration(days: 4)),
      priority: Priority.medium,
      category: 'Study',
      isCompleted: false,
      createdAt: today,
    ),
    TaskModel(
      id: 'seed_9',
      title: 'Water plants',
      description: '',
      dueDate: today.add(const Duration(days: 5)),
      priority: Priority.low,
      category: 'Personal',
      isCompleted: true,
      createdAt: today,
    ),
    TaskModel(
      id: 'seed_10',
      title: 'Renew gym membership',
      description: 'Check if the annual plan is still discounted.',
      dueDate: today.add(const Duration(days: 14)),
      priority: Priority.low,
      category: 'Personal',
      isCompleted: false,
      createdAt: today,
    ),
  ];
}
