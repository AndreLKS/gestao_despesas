import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_despesas/presentation/pages/transactions/transaction_list_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/transaction_model.dart';
import 'presentation/pages/transactions/transaction_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  await Hive.openBox<TransactionModel>('transactions');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Despesas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TransactionListPage(),
    );
  }
}
