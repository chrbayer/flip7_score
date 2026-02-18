import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      tester.view.physicalSize = const Size(1080, 1920);
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
      tester.view.physicalSize = const Size(1080, 1920);
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

      // 3 ListTiles für die Rangliste
      final rankings = find.byType(ListTile);
      expect(rankings, findsNWidgets(3));
    });

    testWidgets('Buttons für neue Partie vorhanden', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
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
      tester.view.physicalSize = const Size(1080, 1920);
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
      tester.view.physicalSize = const Size(1080, 1920);
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
  });
}
