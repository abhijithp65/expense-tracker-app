import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/constants.dart';
import '../providers/expense_provider.dart';

class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({super.key});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final sorted   = provider.sortedCategoryTotals;
    final total    = provider.monthlyTotal;

    if (sorted.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color:        AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border:       Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Text('No data this month',
              style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return Container(
      padding:     const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border:       Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By Category', style: AppTextStyles.titleMedium),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 140, height: 140,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          _touched = (event.isInterestedForInteractions &&
                                  response?.touchedSection != null)
                              ? response!.touchedSection!.touchedSectionIndex
                              : -1;
                        });
                      },
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                    sections: List.generate(sorted.length, (i) {
                      final cat    = AppCategories.fromId(sorted[i].key);
                      final pct    = total > 0 ? sorted[i].value / total * 100 : 0;
                      final isTouched = i == _touched;
                      return PieChartSectionData(
                        value:         sorted[i].value,
                        color:         cat.color,
                        radius:        isTouched ? 46 : 38,
                        title:         '${pct.toStringAsFixed(0)}%',
                        titleStyle:    TextStyle(
                          fontSize:     isTouched ? 13 : 11,
                          fontWeight:   FontWeight.w700,
                          color:        Colors.white,
                        ),
                        badgeWidget:   isTouched
                            ? Text(cat.emoji,
                                style: const TextStyle(fontSize: 16))
                            : null,
                        badgePositionPercentageOffset: 1.3,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: List.generate(
                    sorted.length > 5 ? 5 : sorted.length,
                    (i) {
                      final cat = AppCategories.fromId(sorted[i].key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                color:  cat.color,
                                shape:  BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(cat.name,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(fontSize: 12),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              '${AppConstants.currencySymbol}${NumberFormat('#,##0').format(sorted[i].value)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
