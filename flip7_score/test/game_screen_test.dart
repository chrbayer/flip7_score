import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flip7_score/models/player.dart';
import 'package:flip7_score/screens/game_screen.dart';

void main() {
  group('GameScreen', () {
    late List<Player> players;

    setUp(() {
      players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];
    });

    testWidgets('zeigt Spielstand mit Runde 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('0 Punkte'), findsNWidgets(2));
    });

    testWidgets('erster Spieler ist ausgewählt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Eingabe für: Alice'), findsOneWidget);
    });

    testWidgets('Punkte können eingegeben werden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      final scoreField = find.byType(TextField);
      await tester.enterText(scoreField, '25');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('25 Punkte'), findsOneWidget);
    });

    testWidgets('leere Eingabe wird als 0 interpretiert', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('0 Punkte'), findsNWidgets(2));
    });

    testWidgets('Runde wechselt nach allen Spielern', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      // Alice: 10 Punkte
      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('Eingabe für: Bob'), findsOneWidget);

      // Bob: 5 Punkte
      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      // Runde sollte jetzt 2 sein
      expect(find.text('Runde 2'), findsOneWidget);
      expect(find.text('Eingabe für: Alice'), findsOneWidget);
    });

    testWidgets('Spiel abbrechen Button vorhanden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('Check-Icon bei eingetragenem Spieler', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Ungültige Eingabe zeigt Fehler', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('Bitte eine gültige Zahl eingeben'), findsOneWidget);
    });

    testWidgets('Abbrechen-Dialog zeigt Optionen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Spiel abbrechen?'), findsOneWidget);
      expect(find.text('Mit gleichen Spielern'), findsOneWidget);
      expect(find.text('Neue Spieler'), findsOneWidget);
      expect(find.text('Weiterspielen'), findsOneWidget);
    });

    testWidgets('Abbrechen-Dialog - Weiterspielen schließt Dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weiterspielen'));
      await tester.pumpAndSettle();

      // Dialog sollte geschlossen sein, Spiel läuft weiter
      expect(find.text('Spiel abbrechen?'), findsNothing);
      expect(find.text('Runde 1'), findsOneWidget);
    });

    testWidgets('Gewinner bei 200 Punkten', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Spieler mit 195 Punkten starten
      final playersWithScore = [
        Player(name: 'Alice', score: 195),
        Player(name: 'Bob', score: 100),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: playersWithScore)),
      );
      await tester.pumpAndSettle();

      // Alice gibt 5 Punkte ein -> 200
      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      // Sollte zum WinnerScreen navigieren
      expect(find.text('Gewinner!'), findsOneWidget);
      expect(find.text('Alice'), findsAtLeast(1));
    });
  });

  group('GameScreen Undo', () {
    late List<Player> players;

    setUp(() {
      players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];
    });

    testWidgets('Long-Press auf Spieler mit Score macht Undo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      // Alice: 10 Punkte
      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('10 Punkte'), findsOneWidget);

      // Long-Press auf Alice für Undo
      final aliceTile = find.text('Alice');
      await tester.longPress(aliceTile);
      await tester.pumpAndSettle();

      // Score sollte zurückgesetzt sein
      expect(find.text('0 Punkte'), findsNWidgets(2));
      expect(find.text('Eingabe für: Alice'), findsOneWidget);
    });

    // Long-Press Test für Spieler ohne Score wird aufgrund von Widget-Test-Komplexität übersprungen
    // Die Funktionalität ist durch player_test.dart abgedeckt (undoLastScore prüft hasEnteredScore)
  });
}
