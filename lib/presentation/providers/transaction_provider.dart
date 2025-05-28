import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/transaction_model.dart';

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>(
  (ref) => TransactionNotifier(),
);

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]) {
    loadTransactions();
    generateRecurringTransactions();
  }

  final Box<TransactionModel> _box = Hive.box('transactions');

  /// Carrega transações do Hive
  void loadTransactions() {
    state = _box.values.toList();
  }

  /// Adiciona uma transação
  void add(TransactionModel transaction) {
    _box.put(transaction.id, transaction);
    state = _box.values.toList();
  }

  /// Remove uma transação
  void delete(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  /// Atualiza uma transação
  void update(TransactionModel transaction) {
    _box.put(transaction.id, transaction);
    state = _box.values.toList();
  }

  /// Gera transações recorrentes automaticamente
  void generateRecurringTransactions() {
    final now = DateTime.now();
    final existing = _box.values.toList();

    for (final tx in existing) {
      if (tx.isRecurring && tx.recurrence != null) {
        final lastTransaction = existing
            .where((t) =>
                t.title == tx.title &&
                t.isRecurring &&
                t.recurrence == tx.recurrence)
            .fold<DateTime?>(null, (prev, t) {
          if (prev == null) return t.date;
          return t.date.isAfter(prev) ? t.date : prev;
        });

        bool shouldCreate = false;
        DateTime newDate = now;

        switch (tx.recurrence) {
          case 'mensal':
            final targetDate =
                DateTime(now.year, now.month, tx.date.day);
            shouldCreate = lastTransaction == null ||
                (lastTransaction.month != now.month ||
                    lastTransaction.year != now.year);
            newDate = targetDate;
            break;
          case 'semanal':
            final daysDiff =
                now.difference(lastTransaction ?? tx.date).inDays;
            shouldCreate = daysDiff >= 7;
            newDate = now;
            break;
          case 'anual':
            final targetDate =
                DateTime(now.year, tx.date.month, tx.date.day);
            shouldCreate = lastTransaction == null ||
                lastTransaction.year != now.year;
            newDate = targetDate;
            break;
          default:
            shouldCreate = false;
            break;
        }

        if (shouldCreate) {
          final newTx = tx.copyWith(
            id: UniqueKey().toString(),
            date: newDate,
          );
          _box.put(newTx.id, newTx);
        }
      }
    }

    state = _box.values.toList();
  }
}
