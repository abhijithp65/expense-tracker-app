import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/expense_usecases.dart';

enum ExpenseStatus { initial, loading, loaded, error }

class ExpenseProvider extends ChangeNotifier {
  final GetExpensesByMonth   _getByMonth;
  final AddExpense           _add;
  final UpdateExpense        _update;
  final DeleteExpense        _delete;
  final GetCategoryTotals    _getCategoryTotals;
  final GetDailyTotals       _getDailyTotals;
  final GetMonthlyTotal      _getMonthlyTotal;

  ExpenseProvider({
    required GetAllExpenses       getAll,
    required GetExpensesByMonth   getByMonth,
    required AddExpense           add,
    required UpdateExpense        update,
    required DeleteExpense        delete,
    required GetCategoryTotals    getCategoryTotals,
    required GetDailyTotals       getDailyTotals,
    required GetMonthlyTotal      getMonthlyTotal,
  })  : _getByMonth         = getByMonth,
        _add                = add,
        _update             = update,
        _delete             = delete,
        _getCategoryTotals  = getCategoryTotals,
        _getDailyTotals     = getDailyTotals,
        _getMonthlyTotal    = getMonthlyTotal;

  ExpenseStatus _status       = ExpenseStatus.initial;
  String?       _errorMessage;
  List<Expense> _expenses     = [];
  Map<String, double> _categoryTotals = {};
  Map<String, double> _dailyTotals    = {};
  double        _monthlyTotal = 0;
  DateTime      _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  ExpenseStatus       get status        => _status;
  String?             get errorMessage  => _errorMessage;
  List<Expense>       get expenses      => List.unmodifiable(_expenses);
  Map<String, double> get categoryTotals => Map.unmodifiable(_categoryTotals);
  Map<String, double> get dailyTotals    => Map.unmodifiable(_dailyTotals);
  double              get monthlyTotal  => _monthlyTotal;
  DateTime            get selectedMonth => _selectedMonth;

  List<Expense> get recentExpenses => _expenses.take(5).toList();

  Future<void> loadMonth([DateTime? month]) async {
    _selectedMonth = month ?? _selectedMonth;
    _status        = ExpenseStatus.loading;
    notifyListeners();
    try {
      final y = _selectedMonth.year;
      final m = _selectedMonth.month;
      _expenses       = await _getByMonth(y, m);
      _categoryTotals = await _getCategoryTotals(y, m);
      _dailyTotals    = await _getDailyTotals(y, m);
      _monthlyTotal   = await _getMonthlyTotal(y, m);
      _status         = ExpenseStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = ExpenseStatus.error;
    }
    notifyListeners();
  }

  Future<void> addExpense({
    required String   title,
    required double   amount,
    required String   categoryId,
    required DateTime date,
    String?           note,
  }) async {
    final expense = Expense(
      id:         const Uuid().v4(),
      title:      title,
      amount:     amount,
      categoryId: categoryId,
      date:       date,
      note:       note,
    );
    await _add(expense);
    await loadMonth();
  }

  Future<void> updateExpense(Expense expense) async {
    await _update(expense);
    await loadMonth();
  }

  Future<void> deleteExpense(String id) async {
    await _delete(id);
    await loadMonth();
  }

  void goToPreviousMonth() {
    final d = _selectedMonth;
    loadMonth(DateTime(d.year, d.month - 1));
  }

  void goToNextMonth() {
    final d   = _selectedMonth;
    final now = DateTime.now();
    final next = DateTime(d.year, d.month + 1);
    if (next.isBefore(DateTime(now.year, now.month + 1))) {
      loadMonth(next);
    }
  }

  bool get canGoNext {
    final now  = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    return next.isBefore(DateTime(now.year, now.month + 1));
  }

  List<MapEntry<String, double>> get sortedCategoryTotals {
    final entries = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  double get highestDailySpend =>
      _dailyTotals.values.isEmpty ? 0 : _dailyTotals.values.reduce((a, b) => a > b ? a : b);
}
