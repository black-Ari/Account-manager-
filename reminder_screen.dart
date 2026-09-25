import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/reminder.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<ReminderModel> _reminders = [];
  final _types = ['GST', 'TDS', 'ITR', 'MCA', 'Other'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await DBHelper.instance.getReminders();
    setState(() => _reminders = r);
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    String type = _types.first;
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

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
                Text('Add Reminder', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title (e.g. GSTR-3B filing)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setSheetState(() => type = v!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date'),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(dueDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) setSheetState(() => dueDate = picked);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (titleCtrl.text.isEmpty) return;
                      await DBHelper.instance.insertReminder(ReminderModel(
                        title: titleCtrl.text,
                        dueDate: dueDate,
                        type: type,
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
      appBar: AppBar(title: const Text('Compliance Reminders')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: _reminders.isEmpty
          ? const Center(child: Text('No reminders yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (ctx, i) {
                final r = _reminders[i];
                final daysLeft = r.dueDate.difference(DateTime.now()).inDays;
                return Dismissible(
                  key: Key(r.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await DBHelper.instance.deleteReminder(r.id!);
                    _load();
                  },
                  child: CheckboxListTile(
                    value: r.completed,
                    onChanged: (v) async {
                      await DBHelper.instance.toggleReminder(r.id!, v!);
                      _load();
                    },
                    title: Text(r.title, style: TextStyle(decoration: r.completed ? TextDecoration.lineThrough : null)),
                    subtitle: Text('${r.type} • Due ${DateFormat('dd MMM yyyy').format(r.dueDate)}'
                        '${!r.completed && daysLeft >= 0 ? ' ($daysLeft days left)' : ''}'
                        '${!r.completed && daysLeft < 0 ? ' (Overdue!)' : ''}'),
                    secondary: Icon(
                      Icons.circle,
                      size: 12,
                      color: r.completed
                          ? Colors.grey
                          : (daysLeft < 3 ? Colors.red : (daysLeft < 7 ? Colors.orange : Colors.green)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
