import 'package:flutter/material.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/task/edit_task_modal.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final int index;
  final void Function(int) onToggle;
  final void Function(int) onImportant;
  final void Function(int) onDelete;
  final void Function(int, String, DateTime?) onEdit;
  final void Function(int, Task) onUndo;

  const TaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onToggle,
    required this.onImportant,
    required this.onDelete,
    required this.onEdit,
    required this.onUndo,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  void _openEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => EditTaskModal(
        initialTitle: task.title,
        initialDate: task.dueDate,
        onSave: (newTitle, newDate) {
          onEdit(index, newTitle, newDate);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.title + task.hashCode.toString()),
      direction: DismissDirection.endToStart,

      background: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
      ),
      onDismissed: (direction) {
        onDelete(index);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openEditModal(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: task.isDone,
                      onChanged: (_) => onToggle(index),
                    ),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          color: task.isDone ? Colors.grey : Colors.black,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontSize: 18,
                          height: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        task.isStarred ? Icons.star : Icons.star_border,
                        color: task.isStarred ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () => onImportant(index),
                    ),
                  ],
                ),
                if (task.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 50, top: 1),
                    child: Text(
                      'Due: ${_formatDate(task.dueDate!)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
