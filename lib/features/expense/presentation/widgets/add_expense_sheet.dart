import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/constants.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? existing;
  const AddExpenseSheet({super.key, this.existing});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey      = GlobalKey<FormState>();
  final _titleCtrl    = TextEditingController();
  final _amountCtrl   = TextEditingController();
  final _noteCtrl     = TextEditingController();

  String   _categoryId = AppCategories.all.first.id;
  DateTime _date       = DateTime.now();
  bool     _saving     = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e       = widget.existing!;
      _titleCtrl.text  = e.title;
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _noteCtrl.text   = e.note ?? '';
      _categoryId      = e.categoryId;
      _date            = e.date;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:      context,
      initialDate:  _date,
      firstDate:    DateTime(2020),
      lastDate:     DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary:   AppColors.primary,
            onPrimary: Colors.white,
            surface:   AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<ExpenseProvider>();
    final amount   = double.parse(_amountCtrl.text.replaceAll(',', ''));

    if (_isEditing) {
      await provider.updateExpense(widget.existing!.copyWith(
        title:      _titleCtrl.text.trim(),
        amount:     amount,
        categoryId: _categoryId,
        date:       _date,
        note:       _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ));
    } else {
      await provider.addExpense(
        title:      _titleCtrl.text.trim(),
        amount:     amount,
        categoryId: _categoryId,
        date:       _date,
        note:       _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color:        AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(_isEditing ? 'Edit Expense' : 'Add Expense',
                  style: AppTextStyles.titleLarge),
              const SizedBox(height: 24),

              _FieldLabel('Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                style:      AppTextStyles.bodyLarge,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'e.g. Lunch, Uber...'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title required' : null,
              ),
              const SizedBox(height: 16),

              _FieldLabel('Amount (${AppConstants.currencySymbol})'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountCtrl,
                style:      AppTextStyles.bodyLarge,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(hintText: '0.00'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Amount required';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _FieldLabel('Category'),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount:       AppCategories.all.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final cat      = AppCategories.all[i];
                    final selected = cat.id == _categoryId;
                    return GestureDetector(
                      onTap: () => setState(() => _categoryId = cat.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color:        selected
                              ? cat.color
                              : cat.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? cat.color : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(cat.emoji,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(cat.name,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : cat.color,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              _FieldLabel('Date'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color:        AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border:       Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 12),
                      Text(DateFormat('EEEE, d MMM yyyy').format(_date),
                          style: AppTextStyles.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _FieldLabel('Note (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteCtrl,
                style:      AppTextStyles.bodyLarge,
                maxLines:   2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Add a note...'),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width:  double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isEditing ? 'Update Expense' : 'Add Expense',
                          style: AppTextStyles.labelLarge
                              .copyWith(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5));
}
