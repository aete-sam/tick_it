import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String priority;
  final String description;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.priority = 'Low',
    this.description = '',
    this.isCompleted = false,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? priority,
    String? description,
    bool? isCompleted,
    String? userId,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'priority': priority,
      'description': description,
      'isCompleted': isCompleted,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? 'General',
      date: (map['date'] as Timestamp).toDate(),
      startTime: map['startTime'] ?? '08:00 AM',
      endTime: map['endTime'] ?? '09:00 AM',
      priority: map['priority'] ?? 'Low',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'priority': priority,
      'description': description,
      'isCompleted': isCompleted,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      date: DateTime.parse(json['date']),
      startTime: json['startTime'] ?? '08:00 AM',
      endTime: json['endTime'] ?? '09:00 AM',
      priority: json['priority'] ?? 'Low',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static const List<String> categories = [
    'Project',
    'Work',
    'Daily Tasks',
    'Groceries',
  ];

  static const List<String> priorities = [
    'Low',
    'Medium',
    'High',
  ];

  @override
  String toString() => 'TaskModel(id: $id, title: $title, category: $category)';
}
