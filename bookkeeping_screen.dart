import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/transaction.dart';

class BookkeepingScreen extends StatefulWidget {
  const BookkeepingScreen({super.key});

  @override
  State<BookkeepingScreen> createState() => _BookkeepingScreenState();
}

class _BookkeepingScreenState extends State<BookkeepingScreen> {
  Map<String, double> _categoryTotals = {};
  double _totalIncome = 0;
  double _totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txns = await DBHelper.instance.getTransactions();
    final Map<String, double> totals = {};
    double income = 0, expense = 0;
    for (var t in txns) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    setState(() {
      _categoryTotals = totals;
      _totalIncome = income;
      _totalExpense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedEntries = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Bookkeeping')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total Income'),
                      Text('₹${_totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total Expense'),
                      Text('₹${_totalExpense.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ]),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Net Profit/Loss', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('₹${(_totalIncome - _totalExpense).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Category-wise Breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (sortedEntries.isEmpty) const Text('No data yet.'),
            ...sortedEntries.map((e) => Card(
                  child: ListTile(
                    title: Text(e.key),
                    trailing: Text('₹${e.value.toStringAsFixed(2)}'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
