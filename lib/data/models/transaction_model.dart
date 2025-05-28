import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel {
  final String id;
  final String title;
  final String category;
  final String type; // 'receita' ou 'despesa'
  final double amount;
  final DateTime date;
  final bool isRecurring; // Se é uma conta recorrente
  final String? recurrence; // 'mensal', 'semanal', 'anual', etc.

  TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.amount,
    required this.date,
    this.isRecurring = false,
    this.recurrence,
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    String? category,
    String? type,
    double? amount,
    DateTime? date,
    bool? isRecurring,
    String? recurrence,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrence: recurrence ?? this.recurrence,
    );
  }
}
