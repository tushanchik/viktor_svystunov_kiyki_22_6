import 'package:flutter/material.dart';

class AddTaskModal extends StatefulWidget {
  final void Function(String title, bool isImportant, DateTime? dueDate) onAdd;

  const AddTaskModal({super.key, required this.onAdd});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _controller = TextEditingController();
  DateTime? _dueDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            cursorColor: Colors.black,
            style: const TextStyle(color: Colors.black, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Enter task title',
              hintStyle: const TextStyle(
                color: Color.fromARGB(179, 109, 109, 109),
              ),
              filled: true,
              fillColor: const Color.fromRGBO(255, 255, 255, 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 49, 49, 49),
                  width: 2,
                ),
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
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
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
                    widget.onAdd(title, false, _dueDate);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
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
