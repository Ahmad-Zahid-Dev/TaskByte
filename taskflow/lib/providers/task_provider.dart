import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../core/utils/date_helper.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._service) {
    _tasks = List.from(_service.getAll());
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  final TaskService _service;

  late List<TaskModel> _tasks;
  TaskModel? _lastDeleted;

  // Filter state
  String _statusFilter = 'All';
  String _priorityFilter = 'All';
  String _search = '';

  String get statusFilter => _statusFilter;
  String get priorityFilter => _priorityFilter;
  String get search => _search;

  List<TaskModel> get tasks => _tasks;

  List<TaskModel> get filtered {
    return _tasks.where((t) {
      if (_statusFilter == 'Pending' && t.isCompleted) return false;
      if (_statusFilter == 'Completed' && !t.isCompleted) return false;
      if (_priorityFilter != 'All') {
        final match = _priorityFilter.toLowerCase();
        if (t.priority.name != match) return false;
      }
      if (_search.isNotEmpty) {
        if (!t.title.toLowerCase().contains(_search.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Map<TaskGroup, List<TaskModel>> get grouped {
    final result = <TaskGroup, List<TaskModel>>{};
    for (final t in filtered) {
      final g = DateHelper.groupFor(t.dueDate);
      result.putIfAbsent(g, () => []).add(t);
    }
    return result;
  }

  void setStatusFilter(String value) {
    if (_statusFilter == value) return;
    _statusFilter = value;
    notifyListeners();
  }

  void setPriorityFilter(String value) {
    if (_priorityFilter == value) return;
    _priorityFilter = value;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    await _service.add(task);
    _tasks.add(task);
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    await _service.update(task);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  Future<void> toggleComplete(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final updated = _tasks[idx].copyWith(isCompleted: !_tasks[idx].isCompleted);
    await _service.update(updated);
    _tasks[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _lastDeleted = _tasks[idx];
    await _service.delete(id);
    _tasks.removeAt(idx);
    notifyListeners();
  }

  Future<void> undoDelete() async {
    final task = _lastDeleted;
    if (task == null) return;
    _lastDeleted = null;
    await _service.restore(task);
    _tasks.add(task);
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  bool get canUndo => _lastDeleted != null;
}
