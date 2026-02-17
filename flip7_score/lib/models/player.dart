class Player {
  String name;
  int score;

  Player({
    required this.name,
    this.score = 0,
  });

  Player copyWith({
    String? name,
    int? score,
  }) {
    return Player(
      name: name ?? this.name,
      score: score ?? this.score,
    );
  }
}
