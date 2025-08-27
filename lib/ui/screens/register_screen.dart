import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'admin';
  bool _loading = false;

  Future<void> _createUser(AuthService auth) async {
    setState(() => _loading = true);

    final err = await auth.register(
      _usernameController.text.trim(),
      _passwordController.text,
      role: _role,
    );

    if (!mounted) return; // ✅ Safely exit if widget disposed

    setState(() => _loading = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Role',
              ),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'operator', child: Text('Operator')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'operator'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : () => _createUser(auth),
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}