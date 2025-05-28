import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_provider.dart';
import 'transaction_form.dart';

class TransactionListPage extends ConsumerWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);

    final receita = transactions
        .where((e) => e.type == 'receita')
        .fold(0.0, (a, b) => a + b.amount);

    final despesa = transactions
        .where((e) => e.type == 'despesa')
        .fold(0.0, (a, b) => a + b.amount);

    final saldo = receita - despesa;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de Despesas')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: const Text('Saldo'),
              subtitle: Text('R\$ ${saldo.toStringAsFixed(2)}'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (_, index) {
                final tx = transactions[index];
                return Card(
                  child: ListTile(
                    title: Text(tx.title),
                    subtitle: Text(
                        '${tx.category} - ${tx.date.toLocal().toString().split(' ')[0]}'),
                    trailing: Text(
                      'R\$ ${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: tx.type == 'despesa' ? Colors.red : Colors.green,
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
