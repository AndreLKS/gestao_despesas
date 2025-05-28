import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

class TransactionForm extends ConsumerStatefulWidget {
  const TransactionForm({super.key});

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String category = 'Geral';
  String type = 'despesa';
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Transação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o título' : null,
              ),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'despesa', child: Text('Despesa')),
                  DropdownMenuItem(value: 'receita', child: Text('Receita')),
                ],
                onChanged: (value) {
                  setState(() {
                    type = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                items: const [
                  DropdownMenuItem(value: 'Geral', child: Text('Geral')),
                  DropdownMenuItem(value: 'Alimentação', child: Text('Alimentação')),
                  DropdownMenuItem(value: 'Lazer', child: Text('Lazer')),
                  DropdownMenuItem(value: 'Salário', child: Text('Salário')),
                ],
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text('Data: ${date.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      date = selectedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final transaction = TransactionModel(
                      id: const Uuid().v4(),
                      title: titleController.text,
                      amount: double.parse(amountController.text),
                      date: date,
                      category: category,
                      type: type,
                    );
                    ref.read(transactionProvider.notifier).add(transaction);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
