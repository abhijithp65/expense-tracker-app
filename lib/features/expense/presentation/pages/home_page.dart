import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../providers/expense_provider.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/monthly_summary_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context:          context,
      isScrollControlled: true,
      useSafeArea:      true,
      backgroundColor:  Colors.transparent,
      builder:          (_) => const AddExpenseSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadMonth(),
          color:     AppColors.primary,
          backgroundColor: AppColors.cardBg,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Expenses',
                              style: AppTextStyles.displayMedium),
                          const SizedBox(height: 2),
                          Text('Track your spending',
                              style: AppTextStyles.bodyMedium),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _openAddSheet(context),
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color:        AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:      AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset:     const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 26),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: MonthlySummaryCard(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent', style: AppTextStyles.titleMedium),
                      if (provider.expenses.isNotEmpty)
                        Text('${provider.expenses.length} total',
                            style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ),

              if (provider.status == ExpenseStatus.loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2),
                  ),
                )
              else if (provider.expenses.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💸',
                            style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text('No expenses yet',
                            style: AppTextStyles.titleMedium),
                        const SizedBox(height: 6),
                        Text('Tap + to add your first expense',
                            style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final expense = provider.expenses[i];
                        return ExpenseListTile(
                          expense:  expense,
                          onDelete: () => provider.deleteExpense(expense.id),
                          onTap: () => showModalBottomSheet(
                            context:            ctx,
                            isScrollControlled: true,
                            useSafeArea:        true,
                            backgroundColor:    Colors.transparent,
                            builder: (_) => AddExpenseSheet(existing: expense),
                          ),
                        );
                      },
                      childCount: provider.expenses.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
