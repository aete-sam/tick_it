import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_it/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _cacheKey = 'cached_tasks';

  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  Future<TaskModel> addTask(TaskModel task) async {
    final docRef = await _tasksRef(task.userId).add(task.toMap());
    final newTask = task.copyWith(id: docRef.id);

    await _updateCache(task.userId);

    return newTask;
  }

  Future<void> updateTask(TaskModel task) async {
    await _tasksRef(task.userId).doc(task.id).update(task.toMap());
    await _updateCache(task.userId);
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _tasksRef(userId).doc(taskId).delete();
    await _updateCache(userId);
  }

  Future<void> toggleComplete(TaskModel task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  Stream<List<TaskModel>> getTasksByDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _tasksRef(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<TaskModel>> getAllTasks(String userId) {
    return _tasksRef(userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<Map<String, int>> getTaskCountByCategory(String userId) async {
    final snapshot = await _tasksRef(userId)
        .where('isCompleted', isEqualTo: false)
        .get();

    final counts = <String, int>{};
    for (final doc in snapshot.docs) {
      final category = doc.data()['category'] as String? ?? 'General';
      counts[category] = (counts[category] ?? 0) + 1;
    }

    return counts;
  }

  Future<void> _updateCache(String userId) async {
    try {
      final snapshot = await _tasksRef(userId).get();
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final jsonList = tasks.map((t) => t.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (_) {

    }
  }

  Future<List<TaskModel>> getCachedTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached == null) return [];

      final List<dynamic> jsonList = jsonDecode(cached);
      return jsonList
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> getTodayTaskCount(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _tasksRef(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .where('isCompleted', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }
}
