import 'package:flutter/material.dart';
import 'package:todo/models/category.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final int activeCount;
  final int completedCount;

  const CategoryItem({
    super.key,
    required this.category,
    required this.activeCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            category.color.withOpacity(0.55),
            category.color.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Active: $activeCount',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          Text(
            'Completed: $completedCount',
            style: GoogleFonts.lato(color: Colors.white70, fontSize: 12),
          ),

          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(category.icon, size: 30, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
