import 'package:flutter/material.dart';
import 'package:todo/models/category.dart';
import 'package:todo/data/categories.dart';

class AddTaskModal extends StatefulWidget {
  final void Function(
    String title,
    bool isImportant,
    DateTime? dueDate,
    String categoryId,
  )
  onAdd;

  const AddTaskModal({super.key, required this.onAdd});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _controller = TextEditingController();
  DateTime? _dueDate;
  Category _selectedCategory = availableCategories.last;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final inputFill = isDark ? Colors.white10 : Colors.black12;

    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            cursorColor: textColor,
            style: TextStyle(color: textColor, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Enter task title',
              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              filled: true,
              fillColor: inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),

          DropdownButtonFormField<Category>(
            value: _selectedCategory,
            dropdownColor: Theme.of(context).cardColor,
            items: availableCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(category.icon, color: category.color),
                    const SizedBox(width: 10),
                    Text(category.title, style: TextStyle(color: textColor)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategory = value);
            },
            decoration: InputDecoration(
              labelText: 'Select Category',
              labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              filled: true,
              fillColor: inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? now,
                    firstDate: now,
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(data: Theme.of(context), child: child!);
                    },
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _dueDate == null
                      ? 'Set due date'
                      : 'Due: ${_dueDate!.day.toString().padLeft(2, '0')}.${_dueDate!.month.toString().padLeft(2, '0')}.${_dueDate!.year}',
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  final title = _controller.text.trim();
                  if (title.isNotEmpty) {
                    widget.onAdd(title, false, _dueDate, _selectedCategory.id);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
