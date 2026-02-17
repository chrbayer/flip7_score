import 'package:flutter/material.dart';
import '../models/player.dart';
import 'game_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _playerCount = 2;
  final List<TextEditingController> _nameControllers = [];
  final List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _initControllers(2);
  }

  void _initControllers(int count) {
    _nameControllers.clear();
    for (int i = 0; i < count; i++) {
      _nameControllers.add(TextEditingController(text: 'Spieler ${i + 1}'));
    }
  }

  void _updatePlayerCount(int count) {
    setState(() {
      _playerCount = count;
      _initControllers(count);
    });
  }

  void _startGame() {
    _players.clear();
    for (int i = 0; i < _playerCount; i++) {
      _players.add(Player(name: _nameControllers[i].text.trim().isEmpty
          ? 'Spieler ${i + 1}'
          : _nameControllers[i].text.trim()));
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(players: _players),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flip 7 - Neues Spiel'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Anzahl der Mitspieler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _playerCount > 2 ? () => _updatePlayerCount(_playerCount - 1) : null,
                  icon: const Icon(Icons.remove_circle),
                  iconSize: 36,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_playerCount',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _playerCount < 6 ? () => _updatePlayerCount(_playerCount + 1) : null,
                  icon: const Icon(Icons.add_circle),
                  iconSize: 36,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Spielernamen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _playerCount,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: _nameControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Spieler ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Spiel starten', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
