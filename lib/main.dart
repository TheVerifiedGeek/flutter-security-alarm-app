import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'core/services/notification_service.dart';
import 'core/services/scheduler_service.dart';
import 'ui/screens/loading_screen.dart'; // Import LoadingScreen
import 'core/services/auth_service.dart'; // Import AuthService


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await SchedulerService.init();
  runApp(const SaccoApp());
}

// Modify SaccoApp to use LoadingScreen as the initial screen
class SaccoApp extends StatelessWidget {
  const SaccoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Use MultiProvider if you have other providers
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..loadSession()),
// Add other providers here if you have any
      ],
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'SaccoSecure',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
              // textTheme: GoogleFonts.interTextTheme(), // Keep or adjust based on your theme setup
            ),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: auth.themeMode,
            home: const LoadingScreen(), // Set LoadingScreen as the initial screen
            // Remove the logic that directly navigates to Login/Dashboard here
          );
        },
      ),
    );
  }
}
