import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/category.dart';
import 'package:todo/data/categories.dart';

class EditTaskModal extends StatefulWidget {
  final String initialTitle;
  final DateTime? initialDate;
  final String initialCategoryId;
  final void Function(String, DateTime?, String) onSave;

  const EditTaskModal({
    super.key,
    required this.initialTitle,
    this.initialDate,
    required this.initialCategoryId,
    required this.onSave,
  });

  @override
  State<EditTaskModal> createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<EditTaskModal> {
  late TextEditingController _controller;
  DateTime? _selectedDate;
  late Category _selectedCategory;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
    _selectedDate = widget.initialDate;

    _selectedCategory = availableCategories.firstWhere(
      (cat) => cat.id == widget.initialCategoryId,
      orElse: () => availableCategories.first,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

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
              hintText: 'Edit your task...',
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
              labelText: 'Category',
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
              TextButton.icon(
                onPressed: _pickDate,
                icon: Icon(
                  Icons.calendar_today,
                  color: textColor.withOpacity(0.7),
                ),
                label: Text(
                  _selectedDate == null
                      ? 'Set date'
                      : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                  style: TextStyle(color: textColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  widget.onSave(text, _selectedDate, _selectedCategory.id);
                  Navigator.pop(context);
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
        ],
      ),
    );
  }
}
