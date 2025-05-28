import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionLocalDatasource {
  final Box<TransactionModel> box;

  TransactionLocalDatasource(this.box);

  List<TransactionModel> getAll() {
    return box.values.toList();
  }

  Future<void> add(TransactionModel model) async {
    await box.put(model.id, model);
  }

  Future<void> delete(String id) async {
    await box.delete(id);
  }

  Future<void> update(TransactionModel model) async {
    await box.put(model.id, model);
  }
}
