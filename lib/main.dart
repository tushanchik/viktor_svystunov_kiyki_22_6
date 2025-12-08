import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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
      _themeMode = savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
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
  final Uri _url = Uri.https(
    'tasks-2a458-default-rtdb.firebaseio.com',
    'tasks.json',
  );

  int _selectedPageIndex = 0;
  List<Task> _tasks = [];
  bool _isCompletedOpen = false;

  bool _isLoading = true;
  String? _error;

  String? _backgroundImage;
  Color? _backgroundColor = const Color.fromARGB(255, 30, 30, 30);

  final List<String> _wallpaperAssets = [
    'assets/backgrounds/back1.jpg',
    'assets/backgrounds/back2.jpg',
    'assets/backgrounds/back3.jpg',
    'assets/backgrounds/back4.jpg',
    'assets/backgrounds/back5.jpg',
  ];

  final List<Color> _solidColors = [
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
    _loadWallpaperSettings();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(_url);

      if (response.statusCode == 200) {
        if (response.body == 'null') {
          setState(() {
            _tasks = [];
            _isLoading = false;
          });
          return;
        }

        final Map<String, dynamic> listData = json.decode(response.body);
        final List<Task> loadedTasks = [];

        listData.forEach((id, data) {
          loadedTasks.add(Task.fromJson(data, id));
        });

        setState(() {
          _tasks = loadedTasks;
          _isLoading = false;
        });
        _sortTasks();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again later.';
        _isLoading = false;
      });
    }
  }

  void _addTask(
    String title,
    bool isImportant,
    DateTime? dueDate,
    String categoryId,
  ) async {
    if (title.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        _url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'isDone': false,
          'isStarred': isImportant,
          'dueDate': dueDate?.toIso8601String(),
          'categoryId': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = json.decode(response.body);

        setState(() {
          _tasks.add(
            Task(
              id: resData['name'],
              title: title,
              isStarred: isImportant,
              dueDate: dueDate,
              categoryId: categoryId,
            ),
          );
          _isLoading = false;
        });
        _sortTasks();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to add task';
        _isLoading = false;
      });
    }
  }

  void _deleteTask(int index) {
    final taskToDelete = _tasks[index];

    setState(() {
      _tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(
              'Task deleted',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            backgroundColor: Theme.of(context).cardColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: isDark ? Colors.white : Colors.black,
              onPressed: () {
                setState(() {
                  _tasks.insert(index, taskToDelete);
                });
              },
            ),
          ),
        )
        .closed
        .then((reason) {
          if (reason != SnackBarClosedReason.action) {
            final url = Uri.https(
              'tasks-2a458-default-rtdb.firebaseio.com',
              'tasks/${taskToDelete.id}.json',
            );

            http.delete(url).then((response) {
              if (response.statusCode >= 400) {}
            });
          }
        });
  }

  void _updateTask(int index, Map<String, dynamic> updates) async {
    setState(() {});

    final task = _tasks[index];
    final url = Uri.https(
      'tasks-2a458-default-rtdb.firebaseio.com',
      'tasks/${task.id}.json',
    );

    try {
      await http.patch(url, body: json.encode(updates));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to sync changes')));
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
      if (_tasks[index].isDone) _tasks[index].isStarred = false;
      _sortTasks();
    });
    _updateTask(index, {
      'isDone': _tasks[index].isDone,
      'isStarred': _tasks[index].isStarred,
    });
  }

  void _toggleStar(int index) {
    setState(() {
      if (!_tasks[index].isDone) {
        _tasks[index].isStarred = !_tasks[index].isStarred;
      }
      _sortTasks();
    });
    _updateTask(index, {'isStarred': _tasks[index].isStarred});
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
    _updateTask(index, {
      'title': newTitle,
      'dueDate': newDate?.toIso8601String(),
      'categoryId': newCategoryId,
    });
  }

  Future<void> _loadWallpaperSettings() async {
    final prefs = await SharedPreferences.getInstance();
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
      if (_isLoading) {
        activePage = const Center(child: CircularProgressIndicator());
      } else if (_error != null) {
        activePage = Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        );
      } else {
        activePage = Column(
          children: [
            Expanded(
              child: TaskList(
                tasks: _tasks,
                onToggle: _toggleTask,
                onImportant: _toggleStar,
                onDelete: _deleteTask,
                onEdit: _editTask,
                onUndo: (i, t) {},
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
