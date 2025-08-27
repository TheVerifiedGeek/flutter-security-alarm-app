import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'sacco_secure.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          passwordHash TEXT,
          role TEXT
        );
      ''');
      await db.execute('''
        CREATE TABLE logs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          branch TEXT,
          type TEXT,
          status TEXT,
          timestamp TEXT,
          compliance TEXT
        );
      ''');
    });
    return _db!;
  }
}