import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task.dart';
import '../../controllers/task_controller.dart';
import 'task_form_modal.dart';

void showTaskDetailModal(BuildContext context, {Task? task}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => SafeArea(child: TaskDetailModal(task: task!)),
  );
}

class TaskDetailModal extends StatelessWidget {
  final Task task;

  const TaskDetailModal({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskController>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(task.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (task.description.isNotEmpty) ...[
            Text(task.description),
            const SizedBox(height: 24),
          ],
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 8),
              Text('Due: ${task.dueDate.toLocal().toString().split(' ')[0]}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.priority_high, size: 18),
              const SizedBox(width: 8),
              Text('Priority: ${task.priority.name.toUpperCase()}'),
            ],
          ),
          if (task.hasReminder && task.reminderDateTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.alarm, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Reminder: ${task.reminderDateTime!.toLocal().day}/${task.reminderDateTime!.toLocal().month}/${task.reminderDateTime!.toLocal().year} ${task.reminderDateTime!.toLocal().hour}:${task.reminderDateTime!.toLocal().minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.toggleTaskCompletion(task.id);
                    Get.back(); // Close modal
                  },
                  icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
                  label: Text(
                    task.isCompleted ? "Mark as Undone" : "Mark as Done",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showTaskFormModal(context, initialTask: task);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      pageBuilder: (context, _, __) {
                        return AlertDialog(
                          title: const Text('Delete Task'),
                          content: const Text(
                            'Are you sure you want to delete this task?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.deleteTask(task.id);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
