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
  }

  final Box<TransactionModel> _box = Hive.box('transactions');

  void loadTransactions() {
    state = _box.values.toList();
  }

  void add(TransactionModel transaction) {
    _box.put(transaction.id, transaction);
    state = _box.values.toList();
  }

  void delete(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  void update(TransactionModel transaction) {
    _box.put(transaction.id, transaction);
    state = _box.values.toList();
  }
}
