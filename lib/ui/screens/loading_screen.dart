import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer

import 'package:provider/provider.dart'; // Import for Provider
import '../../core/services/auth_service.dart'; // Import AuthService
import 'login_screen.dart'; // Import LoginScreen
import 'dashboard_screen.dart'; // Import DashboardScreen


class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Animation duration
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn, // Use an ease-in curve for a smooth fade
    );

    _controller.forward(); // Start the animation
    
    // Add a timer to navigate to the next screen after the animation completes
    Timer(const Duration(seconds: 3), _navigateToNextScreen); // Wait for animation + 1 second
  }

  void _navigateToNextScreen() {
    if (!mounted) return; // Safeguard

    // Check authentication status using AuthService
    final auth = Provider.of<AuthService>(context, listen: false);

    if (auth.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }


  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
 return Scaffold(
      backgroundColor: Colors.black87, // Dark background for security theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition( // Add scaling animation
              scale: _animation,
              child: FadeTransition(
                opacity: _animation, // Apply the fading animation
                child: Padding(
                  padding: const EdgeInsets.all(50.0), // Add some padding around the logo
                  child: Image.asset('lib/assets/images/logo.png'),
                ),
              ),
            ),
            const SizedBox(height: 20), // Spacing between logo and icon
           const Icon(
              Icons.security, // Security icon
              size: 50,
              color: Colors.white70, // Icon color
            ),
          ],
        ),
      ),
    );
  }
}
