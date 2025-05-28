import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/transaction_model.dart';

class AppInitializer {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TransactionModelAdapter());

    await Hive.openBox<TransactionModel>('transactions');
  }
}
