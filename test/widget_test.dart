import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_materiel/main.dart';

void main() {
  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GestionMaterielApp());
    await tester.pumpAndSettle();

    expect(find.text('Gestion Matériel'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });
}
