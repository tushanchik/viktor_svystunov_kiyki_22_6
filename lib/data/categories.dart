import 'package:flutter/material.dart';
import 'package:todo/models/category.dart';

const availableCategories = [
  Category(id: 'c1', title: 'Work', color: Color(0xFF0D47A1), icon: Icons.work),
  Category(id: 'c2', title: 'Home', color: Color(0xFF1B5E20), icon: Icons.home),
  Category(
    id: 'c3',
    title: 'Study',
    color: Color(0xFFE65100),
    icon: Icons.school,
  ),
  Category(
    id: 'c4',
    title: 'Personal',
    color: Color(0xFF4A148C),
    icon: Icons.person,
  ),
];
