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
  final List<FocusNode> _nameFocusNodes = [];
  // Zuletzt bestätigte Namen (parallel zu _nameControllers),
  // dient als Referenz um manuelle Änderungen zu erkennen.
  final List<String> _committedNames = [];
  final List<Player> _players = [];
  List<String> _recentNames = [];

  @override
  void initState() {
    super.initState();
    _addController('Spieler 1');
    _addController('Spieler 2');
    _loadSavedData();
  }

  void _addController(String text) {
    _nameControllers.add(TextEditingController(text: text));
    _nameFocusNodes.add(FocusNode());
    _committedNames.add(text);
  }

  /// Vergleicht aktuelle Controller-Texte mit _committedNames für die ersten
  /// [keepCount] Slots und pflegt _recentNames entsprechend.
  /// Muss VOR jeder Zähleränderung oder vor _saveData aufgerufen werden.
  void _reconcileChangedNames(int keepCount) {
    for (int i = 0; i < keepCount; i++) {
      final oldName = _committedNames[i].trim();
      final newName = _nameControllers[i].text.trim();
      if (oldName == newName) continue;

      if (oldName.isNotEmpty) {
        // Alten Namen in History aufnehmen, wenn er nicht noch in einem anderen Slot steht
        final usedByOther = _nameControllers
            .asMap()
            .entries
            .any((e) => e.key != i && e.value.text.trim() == oldName);
        if (!usedByOther) {
          _recentNames.remove(oldName);
          _recentNames.insert(0, oldName);
        }
      }
      // Neuen Namen aus History entfernen (kein Duplikat beim nächsten Vorschlag)
      _recentNames.remove(newName);
      _committedNames[i] = _nameControllers[i].text;
    }
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCount = prefs.getInt('playerCount') ?? 2;
      final savedNames = prefs.getStringList('playerNames') ?? [];
      final savedRecent = prefs.getStringList('recentNames') ?? [];

      setState(() {
        _playerCount = savedCount;
        _recentNames = savedRecent;

        for (var c in _nameControllers) c.dispose();
        for (var f in _nameFocusNodes) f.dispose();
        _nameControllers.clear();
        _nameFocusNodes.clear();
        _committedNames.clear();

        for (int i = 0; i < savedCount; i++) {
          final name = (i < savedNames.length && savedNames[i].isNotEmpty)
              ? savedNames[i]
              : 'Spieler ${i + 1}';
          _addController(name);
        }
      });
    } catch (e) {
      // Fallback auf Standardwerte bei Fehler
      debugPrint('Fehler beim Laden der Daten: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('playerCount', _playerCount);

      final names = _nameControllers
          .map((c) => c.text.trim().isEmpty
              ? 'Spieler ${_nameControllers.indexOf(c) + 1}'
              : c.text.trim())
          .toList();
      await prefs.setStringList('playerNames', names);
      await prefs.setStringList('recentNames', _recentNames);
    } catch (e) {
      // Fehler ignorieren, Spiel läuft weiter
      debugPrint('Fehler beim Speichern der Daten: $e');
    }
  }

  void _updatePlayerCount(int count) {
    final currentCount = _nameControllers.length;
    // Nur verbleibende Slots auf Namensänderungen prüfen;
    // entfernte Slots werden separat im Removal-Loop behandelt.
    final keepCount = count < currentCount ? count : currentCount;
    _reconcileChangedNames(keepCount);

    setState(() {
      _playerCount = count;

      if (count < currentCount) {
        // Entfernte Slots: aktuellen Namen in History aufnehmen
        for (int i = currentCount - 1; i >= count; i--) {
          final name = _nameControllers[i].text.trim();
          if (name.isNotEmpty) {
            _recentNames.remove(name);
            _recentNames.insert(0, name);
          }
          _nameControllers[i].dispose();
          _nameFocusNodes[i].dispose();
          _nameControllers.removeAt(i);
          _nameFocusNodes.removeAt(i);
          _committedNames.removeAt(i);
        }
      } else {
        // Neue Slots: ersten nicht-duplizierten Namen aus History vorbelegen
        final activeNames = _nameControllers.map((c) => c.text.trim()).toSet();
        for (int i = currentCount; i < count; i++) {
          final historyName = _recentNames.firstWhere(
            (n) => n.isNotEmpty && !activeNames.contains(n),
            orElse: () => '',
          );
          if (historyName.isNotEmpty) {
            _recentNames.remove(historyName);
            activeNames.add(historyName);
          }
          final defaultName =
              historyName.isNotEmpty ? historyName : 'Spieler ${i + 1}';
          _addController(defaultName);
        }
      }
    });
  }

  /// Hängt bei Duplikaten " (1)", " (2)" usw. an.
  List<String> _deduplicateNames(List<String> names) {
    final used = <String>{};
    return names.map((name) {
      if (used.add(name)) return name;
      int n = 1;
      while (!used.add('$name ($n)')) {
        n++;
      }
      return '$name ($n)';
    }).toList();
  }

  void _startGame() {
    _reconcileChangedNames(_nameControllers.length);
    _saveData();

    final rawNames = List.generate(_playerCount, (i) {
      final t = _nameControllers[i].text.trim();
      return t.isEmpty ? 'Spieler ${i + 1}' : t;
    });
    final names = _deduplicateNames(rawNames);

    _players.clear();
    for (int i = 0; i < _playerCount; i++) {
      _players.add(Player(name: names[i]));
    }

    final hasDuplicates = List.generate(_playerCount, (i) => rawNames[i] != names[i]).any((c) => c);
    if (hasDuplicates) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Doppelte Namen angepasst'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bitte merkt euch eure Spielernamen:'),
              const SizedBox(height: 12),
              ...List.generate(_playerCount, (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text('Spieler ${i + 1}:  ',
                        style: const TextStyle(color: Colors.grey)),
                    Text(
                      names[i],
                      style: TextStyle(
                        fontWeight: rawNames[i] != names[i]
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (rawNames[i] != names[i])
                      const Text(' ← angepasst',
                          style: TextStyle(color: Colors.orange, fontSize: 12)),
                  ],
                ),
              )),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(players: _players),
                  ),
                );
              },
              child: const Text('Verstanden – Spiel starten'),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(players: _players),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var focusNode in _nameFocusNodes) {
      focusNode.dispose();
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
                  onPressed: _playerCount > 2
                      ? () => _updatePlayerCount(_playerCount - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle),
                  iconSize: 36,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_playerCount',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _playerCount < 6
                      ? () => _updatePlayerCount(_playerCount + 1)
                      : null,
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
                      focusNode: _nameFocusNodes[index],
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Spieler ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) {
                        if (index < _playerCount - 1) {
                          // Zum nächsten Eingabefeld
                          _nameFocusNodes[index + 1].requestFocus();
                        }
                        // Bei letztem Spieler: kein Fokus setzen
                      },
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
