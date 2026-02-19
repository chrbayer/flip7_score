class Round {
  final int roundNumber;
  final Map<String, int> playerScores; // playerName -> punkte dieser Runde
  final int lastPlayerIndex; // Index des zuletzt eingebenden Spielers

  Round({
    required this.roundNumber,
    required this.playerScores,
    required this.lastPlayerIndex,
  });
}
