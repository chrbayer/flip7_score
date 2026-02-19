import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/player.dart';
import 'game_screen.dart';
import 'start_screen.dart';

class WinnerScreen extends StatefulWidget {
  final Player winner;
  final List<Player> allPlayers;

  const WinnerScreen({
    super.key,
    required this.winner,
    required this.allPlayers,
  });

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  late ConfettiController _confettiController;

  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    // Konfetti starten
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _restartWithSamePlayers(BuildContext context) {
    // Reset scores and round status
    for (var player in widget.allPlayers) {
      player.score = 0;
      player.hasEnteredScore = false;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(players: widget.allPlayers),
      ),
    );
  }

  void _confirmUndoWinner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gewinner rückgängig?'),
        content: Text(
          'Der letzte eingegebene Score von ${widget.winner.name} wird zurückgesetzt und das Spiel fortgesetzt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog schließen
              Navigator.pop(context, true); // WinnerScreen mit Ergebnis verlassen
            },
            child: const Text('Zurück zum Spiel'),
          ),
        ],
      ),
    );
  }

  void _startNewGame(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const StartScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gewinner!'),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Color(0xFFFFD700),
                ),
                const SizedBox(height: 24),
                const Text(
                  'GEWINNER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.winner.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.winner.score} Punkte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Endstand',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: _buildRankings(),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _restartWithSamePlayers(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Mit gleichen Spielern weiterspielen', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _startNewGame(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Neue Spieler auswählen', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => _confirmUndoWinner(context),
                  icon: const Icon(Icons.undo),
                  label: const Text('Zurück zum Spiel'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Konfetti von oben
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFFFFD700),
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
              ],
              numberOfParticles: 30,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRankings() {
    final sortedPlayers = List<Player>.from(widget.allPlayers)
      ..sort((a, b) => b.score.compareTo(a.score));

    if (_isTablet) {
      // Tablet: 2-Spalten-Layout mit GridView
      return [
        SizedBox(
          height: sortedPlayers.length * 40.0,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4,
            ),
            itemCount: sortedPlayers.length,
            itemBuilder: (context, index) {
              return _buildRankingTile(sortedPlayers[index], index == 0);
            },
          ),
        ),
      ];
    }

    return sortedPlayers.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      return _buildRankingTile(player, index == 0);
    }).toList();
  }

  Widget _buildRankingTile(Player player, bool isWinner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: isWinner
          ? BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWinner ? Icons.emoji_events : Icons.person,
                color: isWinner ? const Color(0xFFFFD700) : null,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  player.name,
                  style: TextStyle(
                    fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            '${player.score}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isWinner ? const Color(0xFFFFD700) : null,
            ),
          ),
        ],
      ),
    );
  }
}
