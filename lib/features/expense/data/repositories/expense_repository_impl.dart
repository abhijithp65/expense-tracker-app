import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _local;
  ExpenseRepositoryImpl(this._local);

  @override
  Future<List<Expense>> getAllExpenses() => _local.getAllExpenses();

  @override
  Future<List<Expense>> getExpensesByMonth(int year, int month) =>
      _local.getExpensesByMonth(year, month);

  @override
  Future<void> addExpense(Expense expense) =>
      _local.insertExpense(ExpenseModel.fromEntity(expense));

  @override
  Future<void> updateExpense(Expense expense) =>
      _local.updateExpense(ExpenseModel.fromEntity(expense));

  @override
  Future<void> deleteExpense(String id) => _local.deleteExpense(id);

  @override
  Future<Map<String, double>> getCategoryTotals(int year, int month) =>
      _local.getCategoryTotals(year, month);

  @override
  Future<Map<String, double>> getDailyTotals(int year, int month) =>
      _local.getDailyTotals(year, month);

  @override
  Future<double> getMonthlyTotal(int year, int month) =>
      _local.getMonthlyTotal(year, month);
}
