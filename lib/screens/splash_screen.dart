import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

/// Splash screen shown on app startup.
/// Shows logo, then navigates based on auth state.
/// Includes a 5-second hard timeout to prevent getting stuck.
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
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('Splash: starting...');

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Hard timeout - force navigate after 5 seconds no matter what
    final timeout = Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_navigated) {
        debugPrint('Splash: timeout reached, forcing navigation to login');
        _navigated = true;
        _goToLogin();
      }
    });

    try {
      // Wait a minimum of 2 seconds for splash animation
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted || _navigated) return;

      // Use AuthService (no direct Firebase access)
      final authService = AuthService();
      final user = await authService.getCurrentUserAsync();
      debugPrint('Splash: auth check done, user=${user?.uid ?? "null"}');

      // Always go to LoginScreen - it handles auth state internally
      debugPrint('Splash: navigating to login screen');
      _navigated = true;
      _goToLogin();
    } catch (e) {
      debugPrint('Splash: error during init: $e');
      if (mounted && !_navigated) {
        _navigated = true;
        _goToLogin();
      }
    }

    // Cancel timeout if navigation already happened
    timeout.ignore();
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
              // App Name — hardcoded to avoid null-safety crash on first frame
              const Text(
                'GN Talkies-Walkies Pro',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Loading text — hardcoded
              const Text(
                'Chargement...',
                style: TextStyle(
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
