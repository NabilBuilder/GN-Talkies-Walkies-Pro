import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../models/utilisateur.dart';
import '../services/auth_service.dart';

/// Splash screen shown on app startup.
/// Shows logo for 2 seconds, then navigates based on auth state.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    // Navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && mounted) {
      // User is logged in, fetch their profile and go to home
      try {
        final authService = AuthService();
        final utilisateur = await authService.getUtilisateurActuel();
        if (mounted && utilisateur != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(utilisateur: utilisateur),
            ),
          );
        } else {
          _goToLogin();
        }
      } catch (e) {
        _goToLogin();
      }
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/images/logo.png',
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.settings_input_component,
                    size: 100,
                    color: Colors.white,
                  );
                },
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                AppLocalizations.of(context)!.appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Welcome Message
              Text(
                AppLocalizations.of(context)!.welcomeMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
