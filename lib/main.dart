import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/themes/app_theme.dart';
import 'data/models/transaction_model.dart';
import 'presentation/pages/transactions/transaction_list_page.dart';
import 'core/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.init();

  runApp(const ProviderScope(child: MyApp()));
}


/// Inicialização dos serviços locais (Hive, banco, etc.)
Future<void> _initApp() async {
  try {
    await Hive.initFlutter();

    Hive.registerAdapter(TransactionModelAdapter());

    await Hive.openBox<TransactionModel>('transactions');
  } catch (e) {
    debugPrint('Erro na inicialização do Hive: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Despesas',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const TransactionListPage(),
    );
  }
}
