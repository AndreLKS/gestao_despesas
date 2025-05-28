import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Geral';
  String _type = 'despesa';
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

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
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o valor';
                  }
                  final amount = double.tryParse(value.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) {
                    return 'Informe um valor válido maior que zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'despesa', child: Text('Despesa')),
                  DropdownMenuItem(value: 'receita', child: Text('Receita')),
                ],
                onChanged: (value) {
                  setState(() => _type = value!);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Geral', child: Text('Geral')),
                  DropdownMenuItem(value: 'Alimentação', child: Text('Alimentação')),
                  DropdownMenuItem(value: 'Lazer', child: Text('Lazer')),
                  DropdownMenuItem(value: 'Salário', child: Text('Salário')),
                  DropdownMenuItem(value: 'Moradia', child: Text('Moradia')),
                  DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
                  DropdownMenuItem(value: 'Educação', child: Text('Educação')),
                  DropdownMenuItem(value: 'Saúde', child: Text('Saúde')),
                ],
                onChanged: (value) {
                  setState(() => _category = value!);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _date = picked);
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        date: _date,
        category: _category,
        type: _type,
      );

      ref.read(transactionProvider.notifier).add(transaction);
      Navigator.pop(context);
    }
  }
}
