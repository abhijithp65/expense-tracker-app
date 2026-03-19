import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/constants.dart';
import '../providers/expense_provider.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final month    = DateFormat('MMMM yyyy').format(provider.selectedMonth);
    final total    = provider.monthlyTotal;
    final count    = provider.expenses.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF4B44CC)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:       const Color(0xFF6C63FF).withOpacity(0.35),
            blurRadius:  24,
            offset:      const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: provider.goToPreviousMonth,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color:        Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.chevron_left_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(month,
                      style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: provider.canGoNext ? provider.goToNextMonth : null,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color:        Colors.white
                            .withOpacity(provider.canGoNext ? 0.15 : 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.chevron_right_rounded,
                          color: Colors.white
                              .withOpacity(provider.canGoNext ? 1 : 0.3),
                          size: 20),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:        Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$count expenses',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Total Spent', style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 6),
          Text(
            '${AppConstants.currencySymbol}${NumberFormat('#,##,##0.00').format(total)}',
            style: AppTextStyles.amount.copyWith(color: Colors.white, fontSize: 36),
          ),
        ],
      ),
    );
  }
}
