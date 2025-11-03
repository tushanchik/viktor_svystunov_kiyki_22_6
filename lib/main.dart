import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/task.dart';
import 'package:todo/pages/task_page.dart';
import 'package:todo/widgets/module_window.dart';
import 'package:todo/widgets/task_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final List<Task> _tasks = [];
  Task? _recentlyDeletedTask;
  int? _recentlyDeletedIndex;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        _tasks.clear();
        _tasks.addAll(jsonList.map((e) => Task.fromJson(e)).toList());
        _sortTasks();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _tasks.map((t) => t.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(jsonList));
  }

  void _addTask(String title, bool isImportant, DateTime? dueDate) {
    if (title.trim().isEmpty) return;
    setState(() {
      _tasks.add(Task(title: title, isStarred: isImportant, dueDate: dueDate));
      _sortTasks();
    });
    _saveTasks();
  }

  void _toggleTask(int index) {
    setState(() {
      final task = _tasks[index];
      task.isDone = !task.isDone;
      if (task.isDone) task.isStarred = false;
      _sortTasks();
    });
    _saveTasks();
  }

  void _toggleStar(int index) {
    setState(() {
      final task = _tasks[index];
      if (!task.isDone) task.isStarred = !task.isStarred;
      _sortTasks();
    });
    _saveTasks();
  }

  void _editTask(int index, String newTitle, DateTime? newDate) {
    setState(() {
      _tasks[index].title = newTitle;
      _tasks[index].dueDate = newDate;
      _sortTasks();
    });
    _saveTasks();
  }

  void _undoDelete() {
    if (_recentlyDeletedTask != null && _recentlyDeletedIndex != null) {
      setState(() {
        _tasks.insert(_recentlyDeletedIndex!, _recentlyDeletedTask!);
        _sortTasks();
      });
      _saveTasks();
      _recentlyDeletedTask = null;
      _recentlyDeletedIndex = null;
    }
  }

  void _deleteTask(int index) {
    setState(() {
      _recentlyDeletedTask = _tasks[index];
      _recentlyDeletedIndex = index;
      _tasks.removeAt(index);
    });
    _saveTasks();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Row(
          children: [
            const Icon(Icons.delete, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Task deleted',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.black,
          onPressed: () {
            _undoDelete();
          },
        ),
      ),
    );
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      if (!a.isDone && !b.isDone && a.isStarred != b.isStarred) {
        return a.isStarred ? -1 : 1;
      }
      return 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const TaskPage(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: TaskList(
                    tasks: _tasks,
                    onToggle: _toggleTask,
                    onImportant: _toggleStar,
                    onDelete: _deleteTask,
                    onEdit: _editTask,
                    onUndo: (index, task) {
                      _undoDelete();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: TaskInputField(onSubmitted: _addTask),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
