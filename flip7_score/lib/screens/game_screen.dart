import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late AnimationController _roundAnimationController;
  late Animation<double> _roundScaleAnimation;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreScaleAnimation;
  String? _lastAnimatedPlayer;

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
      _roundHistory.add(Round(
        roundNumber: _currentRound,
        playerScores: roundScores,
      ));

      // Runde abschließen und zur nächsten wechseln
      setState(() {
        for (var player in widget.players) {
          player.resetRoundScore();
        }
        _currentRound++;
        // Ersten Spieler auswählen der noch keinen Score hat (alle sind falsch)
        _selectedPlayerIndex = 0;
        _scoreController.clear();
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

  void _showWinnerDialog() {
    final winner = widget.players[_selectedPlayerIndex!];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WinnerScreen(
          winner: winner,
          allPlayers: widget.players,
        ),
      ),
    );
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
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _roundScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _roundScaleAnimation.value,
                          child: child,
                        );
                      },
                      child: Text(
                        'Runde $_currentRound',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            ),
            // Runden-Historie (ausklappbar)
            if (_roundHistory.isNotEmpty) ...[
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
            const SizedBox(height: 24),
            const Text(
              'Spielstände',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: widget.players.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final player = widget.players[index];
                    final isSelected = index == _selectedPlayerIndex;
                    final hasEntered = player.hasEnteredScore;

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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
