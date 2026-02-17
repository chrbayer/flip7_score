# Flip 7 Score

Eine Flutter-Android-App zur Spielstand-Verwaltung für das Kartenspiel Flip 7.

## Funktionen

- **Spielersetup**: 2-6 Mitspieler mit individuellen Namen
- **Punkteerfassung**: Punkte pro Runde eingeben und aufaddieren
- **Rundenzähler**: Aktuelle Runde wird angezeigt
- **Gewinnermittlung**: Gewinner wird bei 200+ Punkten angezeigt
- **Neue Partie**: Option für Rematch mit gleichen Spielern

## Bildschirme

1. **Startbildschirm**: Spielerauswahl (Anzahl + Namen)
2. **Spielbildschirm**: Spielstand, Runde, Punkteeingabe
3. **Gewinnerbildschirm**: Gewinner-Anzeige, "Neue Partie"-Option

## Technische Details

- **Framework**: Flutter
- **State Management**: StatefulWidget mit setState
- **Datenmodell**: Player-Klasse (name, score)
- **Design**: Material Design 3

## Farbschema

- Primär: Blau (#2196F3)
- Sekundär: Orange (#FF9800)
- Gewinner: Gold (#FFD700)

## Installation

```bash
cd flip7_score
flutter pub get
flutter run
```

## Build

```bash
flutter build apk --debug
```
