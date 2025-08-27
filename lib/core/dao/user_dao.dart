import '../db/db_helper.dart';
import '../models/user.dart';

class UserDao {
  Future<AppUser?> getByUsername(String username) async {
    final d = await DBHelper.db;
    final res = await d.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    if (res.isEmpty) return null;
    return AppUser.fromMap(res.first);
  }
  Future<int> insert(AppUser u) async {
    final d = await DBHelper.db;
    return d.insert('users', u.toMap());
  }

  Future<List<AppUser>> getAll() async {
    final d = await DBHelper.db;
    final res = await d.query('users');
    return res.map(AppUser.fromMap).toList();
  }
}