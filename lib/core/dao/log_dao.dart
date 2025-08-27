import '../db/db_helper.dart';
import '../models/log.dart';

class LogDao {
  Future<int> insert(LogEntry e) async {
    final d = await DBHelper.db;
    return d.insert('logs', e.toMap());
  }

  Future<List<LogEntry>> list({String? branch, DateTime? from, DateTime? to}) async {
    final d = await DBHelper.db;
    final where = <String>[];
    final args = <Object>[];
    if (branch != null) { where.add('branch = ?'); args.add(branch); }
    if (from != null)  { where.add('timestamp >= ?'); args.add(from.toIso8601String()); }
    if (to != null)    { where.add('timestamp <= ?'); args.add(to.toIso8601String()); }
    final res = await d.query('logs', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args, orderBy: 'timestamp DESC');
    return res.map(LogEntry.fromMap).toList();
  }

  Future<List<LogEntry>> yesterdayTroubles(DateTime today) async {
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 1));
    final end = DateTime(today.year, today.month, today.day).subtract(const Duration(seconds: 1));
    final d = await DBHelper.db;
    final res = await d.query('logs',
      where: 'timestamp >= ? AND timestamp <= ? AND (compliance = ? OR compliance = ?)',
      whereArgs: [start.toIso8601String(), end.toIso8601String(), 'Late', 'Trouble'],
      orderBy: 'timestamp ASC',
    );
    return res.map(LogEntry.fromMap).toList();
  }
}