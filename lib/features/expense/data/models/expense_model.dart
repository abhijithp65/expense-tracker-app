import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.categoryId,
    required super.date,
    super.note,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
        id:         map['id']          as String,
        title:      map['title']       as String,
        amount:     (map['amount']     as num).toDouble(),
        categoryId: map['category_id'] as String,
        date:       DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
        note:       map['note']        as String?,
      );

  Map<String, dynamic> toMap() => {
        'id':          id,
        'title':       title,
        'amount':      amount,
        'category_id': categoryId,
        'date':        date.millisecondsSinceEpoch,
        'note':        note,
      };

  factory ExpenseModel.fromEntity(Expense e) => ExpenseModel(
        id:         e.id,
        title:      e.title,
        amount:     e.amount,
        categoryId: e.categoryId,
        date:       e.date,
        note:       e.note,
      );
}
