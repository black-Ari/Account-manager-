import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/reminder.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'accountmate.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            category TEXT,
            type TEXT,
            date TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE reminders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            dueDate TEXT,
            type TEXT,
            completed INTEGER
          )
        ''');
      },
    );
  }

  // ---------- Transactions ----------
  Future<int> insertTransaction(TransactionModel t) async {
    final db = await database;
    return await db.insert('transactions', t.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Reminders ----------
  Future<int> insertReminder(ReminderModel r) async {
    final db = await database;
    return await db.insert('reminders', r.toMap());
  }

  Future<List<ReminderModel>> getReminders() async {
    final db = await database;
    final result = await db.query('reminders', orderBy: 'dueDate ASC');
    return result.map((e) => ReminderModel.fromMap(e)).toList();
  }

  Future<int> toggleReminder(int id, bool completed) async {
    final db = await database;
    return await db.update('reminders', {'completed': completed ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
