import 'package:flutter_test/flutter_test.dart';
import 'package:flip7_score/models/stats.dart';

void main() {
  group('PlayerStats', () {
    test('erstellt SpielerStats mit Standardwerten', () {
      final stats = PlayerStats(playerName: 'Max');
      expect(stats.playerName, 'Max');
      expect(stats.highestRoundScore, 0);
      expect(stats.totalScore, 0);
      expect(stats.roundsPlayed, 0);
    });

    test('averageScore berechnet korrekt', () {
      final stats = PlayerStats(playerName: 'Max', totalScore: 100, roundsPlayed: 4);
      expect(stats.averageScore, 25.0);
    });

    test('averageScore gibt 0 zurück bei 0 Runden', () {
      final stats = PlayerStats(playerName: 'Max', totalScore: 0, roundsPlayed: 0);
      expect(stats.averageScore, 0.0);
    });

    test('toJson erstellt korrekte Map', () {
      final stats = PlayerStats(
        playerName: 'Max',
        highestRoundScore: 50,
        totalScore: 150,
        roundsPlayed: 3,
      );
      final json = stats.toJson();
      expect(json['playerName'], 'Max');
      expect(json['highestRoundScore'], 50);
      expect(json['totalScore'], 150);
      expect(json['roundsPlayed'], 3);
    });

    test('fromJson erstellt korrektes Objekt', () {
      final json = {
        'playerName': 'Max',
        'highestRoundScore': 50,
        'totalScore': 150,
        'roundsPlayed': 3,
      };
      final stats = PlayerStats.fromJson(json);
      expect(stats.playerName, 'Max');
      expect(stats.highestRoundScore, 50);
      expect(stats.totalScore, 150);
      expect(stats.roundsPlayed, 3);
    });

    test('fromJson mit fehlenden Werten verwendet Standardwerte', () {
      final json = {'playerName': 'Max'};
      final stats = PlayerStats.fromJson(json);
      expect(stats.highestRoundScore, 0);
      expect(stats.totalScore, 0);
      expect(stats.roundsPlayed, 0);
    });

    test('copyWith erstellt Kopie mit geänderten Werten', () {
      final stats = PlayerStats(playerName: 'Max', totalScore: 100);
      final copied = stats.copyWith(totalScore: 150, roundsPlayed: 2);
      expect(copied.playerName, 'Max');
      expect(copied.totalScore, 150);
      expect(copied.roundsPlayed, 2);
    });
  });

  group('GameStats', () {
    test('erstellt GameStats mit Standardwerten', () {
      final stats = GameStats();
      expect(stats.totalGamesPlayed, 0);
      expect(stats.highestRoundScoreOverall, 0);
      expect(stats.totalPointsAllPlayers, 0);
    });

    test('averagePointsPerGame berechnet korrekt', () {
      final stats = GameStats(totalGamesPlayed: 5, totalPointsAllPlayers: 500);
      expect(stats.averagePointsPerGame, 100.0);
    });

    test('averagePointsPerGame gibt 0 zurück bei 0 Spielen', () {
      final stats = GameStats(totalGamesPlayed: 0, totalPointsAllPlayers: 0);
      expect(stats.averagePointsPerGame, 0.0);
    });

    test('toJson erstellt korrekte Map', () {
      final stats = GameStats(
        totalGamesPlayed: 10,
        highestRoundScoreOverall: 77,
        totalPointsAllPlayers: 1500,
      );
      final json = stats.toJson();
      expect(json['totalGamesPlayed'], 10);
      expect(json['highestRoundScoreOverall'], 77);
      expect(json['totalPointsAllPlayers'], 1500);
    });

    test('fromJson erstellt korrektes Objekt', () {
      final json = {
        'totalGamesPlayed': 10,
        'highestRoundScoreOverall': 77,
        'totalPointsAllPlayers': 1500,
      };
      final stats = GameStats.fromJson(json);
      expect(stats.totalGamesPlayed, 10);
      expect(stats.highestRoundScoreOverall, 77);
      expect(stats.totalPointsAllPlayers, 1500);
    });

    test('fromJson mit fehlenden Werten verwendet Standardwerte', () {
      final json = <String, dynamic>{};
      final stats = GameStats.fromJson(json);
      expect(stats.totalGamesPlayed, 0);
      expect(stats.highestRoundScoreOverall, 0);
      expect(stats.totalPointsAllPlayers, 0);
    });
  });
}
