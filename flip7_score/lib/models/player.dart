class Player {
  String name;
  int score;
  bool hasEnteredScore;
  int lastRoundScore; // Speichert den Score der letzten Runde für Undo

  Player({
    required this.name,
    this.score = 0,
    this.hasEnteredScore = false,
    this.lastRoundScore = 0,
  });

  void resetRoundScore() {
    hasEnteredScore = false;
  }

  void undoLastScore() {
    if (lastRoundScore >= 0) {
      score -= lastRoundScore;
      lastRoundScore = 0;
      hasEnteredScore = false;
    }
  }

  Player copyWith({
    String? name,
    int? score,
    bool? hasEnteredScore,
    int? lastRoundScore,
  }) {
    return Player(
      name: name ?? this.name,
      score: score ?? this.score,
      hasEnteredScore: hasEnteredScore ?? this.hasEnteredScore,
      lastRoundScore: lastRoundScore ?? this.lastRoundScore,
    );
  }
}
