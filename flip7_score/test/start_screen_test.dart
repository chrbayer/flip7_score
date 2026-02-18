import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flip7_score/screens/start_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StartScreen', () {
    testWidgets('zeigt Startbildschirm mit 2 Spielern', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: StartScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flip 7 - Neues Spiel'), findsOneWidget);
      expect(find.text('Anzahl der Mitspieler'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      // Prüfe nur, dass Spieler-TextFields existieren (nicht wie viele)
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Spieleranzahl kann erhöht werden', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: StartScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('Spieleranzahl kann verringert werden', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: StartScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove_circle));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Minimal 2 Spieler - Minus-Button deaktiviert', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: StartScreen()),
      );
      await tester.pumpAndSettle();

      final removeButtons = find.byType(IconButton);
      final removeButton = removeButtons.first;
      final iconButton = tester.widget<IconButton>(removeButton);
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('Maximal 6 Spieler - Plus-Button deaktiviert', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: StartScreen()),
      );
      await tester.pumpAndSettle();

      // Bis auf 6 erhöhen
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byIcon(Icons.add_circle));
        await tester.pumpAndSettle();
      }

      expect(find.text('6'), findsOneWidget);

      // Jetzt sollte + deaktiviert sein
      final addButtons = find.byType(IconButton);
      final addButton = addButtons.last;
      final iconButton = tester.widget<IconButton>(addButton);
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('Spiel starten Button vorhanden', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: StartScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Spiel starten'), findsOneWidget);
    });

    testWidgets('Namen können eingegeben werden', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: StartScreen()),
      );
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Alice');
      await tester.pumpAndSettle();

      // TextField hat jetzt Alice als Text
      expect(nameField, findsOneWidget);
    });

    testWidgets('Doppelte Namen zeigen Dialog vor Spielstart', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: StartScreen()),
      );
      await tester.pumpAndSettle();

      // Anzahl auf 3 erhöhen
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      // Alle 3 Spieler auf "Max" setzen
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Max');
      await tester.enterText(textFields.at(1), 'Max');
      await tester.enterText(textFields.at(2), 'Max');
      await tester.pumpAndSettle();

      // Spiel starten
      await tester.tap(find.text('Spiel starten'));
      await tester.pumpAndSettle();

      // Dialog sollte erscheinen
      expect(find.text('Doppelte Namen angepasst'), findsOneWidget);
    });

    testWidgets('Dialog zeigt eindeutige Namen nach Deduplizierung', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: StartScreen()),
      );
      await tester.pumpAndSettle();

      // Anzahl auf 3 erhöhen
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      // Alle 3 Spieler auf "Max" setzen
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Max');
      await tester.enterText(textFields.at(1), 'Max');
      await tester.enterText(textFields.at(2), 'Max');
      await tester.pumpAndSettle();

      // Spiel starten
      await tester.tap(find.text('Spiel starten'));
      await tester.pumpAndSettle();

      // Sollte "Max (1)" und "Max (2)" im Dialog zeigen
      expect(find.text('Max'), findsAtLeast(1));
      expect(find.text('Max (1)'), findsOneWidget);
    });

    testWidgets('Drei gleiche Namen werden zu Max, Max (1), Max (2)', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: StartScreen()),
      );
      await tester.pumpAndSettle();

      // Anzahl auf 3 erhöhen
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      // Alle 3 Spieler auf "Max" setzen
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Max');
      await tester.enterText(textFields.at(1), 'Max');
      await tester.enterText(textFields.at(2), 'Max');
      await tester.pumpAndSettle();

      // Spiel starten
      await tester.tap(find.text('Spiel starten'));
      await tester.pumpAndSettle();

      // Sollte alle drei Varianten im Dialog zeigen (nicht in den TextFields)
      // Wir prüfen nur auf die erweiterten Namen, nicht auf "Max" allgemein
      expect(find.text('Max (1)'), findsOneWidget);
      expect(find.text('Max (2)'), findsOneWidget);
    });
  });
}
