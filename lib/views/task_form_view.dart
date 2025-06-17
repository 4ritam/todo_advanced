import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';

class TaskFormView extends StatefulWidget {
  const TaskFormView({super.key});

  @override
  State<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<TaskFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  Level _priority = Level.medium;

  final TaskController _taskController = Get.find();
  Task? _editingTask;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    if (arg is Task) {
      _editingTask = arg;
      _titleController.text = arg.title;
      _descriptionController.text = arg.description;
      _dueDate = arg.dueDate;
      _priority = arg.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingTask == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  'Due Date: ${_dueDate.toLocal().toString().split(" ")[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Level>(
                value: _priority,
                onChanged: (val) => setState(() => _priority = val!),
                items: Level.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level.name.toUpperCase()),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        id: _editingTask?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: _editingTask?.isCompleted ?? false,
      );

      if (_editingTask != null) {
        _taskController.updateTask(newTask);
      } else {
        _taskController.addTask(newTask);
      }

      Get.back();
    }
  }
}
