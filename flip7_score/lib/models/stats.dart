class PlayerStats {
  final String playerName;
  int highestRoundScore;
  int totalScore;
  int roundsPlayed;
  int gamesWon;
  int gamesPlayed;

  PlayerStats({
    required this.playerName,
    this.highestRoundScore = 0,
    this.totalScore = 0,
    this.roundsPlayed = 0,
    this.gamesWon = 0,
    this.gamesPlayed = 0,
  });

  double get averageScore => roundsPlayed > 0 ? totalScore / roundsPlayed : 0;

  double get winRate => gamesPlayed > 0 ? gamesWon / gamesPlayed : 0;

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'highestRoundScore': highestRoundScore,
    'totalScore': totalScore,
    'roundsPlayed': roundsPlayed,
    'gamesWon': gamesWon,
    'gamesPlayed': gamesPlayed,
  };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    playerName: json['playerName'],
    highestRoundScore: json['highestRoundScore'] ?? 0,
    totalScore: json['totalScore'] ?? 0,
    roundsPlayed: json['roundsPlayed'] ?? 0,
    gamesWon: json['gamesWon'] ?? 0,
    gamesPlayed: json['gamesPlayed'] ?? 0,
  );

  PlayerStats copyWith({
    String? playerName,
    int? highestRoundScore,
    int? totalScore,
    int? roundsPlayed,
    int? gamesWon,
    int? gamesPlayed,
  }) {
    return PlayerStats(
      playerName: playerName ?? this.playerName,
      highestRoundScore: highestRoundScore ?? this.highestRoundScore,
      totalScore: totalScore ?? this.totalScore,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
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

  GameStats copyWith({
    int? totalGamesPlayed,
    int? highestRoundScoreOverall,
    int? totalPointsAllPlayers,
  }) {
    return GameStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      highestRoundScoreOverall: highestRoundScoreOverall ?? this.highestRoundScoreOverall,
      totalPointsAllPlayers: totalPointsAllPlayers ?? this.totalPointsAllPlayers,
    );
  }
}
