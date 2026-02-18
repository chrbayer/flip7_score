import 'package:flutter_test/flutter_test.dart';
import 'package:flip7_score/models/player.dart';

void main() {
  group('Player', () {
    test('erstellt Spieler mit Standardwerten', () {
      final player = Player(name: 'TestSpieler');

      expect(player.name, 'TestSpieler');
      expect(player.score, 0);
      expect(player.hasEnteredScore, false);
      expect(player.lastRoundScore, 0);
    });

    test('erstellt Spieler mit benutzerdefinierten Werten', () {
      final player = Player(
        name: 'TestSpieler',
        score: 50,
        hasEnteredScore: true,
        lastRoundScore: 25,
      );

      expect(player.score, 50);
      expect(player.hasEnteredScore, true);
      expect(player.lastRoundScore, 25);
    });

    test('resetRoundScore setzt hasEnteredScore auf false', () {
      final player = Player(name: 'Test', hasEnteredScore: true);

      player.resetRoundScore();

      expect(player.hasEnteredScore, false);
    });

    test('undoLastScore subtrahiert lastRoundScore vom GesamtScore', () {
      final player = Player(name: 'Test', score: 100, lastRoundScore: 25);

      player.undoLastScore();

      expect(player.score, 75);
      expect(player.lastRoundScore, 0);
      expect(player.hasEnteredScore, false);
    });

    test('undoLastScore mit 0 funktioniert korrekt', () {
      final player = Player(name: 'Test', score: 50, lastRoundScore: 0);

      player.undoLastScore();

      expect(player.score, 50);
      expect(player.hasEnteredScore, false);
    });

    test('copyWith erstellt Kopie mit geänderten Werten', () {
      final player = Player(name: 'Test', score: 10);

      final copy = player.copyWith(score: 20, name: 'NeuerName');

      expect(copy.name, 'NeuerName');
      expect(copy.score, 20);
      expect(player.name, 'Test'); // Original unverändert
      expect(player.score, 10);
    });
  });
}
