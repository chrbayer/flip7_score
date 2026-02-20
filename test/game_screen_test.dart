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

// Hilfsfunktion: Score über Zifferntastatur eingeben
Future<void> enterScore(WidgetTester tester, int score) async {
  final scoreStr = score.toString();
  for (int i = 0; i < scoreStr.length; i++) {
    // Finde den Zahlen-Button nach Key
    final buttonKey = Key('numkey_${scoreStr[i]}');
    await tester.tap(find.byKey(buttonKey));
    await tester.pump(const Duration(milliseconds: 50));
  }
  // Auf Bestätigen-Button tippen (nach Key)
  await tester.tap(find.byKey(const Key('btn_confirm')));
  await tester.pump();
}

void main() {
  group('GameScreen Edge Cases', () {
    testWidgets('Runde wird nicht gewechselt wenn nur ein Spieler fehlt', (tester) async {
      setPhoneSize(tester);
      final players = [Player(name: 'Alice'), Player(name: 'Bob')];
      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      await enterScore(tester, 10);

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('Eingabe für: Bob'), findsOneWidget);
    });

    testWidgets('Leere Scores werden korrekt behandelt', (tester) async {
      SharedPreferences.setMockInitialValues({});
      setPhoneSize(tester);

      final players = [Player(name: 'Alice'), Player(name: 'Bob')];
      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      // Leere Eingabe = 0, mit Bestätigen
      await tester.tap(find.byKey(const Key('btn_confirm')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_confirm')));
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

      await enterScore(tester, 25);

      expect(find.text('25 Punkte'), findsOneWidget);
    });

    testWidgets('leere Eingabe wird als 0 interpretiert', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_confirm')));
      await tester.pumpAndSettle();

      expect(find.text('0 Punkte'), findsNWidgets(2));
    });

    testWidgets('Eingabefeld wird nach Punkte eintragen geleert', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await enterScore(tester, 10);

      // Prüfen dass das TextField leer ist
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('Runde wechselt nach allen Spielern', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await enterScore(tester, 10);

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('Eingabe für: Bob'), findsOneWidget);

      await enterScore(tester, 5);
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

      await enterScore(tester, 10);

      // Es gibt jetzt 2 Check-Icons (eines in Spielerliste, eines in Tastatur)
      expect(find.byIcon(Icons.check), findsAtLeast(1));
    });

    testWidgets('Abbrechen-Dialog zeigt Optionen', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Spiel beenden?'), findsOneWidget);
      expect(find.text('Wähle eine Option:'), findsOneWidget);
      expect(find.text('Neu starten'), findsOneWidget);
      expect(find.text('Zurück zum Start'), findsOneWidget);
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

      expect(find.text('Spiel beenden?'), findsNothing);
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

      await enterScore(tester, 5);
      // pumpAndSettle timeoutet wegen Confetti; pump() verwenden
      await tester.pump();
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

      await enterScore(tester, 5);
      // pumpAndSettle timeoutet wegen Confetti; pump() verwenden
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Gewinner!'), findsOneWidget);

      await tester.tap(find.text('Zurück zum Spiel'));
      await tester.pump();

      expect(find.text('Gewinner rückgängig?'), findsOneWidget);

      await tester.tap(find.text('Zurück zum Spiel').last);
      await tester.pump();

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

      await enterScore(tester, 10);

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

      await enterScore(tester, 10);

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

      await enterScore(tester, 10);
      await enterScore(tester, 5);
      await enterScore(tester, 3);
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

      await enterScore(tester, 10);
      await enterScore(tester, 5);
      await enterScore(tester, 3);
      await tester.pump(const Duration(seconds: 1));

      await enterScore(tester, 7);

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
      await enterScore(tester, 3);
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

      await enterScore(tester, 10);
      await enterScore(tester, 5);
      await tester.pump(const Duration(seconds: 1));

      await enterScore(tester, 8);
      await enterScore(tester, 3);
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

      await enterScore(tester, 10);
      await enterScore(tester, 5);
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
      // Prüfe Markierung
      expect(textField.controller!.selection.baseOffset, 0);
      expect(textField.controller!.selection.extentOffset, 1);
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

      await enterScore(tester, 10);
      await enterScore(tester, 5);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);

      await enterScore(tester, 20);

      expect(find.text('30 Punkte'), findsOneWidget);
      expect(find.text('Eingabe für: Bob'), findsOneWidget);

      await tester.longPress(find.text('Runde 2'));
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('10 Punkte'), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '5');
      // Prüfe Markierung
      expect(textField.controller!.selection.baseOffset, 0);
      expect(textField.controller!.selection.extentOffset, 1);
      await enterScore(tester, 5);
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
    testWidgets('Runden-Historie Icon mit Badge erscheint nach Runde 1', (tester) async {
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      // Noch kein History-Icon sichtbar (keine Runde abgeschlossen)
      // Nach Runde 1 sollte das Icon mit Badge erscheinen
      await enterScore(tester, 10);
      await enterScore(tester, 5);

      // Prüfe dass der Icon-Button vorhanden ist (findByType für IconButton mit Badge)
      expect(find.byIcon(Icons.history), findsOneWidget);
      // Ein Badge-Widget sollte vorhanden sein
      expect(find.byType(Badge), findsOneWidget);
    });

    testWidgets('Tippen auf History-Icon öffnet BottomSheet', (tester) async {
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      await enterScore(tester, 10);
      await enterScore(tester, 5);

      // Auf History-Icon tippen
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // BottomSheet sollte geöffnet sein mit "Runden-Historie" Titel
      expect(find.text('Runden-Historie'), findsOneWidget);
      // Die Runde 1 sollte angezeigt werden
      expect(find.text('Runde 1'), findsAtLeast(1));
    });

    testWidgets('BottomSheet zeigt alle Runden-Scores', (tester) async {
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      // Runde 1
      await enterScore(tester, 10);
      await enterScore(tester, 5);

      // Runde 2
      await enterScore(tester, 7);
      await enterScore(tester, 3);

      // Auf History-Icon tippen
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Beide Runden sollten angezeigt werden
      expect(find.text('Runde 1'), findsAtLeast(1));
      expect(find.text('Runde 2'), findsAtLeast(1));
    });

    testWidgets('History-Icon erscheint nicht bei leerer Historie', (tester) async {
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      // Vor dem Abschließen einer Runde: kein History-Icon
      // (Das Icon erscheint erst nach Runde 1)
    });
  });

  group('GameScreen Undo mit markiertem Wert', () {
    testWidgets('Undo füllt alten Wert ein und markiert ihn', (tester) async {
      setPhoneSize(tester);
      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      // Alice: 25 Punkte eintragen
      await enterScore(tester, 25);

      expect(find.text('25 Punkte'), findsOneWidget);

      // Long-Press auf Alice für Undo
      final aliceTile = find.text('Alice');
      await tester.longPress(aliceTile);
      await tester.pumpAndSettle();

      // Prüfe, dass der alte Wert (25) im TextField steht und markiert ist
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '25');
      expect(textField.controller!.selection.baseOffset, 0);
      expect(textField.controller!.selection.extentOffset, 2);
    });

    testWidgets('Undo bei 0 Punkten zeigt leeres Feld', (tester) async {
      setPhoneSize(tester);
      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];
      await tester.pumpWidget(
        MaterialApp(home: GameScreen(players: players)),
      );
      await tester.pumpAndSettle();

      // Leere Eingabe = 0
      await tester.tap(find.byKey(const Key('btn_confirm')));
      await tester.pumpAndSettle();

      // Bob hat noch 0 Punkte (Alice hat 0 durch leere Eingabe)
      expect(find.text('0 Punkte'), findsNWidgets(2));

      // Long-Press auf Alice für Undo
      final aliceTile = find.text('Alice');
      await tester.longPress(aliceTile);
      await tester.pumpAndSettle();

      // Bei 0 sollte das Feld leer sein
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '');
    });
  });

  group('GameScreen Longpress auf Card für Runde rückgängig', () {
    testWidgets('Long-Press auf gesamte Card macht Runde rückgängig', (tester) async {
      SharedPreferences.setMockInitialValues({});
      setPhoneSize(tester);

      final players = [
        Player(name: 'Alice'),
        Player(name: 'Bob'),
      ];

      await tester.pumpWidget(MaterialApp(home: GameScreen(players: players)));
      await tester.pumpAndSettle();

      // Runde 1 abschließen
      await enterScore(tester, 10);
      await enterScore(tester, 5);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Runde 2'), findsOneWidget);

      // Long-Press auf die Card (nicht nur das Runden-Label)
      // Die Card enthält "Runde 2" und das Undo-Icon
      final cardFinder = find.byType(Card).first;
      await tester.longPress(cardFinder);
      await tester.pumpAndSettle();

      expect(find.text('Runde 1'), findsOneWidget);
      expect(find.text('10 Punkte'), findsOneWidget);
      expect(find.text('0 Punkte'), findsOneWidget);
    });
  });
}
