import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

abstract class TaskService {
  factory TaskService({FirebaseFirestore? firestore}) =>
      FirestoreTaskService(firestore: firestore);
  factory TaskService.inMemory({List<TaskModel>? seed}) =>
      InMemoryTaskService(seed: seed);

  Stream<List<TaskModel>> streamTasks(String userId);
  Future<TaskModel> add(String userId, TaskModel task);
  Future<TaskModel> update(String userId, TaskModel task);
  Future<void> delete(String userId, String id);
  Future<void> restore(String userId, TaskModel task);
}

class FirestoreTaskService implements TaskService {
  FirestoreTaskService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('tasks');

  @override
  Stream<List<TaskModel>> streamTasks(String userId) {
    return _userTasksRef(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<TaskModel> add(String userId, TaskModel task) async {
    await _userTasksRef(userId).doc(task.id).set(task.toMap());
    return task;
  }

  @override
  Future<TaskModel> update(String userId, TaskModel task) async {
    await _userTasksRef(userId).doc(task.id).update(task.toMap());
    return task;
  }

  @override
  Future<void> delete(String userId, String id) async {
    await _userTasksRef(userId).doc(id).delete();
  }

  @override
  Future<void> restore(String userId, TaskModel task) async {
    await _userTasksRef(userId).doc(task.id).set(task.toMap());
  }
}

class InMemoryTaskService implements TaskService {
  InMemoryTaskService({List<TaskModel>? seed})
    : _tasks = List.from(seed ?? seedTasks());

  final List<TaskModel> _tasks;
  final _controller = StreamController<List<TaskModel>>.broadcast();

  void _emit() {
    _controller.add(List.unmodifiable(_tasks));
  }

  @override
  Stream<List<TaskModel>> streamTasks(String userId) {
    // Schedule initial emit
    scheduleMicrotask(_emit);
    return _controller.stream;
  }

  @override
  Future<TaskModel> add(String userId, TaskModel task) async {
    _tasks.add(task);
    _emit();
    return task;
  }

  @override
  Future<TaskModel> update(String userId, TaskModel task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
    _emit();
    return task;
  }

  @override
  Future<void> delete(String userId, String id) async {
    _tasks.removeWhere((t) => t.id == id);
    _emit();
  }

  @override
  Future<void> restore(String userId, TaskModel task) async {
    _tasks.add(task);
    _emit();
  }
}

List<TaskModel> seedTasks() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return [
    TaskModel(
      id: 'seed_1',
      title: 'Submit weekly gig invoice',
      description: 'Prepare timesheet and submit invoice to client.',
      dueDate: today.subtract(const Duration(days: 1)),
      priority: Priority.high,
      category: 'Work',
      isCompleted: false,
      createdAt: today.subtract(const Duration(days: 3)),
    ),
    TaskModel(
      id: 'seed_2',
      title: 'Deliver package to Maple St',
      description: 'Courier order #4492. Signature required.',
      dueDate: today.add(const Duration(hours: 3)),
      priority: Priority.high,
      category: 'Work',
      isCompleted: false,
      createdAt: today.subtract(const Duration(days: 1)),
    ),
    TaskModel(
      id: 'seed_3',
      title: 'Vehicle maintenance & gas refill',
      description: 'Check tire pressure and top up gas tank.',
      dueDate: today.add(const Duration(hours: 6)),
      priority: Priority.medium,
      category: 'Personal',
      isCompleted: false,
      createdAt: today,
    ),
    TaskModel(
      id: 'seed_4',
      title: 'Pick up bakery supplies for cafe run',
      description: 'Collect morning order from Downtown Bakery.',
      dueDate: today.add(const Duration(days: 1, hours: 2)),
      priority: Priority.low,
      category: 'Work',
      isCompleted: false,
      createdAt: today,
    ),
    TaskModel(
      id: 'seed_5',
      title: 'Study Flutter state management architecture',
      description: 'Review modern Provider and reactive patterns.',
      dueDate: today.add(const Duration(days: 3)),
      priority: Priority.medium,
      category: 'Study',
      isCompleted: false,
      createdAt: today,
    ),
  ];
}
