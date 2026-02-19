# Flip 7 Score

Eine Flutter-Android-App zur Spielstand-Verwaltung für das Kartenspiel Flip 7.

## Funktionen

- **Spielersetup**: 2-6 Mitspieler mit individuellen Namen
- **Drag-and-drop**: Spielerreihenfolge kann im Startbildschirm per Drag-and-drop geändert werden
- **Persistenz**: Spieleranzahl, -namen und Namensverlauf werden gespeichert
- **Namensverlauf**: Beim Hinzufügen eines Spielers wird automatisch ein zuletzt verwendeter Name vorgeschlagen (kein Duplikat zu aktiven Spielern)
- **Deduplizierung**: Doppelte Namen erhalten automatisch ein " (1)", " (2)" usw.; ein Dialog informiert alle Spieler vor Spielstart über ihre endgültigen Namen
- **Punkteerfassung**: Jeder Spieler nur einmal pro Runde, leere Eingabe = 0
- **Eingabefeld leeren**: Das Eingabefeld wird nach dem erfolgreichen Eintragen geleert
- **Punkte bleiben beim Spielerwechsel**: Wenn man nach der Eingabe auf einen anderen Spieler drückt, bleibt der eingegebene Wert im Feld
- **Undo (einzelner Spieler)**: Langer Druck auf einen eingetragenen Spieler macht dessen letzten Score rückgängig; alter Wert wird markiert
- **Undo (Runde)**: Langer Druck auf die gesamte Runde-Card macht die letzte abgeschlossene Runde rückgängig
- **Unterbrochene Runde wiederherstellen**: Bereits eingegebene Scores werden beim Rückgängig-Machen einer Runde gespeichert und beim nächsten Runde-Wechsel automatisch wiederhergestellt
- **Rundenzähler**: Aktuelle Runde wird angezeigt
- **Farbliche Markierung**: Grüner Hintergrund/Check für eingegebene Scores
- **Automatischer Runde-Wechsel**: Wenn alle Spieler einen Score haben
- **Konfigurierbares Punktelimit**: Einstellbar von 50-1000 Punkten per Long-Press (Standard: 200)
- **Statistiken**: Gesamtstatistiken (Spiele gespielt, höchste Runde, Gesamtpunkte, ∅ Punkte/Spiel) und Spielerstatistiken (Siege, Spiele gespielt, Siegrate, höchste Runde, ∅ Runde, gespielte Runden, Gesamtpunktzahl) mit Zurücksetzen-Funktion
- **Rückkehr vom Gewinner-Bildschirm**: "Zurück zum Spiel"-Button mit Bestätigungsdialog bei versehentlicher Gewinner-Auslösung
- **Spiel abbrechen**: Button mit Dialog für gleiche/neue Spieler
- **Neue Partie**: Scores und Status werden zurückgesetzt
- **Round History**: Eingeklappte Übersicht vergangener Runden im Spielbildschirm und im Gewinnerbildschirm (mit Rundendetails)

## Bildschirme

1. **Startbildschirm**: Spielerauswahl (Anzahl + Namen)
2. **Spielbildschirm**: Spielstand, Runde, Punkteeingabe
3. **Gewinnerbildschirm**: Gewinner-Anzeige, Endstand-Tabelle, "Neue Partie"-Option

## Technische Details

- **Framework**: Flutter
- **State Management**: StatefulWidget mit setState
- **Datenmodell**: Player-Klasse (`name`, `score`, `hasEnteredScore`, `lastRoundScore`), Round-Klasse (`roundNumber`, `playerScores`, `lastPlayerIndex`)
- **Navigation**: Navigator mit anonymen Routes (MaterialPageRoute)
- **Persistenz**: shared_preferences
- **Design**: Material Design 3
- **Responsive Layout**: Optimiert für Tablets (≥600dp) mit 2-Spalten-Layout
- **Tests**: 75 Unit- und Widget-Tests

## Farbschema

- Primär: Blau (#2196F3)
- Sekundär: Orange (#FF9800)
- Eingetragen: Grün
- Gewinner: Gold (#FFD700)

## Installation

### Voraussetzungen
- Flutter SDK (Version 3.x oder höher)
- Android SDK

### Abhängigkeiten installieren

```bash
flutter pub get
```

### App ausführen (Debug-Modus)

```bash
flutter run
```

### APK bauen

```bash
flutter build apk --release
```

Das APK befindet sich nach dem Build unter `build/app/outputs/flutter-apk/app-release.apk`.
