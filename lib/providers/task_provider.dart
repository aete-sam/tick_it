import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tick_it/models/task_model.dart';
import 'package:tick_it/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  List<TaskModel> _allTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription? _tasksSubscription;
  StreamSubscription? _allTasksSubscription;

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get allTasks => _allTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TaskModel> get sortedTasks {
    final sorted = List<TaskModel>.from(_tasks);
    sorted.sort((a, b) {
      const priorityWeights = {'High': 0, 'Medium': 1, 'Low': 2};
      final weightA = priorityWeights[a.priority] ?? 2;
      final weightB = priorityWeights[b.priority] ?? 2;
      return weightA.compareTo(weightB);
    });
    return sorted;
  }

  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final task in _allTasks) {
      counts[task.category] = (counts[task.category] ?? 0) + 1;
    }
    return counts;
  }

  void loadTasksByDate(String userId, DateTime date) {
    _tasksSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _tasksSubscription = _taskService.getTasksByDate(userId, date).listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load tasks.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void loadAllTasks(String userId) {
    _allTasksSubscription?.cancel();

    _allTasksSubscription = _taskService.getAllTasks(userId).listen(
      (tasks) {
        _allTasks = tasks;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load all tasks.';
      },
    );
  }

  Future<bool> addTask(TaskModel task) async {
    try {
      await _taskService.addTask(task);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      await _taskService.updateTask(task);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String userId, String taskId) async {
    try {
      await _taskService.deleteTask(userId, taskId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleComplete(TaskModel task) async {
    await _taskService.toggleComplete(task);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _allTasksSubscription?.cancel();
    super.dispose();
  }
}
