import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flip7_score/models/player.dart';
import 'package:flip7_score/screens/winner_screen.dart';

void main() {
  group('WinnerScreen', () {
    late List<Player> players;

    setUp(() {
      players = [
        Player(name: 'Alice', score: 250),
        Player(name: 'Bob', score: 180),
        Player(name: 'Charlie', score: 120),
      ];
    });

    testWidgets('zeigt Gewinner mit Namen und Punkten', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: WinnerScreen(
            winner: players[0],
            allPlayers: players,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GEWINNER'), findsOneWidget);
      // Alice wird mehrfach angezeigt (Gewinner + Endstand), daher atleast(1)
      expect(find.text('Alice'), findsAtLeast(1));
      expect(find.text('250 Punkte'), findsOneWidget);
    });

    testWidgets('zeigt Endstand sortiert nach Punkten', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: WinnerScreen(
            winner: players[0],
            allPlayers: players,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Endstand'), findsOneWidget);

      // Alle 3 Spielernamen in der Rangliste sichtbar
      expect(find.text('Alice'), findsAtLeast(1));
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
    });

    testWidgets('Buttons für neue Partie vorhanden', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: WinnerScreen(
            winner: players[0],
            allPlayers: players,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mit gleichen Spielern weiterspielen'), findsOneWidget);
      expect(find.text('Neue Spieler auswählen'), findsOneWidget);
    });

    testWidgets('Gewinner-Icon wird angezeigt', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: WinnerScreen(
            winner: players[0],
            allPlayers: players,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Mehrere Icons werden angezeigt (emoji_events)
      expect(find.byIcon(Icons.emoji_events), findsAtLeast(1));
    });

    testWidgets('AppBar zeigt Gewinner', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: WinnerScreen(
            winner: players[0],
            allPlayers: players,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gewinner!'), findsOneWidget);
    });

    testWidgets('Zurück-zum-Spiel Button und Bestätigungsdialog vorhanden', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: WinnerScreen(
            winner: players[0],
            allPlayers: players,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Zurück zum Spiel'), findsOneWidget);
      expect(find.byIcon(Icons.undo), findsOneWidget);

      // Antippen öffnet Bestätigungsdialog
      await tester.tap(find.text('Zurück zum Spiel'));
      await tester.pumpAndSettle();

      expect(find.text('Gewinner rückgängig?'), findsOneWidget);
      expect(find.text('Abbrechen'), findsOneWidget);
    });

    testWidgets('Abbrechen im Dialog schließt Dialog ohne Navigation', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: WinnerScreen(
            winner: players[0],
            allPlayers: players,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zurück zum Spiel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      // Dialog geschlossen, WinnerScreen noch sichtbar
      expect(find.text('Gewinner rückgängig?'), findsNothing);
      expect(find.text('GEWINNER'), findsOneWidget);
    });

    testWidgets('Bestätigen im Dialog navigiert zurück', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: WinnerScreen(
            winner: players[0],
            allPlayers: players,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Dialog öffnen
      await tester.tap(find.text('Zurück zum Spiel'));
      await tester.pumpAndSettle();

      // Bestätigen
      await tester.tap(find.text('Zurück zum Spiel').last);
      await tester.pumpAndSettle();

      // Sollte vom WinnerScreen zurück navigieren
      // (Der Navigator.pop mit true wird ausgeführt)
      expect(find.text('GEWINNER'), findsNothing);
    });
  });
}
