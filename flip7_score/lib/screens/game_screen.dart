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
  int? _selectedPlayerIndex;
  final TextEditingController _scoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ersten Spieler auswählen
    _selectedPlayerIndex = 0;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte eine gültige Zahl eingeben')),
      );
      return;
    }

    setState(() {
      widget.players[_selectedPlayerIndex!].score += score;
      widget.players[_selectedPlayerIndex!].hasEnteredScore = true;

      // Check for winner
      if (widget.players[_selectedPlayerIndex!].score >= 200) {
        _showWinnerDialog();
        return;
      }

      // Prüfen ob alle Spieler einen Score haben
      _checkRoundComplete();
    });
  }

  void _checkRoundComplete() {
    final allEntered = widget.players.every((p) => p.hasEnteredScore);
    if (allEntered) {
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
    } else {
      // Nächsten Spieler ohne Score auswählen
      int nextIndex = (_selectedPlayerIndex! + 1) % widget.players.length;
      while (widget.players[nextIndex].hasEnteredScore) {
        nextIndex = (nextIndex + 1) % widget.players.length;
      }
      _selectedPlayerIndex = nextIndex;
      _scoreController.clear();
    }
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

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
