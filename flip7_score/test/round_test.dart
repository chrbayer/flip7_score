import 'package:flutter_test/flutter_test.dart';
import 'package:flip7_score/models/round.dart';

void main() {
  group('Round', () {
    test('erstellt Runde mit allen Parametern', () {
      final scores = {'Alice': 10, 'Bob': 5};
      final round = Round(
        roundNumber: 1,
        playerScores: scores,
        lastPlayerIndex: 1,
      );

      expect(round.roundNumber, 1);
      expect(round.playerScores, scores);
      expect(round.lastPlayerIndex, 1);
    });

    test('leere Runde funktioniert', () {
      final round = Round(
        roundNumber: 1,
        playerScores: {},
        lastPlayerIndex: 0,
      );

      expect(round.roundNumber, 1);
      expect(round.playerScores, isEmpty);
      expect(round.lastPlayerIndex, 0);
    });

    test('Runde mit einem Spieler', () {
      final round = Round(
        roundNumber: 3,
        playerScores: {'Alice': 25},
        lastPlayerIndex: 0,
      );

      expect(round.roundNumber, 3);
      expect(round.playerScores['Alice'], 25);
      expect(round.playerScores.length, 1);
    });
  });
}
