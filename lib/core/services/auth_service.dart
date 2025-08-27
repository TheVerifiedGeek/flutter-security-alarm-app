import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart' as c; // add to pubspec if you prefer crypto, else simple hash
import '../dao/user_dao.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  final _userDao = UserDao();
  final _localAuth = LocalAuthentication();

  AppUser? _current;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isLoggedIn => _current != null;
  AppUser? get current => _current;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode m) { _themeMode = m; notifyListeners(); }

  Future<void> loadSession() async {
    final sp = await SharedPreferences.getInstance();
    final u = sp.getString('session_user');
    if (u != null) {
      final map = Map<String, dynamic>.from(jsonDecode(u));
      _current = AppUser.fromMap(map);
    }
    final mode = sp.getString('theme_mode');
    if (mode == 'dark') _themeMode = ThemeMode.dark;
    if (mode == 'light') _themeMode = ThemeMode.light;
    notifyListeners();
  }

  Future<void> saveSession(AppUser u) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('session_user', jsonEncode(u.toMap()));
    _current = u; notifyListeners();
  }

  Future<void> clearSession() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('session_user');
    _current = null; notifyListeners();
  }

  String hash(String input) {
    // simple SHA256 for demo; in production, use a strong salted hash like Argon2
    return c.sha256.convert(utf8.encode(input)).toString();
  }

  Future<String?> register(String username, String password, {String role = 'admin'}) async {
    final existing = await _userDao.getByUsername(username);
    if (existing != null) return 'Username already exists';
    final id = await _userDao.insert(AppUser(username: username, passwordHash: hash(password), role: role));
    return (id > 0) ? null : 'Failed to create user';
  }

  Future<String?> login(String username, String password) async {
    final u = await _userDao.getByUsername(username);
    if (u == null) return 'User not found';
    if (u.passwordHash != hash(password)) return 'Invalid credentials';
    await saveSession(u);
    return null;
  }

  Future<bool> canCheckBiometrics() async => await _localAuth.canCheckBiometrics;

  Future<bool> biometricLogin() async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Unlock SaccoSecure',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (!ok) return false;
      // If there's a session saved, resume it; else require manual login once.
      final sp = await SharedPreferences.getInstance();
      final u = sp.getString('session_user');
      if (u == null) return false;
      return true;
    } catch (_) { return false; }
  }
}