import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Priority':
                  _taskController.sortByPriority();
                  break;
                case 'Due Date':
                  _taskController.sortByDueDate();
                  break;
                case 'Creation':
                  _taskController.sortByCreationDate();
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'Priority',
                child: Text('Sort by Priority'),
              ),
              const PopupMenuItem(
                value: 'Due Date',
                child: Text('Sort by Due Date'),
              ),
              const PopupMenuItem(
                value: 'Creation',
                child: Text('Sort by Creation Date'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _taskController.searchTasks(value),
            ),
          ),
          Expanded(
            child: Obx(() {
              final tasks = _searchController.text.isEmpty
                  ? _taskController.tasks
                  : _taskController.searchTasks(_searchController.text);

              if (tasks.isEmpty) {
                return const Center(child: Text('No tasks found.'));
              }

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      'Due: ${task.dueDate.toLocal().toString().split(' ')[0]} · Priority: ${task.priority.name}',
                    ),
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) =>
                          _taskController.toggleTaskCompletion(task.id),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          Get.toNamed('/task_form', arguments: task),
                    ),
                    onLongPress: () => _showDeleteDialog(context, task),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/task_form'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _taskController.deleteTask(task.id);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
