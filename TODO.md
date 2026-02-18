# Flip7 Score - Todo / Improvements

## Features
- [x] Runden-Historie anzeigen (IMPLEMENTIERT)
- [x] Statistiken (Durchschnitt, höchste Runde, etc.)
- [x] Score-Limit konfigurierbar (nicht jeder spielt bis 200)
- [x] Haptisches Feedback bei Punkteeingabe und Undo
- [x] Animationen für Runde-Wechsel und Gewinner
- [x] Undo für komplette Runde (Long-Press auf Runde-Zahl mit Undo-Icon)
- [x] Unterbrochene Runde wiederherstellen nach Runde-Undo
- [x] Tests (61 Unit- und Widget-Tests)

## UI/UX
- [ ] Tablet-Layout für größere Bildschirme optimieren
- [x] Rückkehr vom Gewinner-Bildschirm zum Spielstand ermöglichen (z.B. bei versehentlicher Gewinner-Auslösung)
- [ ] Drag-and-drop zur Spieler-Reihenfolge im StartScreen

## Statistiken erweitern
- [ ] Siege pro Spieler tracken (gamesWon) und Siegesquote anzeigen (gamesWon / gamesPlayed)
- [ ] Durchschnittlicher Score pro Runde pro Spieler anzeigen

## Technisch
- [x] Fehlerbehandlung bei SharedPreferences
- [x] Winner Screen Layout-Problem beheben (Overflow bei manchen Bildschirmgrößen)

## Dokumentation
- [x] App-Screenshots für README aktualisieren (nicht vorgesehen)
- [x] Changelog pflegen (nicht vorgesehen - Commit-Historie reicht)
