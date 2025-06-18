import 'package:get/get.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

/// TaskController
/// Manages tasks state and persistence, including reminders.
class TaskController extends GetxController {
  final _tasks = <Task>[].obs;

  /// Public getter for tasks
  List<Task> get tasks => _tasks;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  /// Load tasks from storage, assign to list, and schedule pending reminders
  void loadTasks() async {
    final result = await StorageService.readTasks();
    result.match(
      (err) => Get.snackbar('Error', 'Failed to load tasks: ${err.toString()}'),
      (loaded) {
        _tasks.assignAll(loaded);
        _scheduleAllReminders();
      },
    );
  }

  /// Refresh the tasks list, typically after a search or filter change
  void refreshList() {
    // Trigger a refresh of the tasks list
    _tasks.refresh();
  }

  /// Add a new task: persist, schedule reminder
  void addTask(Task task) async {
    _tasks.add(task);
    final result = await StorageService.saveTasks(_tasks);

    result.match(
      (err) => Get.snackbar('Error', 'Failed to save task: ${err.toString()}'),
      (_) {
        Get.snackbar('Success', 'Task added');
        _scheduleReminder(task);
      },
    );
  }

  /// Update an existing task: persist, cancel old and schedule new reminder
  void updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx == -1) {
      Get.snackbar('Error', 'Task not found');
      return;
    }

    _tasks[idx] = task;
    final result = await StorageService.saveTasks(_tasks);

    result.match(
      (err) => Get.snackbar('Error', 'Failed to save task: ${err.toString()}'),
      (_) {
        Get.snackbar('Success', 'Task updated');
        // Cancel any existing reminder
        NotificationService.cancelNotification(task.hashCode);

        // Schedule new if needed
        _scheduleReminder(task);
      },
    );
  }

  /// Delete a task: persist, cancel reminder
  void deleteTask(String id) async {
    final task = _tasks.firstWhereOrNull((t) => t.id == id);
    if (task == null) {
      Get.snackbar('Error', 'Task not found');
      return;
    }
    _tasks.remove(task);
    final result = await StorageService.saveTasks(_tasks);

    result.match(
      (err) =>
          Get.snackbar('Error', 'Failed to delete task: ${err.toString()}'),
      (_) {
        Get.snackbar('Success', 'Task deleted');
        NotificationService.cancelNotification(task.hashCode);
      },
    );
    loadTasks(); // Refresh the list after deletion
  }

  /// Toggle completion: persist, cancel or reschedule reminder
  void toggleTaskCompletion(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final task = _tasks[idx];
    task.isCompleted = !task.isCompleted;

    final result = await StorageService.saveTasks(_tasks);
    result.match(
      (err) =>
          Get.snackbar('Error', 'Failed to update task: ${err.toString()}'),
      (_) {
        Get.snackbar(
          'Success',
          'Task ${task.isCompleted ? 'completed' : 'marked as incomplete'}',
        );
        if (task.isCompleted) {
          NotificationService.cancelNotification(task.hashCode);
        } else {
          _scheduleReminder(task);
        }
      },
    );
    loadTasks();
  }

  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;

    return _tasks.where((task) {
      final lowerQuery = query.toLowerCase();
      return task.title.toLowerCase().contains(lowerQuery) ||
          task.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Internal: schedule reminder if task hasReminder and reminderDateTime
  void _scheduleReminder(Task task) {
    if (task.hasReminder && task.reminderDateTime != null) {
      final dt = task.reminderDateTime!;
      if (dt.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          id: task.hashCode,
          title: task.title,
          body: task.description,
          scheduledTime: dt,
        );
      }
    }
  }

  /// Internal: schedule all reminders on load
  void _scheduleAllReminders() {
    for (final task in _tasks) {
      NotificationService.cancelNotification(task.hashCode);
      _scheduleReminder(task);
    }
  }
}
