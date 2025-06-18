import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../services/notification_service.dart';

void showTaskFormModal(BuildContext context, {Task? initialTask}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => SafeArea(child: TaskFormModal(initialTask: initialTask)),
  );
}

class TaskFormModal extends StatefulWidget {
  const TaskFormModal({super.key, this.initialTask});

  final Task? initialTask;

  @override
  State<TaskFormModal> createState() => _TaskFormModalState();
}

class _TaskFormModalState extends State<TaskFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late Level _selectedPriority;
  late DateTime _dueDate;
  bool _reminderOn = false;
  DateTime? _reminderDateTime;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _selectedPriority = t?.priority ?? Level.medium;
    _dueDate = t?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _reminderOn = t?.hasReminder ?? false;
    _reminderDateTime = t?.reminderDateTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickReminderDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _reminderDateTime ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderDateTime ?? DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      _reminderDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final controller = Get.find<TaskController>();
    final id =
        widget.initialTask?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final newTask = Task(
      id: id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _dueDate,
      priority: _selectedPriority,
      isCompleted: widget.initialTask?.isCompleted ?? false,
      hasReminder: _reminderOn,
      reminderDateTime: _reminderOn ? _reminderDateTime : null,
    );

    if (widget.initialTask == null) {
      controller.addTask(newTask);
    } else {
      controller.updateTask(newTask);
    }

    if (_reminderOn && _reminderDateTime != null) {
      NotificationService.scheduleNotification(
        id: newTask.hashCode,
        title: newTask.title,
        body: newTask.description,
        scheduledTime: _reminderDateTime!,
      );
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initialTask == null ? 'Add Task' : 'Edit Task',
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Level>(
                value: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: Level.values
                    .map(
                      (lvl) => DropdownMenuItem(
                        value: lvl,
                        child: Text(lvl.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedPriority = val!),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text('Due Date: ${DateFormat.yMMMd().format(_dueDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _reminderOn,
                title: const Text('Enable Reminder'),
                onChanged: (val) => setState(() => _reminderOn = val),
              ),
              if (_reminderOn) ...[
                ListTile(
                  title: Text(
                    _reminderDateTime != null
                        ? 'Reminder: ${DateFormat.yMMMd().add_jm().format(_reminderDateTime!)}'
                        : 'Pick reminder date & time',
                  ),
                  trailing: const Icon(Icons.alarm),
                  onTap: _pickReminderDateTime,
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  widget.initialTask == null ? 'Add Task' : 'Update Task',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
