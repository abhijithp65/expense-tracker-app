import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/constants.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/daily_bar_chart.dart';
import '../widgets/monthly_summary_card.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final sorted   = provider.sortedCategoryTotals;
    final total    = provider.monthlyTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text('Statistics', style: AppTextStyles.displayMedium),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: MonthlySummaryCard(),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: DailyBarChart(),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: CategoryPieChart(),
              ),
            ),

            if (sorted.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text('Category Breakdown',
                      style: AppTextStyles.titleMedium),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final cat   = AppCategories.fromId(sorted[i].key);
                      final amt   = sorted[i].value;
                      final pct   = total > 0 ? amt / total : 0.0;
                      return Container(
                        margin:  const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:        AppColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color:        cat.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(cat.emoji,
                                        style: const TextStyle(fontSize: 20)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(cat.name,
                                          style: AppTextStyles.titleMedium),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${(pct * 100).toStringAsFixed(1)}% of total',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${AppConstants.currencySymbol}${NumberFormat('#,##,##0.00').format(amt)}',
                                  style: AppTextStyles.amountSmall.copyWith(
                                    color: cat.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value:            pct,
                                minHeight:        6,
                                backgroundColor:  cat.color.withOpacity(0.12),
                                valueColor:       AlwaysStoppedAnimation<Color>(cat.color),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: sorted.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
