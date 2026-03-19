import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/constants.dart';
import '../../domain/entities/expense.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense       expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cat  = AppCategories.fromId(expense.categoryId);
    final date = DateFormat('d MMM, hh:mm a').format(expense.date);

    return Dismissible(
      key:       ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding:   const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color:        AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin:  const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color:        cat.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(cat.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:        cat.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(cat.name,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: cat.color, fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        Text(date,
                            style: AppTextStyles.bodySmall
                                .copyWith(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${NumberFormat('#,##,##0.00').format(expense.amount)}',
                style: AppTextStyles.amountSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
