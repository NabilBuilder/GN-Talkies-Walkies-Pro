import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'di/service_locator.dart';
import 'screens/login_screen.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

// Création & Développement : Boukhoulkhal Nabil (2026)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupServiceLocator();
  runApp(const GestionMaterielApp());
}

class GestionMaterielApp extends StatelessWidget {
  const GestionMaterielApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = getIt<IThemeService>();
    final localeService = getIt<ILocaleService>();

    return MaterialApp(
      title: 'Gestion Matériel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.getThemeMode(),
      locale: localeService.getCurrentLocale(),
      supportedLocales: localeService.getSupportedLocales(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoginScreen(),
    );
  }
}
