import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rock_paper_scissors/main.dart'; // Assuming main.dart is in lib
import 'package:rock_paper_scissors/onboarding_screen.dart'; // Import onboarding screen
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    Timer(const Duration(seconds: 3), () {
      if (hasSeenOnboarding) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GamePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can add your app logo or an image here if you have one
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rocket_launch,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.description,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.content_cut,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Rock Paper Scissors',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 