import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:todo_advanced/controllers/task_controller.dart';
import 'package:todo_advanced/models/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaskController', () {
    late TaskController controller;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      // Initialize GetX for testing (disable snackbars)
      Get.testMode = true;
      controller = TaskController(isTestMode: true);
    });

    test('loadTasks loads saved tasks into controller', () async {
      // Seed SharedPreferences with one task
      final prefs = await SharedPreferences.getInstance();
      final task = Task(
        id: '1',
        title: 'Load Test',
        description: 'Testing load',
        dueDate: DateTime.utc(2025, 6, 30),
        priority: Level.medium,
      );
      final jsonList = [task.toJson()];
      await prefs.setString('tasks', json.encode(jsonList));

      controller.loadTasks();
      // allow async to complete
      await Future.delayed(Duration.zero);

      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.title, 'Load Test');
    });

    test('addTask adds and persists new task', () async {
      final task = Task(
        id: '2',
        title: 'Add Test',
        description: 'Testing add',
        dueDate: DateTime.utc(2025, 7, 1),
        priority: Level.high,
      );

      controller.addTask(task);
      await Future.delayed(Duration.zero);

      // In-memory list updated
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.id, '2');

      // Persisted to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('tasks');
      expect(stored, isNotNull);
      final decoded = json.decode(stored!);
      expect(decoded.length, 1);
      expect(decoded[0]['id'], '2');
    });

    test('updateTask updates existing task', () async {
      // First add a task
      final task = Task(
        id: '3',
        title: 'Original',
        description: 'Original desc',
        dueDate: DateTime.utc(2025, 8, 1),
        priority: Level.low,
      );
      controller.addTask(task);
      await Future.delayed(Duration.zero);

      // Update
      final updated = Task(
        id: '3',
        title: 'Updated',
        description: 'Updated desc',
        dueDate: DateTime.utc(2025, 8, 2),
        priority: Level.high,
      );
      controller.updateTask(updated);
      await Future.delayed(Duration.zero);

      expect(controller.tasks.first.title, 'Updated');
      final prefs = await SharedPreferences.getInstance();
      final decoded = json.decode(prefs.getString('tasks')!);
      expect(decoded[0]['title'], 'Updated');
    });

    test('deleteTask removes task and updates storage', () async {
      final task = Task(
        id: '4',
        title: 'Delete Me',
        description: 'To be deleted',
        dueDate: DateTime.utc(2025, 9, 1),
        priority: Level.low,
      );
      controller.addTask(task);
      await Future.delayed(Duration.zero);

      controller.deleteTask('4');
      await Future.delayed(Duration.zero);

      expect(controller.tasks, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      final decoded = json.decode(prefs.getString('tasks')!);
      expect((decoded as List).length, 0);
    });

    test('toggleTaskCompletion flips isCompleted and persists', () async {
      final task = Task(
        id: '5',
        title: 'Toggle Me',
        description: 'To be toggled',
        dueDate: DateTime.utc(2025, 10, 1),
        priority: Level.medium,
      );
      controller.addTask(task);
      await Future.delayed(Duration.zero);

      controller.toggleTaskCompletion('5');
      await Future.delayed(Duration.zero);

      expect(controller.tasks.first.isCompleted, true);
      final prefs = await SharedPreferences.getInstance();
      final decoded = json.decode(prefs.getString('tasks')!);
      expect(decoded[0]['isCompleted'], true);
    });
  });
}
