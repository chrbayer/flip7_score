import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flip7_score/models/player.dart';
import 'package:flip7_score/screens/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      await tester.pump(const Duration(seconds: 1));

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
      SharedPreferences.setMockInitialValues({});
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
      await tester.pump(const Duration(seconds: 2));

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

    testWidgets('Long-Press auf Spieler ohne Score ändert nichts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      // Alice gibt Punkte ein
      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      // Alice hat jetzt 10 Punkte, Bob 0
      expect(find.text('10 Punkte'), findsOneWidget);
      expect(find.text('0 Punkte'), findsOneWidget);

      // Bob hat noch keine Punkte (Long-Press sollte nichts tun)
      final bobTile = find.text('Bob');
      await tester.longPress(bobTile);
      await tester.pumpAndSettle();

      // Scores sollten unverändert sein
      expect(find.text('10 Punkte'), findsOneWidget);
      expect(find.text('0 Punkte'), findsOneWidget);
    });
  });

  group('GameScreen Runde öffnen (Undo letzte Runde)', () {
    testWidgets('Long-Press auf Runden-Label öffnet letzte Runde', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      // Runde 1 abschließen: Alice 10, Bob 5
      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);

      // Long-Press auf "Runde 2" → Runde 1 wird wieder geöffnet
      await tester.longPress(find.text('Runde 2'));
      await tester.pumpAndSettle();

      // Sollte wieder Runde 1 zeigen
      expect(find.text('Runde 1'), findsOneWidget);

      // Alice hat noch 10 Punkte (hasEnteredScore = true)
      expect(find.text('10 Punkte'), findsOneWidget);

      // Bobs Score (letzter Spieler) wurde zurückgesetzt auf 0
      expect(find.text('0 Punkte'), findsOneWidget);

      // Bob ist ausgewählt (letzter Eingeber), mit Vorbelegung "5"
      expect(find.text('Eingabe für: Bob'), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '5');
    });

    testWidgets('Laufende Runde wird gesichert und nach Wiederschließen wiederhergestellt', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      // Runde 1: Alice 10, Bob 5
      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);

      // Runde 2: Alice gibt 20 ein (Bob noch nicht)
      await tester.enterText(find.byType(TextField), '20');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('30 Punkte'), findsOneWidget); // Alice: 10 + 20
      expect(find.text('Eingabe für: Bob'), findsOneWidget);

      // Long-Press auf "Runde 2" → Runde 1 öffnen
      await tester.longPress(find.text('Runde 2'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      // Alices Score: 10 + 20 (Runde 1 intakt) - 20 (Runde-2-Eintrag rückgängig) = 10
      expect(find.text('10 Punkte'), findsOneWidget);

      // Bob schließt Runde 1 ab (Vorbelegung 5)
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // Runde 2 ist jetzt wieder offen
      expect(find.text('Runde 2'), findsOneWidget);
      // Alice hat ihren Runde-2-Eintrag wiederhergestellt: 10 + 20 = 30
      expect(find.text('30 Punkte'), findsOneWidget);
      // Bob ist wieder dran
      expect(find.text('Eingabe für: Bob'), findsOneWidget);
    });

    testWidgets('Runde 1 kann nicht per Long-Press geöffnet werden', (tester) async {
      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      // Wir sind in Runde 1 – Long-Press sollte nichts tun
      await tester.longPress(find.text('Runde 1'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
    });
  });

  group('GameScreen Runden-Historie', () {
    testWidgets('Runden-Historie erscheint nach Runde 1', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      // Runde 1: Alice 10, Bob 5
      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      // Historie sollte sichtbar sein
      expect(find.text('Runden (1)'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('Runden-Historie zeigt Scores nach Ausklappen', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      // Runde 1: Alice 10, Bob 5
      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      // Ausklappen
      await tester.tap(find.text('Runden (1)'));
      await tester.pumpAndSettle();

      // Runde 1 sollte angezeigt werden
      expect(find.text('Runde 1'), findsAtLeast(1));
    });
  });
}
