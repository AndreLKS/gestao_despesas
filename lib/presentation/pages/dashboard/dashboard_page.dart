import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transaction_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);

    final receita = transactions
        .where((e) => e.type == 'receita')
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final despesa = transactions
        .where((e) => e.type == 'despesa')
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final saldo = receita - despesa;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Saldo Atual'),
                subtitle: Text('R\$ ${saldo.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Resumo do Mês',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.red,
                      value: despesa,
                      title: 'Despesas',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: receita,
                      title: 'Receitas',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
