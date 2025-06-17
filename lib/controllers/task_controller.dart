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

  // Flag to determine if GetX is in test mode
  final bool isTestMode;

  TaskController({this.isTestMode = false});

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
    if (isTestMode) {
      // In test mode, we don't show snackbars
      return;
    }
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
      if (isTestMode) {
        // In test mode, we don't show snackbars
        return;
      }
      result.match(
        (l) => Get.snackbar('Error', 'Failed to save task: ${l.toString()}'),
        (_) => Get.snackbar('Success', 'Task saved successfully'),
      );
    } else {
      if (isTestMode) return; // Skip snackbar in test mode
      Get.snackbar('Error', 'Task not found');
    }
  }

  // Deletes a task from the list and saves the updated list to storage.
  void deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    final result = await StorageService.saveTasks(_tasks);
    if (isTestMode) {
      // In test mode, we don't show snackbars
      return;
    }
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
      if (isTestMode) {
        // In test mode, we don't show snackbars
        return;
      }
      if (result.isLeft()) {
        Get.snackbar(
          'Error',
          'Failed to update task: ${result.getLeft().toString()}',
        );
        return;
      }
      loadTasks(); // Refresh the task list after toggling completion
    }
  }

  void sortByDueDate() {
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    StorageService.saveTasks(_tasks);
  }

  void sortByPriority() {
    _tasks.sort((a, b) => a.priority.val.compareTo(b.priority.val));
    StorageService.saveTasks(_tasks);
  }

  void sortByTitle() {
    _tasks.sort((a, b) => a.title.compareTo(b.title));
    StorageService.saveTasks(_tasks);
  }

  void clearTasks() {
    _tasks.clear();
    StorageService.saveTasks(_tasks);
    if (!isTestMode) {
      Get.snackbar('Success', 'All tasks cleared');
    }
  }

  List<Task> searchTasks(String query) {
    if (query.isEmpty) {
      loadTasks(); // Reload all tasks if query is empty
      return _tasks;
    } else {
      final filtered = _tasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(query.toLowerCase()) ||
                task.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      _tasks.assignAll(filtered);
      return filtered;
    }
  }

  void sortByCreationDate() {
    _tasks.sort((a, b) => a.creationDate.compareTo(b.creationDate));
    StorageService.saveTasks(_tasks);
  }

  void sortByCompletionStatus() {
    _tasks.sort((a, b) => a.isCompleted ? 1 : 0 - (b.isCompleted ? 1 : 0));
    StorageService.saveTasks(_tasks);
  }
}
