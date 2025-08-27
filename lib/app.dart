import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/services/auth_service.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/dashboard_screen.dart';

class SaccoApp extends StatelessWidget {
  const SaccoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
    );
    return ChangeNotifierProvider(
      create: (_) => AuthService()..loadSession(),
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'SaccoSecure',
            debugShowCheckedModeBanner: false,
            theme: baseTheme,
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: auth.themeMode,
            home: auth.isLoggedIn ? const DashboardScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}