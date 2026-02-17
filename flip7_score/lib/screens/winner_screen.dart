import 'package:flutter/material.dart';
import '../models/player.dart';
import 'game_screen.dart';
import 'start_screen.dart';

class WinnerScreen extends StatelessWidget {
  final Player winner;
  final List<Player> allPlayers;

  const WinnerScreen({
    super.key,
    required this.winner,
    required this.allPlayers,
  });

  void _restartWithSamePlayers(BuildContext context) {
    // Reset scores
    for (var player in allPlayers) {
      player.score = 0;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(players: allPlayers),
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
      body: Padding(
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
              winner.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${winner.score} Punkte',
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
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRankings() {
    final sortedPlayers = List<Player>.from(allPlayers)
      ..sort((a, b) => b.score.compareTo(a.score));

    return sortedPlayers.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final isWinner = index == 0;

      return ListTile(
        leading: Icon(
          isWinner ? Icons.emoji_events : Icons.person,
          color: isWinner ? const Color(0xFFFFD700) : null,
        ),
        title: Text(
          player.name,
          style: TextStyle(
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        trailing: Text(
          '${player.score}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isWinner ? const Color(0xFFFFD700) : null,
          ),
        ),
      );
    }).toList();
  }
}
