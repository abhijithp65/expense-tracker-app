import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppConstants {
  AppConstants._();
  static const String dbName    = 'expenses.db';
  static const int    dbVersion = 1;
  static const String tableName = 'expenses';
  static const String currencySymbol = '₹';
}

class ExpenseCategory {
  final String id;
  final String name;
  final String emoji;
  final Color  color;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });
}

class AppCategories {
  AppCategories._();

  static const List<ExpenseCategory> all = [
    ExpenseCategory(id: 'food',          name: 'Food',          emoji: '🍔', color: Color(0xFFFF6B6B)),
    ExpenseCategory(id: 'transport',     name: 'Transport',     emoji: '🚗', color: Color(0xFF6C63FF)),
    ExpenseCategory(id: 'shopping',      name: 'Shopping',      emoji: '🛍️', color: Color(0xFFFFD93D)),
    ExpenseCategory(id: 'entertainment', name: 'Entertainment', emoji: '🎮', color: Color(0xFF4ECDC4)),
    ExpenseCategory(id: 'health',        name: 'Health',        emoji: '💊', color: Color(0xFFA8E6CF)),
    ExpenseCategory(id: 'bills',         name: 'Bills',         emoji: '💡', color: Color(0xFFFF8C42)),
    ExpenseCategory(id: 'education',     name: 'Education',     emoji: '📚', color: Color(0xFF85C1E9)),
    ExpenseCategory(id: 'other',         name: 'Other',         emoji: '📦', color: Color(0xFFFF85A1)),
  ];

  static ExpenseCategory fromId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.last);

  static Color colorAt(int index) =>
      AppColors.categoryColors[index % AppColors.categoryColors.length];
}
