import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/transaction.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  List<TransactionModel> _transactions = [];

  final _categories = ['Food', 'Travel', 'Office', 'Rent', 'Utilities', 'Client Payment', 'Salary', 'Other'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txns = await DBHelper.instance.getTransactions();
    setState(() => _transactions = txns);
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String type = 'expense';
    String category = _categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Transaction', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'expense', label: Text('Expense')),
                    ButtonSegment(value: 'income', label: Text('Income')),
                  ],
                  selected: {type},
                  onSelectionChanged: (s) => setSheetState(() => type = s.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setSheetState(() => category = v!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final amount = double.tryParse(amountCtrl.text) ?? 0;
                      if (titleCtrl.text.isEmpty || amount <= 0) return;
                      await DBHelper.instance.insertTransaction(TransactionModel(
                        title: titleCtrl.text,
                        amount: amount,
                        category: category,
                        type: type,
                        date: DateTime.now(),
                      ));
                      if (ctx.mounted) Navigator.pop(ctx);
                      _load();
                    },
                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Save')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: _transactions.isEmpty
          ? const Center(child: Text('No transactions yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (ctx, i) {
                final t = _transactions[i];
                final isIncome = t.type == 'income';
                return Dismissible(
                  key: Key(t.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await DBHelper.instance.deleteTransaction(t.id!);
                    _load();
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? Colors.green : Colors.red),
                    ),
                    title: Text(t.title),
                    subtitle: Text('${t.category} • ${DateFormat('dd MMM yyyy').format(t.date)}'),
                    trailing: Text(
                      '${isIncome ? '+' : '-'}₹${t.amount.toStringAsFixed(2)}',
                      style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
