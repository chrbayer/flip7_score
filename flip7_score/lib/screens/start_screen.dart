import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final List<String> _usedPlayerNames = []; // Historie aller verwendeten Namen
  final List<String> _modifiedNames = []; // Namen die vom User angepasst wurden

  @override
  void initState() {
    super.initState();
    _initControllers(2);
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCount = prefs.getInt('playerCount') ?? 2;
    final savedNames = prefs.getStringList('playerNames');
    final savedUsedNames = prefs.getStringList('usedPlayerNames');
    final savedModifiedNames = prefs.getStringList('modifiedNames');

    setState(() {
      _playerCount = savedCount;
      _initControllers(savedCount);

      if (savedNames != null) {
        for (int i = 0; i < savedNames.length && i < _nameControllers.length; i++) {
          _nameControllers[i].text = savedNames[i];
        }
      }

      if (savedUsedNames != null) {
        _usedPlayerNames.addAll(savedUsedNames);
      }

      if (savedModifiedNames != null) {
        _modifiedNames.addAll(savedModifiedNames);
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('playerCount', _playerCount);

    final names = _nameControllers
        .map((c) => c.text.trim().isEmpty ? 'Spieler ${_nameControllers.indexOf(c) + 1}' : c.text.trim())
        .toList();
    await prefs.setStringList('playerNames', names);
    await prefs.setStringList('usedPlayerNames', _usedPlayerNames);
  }

  String _getNextPlayerName(int index, int previousCount) {
    // Prüfe, ob der Default-Name "Spieler N" bereits in der Historie ist
    final defaultName = 'Spieler ${index + 1}';

    // Suche in der Historie nach einem bereits verwendeten Namen
    if (_usedPlayerNames.contains(defaultName)) {
      // Default-Name wurde schon mal verwendet, suche einen neuen
      int counter = 2;
      String newName = '$defaultName ($counter)';
      while (_usedPlayerNames.contains(newName)) {
        counter++;
        newName = '$defaultName ($counter)';
      }
      return newName;
    }

    // Default-Name wurde noch nie verwendet
    return defaultName;
  }

  void _initControllers(int count, [List<String>? previousNames]) {
    final previousCount = _nameControllers.length;
    final namesToUse = previousNames ?? _nameControllers.map((c) => c.text).toList();
    _nameControllers.clear();

    for (int i = 0; i < count; i++) {
      final controller = TextEditingController();

      if (i < previousCount && i < namesToUse.length && namesToUse[i].trim().isNotEmpty) {
        // Behalte den existierenden Namen wenn möglich
        controller.text = namesToUse[i];
      } else {
        // Neuer Spieler: hol den nächsten verfügbaren Namen
        controller.text = _getNextPlayerName(i, previousCount);
      }

      _nameControllers.add(controller);
    }
  }

  void _updatePlayerCount(int count) {
    // Sichere aktuelle Namen bevor neue Controller erstellt werden
    final currentNames = _nameControllers.map((c) => c.text.trim()).toList();

    // Aktualisiere die Historie der verwendeten Namen bevor die Controller verworfen werden
    for (int i = 0; i < _playerCount; i++) {
      if (i < currentNames.length && currentNames[i].isNotEmpty) {
        if (!_usedPlayerNames.contains(currentNames[i])) {
          _usedPlayerNames.add(currentNames[i]);
        }
      }
    }

    // Speichere die Historie sofort in die SharedPreferences
    _saveUsedNamesToPrefs();

    setState(() {
      _playerCount = count;
      _initControllers(count, currentNames);
    });
  }

  Future<void> _saveUsedNamesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('usedPlayerNames', _usedPlayerNames);
  }

  void _startGame() {
    // Aktualisiere die Historie der verwendeten Namen
    for (int i = 0; i < _playerCount; i++) {
      final name = _nameControllers[i].text.trim().isEmpty
          ? 'Spieler ${i + 1}'
          : _nameControllers[i].text.trim();
      if (!_usedPlayerNames.contains(name)) {
        _usedPlayerNames.add(name);
      }
    }

    _saveData();

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
                      textCapitalization: TextCapitalization.words,
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
