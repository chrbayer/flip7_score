class Round {
  final int roundNumber;
  final Map<String, int> playerScores; // playerName -> punkte dieser Runde

  Round({
    required this.roundNumber,
    required this.playerScores,
  });
}
