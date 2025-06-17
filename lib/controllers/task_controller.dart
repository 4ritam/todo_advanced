import 'package:get/get.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

/// TaskController
/// Manages the state of tasks in the application.
/// Uses GetX for state management and SharedPreferences for persistent storage.
/// Provides methods to load, add, update, delete, and toggle task completion.
/// Uses Either type for error handling.
class TaskController extends GetxController {
  // List of tasks managed by this controller.
  final _tasks = <Task>[].obs;

  // Getter for tasks
  List<Task> get tasks => _tasks;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  // Loads tasks from storage and updates the observable list.
  void loadTasks() async {
    final saved = await StorageService.readTasks();
    saved.match(
      (l) => Get.snackbar('Error', 'Failed to load tasks: ${l.toString()}'),
      (tasks) => _tasks.assignAll(tasks),
    );
  }

  // Adds a new task to the list and saves it to storage.
  void addTask(Task task) async {
    _tasks.add(task);
    final result = await StorageService.saveTasks(_tasks);
    result.match(
      (l) => Get.snackbar('Error', 'Failed to save task: ${l.toString()}'),
      (_) => Get.snackbar('Success', 'Task saved successfully'),
    );
  }

  // Updates an existing task and saves the updated list to storage.
  void updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      final result = await StorageService.saveTasks(_tasks);
      result.match(
        (l) => Get.snackbar('Error', 'Failed to save task: ${l.toString()}'),
        (_) => Get.snackbar('Success', 'Task saved successfully'),
      );
    } else {
      Get.snackbar('Error', 'Task not found');
    }
  }

  // Deletes a task from the list and saves the updated list to storage.
  void deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    final result = await StorageService.saveTasks(_tasks);
    result.match(
      (l) => Get.snackbar('Error', 'Failed to delete task: ${l.toString()}'),
      (_) => Get.snackbar('Success', 'Task deleted successfully'),
    );
    loadTasks(); // Refresh the task list after deletion
  }

  // Toggles the completion status of a task and saves the updated list to storage.
  void toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      final result = await StorageService.saveTasks(_tasks);
      result.match(
        (l) => Get.snackbar('Error', 'Failed to update task: ${l.toString()}'),
        (_) => Get.snackbar('Success', 'Task updated successfully'),
      );
    }
  }
}
