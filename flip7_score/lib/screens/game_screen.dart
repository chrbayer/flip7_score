import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/stats.dart';
import '../models/player.dart';
import '../models/round.dart';
import 'winner_screen.dart';
import 'start_screen.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players;
  final int scoreLimit;

  const GameScreen({super.key, required this.players, this.scoreLimit = 200});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int _currentRound = 1;
  int? _selectedPlayerIndex;
  final TextEditingController _scoreController = TextEditingController();
  final FocusNode _scoreFocusNode = FocusNode();
  final List<Round> _roundHistory = [];
  bool _historyExpanded = false;
  Map<int, int>? _pendingRoundState; // playerIndex → score bei Runden-Undo
  late AnimationController _roundAnimationController;
  late Animation<double> _roundScaleAnimation;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreScaleAnimation;
  String? _lastAnimatedPlayer;

  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  @override
  void initState() {
    super.initState();
    // Ersten Spieler auswählen
    _selectedPlayerIndex = 0;

    // Runde-Animationscontroller
    _roundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _roundScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _roundAnimationController,
      curve: Curves.easeInOut,
    ));

    // Score-Animationscontroller
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scoreScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _selectPlayer(int index) {
    // Nur Spieler auswählen die noch keinen Score eingetragen haben
    if (widget.players[index].hasEnteredScore) return;

    setState(() {
      _selectedPlayerIndex = index;
      _scoreController.clear();
    });
  }

  void _submitScore() {
    if (_selectedPlayerIndex == null) return;

    final scoreText = _scoreController.text.trim();
    final score = scoreText.isEmpty ? 0 : int.tryParse(scoreText);
    if (score == null || score < 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte eine gültige Zahl eingeben')),
      );
      return;
    }

    // Leichte Vibration bei erfolgreicher Eingabe
    HapticFeedback.lightImpact();

    // Spieler für Animation merken
    final playerName = widget.players[_selectedPlayerIndex!].name;

    setState(() {
      widget.players[_selectedPlayerIndex!].lastRoundScore = score;
      widget.players[_selectedPlayerIndex!].score += score;
      widget.players[_selectedPlayerIndex!].hasEnteredScore = true;

      // Check for winner
      if (widget.players[_selectedPlayerIndex!].score >= widget.scoreLimit) {
        _showWinnerDialog();
        return;
      }

      // Prüfen ob alle Spieler einen Score haben
      _checkRoundComplete();
    });

    // Score-Animation starten
    _lastAnimatedPlayer = playerName;
    _scoreAnimationController.forward(from: 0);
  }

  void _checkRoundComplete() {
    final allEntered = widget.players.every((p) => p.hasEnteredScore);
    if (allEntered) {
      // Runde in History speichern
      final roundScores = <String, int>{};
      for (var player in widget.players) {
        roundScores[player.name] = player.lastRoundScore;
      }
      final round = Round(
        roundNumber: _currentRound,
        playerScores: roundScores,
        lastPlayerIndex: _selectedPlayerIndex!,
      );
      _roundHistory.add(round);

      // Statistiken nach jeder abgeschlossenen Runde aktualisieren
      _updateRoundStats(round);

      // Runde abschließen und zur nächsten wechseln
      final savedPending = _pendingRoundState;
      _pendingRoundState = null;

      setState(() {
        for (var player in widget.players) {
          player.resetRoundScore();
        }
        _currentRound++;
        _scoreController.clear();

        if (savedPending != null && savedPending.isNotEmpty) {
          // Unterbrochenen Rundenteilstand wiederherstellen
          for (final entry in savedPending.entries) {
            final player = widget.players[entry.key];
            player.score += entry.value;
            player.lastRoundScore = entry.value;
            player.hasEnteredScore = true;
          }
          final idx = widget.players.indexWhere((p) => !p.hasEnteredScore);
          _selectedPlayerIndex = idx < 0 ? 0 : idx;
        } else {
          _selectedPlayerIndex = 0;
        }
      });
      // Runde-Animation starten
      _roundAnimationController.forward(from: 0);
      // Fokus auf TextField setzen
      FocusScope.of(context).requestFocus(_scoreFocusNode);
    } else {
      // Nächsten Spieler ohne Score auswählen
      int nextIndex = (_selectedPlayerIndex! + 1) % widget.players.length;
      while (widget.players[nextIndex].hasEnteredScore) {
        nextIndex = (nextIndex + 1) % widget.players.length;
      }
      setState(() {
        _selectedPlayerIndex = nextIndex;
        _scoreController.clear();
      });
      // Fokus auf TextField setzen
      FocusScope.of(context).requestFocus(_scoreFocusNode);
    }
  }

  void _undoLastScore(int index) {
    final player = widget.players[index];
    if (!player.hasEnteredScore) return;

    // Mittlere Vibration bei Undo
    HapticFeedback.mediumImpact();

    setState(() {
      player.undoLastScore();
      // Wenn der Spieler der aktuell ausgewählte war, bleib ausgewählt
      // sonst wähle den ersten Spieler ohne Score
      if (_selectedPlayerIndex != index) {
        _selectedPlayerIndex = index;
      }
      _scoreController.clear();
    });
  }

  Future<void> _updateRoundStats(Round round) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // GameStats: Rundenpunkte und höchsten Rundenscore aktualisieren
      final gamesJson = prefs.getString('gameStats');
      GameStats gameStats = gamesJson != null
          ? GameStats.fromJson(jsonDecode(gamesJson))
          : GameStats();

      final roundTotal = round.playerScores.values.fold(0, (a, b) => a + b);
      gameStats.totalPointsAllPlayers += roundTotal;

      for (final score in round.playerScores.values) {
        if (score > gameStats.highestRoundScoreOverall) {
          gameStats.highestRoundScoreOverall = score;
        }
      }

      await prefs.setString('gameStats', jsonEncode(gameStats.toJson()));

      // Spieler-Statistiken aktualisieren
      final playersJson = prefs.getString('playerStats') ?? '[]';
      final List<dynamic> playersData = jsonDecode(playersJson);
      List<PlayerStats> playerStatsList =
          playersData.map((e) => PlayerStats.fromJson(e)).toList();

      for (final entry in round.playerScores.entries) {
        final playerName = entry.key;
        final roundScore = entry.value;

        final existingIndex = playerStatsList.indexWhere(
            (ps) => ps.playerName.toLowerCase() == playerName.toLowerCase());

        if (existingIndex >= 0) {
          final ps = playerStatsList[existingIndex];
          playerStatsList[existingIndex] = ps.copyWith(
            highestRoundScore: roundScore > ps.highestRoundScore
                ? roundScore
                : ps.highestRoundScore,
            totalScore: ps.totalScore + roundScore,
            roundsPlayed: ps.roundsPlayed + 1,
          );
        } else {
          playerStatsList.add(PlayerStats(
            playerName: playerName,
            highestRoundScore: roundScore,
            totalScore: roundScore,
            roundsPlayed: 1,
          ));
        }
      }

      await prefs.setString(
          'playerStats', jsonEncode(playerStatsList.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Fehler beim Speichern der Rundenstatistiken: $e');
    }
  }

  Future<void> _updateGameStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gamesJson = prefs.getString('gameStats');
      GameStats gameStats = gamesJson != null
          ? GameStats.fromJson(jsonDecode(gamesJson))
          : GameStats();
      gameStats.totalGamesPlayed++;
      await prefs.setString('gameStats', jsonEncode(gameStats.toJson()));
    } catch (e) {
      debugPrint('Fehler beim Speichern der Spielstatistiken: $e');
    }
  }

  Future<void> _undoRoundStats(Round round, {bool isWinningRound = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final gamesJson = prefs.getString('gameStats');
      GameStats gameStats = gamesJson != null
          ? GameStats.fromJson(jsonDecode(gamesJson))
          : GameStats();

      final roundTotal = round.playerScores.values.fold(0, (a, b) => a + b);
      gameStats.totalPointsAllPlayers =
          (gameStats.totalPointsAllPlayers - roundTotal).clamp(0, double.maxFinite.toInt());

      await prefs.setString('gameStats', jsonEncode(gameStats.toJson()));

      final playersJson = prefs.getString('playerStats') ?? '[]';
      final List<dynamic> playersData = jsonDecode(playersJson);
      List<PlayerStats> playerStatsList =
          playersData.map((e) => PlayerStats.fromJson(e)).toList();

      for (final entry in round.playerScores.entries) {
        final playerName = entry.key;
        final roundScore = entry.value;

        final existingIndex = playerStatsList.indexWhere(
            (ps) => ps.playerName.toLowerCase() == playerName.toLowerCase());

        if (existingIndex >= 0) {
          final ps = playerStatsList[existingIndex];
          // Gewinnername ermitteln aus lastPlayerIndex
          final winnerName = round.lastPlayerIndex != null && round.lastPlayerIndex! < widget.players.length
              ? widget.players[round.lastPlayerIndex!].name
              : '';
          playerStatsList[existingIndex] = ps.copyWith(
            totalScore: (ps.totalScore - roundScore).clamp(0, ps.totalScore),
            roundsPlayed: (ps.roundsPlayed - 1).clamp(0, ps.roundsPlayed),
            // Bei Gewinner-Runde: Spiele gespielt und gewonnen reduzieren
            gamesPlayed: isWinningRound
                ? (ps.gamesPlayed - 1).clamp(0, ps.gamesPlayed)
                : ps.gamesPlayed,
            gamesWon: isWinningRound && ps.playerName.toLowerCase() == winnerName.toLowerCase()
                ? (ps.gamesWon - 1).clamp(0, ps.gamesWon)
                : ps.gamesWon,
          );
        }
      }

      await prefs.setString(
          'playerStats', jsonEncode(playerStatsList.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Fehler beim Rückgängigmachen der Rundenstatistiken: $e');
    }
  }

  /// Aktualisiert Spieler-Statistiken wenn ein Gewinner ermittelt wird
  Future<void> _updateGamePlayerStats(List<Player> players, Player winner) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playersJson = prefs.getString('playerStats') ?? '[]';
      final List<dynamic> playersData = jsonDecode(playersJson);
      List<PlayerStats> playerStatsList =
          playersData.map((e) => PlayerStats.fromJson(e)).toList();

      for (final player in players) {
        final existingIndex = playerStatsList.indexWhere(
            (ps) => ps.playerName.toLowerCase() == player.name.toLowerCase());

        if (existingIndex >= 0) {
          final ps = playerStatsList[existingIndex];
          playerStatsList[existingIndex] = ps.copyWith(
            gamesPlayed: ps.gamesPlayed + 1,
            gamesWon: player.name.toLowerCase() == winner.name.toLowerCase()
                ? ps.gamesWon + 1
                : ps.gamesWon,
          );
        } else {
          playerStatsList.add(PlayerStats(
            playerName: player.name,
            gamesPlayed: 1,
            gamesWon: player.name.toLowerCase() == winner.name.toLowerCase() ? 1 : 0,
          ));
        }
      }

      await prefs.setString(
          'playerStats', jsonEncode(playerStatsList.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Fehler beim Aktualisieren der Spielerstatistiken: $e');
    }
  }

  void _undoLastRound() {
    if (_currentRound <= 1 || _roundHistory.isEmpty) return;

    HapticFeedback.mediumImpact();

    // Aktuellen Teilstand der laufenden Runde sichern und rückgängig machen
    final pendingState = <int, int>{};
    for (int i = 0; i < widget.players.length; i++) {
      final player = widget.players[i];
      if (player.hasEnteredScore) {
        pendingState[i] = player.lastRoundScore;
        player.score -= player.lastRoundScore;
        player.hasEnteredScore = false;
        player.lastRoundScore = 0;
      }
    }
    _pendingRoundState = pendingState.isNotEmpty ? pendingState : null;

    final lastRound = _roundHistory.removeLast();
    final lastPlayerIndex = lastRound.lastPlayerIndex;
    final lastPlayer = widget.players[lastPlayerIndex];
    final lastPlayerScore = lastRound.playerScores[lastPlayer.name] ?? 0;

    // Alle Spieler außer dem letzten behalten ihren Rundenstand (hasEnteredScore = true),
    // können aber per Long-Press noch geändert werden.
    // Der letzte Spieler gibt seinen Score neu ein → sein Rundenanteil wird entfernt.
    for (int i = 0; i < widget.players.length; i++) {
      final player = widget.players[i];
      final roundScore = lastRound.playerScores[player.name] ?? 0;
      if (i == lastPlayerIndex) {
        player.score -= roundScore;
        player.hasEnteredScore = false;
        player.lastRoundScore = 0;
      } else {
        player.hasEnteredScore = true;
        player.lastRoundScore = roundScore;
      }
    }

    setState(() {
      _currentRound--;
      _selectedPlayerIndex = lastPlayerIndex;
      _scoreController.text = lastPlayerScore > 0 ? lastPlayerScore.toString() : '';
      _lastAnimatedPlayer = null;
    });

    FocusScope.of(context).requestFocus(_scoreFocusNode);
    _undoRoundStats(lastRound);
  }

  void _showWinnerDialog() async {
    final winner = widget.players[_selectedPlayerIndex!];
    final winnerLastScore = winner.lastRoundScore;

    // Aktuelle (evtl. unvollständige) Runde speichern – nicht eingegebene Spieler zählen mit 0
    final roundScores = <String, int>{};
    for (var player in widget.players) {
      roundScores[player.name] = player.lastRoundScore;
    }
    final winningRound = Round(
      roundNumber: _currentRound,
      playerScores: roundScores,
      lastPlayerIndex: _selectedPlayerIndex!,
    );
    _roundHistory.add(winningRound);
    await _updateRoundStats(winningRound);

    // Spielzähler aktualisieren
    await _updateGameStats();

    // Spieler-Statistiken für Gewinn aktualisieren
    await _updateGamePlayerStats(widget.players, winner);

    if (!mounted) return;

    final undone = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => WinnerScreen(
          winner: winner,
          allPlayers: widget.players,
        ),
      ),
    );

    if (undone == true && mounted) {
      _roundHistory.removeLast();
      await _undoRoundStats(winningRound, isWinningRound: true);
      await _undoGameStats();
      winner.score -= winnerLastScore;
      winner.hasEnteredScore = false;
      setState(() {
        _selectedPlayerIndex = widget.players.indexOf(winner);
        _scoreController.text = winnerLastScore > 0 ? winnerLastScore.toString() : '';
        _lastAnimatedPlayer = null;
      });
      FocusScope.of(context).requestFocus(_scoreFocusNode);
    }
  }

  Future<void> _undoGameStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gamesJson = prefs.getString('gameStats');
      GameStats gameStats = gamesJson != null
          ? GameStats.fromJson(jsonDecode(gamesJson))
          : GameStats();
      gameStats.totalGamesPlayed =
          (gameStats.totalGamesPlayed - 1).clamp(0, gameStats.totalGamesPlayed);
      await prefs.setString('gameStats', jsonEncode(gameStats.toJson()));
    } catch (e) {
      debugPrint('Fehler beim Rückgängigmachen der Spielstatistiken: $e');
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spiel abbrechen?'),
        content: const Text('Was möchten Sie tun?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartWithSamePlayers();
            },
            child: const Text('Mit gleichen Spielern'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text('Neue Spieler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Weiterspielen'),
          ),
        ],
      ),
    );
  }

  void _restartWithSamePlayers() {
    for (var player in widget.players) {
      player.score = 0;
      player.hasEnteredScore = false;
    }
    setState(() {
      _currentRound = 1;
      _selectedPlayerIndex = 0;
      _scoreController.clear();
      _roundHistory.clear();
      _historyExpanded = false;
    });
    // Fokus auf TextField setzen
    FocusScope.of(context).requestFocus(_scoreFocusNode);
  }

  void _startNewGame() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const StartScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _scoreFocusNode.dispose();
    _roundAnimationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Flip 7 - Spielstand'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showCancelDialog,
            tooltip: 'Spiel abbrechen',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isTablet)
              _buildTabletHeader()
            else
              _buildPhoneHeader(),
            // Runden-Historie (ausklappbar) - nur im Phone-Modus, im Tablet ist sie im Header
            if (!_isTablet && _roundHistory.isNotEmpty) ...[
              const SizedBox(height: 8),
              Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.history),
                  title: Text('Runden (${_roundHistory.length})'),
                  trailing: Icon(
                    _historyExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _historyExpanded = expanded;
                    });
                  },
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _roundHistory.length,
                      itemBuilder: (context, index) {
                        final round = _roundHistory[index];
                        final scoresText = round.playerScores.entries
                            .map((e) => '${e.key}: +${e.value}')
                            .join(', ');
                        return ListTile(
                          dense: true,
                          title: Text('Runde ${round.roundNumber}'),
                          subtitle: Text(scoresText),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_isTablet) ...[
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildScoreInput()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPlayerList()),
                  ],
                ),
              ),
            ] else ...[
              _buildScoreInput(),
              const SizedBox(height: 24),
              const Text(
                'Spielstände',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildPlayerList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabletHeader() {
    return Row(
      children: [
        Expanded(child: _buildRoundCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildHistoryCard()),
      ],
    );
  }

  Widget _buildPhoneHeader() {
    return Column(children: [_buildRoundCard()]);
  }

  Widget _buildRoundCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onLongPress: _currentRound > 1 ? _undoLastRound : null,
              child: AnimatedBuilder(
                animation: _roundScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _roundScaleAnimation.value,
                    child: child,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Runde $_currentRound',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_currentRound > 1) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.undo,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedPlayerIndex != null)
              Text(
                'Eingabe für: ${widget.players[_selectedPlayerIndex!].name}',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    if (_roundHistory.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.history),
        title: Text('Runden (${_roundHistory.length})'),
        trailing: Icon(
          _historyExpanded ? Icons.expand_less : Icons.expand_more,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _historyExpanded = expanded;
          });
        },
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _roundHistory.length,
            itemBuilder: (context, index) {
              final round = _roundHistory[index];
              final scoresText = round.playerScores.entries
                  .map((e) => '${e.key}: +${e.value}')
                  .join(', ');
              return ListTile(
                dense: true,
                title: Text('Runde ${round.roundNumber}'),
                subtitle: Text(scoresText),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _scoreController,
          focusNode: _scoreFocusNode,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Punkte eingeben',
            hintText: '0',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.add_circle_outline),
          ),
          onSubmitted: (_) => _submitScore(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submitScore,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Punkte eintragen', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildPlayerList() {
    if (_isTablet) {
      return Card(
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4.0,
          ),
          itemCount: widget.players.length,
          itemBuilder: (context, index) {
            return _buildPlayerTile(index);
          },
        ),
      );
    }

    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: widget.players.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return _buildPlayerTile(index);
        },
      ),
    );
  }

  Widget _buildPlayerTile(int index) {
    final player = widget.players[index];
    final isSelected = index == _selectedPlayerIndex;
    final hasEntered = player.hasEnteredScore;

    if (_isTablet) {
      // Tablet: kompaktes Row-Layout
      return InkWell(
        onTap: () => _selectPlayer(index),
        onLongPress: hasEntered ? () => _undoLastScore(index) : null,
        child: Container(
          color: hasEntered
              ? Colors.green.withValues(alpha: 0.1)
              : isSelected
                  ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : null,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: hasEntered
                    ? Colors.green
                    : isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                child: hasEntered
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  player.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                    color: hasEntered ? Colors.green[700] : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AnimatedBuilder(
                animation: _scoreScaleAnimation,
                builder: (context, child) {
                  final shouldAnimate = _lastAnimatedPlayer == player.name;
                  return Transform.scale(
                    scale: shouldAnimate ? _scoreScaleAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: Text(
                  '${player.score}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: player.score >= widget.scoreLimit
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Phone: ListTile-Layout (für Tests kompatibel)
    return InkWell(
      onTap: () => _selectPlayer(index),
      onLongPress: hasEntered ? () => _undoLastScore(index) : null,
      child: Container(
        color: hasEntered
            ? Colors.green.withValues(alpha: 0.1)
            : isSelected
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: hasEntered
                ? Colors.green
                : isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary,
            child: hasEntered
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
          title: Text(
            player.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
              color: hasEntered ? Colors.green[700] : null,
            ),
          ),
          trailing: AnimatedBuilder(
            animation: _scoreScaleAnimation,
            builder: (context, child) {
              final shouldAnimate = _lastAnimatedPlayer == player.name;
              return Transform.scale(
                scale: shouldAnimate ? _scoreScaleAnimation.value : 1.0,
                child: child,
              );
            },
            child: Text(
              '${player.score} Punkte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: player.score >= widget.scoreLimit
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
