import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as fcp_test;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_materiel/l10n/app_localizations.dart';

import 'package:gestion_materiel/di/service_locator.dart';
import 'package:gestion_materiel/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock SharedPreferences for tests
    SharedPreferences.setMockInitialValues({});
    // Mock the Firebase platform channels so no native Firebase app is
    // required when running widget tests on the Dart VM.
    fcp_test.setupFirebaseCoreMocks();
    // Values must match the ones returned by the mock (see MockFirebaseApp).
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: '123',
        appId: '123',
        messagingSenderId: '123',
        projectId: '123',
      ),
    );
    await setupServiceLocator();
  });

  tearDownAll(() async {
    await resetServiceLocator();
  });

  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LoginScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Gardnet - Talkie Walkie Pro'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });
}
