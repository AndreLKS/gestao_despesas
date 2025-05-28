import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_despesas/presentation/pages/dashboard/dashboard_page.dart';

import '../../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'transaction_form.dart';

enum PeriodFilter { hoje, semana, mes, todos }

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  PeriodFilter _selectedPeriodFilter = PeriodFilter.todos;
  String? _selectedCategory;
  String? _selectedType;
  double? _minValue;
  double? _maxValue;

  final _minValueController = TextEditingController();
  final _maxValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionProvider.notifier).generateRecurringTransactions();
    });
  }

  @override
  void dispose() {
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    final now = DateTime.now();

    return transactions.where((t) {
      bool matchesPeriod;
      switch (_selectedPeriodFilter) {
        case PeriodFilter.hoje:
          matchesPeriod = t.date.year == now.year &&
                          t.date.month == now.month &&
                          t.date.day == now.day;
          break;
        case PeriodFilter.semana:
          matchesPeriod = t.date.isAfter(now.subtract(const Duration(days: 7)));
          break;
        case PeriodFilter.mes:
          matchesPeriod = t.date.year == now.year &&
                          t.date.month == now.month;
          break;
        case PeriodFilter.todos:
          matchesPeriod = true;
          break;
      }

      if (!matchesPeriod) return false;

      if (_selectedCategory != null && t.category != _selectedCategory) return false;
      if (_selectedType != null && t.type != _selectedType) return false;
      if (_minValue != null && t.amount < _minValue!) return false;
      if (_maxValue != null && t.amount > _maxValue!) return false;

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedPeriodFilter = PeriodFilter.todos;
      _selectedCategory = null;
      _selectedType = null;
      _minValue = null;
      _maxValue = null;
      _minValueController.clear();
      _maxValueController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final filteredTransactions = _filterTransactions(transactions);

    final receita = filteredTransactions
        .where((e) => e.type == 'receita')
        .fold(0.0, (a, b) => a + b.amount);

    final despesa = filteredTransactions
        .where((e) => e.type == 'despesa')
        .fold(0.0, (a, b) => a + b.amount);

    final saldo = receita - despesa;

    final categories = [
      'Alimentação',
      'Lazer',
      'Salário',
      'Moradia',
      'Transporte',
      'Educação',
      'Saúde',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Despesas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Limpar filtros',
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro período
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Wrap(
              spacing: 8,
              children: PeriodFilter.values.map((filter) {
                String label;
                switch (filter) {
                  case PeriodFilter.hoje:
                    label = 'Hoje';
                    break;
                  case PeriodFilter.semana:
                    label = 'Última Semana';
                    break;
                  case PeriodFilter.mes:
                    label = 'Mês';
                    break;
                  case PeriodFilter.todos:
                    label = 'Todos';
                    break;
                }
                return FilterChip(
                  label: Text(label),
                  selected: _selectedPeriodFilter == filter,
                  onSelected: (_) => setState(() => _selectedPeriodFilter = filter),
                );
              }).toList(),
            ),
          ),

          // Filtros avançados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<String?>(
                  value: _selectedCategory,
                  hint: const Text('Todas Categorias'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Geral')),
                    ...categories.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
                DropdownButton<String?>(
                  value: _selectedType,
                  hint: const Text('Todos Tipos'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Geral')),
                    DropdownMenuItem(value: 'receita', child: Text('Receita')),
                    DropdownMenuItem(value: 'despesa', child: Text('Despesa')),
                  ],
                  onChanged: (value) => setState(() => _selectedType = value),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _minValueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Valor Mín', isDense: true),
                    onChanged: (value) => setState(() => _minValue = double.tryParse(value)),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _maxValueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Valor Máx', isDense: true),
                    onChanged: (value) => setState(() => _maxValue = double.tryParse(value)),
                  ),
                ),
              ],
            ),
          ),

          // Saldo
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: const Text('Saldo'),
              subtitle: Text('R\$ ${saldo.toStringAsFixed(2)}'),
            ),
          ),

          // Lista de transações
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(child: Text('Nenhuma transação encontrada'))
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (_, index) {
                      final tx = filteredTransactions[index];
                      return Card(
                        child: ListTile(
                          title: Text(tx.title),
                          subtitle: Text(
                            '${tx.category} - ${DateFormat('dd/MM/yyyy').format(tx.date)}',
                          ),
                          trailing: Text(
                            'R\$ ${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: tx.type == 'despesa' ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onLongPress: () =>
                              ref.read(transactionProvider.notifier).delete(tx.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransactionForm()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
