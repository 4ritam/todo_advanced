import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_advanced/core/typedefs.dart';
import '../models/task.dart' as models;

/// StorageService
/// Provides methods to read and save tasks using SharedPreferences.
/// Uses Either type for error handling.
class StorageService {
  // Reads tasks from SharedPreferences.
  // Returns a Right with a list of tasks or a Left with an error.
  static FutureEitherList<models.Task> readTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = prefs.getString('tasks') ?? '[]';
      final List<dynamic> data = json.decode(response);
      return Right(data.map((item) => models.Task.fromJson(item)).toList());
    } catch (e) {
      return Left(Exception('Failed to read tasks: $e'));
    }
  }

  // Saves a list of tasks to SharedPreferences.
  // Returns a Right with null on success or a Left with an error.
  static FutureVoid saveTasks(List<models.Task> tasks) async {
    try {
      final jsonString = json.encode(
        tasks.map((task) => task.toJson()).toList(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tasks', jsonString);
      return Right(null);
    } catch (e) {
      return Left(Exception('Failed to save tasks: $e'));
    }
  }
}
