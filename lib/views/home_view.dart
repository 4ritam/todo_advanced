import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_advanced/views/components/task_detail_modal.dart';
import '../../controllers/task_controller.dart';
import 'components/task_form_modal.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo List')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _taskController.refreshList(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                // Filter by search query
                final query = _searchController.text.toLowerCase();
                final allTasks = _taskController.tasks.where((t) {
                  return t.title.toLowerCase().contains(query) ||
                      t.description.toLowerCase().contains(query);
                }).toList();

                // Split into incomplete and completed
                final incomplete = allTasks
                    .where((t) => !t.isCompleted)
                    .toList();
                final completed = allTasks.where((t) => t.isCompleted).toList();

                // Sort incomplete: priority desc
                // incomplete.sort(
                //   (a, b) => b.priority.val.compareTo(a.priority.val),
                // );
                // Sort incomplete: due date asc
                incomplete.sort((a, b) {
                  // Compare by calendar date only (ignore time)
                  final aDate = DateTime(
                    a.dueDate.year,
                    a.dueDate.month,
                    a.dueDate.day,
                  );
                  final bDate = DateTime(
                    b.dueDate.year,
                    b.dueDate.month,
                    b.dueDate.day,
                  );
                  final dateCmp = aDate.compareTo(bDate);
                  if (dateCmp != 0) return dateCmp;
                  // If same day, higher priority first
                  return b.priority.val.compareTo(a.priority.val);
                });

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Incomplete Section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Incomplete Tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (incomplete.isEmpty)
                        const Text('No incomplete tasks.')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: incomplete.length,
                          itemBuilder: (context, index) {
                            final task = incomplete[index];
                            return ListTile(
                              title: Text(task.title),
                              subtitle: Text(
                                'Due: ${task.dueDate.toLocal().toString().split(' ')[0]} · Priority: ${task.priority.name.toUpperCase()}',
                              ),
                              trailing: Checkbox(
                                value: task.isCompleted,
                                onChanged: (_) => _taskController
                                    .toggleTaskCompletion(task.id),
                              ),
                              onTap: () =>
                                  showTaskDetailModal(context, task: task),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      // Completed Section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Completed Tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (completed.isEmpty)
                        const Text('No completed tasks.')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: completed.length,
                          itemBuilder: (context, index) {
                            final task = completed[index];
                            return ListTile(
                              title: Text(
                                task.title,
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              subtitle: Text(
                                'Due: ${task.dueDate.toLocal().toString().split(' ')[0]} · Priority: ${task.priority.name.toUpperCase()}',
                              ),
                              trailing: Checkbox(
                                value: task.isCompleted,
                                onChanged: (_) => _taskController
                                    .toggleTaskCompletion(task.id),
                              ),
                              onTap: () =>
                                  showTaskDetailModal(context, task: task),
                            );
                          },
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskFormModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
