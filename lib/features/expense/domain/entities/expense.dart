import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String   id;
  final String   title;
  final double   amount;
  final String   categoryId;
  final DateTime date;
  final String?  note;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
  });

  Expense copyWith({
    String?   id,
    String?   title,
    double?   amount,
    String?   categoryId,
    DateTime? date,
    String?   note,
  }) =>
      Expense(
        id:         id         ?? this.id,
        title:      title      ?? this.title,
        amount:     amount     ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        date:       date       ?? this.date,
        note:       note       ?? this.note,
      );

  @override
  List<Object?> get props => [id, title, amount, categoryId, date, note];
}
