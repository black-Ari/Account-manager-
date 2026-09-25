import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double income = 0;
  double expense = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final txns = await DBHelper.instance.getTransactions();
    double inc = 0, exp = 0;
    for (var t in txns) {
      if (t.type == 'income') {
        inc += t.amount;
      } else {
        exp += t.amount;
      }
    }
    setState(() {
      income = inc;
      expense = exp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    return Scaffold(
      appBar: AppBar(title: const Text('AccountMate'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _loadSummary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Net Balance', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    Text('₹${balance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(label: 'Income', value: income, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(label: 'Expense', value: expense, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Modules', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _ModuleTile(icon: Icons.calculate, title: 'Tax Calculator', subtitle: 'GST, TDS & Income Tax'),
            const _ModuleTile(icon: Icons.receipt_long, title: 'Expense Tracker', subtitle: 'Track income & expenses'),
            const _ModuleTile(icon: Icons.book, title: 'Bookkeeping', subtitle: 'Ledger & reports'),
            const _ModuleTile(icon: Icons.alarm, title: 'Compliance Reminders', subtitle: 'GST/ITR/MCA deadlines'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('₹${value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ModuleTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
