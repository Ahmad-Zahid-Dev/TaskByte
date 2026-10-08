import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../core/utils/date_helper.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._service);

  final TaskService _service;
  String? _userId;
  StreamSubscription<List<TaskModel>>? _tasksSubscription;

  List<TaskModel> _tasks = [];
  TaskModel? _lastDeleted;

  // Filter state
  String _statusFilter = 'All';
  String _priorityFilter = 'All';
  String _categoryFilter = 'All';
  String _search = '';

  String get statusFilter => _statusFilter;
  String get priorityFilter => _priorityFilter;
  String get categoryFilter => _categoryFilter;
  String get search => _search;

  bool get hasActiveFilters =>
      _statusFilter != 'All' ||
      _priorityFilter != 'All' ||
      _categoryFilter != 'All';

  int get activeFilterCount {
    int count = 0;
    if (_statusFilter != 'All') count++;
    if (_priorityFilter != 'All') count++;
    if (_categoryFilter != 'All') count++;
    return count;
  }

  List<TaskModel> get tasks => _tasks;

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _tasksSubscription?.cancel();
    _lastDeleted = null;

    if (userId == null) {
      _tasks = [];
      notifyListeners();
      return;
    }

    _tasksSubscription = _service.streamTasks(userId).listen((newTasks) {
      _tasks = List.from(newTasks);
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
    });
  }

  List<TaskModel> get filtered {
    return _tasks.where((t) {
      if (_statusFilter == 'Pending' && t.isCompleted) return false;
      if (_statusFilter == 'Completed' && !t.isCompleted) return false;
      if (_priorityFilter != 'All') {
        final match = _priorityFilter.toLowerCase();
        if (t.priority.name != match) return false;
      }
      if (_categoryFilter != 'All') {
        if (t.category == null ||
            t.category!.toLowerCase() != _categoryFilter.toLowerCase()) {
          return false;
        }
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

  void setCategoryFilter(String value) {
    if (_categoryFilter == value) return;
    _categoryFilter = value;
    notifyListeners();
  }

  void resetFilters() {
    _statusFilter = 'All';
    _priorityFilter = 'All';
    _categoryFilter = 'All';
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    final uid = _userId;
    if (uid != null) {
      await _service.add(uid, task);
    } else {
      _tasks.add(task);
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel task) async {
    final uid = _userId;
    if (uid != null) {
      await _service.update(uid, task);
    } else {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) _tasks[idx] = task;
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
    }
  }

  Future<void> toggleComplete(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final updated = _tasks[idx].copyWith(isCompleted: !_tasks[idx].isCompleted);
    final uid = _userId;
    if (uid != null) {
      await _service.update(uid, updated);
    } else {
      _tasks[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _lastDeleted = _tasks[idx];
    final uid = _userId;

    // Immediately remove from local list and update UI
    _tasks.removeAt(idx);
    notifyListeners();

    if (uid != null) {
      try {
        await _service.delete(uid, id);
      } catch (_) {
        // Restore locally if remote delete failed
        if (_lastDeleted?.id == id) {
          _tasks.insert(idx, _lastDeleted!);
          _lastDeleted = null;
          notifyListeners();
        }
      }
    }
  }

  Future<void> undoDelete() async {
    final task = _lastDeleted;
    if (task == null) return;
    _lastDeleted = null;

    // Immediately restore to local list, sort, and update UI
    if (!_tasks.any((t) => t.id == task.id)) {
      _tasks.add(task);
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
    }

    final uid = _userId;
    if (uid != null) {
      try {
        await _service.restore(uid, task);
      } catch (_) {
        // Handled silently
      }
    }
  }

  bool get canUndo => _lastDeleted != null;

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
