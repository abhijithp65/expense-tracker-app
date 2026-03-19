import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetAllExpenses {
  final ExpenseRepository _repo;
  GetAllExpenses(this._repo);
  Future<List<Expense>> call() => _repo.getAllExpenses();
}

class GetExpensesByMonth {
  final ExpenseRepository _repo;
  GetExpensesByMonth(this._repo);
  Future<List<Expense>> call(int year, int month) =>
      _repo.getExpensesByMonth(year, month);
}

class AddExpense {
  final ExpenseRepository _repo;
  AddExpense(this._repo);
  Future<void> call(Expense expense) => _repo.addExpense(expense);
}

class UpdateExpense {
  final ExpenseRepository _repo;
  UpdateExpense(this._repo);
  Future<void> call(Expense expense) => _repo.updateExpense(expense);
}

class DeleteExpense {
  final ExpenseRepository _repo;
  DeleteExpense(this._repo);
  Future<void> call(String id) => _repo.deleteExpense(id);
}

class GetCategoryTotals {
  final ExpenseRepository _repo;
  GetCategoryTotals(this._repo);
  Future<Map<String, double>> call(int year, int month) =>
      _repo.getCategoryTotals(year, month);
}

class GetDailyTotals {
  final ExpenseRepository _repo;
  GetDailyTotals(this._repo);
  Future<Map<String, double>> call(int year, int month) =>
      _repo.getDailyTotals(year, month);
}

class GetMonthlyTotal {
  final ExpenseRepository _repo;
  GetMonthlyTotal(this._repo);
  Future<double> call(int year, int month) =>
      _repo.getMonthlyTotal(year, month);
}
