# Flip 7 Score

Eine Flutter-Android-App zur Spielstand-Verwaltung für das Kartenspiel Flip 7.

## Funktionen

- **Spielersetup**: 2-6 Mitspieler mit individuellen Namen
- **Persistenz**: Spieleranzahl, -namen und Namensverlauf werden gespeichert
- **Namensverlauf**: Beim Hinzufügen eines Spielers wird automatisch ein zuletzt verwendeter Name vorgeschlagen (kein Duplikat zu aktiven Spielern)
- **Deduplizierung**: Doppelte Namen erhalten automatisch ein " (1)", " (2)" usw.; ein Dialog informiert alle Spieler vor Spielstart über ihre endgültigen Namen
- **Punkteerfassung**: Jeder Spieler nur einmal pro Runde, leere Eingabe = 0
- **Undo**: Langer Druck auf einen eingetragenen Spieler macht dessen letzten Score rückgängig
- **Rundenzähler**: Aktuelle Runde wird angezeigt
- **Farbliche Markierung**: Grüner Hintergrund/Check für eingegebene Scores
- **Automatischer Runde-Wechsel**: Wenn alle Spieler einen Score haben
- **Gewinnermittlung**: Gewinnerbildschirm mit Endstand bei 200+ Punkten
- **Spiel abbrechen**: Button mit Dialog für gleiche/neue Spieler
- **Neue Partie**: Scores und Status werden zurückgesetzt
- **Round History**: Eingeklappte Übersicht vergangener Runden im Spielbildschirm

## Bildschirme

1. **Startbildschirm**: Spielerauswahl (Anzahl + Namen)
2. **Spielbildschirm**: Spielstand, Runde, Punkteeingabe
3. **Gewinnerbildschirm**: Gewinner-Anzeige, Endstand-Tabelle, "Neue Partie"-Option

## Technische Details

- **Framework**: Flutter
- **State Management**: StatefulWidget mit setState
- **Datenmodell**: Player-Klasse (`name`, `score`, `hasEnteredScore`, `lastRoundScore`), Round-Klasse (`roundNumber`, `scores`)
- **Navigation**: Navigator mit anonymen Routes (MaterialPageRoute)
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
