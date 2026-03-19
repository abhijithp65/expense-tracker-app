import 'features/expense/data/datasources/expense_local_datasource.dart';
import 'features/expense/data/repositories/expense_repository_impl.dart';
import 'features/expense/domain/repositories/expense_repository.dart';
import 'features/expense/domain/usecases/expense_usecases.dart';
import 'features/expense/presentation/providers/expense_provider.dart';

class AppDependencies {
  AppDependencies._();

  static ExpenseProvider buildExpenseProvider() {
    final dataSource = ExpenseLocalDataSourceImpl();
    final repository = ExpenseRepositoryImpl(dataSource) as ExpenseRepository;

    return ExpenseProvider(
      getAll:            GetAllExpenses(repository),
      getByMonth:        GetExpensesByMonth(repository),
      add:               AddExpense(repository),
      update:            UpdateExpense(repository),
      delete:            DeleteExpense(repository),
      getCategoryTotals: GetCategoryTotals(repository),
      getDailyTotals:    GetDailyTotals(repository),
      getMonthlyTotal:   GetMonthlyTotal(repository),
    );
  }
}
