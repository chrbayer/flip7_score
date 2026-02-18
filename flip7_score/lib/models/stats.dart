class PlayerStats {
  final String playerName;
  int highestRoundScore;
  int totalScore;
  int roundsPlayed;

  PlayerStats({
    required this.playerName,
    this.highestRoundScore = 0,
    this.totalScore = 0,
    this.roundsPlayed = 0,
  });

  double get averageScore => roundsPlayed > 0 ? totalScore / roundsPlayed : 0;

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'highestRoundScore': highestRoundScore,
    'totalScore': totalScore,
    'roundsPlayed': roundsPlayed,
  };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    playerName: json['playerName'],
    highestRoundScore: json['highestRoundScore'] ?? 0,
    totalScore: json['totalScore'] ?? 0,
    roundsPlayed: json['roundsPlayed'] ?? 0,
  );

  PlayerStats copyWith({
    String? playerName,
    int? highestRoundScore,
    int? totalScore,
    int? roundsPlayed,
  }) {
    return PlayerStats(
      playerName: playerName ?? this.playerName,
      highestRoundScore: highestRoundScore ?? this.highestRoundScore,
      totalScore: totalScore ?? this.totalScore,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
    );
  }
}

class GameStats {
  int totalGamesPlayed;
  int highestRoundScoreOverall;
  int totalPointsAllPlayers;

  GameStats({
    this.totalGamesPlayed = 0,
    this.highestRoundScoreOverall = 0,
    this.totalPointsAllPlayers = 0,
  });

  double get averagePointsPerGame =>
      totalGamesPlayed > 0 ? totalPointsAllPlayers / totalGamesPlayed : 0;

  Map<String, dynamic> toJson() => {
    'totalGamesPlayed': totalGamesPlayed,
    'highestRoundScoreOverall': highestRoundScoreOverall,
    'totalPointsAllPlayers': totalPointsAllPlayers,
  };

  factory GameStats.fromJson(Map<String, dynamic> json) => GameStats(
    totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
    highestRoundScoreOverall: json['highestRoundScoreOverall'] ?? 0,
    totalPointsAllPlayers: json['totalPointsAllPlayers'] ?? 0,
  );
}
