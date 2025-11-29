import 'package:flutter/material.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/Task/task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final void Function(int) onToggle;
  final void Function(int) onImportant;
  final void Function(int) onDelete;
  final void Function(int, String, DateTime?, String) onEdit;
  final void Function(int, Task) onUndo;
  final bool isCompletedOpen;
  final VoidCallback onToggleCompleted;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onImportant,
    required this.onDelete,
    required this.onEdit,
    required this.onUndo,
    required this.isCompletedOpen,
    required this.onToggleCompleted,
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

    final activeTasks = tasks.where((t) => !t.isDone).toList();
    final completedTasks = tasks.where((t) => t.isDone).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        ...activeTasks.map((task) {
          final originalIndex = tasks.indexOf(task);
          return TaskCard(
            task: task,
            index: originalIndex,
            onToggle: onToggle,
            onImportant: onImportant,
            onDelete: onDelete,
            onEdit: onEdit,
            onUndo: onUndo,
          );
        }),

        if (completedTasks.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onToggleCompleted,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Completed (${completedTasks.length})',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isCompletedOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (isCompletedOpen)
            ...completedTasks.map((task) {
              final originalIndex = tasks.indexOf(task);
              return TaskCard(
                task: task,
                index: originalIndex,
                onToggle: onToggle,
                onImportant: onImportant,
                onDelete: onDelete,
                onEdit: onEdit,
                onUndo: onUndo,
              );
            }),
        ],
      ],
    );
  }
}
