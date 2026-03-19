import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<List<Expense>> getExpensesByMonth(int year, int month);
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<Map<String, double>> getCategoryTotals(int year, int month);
  Future<Map<String, double>> getDailyTotals(int year, int month);
  Future<double> getMonthlyTotal(int year, int month);
}
