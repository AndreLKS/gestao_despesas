import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transaction_provider.dart';

enum PeriodFilter { today, week, month, all }

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  PeriodFilter _selectedPeriod = PeriodFilter.all;

  bool _filterByPeriod(DateTime date) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case PeriodFilter.today:
        return date.year == now.year && date.month == now.month && date.day == now.day;
      case PeriodFilter.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return date.isAfter(weekAgo);
      case PeriodFilter.month:
        return date.year == now.year && date.month == now.month;
      case PeriodFilter.all:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);

    final filtered = transactions.where((t) => _filterByPeriod(t.date)).toList();

    final receita = filtered
        .where((e) => e.type == 'receita')
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final despesa = filtered
        .where((e) => e.type == 'despesa')
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final saldo = receita - despesa;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown filtro período
            Row(
              children: [
                const Text('Período: '),
                const SizedBox(width: 10),
                DropdownButton<PeriodFilter>(
                  value: _selectedPeriod,
                  items: const [
                    DropdownMenuItem(value: PeriodFilter.today, child: Text('Hoje')),
                    DropdownMenuItem(value: PeriodFilter.week, child: Text('Última Semana')),
                    DropdownMenuItem(value: PeriodFilter.month, child: Text('Mês Atual')),
                    DropdownMenuItem(value: PeriodFilter.all, child: Text('Todos')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _selectedPeriod = v;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                title: const Text('Saldo Atual'),
                subtitle: Text('R\$ ${saldo.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Resumo',
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
