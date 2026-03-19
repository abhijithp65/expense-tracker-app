import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/constants.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getAllExpenses();
  Future<List<ExpenseModel>> getExpensesByMonth(int year, int month);
  Future<void> insertExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<Map<String, double>> getCategoryTotals(int year, int month);
  Future<Map<String, double>> getDailyTotals(int year, int month);
  Future<double> getMonthlyTotal(int year, int month);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE ${AppConstants.tableName} (
          id          TEXT PRIMARY KEY,
          title       TEXT NOT NULL,
          amount      REAL NOT NULL,
          category_id TEXT NOT NULL,
          date        INTEGER NOT NULL,
          note        TEXT
        )
      '''),
    );
  }

  DateTime _monthStart(int year, int month) => DateTime(year, month, 1);
  DateTime _monthEnd(int year, int month)   => DateTime(year, month + 1, 1);

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    final db   = await database;
    final rows = await db.query(
      AppConstants.tableName,
      orderBy: 'date DESC',
    );
    return rows.map(ExpenseModel.fromMap).toList();
  }

  @override
  Future<List<ExpenseModel>> getExpensesByMonth(int year, int month) async {
    final db    = await database;
    final start = _monthStart(year, month).millisecondsSinceEpoch;
    final end   = _monthEnd(year, month).millisecondsSinceEpoch;
    final rows  = await db.query(
      AppConstants.tableName,
      where:     'date >= ? AND date < ?',
      whereArgs: [start, end],
      orderBy:   'date DESC',
    );
    return rows.map(ExpenseModel.fromMap).toList();
  }

  @override
  Future<void> insertExpense(ExpenseModel expense) async {
    final db = await database;
    await db.insert(
      AppConstants.tableName,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await database;
    await db.update(
      AppConstants.tableName,
      expense.toMap(),
      where:     'id = ?',
      whereArgs: [expense.id],
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.tableName,
      where:     'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Map<String, double>> getCategoryTotals(int year, int month) async {
    final db    = await database;
    final start = _monthStart(year, month).millisecondsSinceEpoch;
    final end   = _monthEnd(year, month).millisecondsSinceEpoch;
    final rows  = await db.rawQuery('''
      SELECT category_id, SUM(amount) AS total
      FROM   ${AppConstants.tableName}
      WHERE  date >= ? AND date < ?
      GROUP  BY category_id
    ''', [start, end]);
    return {
      for (final r in rows)
        r['category_id'] as String: (r['total'] as num).toDouble()
    };
  }

  @override
  Future<Map<String, double>> getDailyTotals(int year, int month) async {
    final db    = await database;
    final start = _monthStart(year, month).millisecondsSinceEpoch;
    final end   = _monthEnd(year, month).millisecondsSinceEpoch;
    final rows  = await db.rawQuery('''
      SELECT date, amount
      FROM   ${AppConstants.tableName}
      WHERE  date >= ? AND date < ?
    ''', [start, end]);

    final Map<String, double> daily = {};
    for (final r in rows) {
      final d   = DateTime.fromMillisecondsSinceEpoch(r['date'] as int);
      final key = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
      daily[key] = (daily[key] ?? 0) + (r['amount'] as num).toDouble();
    }
    return daily;
  }

  @override
  Future<double> getMonthlyTotal(int year, int month) async {
    final db    = await database;
    final start = _monthStart(year, month).millisecondsSinceEpoch;
    final end   = _monthEnd(year, month).millisecondsSinceEpoch;
    final rows  = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM   ${AppConstants.tableName}
      WHERE  date >= ? AND date < ?
    ''', [start, end]);
    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }
}
