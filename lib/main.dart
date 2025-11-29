import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/models/task.dart';
import 'package:todo/pages/categories_screen.dart';
import 'package:todo/widgets/task_list.dart';
import 'package:todo/widgets/Task/add_task_modal.dart';
import 'package:todo/widgets/menu/app_menu_button.dart';
import 'package:todo/widgets/menu/wallpaper_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode');
    setState(() {
      if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
      _isLoaded = true;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
    await prefs.setString(
      'themeMode',
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const SizedBox();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white70,
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        cardColor: const Color(0xFF1E1E1E),
        dialogBackgroundColor: const Color(0xFF1E1E1E),
        textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black54,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      home: TabsScreen(onThemeChanged: _toggleTheme),
    );
  }
}

class TabsScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const TabsScreen({super.key, required this.onThemeChanged});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Task> _tasks = [];
  Task? _recentlyDeletedTask;
  int? _recentlyDeletedIndex;
  bool _isCompletedOpen = false;
  String? _backgroundImage;
  Color? _backgroundColor = const Color.fromARGB(255, 0, 0, 0);

  final List<String> _wallpaperAssets = [
    'assets/backgrounds/back1.jpg',
    'assets/backgrounds/back2.jpg',
    'assets/backgrounds/back3.jpg',
    'assets/backgrounds/back4.jpg',
    'assets/backgrounds/back5.jpg',
  ];

  final List<Color> _solidColors = [
    const Color.fromARGB(255, 255, 255, 255),
    const Color.fromARGB(255, 30, 30, 30),
    const Color.fromARGB(255, 0, 0, 0),
    const Color.fromARGB(255, 99, 149, 224),
    const Color.fromARGB(255, 100, 234, 143),
    const Color.fromARGB(255, 151, 93, 221),
    const Color.fromARGB(255, 241, 108, 108),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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

    final savedImage = prefs.getString('backgroundImage');
    final savedColor = prefs.getInt('backgroundColor');

    setState(() {
      if (savedImage != null) {
        _backgroundImage = savedImage;
        _backgroundColor = null;
      } else if (savedColor != null) {
        _backgroundColor = Color(savedColor);
        _backgroundImage = null;
      }
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _tasks.map((t) => t.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(jsonList));
  }

  Future<void> _saveWallpaperSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_backgroundImage != null) {
      await prefs.setString('backgroundImage', _backgroundImage!);
      await prefs.remove('backgroundColor');
    } else if (_backgroundColor != null) {
      await prefs.setInt('backgroundColor', _backgroundColor!.value);
      await prefs.remove('backgroundImage');
    }
  }

  void _addTask(
    String title,
    bool isImportant,
    DateTime? dueDate,
    String categoryId,
  ) {
    if (title.trim().isEmpty) return;
    setState(() {
      _tasks.add(
        Task(
          title: title,
          isStarred: isImportant,
          dueDate: dueDate,
          categoryId: categoryId,
        ),
      );
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

  void _editTask(
    int index,
    String newTitle,
    DateTime? newDate,
    String newCategoryId,
  ) {
    setState(() {
      _tasks[index].title = newTitle;
      _tasks[index].dueDate = newDate;
      _tasks[index].categoryId = newCategoryId;
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task deleted',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).cardColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: isDark ? Colors.white : Colors.black,
          onPressed: _undoDelete,
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

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _openAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskModal(onAdd: _addTask),
    );
  }

  void _openWallpaperPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return WallpaperPicker(
          wallpaperAssets: _wallpaperAssets,
          solidColors: _solidColors,
          currentImage: _backgroundImage,
          currentColor: _backgroundColor,
          onImageSelected: (image) {
            setState(() {
              _backgroundImage = image;
              _backgroundColor = null;
            });
            _saveWallpaperSettings();
          },
          onColorSelected: (color) {
            setState(() {
              _backgroundColor = color;
              _backgroundImage = null;
            });
            _saveWallpaperSettings();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = CategoriesScreen(activeTasks: _tasks);
    String activePageTitle = 'Categories';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedPageIndex == 1) {
      activePageTitle = 'Your Tasks';
      activePage = Column(
        children: [
          Expanded(
            child: TaskList(
              tasks: _tasks,
              onToggle: _toggleTask,
              onImportant: _toggleStar,
              onDelete: _deleteTask,
              onEdit: _editTask,
              onUndo: (i, t) => _undoDelete(),
              isCompletedOpen: _isCompletedOpen,
              onToggleCompleted: () {
                setState(() {
                  _isCompletedOpen = !_isCompletedOpen;
                });
              },
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor ?? Colors.black,
        image: _backgroundImage != null
            ? DecorationImage(
                image: AssetImage(_backgroundImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(activePageTitle),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          actions: [
            AppMenuButton(
              onWallpaperTap: _openWallpaperPicker,
              onThemeTap: widget.onThemeChanged,
            ),
            if (_selectedPageIndex == 1)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _openAddTaskModal,
              ),
          ],
        ),
        body: activePage,
        bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          currentIndex: _selectedPageIndex,
          backgroundColor: isDark ? Colors.black87 : Colors.white70,
          selectedItemColor: isDark ? Colors.white : Colors.black,
          unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Categories',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
          ],
        ),
      ),
    );
  }
}
