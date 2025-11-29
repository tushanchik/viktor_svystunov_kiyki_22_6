import 'package:flutter/material.dart';
import 'package:todo/data/categories.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/category_item.dart';

class CategoriesScreen extends StatelessWidget {
  final List<Task> activeTasks;

  const CategoriesScreen({super.key, required this.activeTasks});

  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      children: availableCategories.map((category) {
        final activeCount = activeTasks
            .where((task) => task.categoryId == category.id && !task.isDone)
            .length;

        final completedCount = activeTasks
            .where((task) => task.categoryId == category.id && task.isDone)
            .length;

        return CategoryItem(
          category: category,
          activeCount: activeCount,
          completedCount: completedCount,
        );
      }).toList(),
    );
  }
}
