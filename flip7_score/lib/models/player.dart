class Player {
  String name;
  int score;
  bool hasEnteredScore;

  Player({
    required this.name,
    this.score = 0,
    this.hasEnteredScore = false,
  });

  void resetRoundScore() {
    hasEnteredScore = false;
  }

  Player copyWith({
    String? name,
    int? score,
    bool? hasEnteredScore,
  }) {
    return Player(
      name: name ?? this.name,
      score: score ?? this.score,
      hasEnteredScore: hasEnteredScore ?? this.hasEnteredScore,
    );
  }
}
