/// Level enum
/// Represents the priority of a task with three levels: high, medium, and low.
/// Each level has an associated integer value for serialization.
enum Level {
  high(val: 3),
  medium(val: 2),
  low(val: 1);

  final int val;

  const Level({required this.val});
}

/// Task model
/// Represents a task
/// Keeping Properties like id, title, description, due date, priority, completion status.
class Task {
  String id;
  String title;
  String description;
  DateTime creationDate = DateTime.now();
  DateTime dueDate;
  Level priority;
  bool isCompleted;
  bool hasReminder = false;
  DateTime? reminderDateTime;

  Task({
    required this.id,
    required this.title,
    required this.description,
    DateTime? creationDate,
    required this.dueDate,
    required this.priority,
    this.hasReminder = false,
    this.reminderDateTime,
    this.isCompleted = false,
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'creationDate': creationDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'priority': priority.val,
    'isCompleted': isCompleted,
    'hasReminder': hasReminder,
    'reminderDateTime': reminderDateTime?.toIso8601String(),
  };

  // JSON deserialization
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    creationDate: DateTime.parse(json['creationDate']),
    dueDate: DateTime.parse(json['dueDate']),
    priority: Level.values.firstWhere((e) => e.val == json['priority']),
    isCompleted: json['isCompleted'],
    hasReminder: json['hasReminder'],
    reminderDateTime: json['reminderDateTime'] != null
        ? DateTime.parse(json['reminderDateTime'])
        : null,
  );
}
