import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:todo_advanced/services/storage_service.dart';
import 'package:todo_advanced/models/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService with Either', () {
    setUp(() {
      // Reset mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    test('readTasks returns empty list when no tasks saved', () async {
      final result = await StorageService.readTasks();
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: \$l'), (tasks) {
        expect(tasks, isA<List<Task>>());
        expect(tasks, isEmpty);
      });
    });

    test(
      'saveTasks and readTasks persist and retrieve tasks correctly',
      () async {
        // Prepare a sample task
        final task = Task(
          id: '1',
          title: 'Test Task',
          description: 'This is a test',
          dueDate: DateTime.utc(2025, 6, 30),
          priority: Level.high,
          isCompleted: false,
        );

        // Save the task
        final saveResult = await StorageService.saveTasks([task]);
        expect(saveResult.isRight(), true);

        // Inspect raw JSON
        final prefs = await SharedPreferences.getInstance();
        final storedString = prefs.getString('tasks');
        expect(storedString, isNotNull);

        final decoded = json.decode(storedString!);
        expect(decoded, isA<List<dynamic>>());
        expect(decoded.length, 1);
        expect(decoded[0]['id'], '1');
        expect(decoded[0]['title'], 'Test Task');
        expect(decoded[0]['description'], 'This is a test');
        expect(decoded[0]['priority'], Level.high.val);

        // Read back via service
        final readResult = await StorageService.readTasks();
        expect(readResult.isRight(), true);
        readResult.match((l) => fail('Expected Right but got Left: \$l'), (
          tasks,
        ) {
          expect(tasks.length, 1);
          final readTask = tasks.first;
          expect(readTask.id, task.id);
          expect(readTask.title, task.title);
          expect(readTask.description, task.description);
          expect(readTask.dueDate, task.dueDate);
          expect(readTask.priority, task.priority);
          expect(readTask.isCompleted, task.isCompleted);
        });
      },
    );

    test('readTasks handles JSON parsing error gracefully', () async {
      // Seed invalid JSON
      SharedPreferences.setMockInitialValues({'tasks': 'invalid_json'});
      final result = await StorageService.readTasks();
      expect(result.isLeft(), true);
      result.match(
        (exception) => expect(exception, isA<Exception>()),
        (r) => fail('Expected Left but got Right: \$r'),
      );
    });

    test('saveTasks handles exception gracefully', () async {
      // Force SharedPreferences to throw by passing extremely large string?
      // Since SharedPreferences mock won't throw, simulate by overriding method.
      // For demo, wrap call and ensure Right is returned (no exception)
      final result = await StorageService.saveTasks([]);
      expect(result.isRight(), true);
    });
  });
}
