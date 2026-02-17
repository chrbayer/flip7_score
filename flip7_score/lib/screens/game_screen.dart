import 'package:flutter/material.dart';
import '../models/player.dart';
import 'winner_screen.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players;

  const GameScreen({super.key, required this.players});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentRound = 1;
  int _currentPlayerIndex = 0;
  final TextEditingController _scoreController = TextEditingController();
  bool _isInputPhase = true;

  void _submitScore() {
    final scoreText = _scoreController.text.trim();
    // Leere Eingabe als 0 interpretieren
    final score = scoreText.isEmpty ? 0 : int.tryParse(scoreText);
    if (score == null || score < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte eine gültige Zahl eingeben')),
      );
      return;
    }

    setState(() {
      widget.players[_currentPlayerIndex].score += score;

      // Check for winner
      if (widget.players[_currentPlayerIndex].score >= 200) {
        _showWinnerDialog();
        return;
      }

      _currentPlayerIndex++;
      if (_currentPlayerIndex >= widget.players.length) {
        _currentPlayerIndex = 0;
        _currentRound++;
      }
      _scoreController.clear();
    });
  }

  void _showWinnerDialog() {
    final winner = widget.players[_currentPlayerIndex];
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

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = widget.players[_currentPlayerIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flip 7 - Spielstand'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
                    Text(
                      'Runde $_currentRound',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aktuell: ${currentPlayer.name}',
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
            const SizedBox(height: 16),
            TextField(
              controller: _scoreController,
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
              'Aktueller Spielstand',
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
                    final isCurrentPlayer = index == _currentPlayerIndex;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrentPlayer
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: TextStyle(
                          fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      trailing: Text(
                        '${player.score} Punkte',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: player.score >= 200
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
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
