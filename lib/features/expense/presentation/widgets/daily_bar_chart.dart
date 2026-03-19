import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../providers/expense_provider.dart';

class DailyBarChart extends StatelessWidget {
  const DailyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<ExpenseProvider>();
    final dailyMap  = provider.dailyTotals;
    final month     = provider.selectedMonth;
    final maxSpend  = provider.highestDailySpend;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    final spots = List.generate(daysInMonth, (i) {
      final day = i + 1;
      final key = '${month.year}-${month.month.toString().padLeft(2,'0')}-${day.toString().padLeft(2,'0')}';
      return dailyMap[key] ?? 0.0;
    });

    if (spots.every((v) => v == 0)) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color:        AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border:       Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Text('No data this month', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border:       Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Spending', style: AppTextStyles.titleMedium),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY:          maxSpend * 1.25,
                barTouchData:  BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceLight,
                    tooltipRoundedRadius: 10,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '₹${NumberFormat('#,##0').format(rod.toY)}',
                      AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles:   const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles:  const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles:    const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval:   7,
                      getTitlesWidget: (value, _) {
                        final day = value.toInt() + 1;
                        if (day == 1 || day % 7 == 1) {
                          return Text('$day',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 10));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show:              true,
                  drawVerticalLine:  false,
                  horizontalInterval: maxSpend > 0 ? maxSpend / 4 : 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color:       AppColors.divider,
                    strokeWidth: 1,
                    dashArray:   [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups:  List.generate(spots.length, (i) {
                  final val = spots[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY:   val,
                        width: daysInMonth <= 28 ? 8 : 6,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        gradient: val > 0
                            ? const LinearGradient(
                                begin:  Alignment.bottomCenter,
                                end:    Alignment.topCenter,
                                colors: [
                                  Color(0xFF4B44CC),
                                  Color(0xFF9C94FF),
                                ],
                              )
                            : null,
                        color: val == 0 ? AppColors.divider : null,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
