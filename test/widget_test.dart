import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as fcp_test;
import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_materiel/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
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
  });

  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GestionMaterielApp());
    await tester.pumpAndSettle();

    expect(find.text('Gardnet - Talkie Walkie Pro'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });
}
