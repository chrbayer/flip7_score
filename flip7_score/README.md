# Flip 7 Score

Eine Flutter-Android-App zur Spielstand-Verwaltung für das Kartenspiel Flip 7.

## Funktionen

- **Spielersetup**: 2-6 Mitspieler mit individuellen Namen
- **Persistenz**: Spielernamen und Anzahl werden gespeichert
- **Punkteerfassung**: Jeder Spieler nur einmal pro Runde, leere Eingabe = 0
- **Rundenzähler**: Aktuelle Runde wird angezeigt
- **Farbliche Markierung**: Grüner Hintergrund/Check für eingegebene Scores
- **Automatischer Runde-Wechsel**: Wenn alle Spieler einen Score haben
- **Gewinnermittlung**: Gewinner wird bei 200+ Punkten angezeigt
- **Spiel abbrechen**: Button mit Dialog für gleiche/neue Spieler
- **Neue Partie**: Scores und Status werden zurückgesetzt

## Bildschirme

1. **Startbildschirm**: Spielerauswahl (Anzahl + Namen)
2. **Spielbildschirm**: Spielstand, Runde, Punkteeingabe
3. **Gewinnerbildschirm**: Gewinner-Anzeige, "Neue Partie"-Option

## Technische Details

- **Framework**: Flutter
- **State Management**: StatefulWidget mit setState
- **Datenmodell**: Player-Klasse (name, score, hasEnteredScore)
- **Persistenz**: shared_preferences
- **Design**: Material Design 3

## Farbschema

- Primär: Blau (#2196F3)
- Sekundär: Orange (#FF9800)
- Eingetragen: Grün
- Gewinner: Gold (#FFD700)

## Installation

```bash
cd flip7_score
flutter pub get
flutter run
```

## Build

```bash
flutter build apk --release
```
