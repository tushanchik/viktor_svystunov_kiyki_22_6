import 'package:flutter/material.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/Task/task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final void Function(int) onToggle;
  final void Function(int) onImportant;
  final void Function(int) onDelete;
  final void Function(int, String, DateTime?) onEdit;
  final void Function(int, Task) onUndo;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onImportant,
    required this.onDelete,
    required this.onEdit,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'No tasks yet',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          index: index,
          onToggle: onToggle,
          onImportant: onImportant,
          onDelete: onDelete,
          onEdit: onEdit,
          onUndo: onUndo,
        );
      },
    );
  }
}
