import 'package:flutter/material.dart';
import 'package:todo/widgets/task/add_task_modal.dart';

class TaskInputField extends StatefulWidget {
  final void Function(String title, bool isImportant, DateTime? dueDate)?
  onSubmitted;

  const TaskInputField({super.key, this.onSubmitted});

  @override
  State<TaskInputField> createState() => _TaskInputFieldState();
}

class _TaskInputFieldState extends State<TaskInputField> {
  void _openAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddTaskModal(
          onAdd: (title, isImportant, dueDate) {
            widget.onSubmitted?.call(title, isImportant, dueDate);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FloatingActionButton(
          onPressed: _openAddTaskModal,
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: Colors.black, size: 30),
        ),
      ),
    );
  }
}
