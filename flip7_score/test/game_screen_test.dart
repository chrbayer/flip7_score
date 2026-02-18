import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flip7_score/models/player.dart';
import 'package:flip7_score/screens/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Hilfsfunktion: Phone-Größe setzen (verhindert Tablet-Layout)
void setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  group('GameScreen Edge Cases', () {
    testWidgets('Negative Eingabe zeigt Fehler', (tester) async {
      setPhoneSize(tester);
      final players = [Player(name: 'Alice'), Player(name: 'Bob')];
      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '-5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('Bitte eine gültige Zahl eingeben'), findsOneWidget);
    });

    testWidgets('Runde wird nicht gewechselt wenn nur ein Spieler fehlt', (tester) async {
      setPhoneSize(tester);
      final players = [Player(name: 'Alice'), Player(name: 'Bob')];
      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('Eingabe für: Bob'), findsOneWidget);
    });

    testWidgets('Leere Scores werden korrekt behandelt', (tester) async {
      SharedPreferences.setMockInitialValues({});
      setPhoneSize(tester);

      final players = [Player(name: 'Alice'), Player(name: 'Bob')];
      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);
    });
  });

  group('GameScreen', () {
    late List<Player> players;

    setUp(() {
      players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];
    });

    testWidgets('zeigt Spielstand mit Runde 1', (tester) async {
      setPhoneSize(tester);
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
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Eingabe für: Alice'), findsOneWidget);
    });

    testWidgets('Punkte können eingegeben werden', (tester) async {
      setPhoneSize(tester);
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
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('0 Punkte'), findsNWidgets(2));
    });

    testWidgets('Runde wechselt nach allen Spielern', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('Eingabe für: Bob'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);
      expect(find.text('Eingabe für: Alice'), findsOneWidget);
    });

    testWidgets('Spiel abbrechen Button vorhanden', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('Check-Icon bei eingetragenem Spieler', (tester) async {
      setPhoneSize(tester);
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
      setPhoneSize(tester);
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
      setPhoneSize(tester);
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
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weiterspielen'));
      await tester.pumpAndSettle();

      expect(find.text('Spiel abbrechen?'), findsNothing);
      expect(find.text('Runde 1'), findsOneWidget);
    });

    testWidgets('Gewinner bei 200 Punkten', (tester) async {
      SharedPreferences.setMockInitialValues({});
      setPhoneSize(tester);

      final playersWithScore = [
        Player(name: 'Alice', score: 195),
        Player(name: 'Bob', score: 100),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: playersWithScore)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Gewinner!'), findsOneWidget);
      expect(find.text('Alice'), findsAtLeast(1));
    });

    testWidgets('Gewinner kann rückgängig gemacht werden und Spiel wird fortgesetzt', (tester) async {
      SharedPreferences.setMockInitialValues({});
      setPhoneSize(tester);

      final playersWithScore = [
        Player(name: 'Alice', score: 195),
        Player(name: 'Bob', score: 100),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: playersWithScore)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Gewinner!'), findsOneWidget);

      await tester.tap(find.text('Zurück zum Spiel'));
      await tester.pumpAndSettle();

      expect(find.text('Gewinner rückgängig?'), findsOneWidget);

      await tester.tap(find.text('Zurück zum Spiel').last);
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('195 Punkte'), findsOneWidget);
      expect(find.text('100 Punkte'), findsOneWidget);
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
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('10 Punkte'), findsOneWidget);

      final aliceTile = find.text('Alice');
      await tester.longPress(aliceTile);
      await tester.pumpAndSettle();

      expect(find.text('0 Punkte'), findsNWidgets(2));
      expect(find.text('Eingabe für: Alice'), findsOneWidget);
    });

    testWidgets('Long-Press auf Spieler ohne Score ändert nichts', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('10 Punkte'), findsOneWidget);
      expect(find.text('0 Punkte'), findsOneWidget);

      final bobTile = find.text('Bob');
      await tester.longPress(bobTile);
      await tester.pumpAndSettle();

      expect(find.text('10 Punkte'), findsOneWidget);
      expect(find.text('0 Punkte'), findsOneWidget);
    });
  });

  group('GameScreen Runde öffnen (Undo letzte Runde) mit mehr Spielern', () {
    testWidgets('Runde-Undo mit 3 Spielern funktioniert korrekt', (tester) async {
      SharedPreferences.setMockInitialValues({});
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
        Player(name: 'Charlie'),
      ];

      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '3');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);

      await tester.longPress(find.text('Runde 2'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);

      expect(find.text('10 Punkte'), findsOneWidget);
      expect(find.text('5 Punkte'), findsOneWidget);
      expect(find.text('0 Punkte'), findsOneWidget);

      expect(find.text('Eingabe für: Charlie'), findsOneWidget);
    });

    testWidgets('Runde-Undo mit laufender Runde bei 3 Spielern', (tester) async {
      SharedPreferences.setMockInitialValues({});
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
        Player(name: 'Charlie'),
      ];

      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '3');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextField), '7');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('17 Punkte'), findsOneWidget);
      expect(find.text('Eingabe für: Bob'), findsOneWidget);

      await tester.longPress(find.text('Runde 2'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('10 Punkte'), findsOneWidget);
      expect(find.text('5 Punkte'), findsOneWidget);
      expect(find.text('0 Punkte'), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '3');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);
      expect(find.text('17 Punkte'), findsOneWidget);
    });

    testWidgets('Mehrfaches Runde-Undo (2 Runden zurück)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextField), '8');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '3');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 3'), findsOneWidget);

      await tester.longPress(find.text('Runde 3'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 2'), findsOneWidget);

      await tester.longPress(find.text('Runde 2'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);

      expect(find.text('10 Punkte'), findsOneWidget);
      expect(find.text('0 Punkte'), findsOneWidget);
    });
  });

  group('GameScreen Runde öffnen (Undo letzte Runde)', () {
    testWidgets('Long-Press auf Runden-Label öffnet letzte Runde', (tester) async {
      SharedPreferences.setMockInitialValues({});
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);

      await tester.longPress(find.text('Runde 2'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('10 Punkte'), findsOneWidget);
      expect(find.text('0 Punkte'), findsOneWidget);

      expect(find.text('Eingabe für: Bob'), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '5');
    });

    testWidgets('Laufende Runde wird gesichert und nach Wiederschließen wiederhergestellt', (tester) async {
      SharedPreferences.setMockInitialValues({});
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '20');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('30 Punkte'), findsOneWidget);
      expect(find.text('Eingabe für: Bob'), findsOneWidget);

      await tester.longPress(find.text('Runde 2'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('10 Punkte'), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);
      expect(find.text('30 Punkte'), findsOneWidget);
      expect(find.text('Eingabe für: Bob'), findsOneWidget);
    });

    testWidgets('Runde 1 kann nicht per Long-Press geöffnet werden', (tester) async {
      setPhoneSize(tester);
      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Runde 1'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
    });
  });

  group('GameScreen Runden-Historie', () {
    testWidgets('Runden-Historie erscheint nach Runde 1', (tester) async {
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      expect(find.text('Runden (1)'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('Runden-Historie zeigt Scores nach Ausklappen', (tester) async {
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('Punkte eintragen'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Runden (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsAtLeast(1));
    });
  });
}
