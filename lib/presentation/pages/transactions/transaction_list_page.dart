import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_despesas/presentation/pages/dashboard/dashboard_page.dart';

import '../../../data/models/transaction_model.dart';  // Ajuste caminho conforme sua estrutura
import '../../providers/transaction_provider.dart';
import 'transaction_form.dart';

enum PeriodFilter { hoje, semana, mes, todos }

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() =>
      _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  PeriodFilter _selectedPeriodFilter = PeriodFilter.todos;

  String? _selectedCategory; // null significa sem filtro (Geral)
  String? _selectedType; // null significa sem filtro (todos tipos)
  double? _minValue;
  double? _maxValue;

  final _minValueController = TextEditingController();
  final _maxValueController = TextEditingController();

  @override
  void dispose() {
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    final now = DateTime.now();

    return transactions.where((t) {
      // filtro período
      bool matchesPeriod = false;
      switch (_selectedPeriodFilter) {
        case PeriodFilter.hoje:
          matchesPeriod =
              t.date.year == now.year && t.date.month == now.month && t.date.day == now.day;
          break;
        case PeriodFilter.semana:
          final weekAgo = now.subtract(const Duration(days: 7));
          matchesPeriod = t.date.isAfter(weekAgo);
          break;
        case PeriodFilter.mes:
          matchesPeriod = t.date.year == now.year && t.date.month == now.month;
          break;
        case PeriodFilter.todos:
          matchesPeriod = true;
          break;
      }
      if (!matchesPeriod) return false;

      // filtro categoria
      if (_selectedCategory != null) {
        if (t.category != _selectedCategory) return false;
      }

      // filtro tipo
      if (_selectedType != null) {
        if (t.type != _selectedType) return false;
      }

      // filtro valor mínimo
      if (_minValue != null && t.amount < _minValue!) return false;

      // filtro valor máximo
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

    final categories = <String>[
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
          // Filtro período com chips
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

          // Filtros avançados: Categoria, Tipo, Min, Max
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Categoria Dropdown
                DropdownButton<String?>(
                  value: _selectedCategory,
                  hint: const Text('Todas Categorias'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Geral'),
                    ),
                    ...categories.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),

                // Tipo Dropdown
                DropdownButton<String?>(
                  value: _selectedType,
                  hint: const Text('Todos Tipos'),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Geral'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'receita',
                      child: Text('Receita'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'despesa',
                      child: Text('Despesa'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),

                // Min Valor
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _minValueController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Valor Mín',
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _minValue = double.tryParse(value);
                      });
                    },
                  ),
                ),

                // Max Valor
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _maxValueController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Valor Máx',
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _maxValue = double.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: const Text('Saldo'),
              subtitle: Text('R\$ ${saldo.toStringAsFixed(2)}'),
            ),
          ),

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
                              color:
                                  tx.type == 'despesa' ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onLongPress: () {
                            ref.read(transactionProvider.notifier).delete(tx.id);
                          },
                        ),
                      );
                    },
                  ),
          )
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
