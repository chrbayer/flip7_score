# Flip 7 Score App - Spezifikation

## 1. Projektübersicht

- **Projektname**: flip7_score
- **Projekttyp**: Flutter Android App
- **Kernfunktion**: Spielstand-Verwaltung für das Kartenspiel Flip 7 - Punkte pro Runde erfassen und aufaddieren, Gewinner bei konfigurierbarem Punktelimit ermitteln

## 2. Anforderungen

### 2.1 Spielersetup
- Benutzer kann Anzahl der Mitspieler festlegen (2-6 Spieler)
- Für jeden Spieler wird ein Name vergeben (Standard: "Spieler 1", "Spieler 2", etc.)
- Spielstand wird auf 0 Punkte initialisiert
- Anzahl und Namen werden gespeichert und beim nächsten Start als Default geladen
- **Namensverlauf**: Zuletzt benutzte, gerade nicht aktive Namen werden beim Hinzufügen eines Spielers automatisch vorgeschlagen (neueste zuerst, keine Duplikate)
- **Deduplizierung**: Doppelt eingegebene Namen werden automatisch durch Anhängen von " (1)", " (2)" usw. eindeutig gemacht; vor Spielstart erscheint ein Dialog, der alle Spieler über ihre endgültigen Namen informiert

### 2.2 Runde erfassen
- Pro Runde werden die Punkte jedes Spielers eingegeben
- Punkte werden zum Gesamtscore addiert
- Anzeige der aktuellen Runde (Runde 1, 2, ...)
- Jeder Spieler kann nur einmal pro Runde Punkte eintragen
- Spieler können in beliebiger Reihenfolge ausgewählt werden
- Leere Eingabe wird als 0 interpretiert
- Farbliche Markierung (grün) zeigt Spieler mit bereits eingetragenem Score
- Automatischer Runde-Wechsel sobald alle Spieler einen Score haben
- **Undo (einzelner Spieler)**: Langer Druck auf einen bereits eingetragenen Spieler macht dessen letzten Score rückgängig
- **Undo (Runde)**: Langer Druck auf die Runde-Zahl (mit Undo-Icon) macht die letzte abgeschlossene Runde rückgängig
- **Unterbrochene Runde wiederherstellen**: Beim Rückgängig-Machen einer Runde werden bereits in der aktuellen Runde eingegebene Scores gespeichert und beim nächsten Runde-Wechsel automatisch wiederhergestellt

### 2.3 Gewinnbedingung
- Sobald ein Spieler ≥ konfigurierbares Punktelimit erreicht, gewinnt dieser (Standard: 200, konfigurierbar in den Einstellungen)
- Gewinner-Anzeige mit Namen und Punktestand
- Option für neue Partie mit gleichen oder neuen Spielern
- Animation bei Erreichen des Gewinnerstatus
- **Rückkehr zum Spiel**: "Zurück zum Spiel"-Button mit Bestätigungsdialog ermöglicht das Fortsetzen des Spiels bei versehentlicher Gewinner-Auslösung

### 2.4 Spiel abbrechen
- Button zum Abbrechen des laufenden Spiels
- Dialog mit Optionen: Mit gleichen Spielern / Neue Spieler / Weiterspielen

### 2.5 Neue Partie
- Nach Spielende: Gewinnerbildschirm mit Endstand (sortiert nach Punkten)
- "Mit gleichen Spielern weiterspielen": Alle Scores und Runde-Status zurücksetzen, Runde auf 1
- "Neue Spieler auswählen": Zurück zum Startbildschirm für neue Spielerauswahl
- Animierte Anzeige des Gewinners mit Konfetti-Effekt

### 2.6 Round History
- Alle abgeschlossenen Runden werden gespeichert
- Eingeklappte History-Ansicht im Spielbildschirm zeigt vergangene Runden
- Pro Runde werden die Scores aller Spieler angezeigt
- Animation beim Öffnen/Schließen der History

### 2.7 Statistics (Statistiken)
- Statistiken-Funktion über Button im Spielbildschirm zugänglich
- Anzeige von:
  - Gesamtzahl gespielter Partien
  - Gewonnene Spiele pro Spieler
  - Durchschnittliche Punktzahl pro Runde pro Spieler
  - Höchster jemals erreichter Score
  - Gesamtzahl gespielter Runden
- Daten werden persistent gespeichert

### 2.8 Haptic Feedback (Haptisches Feedback)
- Vibrieren bei erfolgreicher Score-Eingabe
- Vibrieren bei Undo-Aktion
- Kurzes, diskretes Feedback für bessere Nutzererfahrung

### 2.9 Dark Mode
- Dunkelmodus-Unterstützung für bessere Lesbarkeit bei schlechten Lichtverhältnissen
- Automatische Erkennung basierend auf Systemeinstellungen
- Manuelles Umschalten zwischen Hell und Dunkel möglich
- Farbschema passt sich automatisch an:
  - Heller Modus: Weiß/Hellgrau Hintergrund, dunkler Text
  - Dunkler Modus: Dunkelgrau/Schwarz Hintergrund, heller Text
  - Primärfarbe bleibt Blau (#2196F3) für Konsistenz

## 3. UI/UX Design

### 3.1 Bildschirme
1. **Startbildschirm**: Spielerauswahl (Anzahl + Namen)
2. **Spielbildschirm**: Aktueller Spielstand, Runde, Punkteeingabe, Statistics-Button
3. **Gewinnerbildschirm**: Gewinner-Anzeige, Endstand-Tabelle, "Neue Partie"-Option
4. **Statistik-Bildschirm**: Übersicht aller Statistiken

### 3.2 Farbschema
- Primär: Blau (#2196F3)
- Sekundär: Orange (#FF9800)
- Hintergrund (Hell): Weiß (#FFFFFF) / Grau (#F5F5F5)
- Hintergrund (Dunkel): Dunkelgrau (#121212) / Anthrazit (#1E1E1E)
- Gewinner: Gold (#FFD700)
- Erfolgreiche Eingabe: Grün (#4CAF50)
- Text (Hell): Schwarz (#212121)
- Text (Dunkel): Weiß (#FFFFFF)

### 3.3 Layout
- Übersichtliche Tabellenansicht der Spielstände
- Große, gut lesbare Schrift
- Kein Zurück-Button auf beiden Bildschirmen (Startbildschirm ist erster Screen, Spielbildschirm wird abgebrochen über Schaltfläche)
- **Responsive Layout**: Optimiert für Tablets (≥600dp) mit 2-Spalten-Grid für Spielerlisten und nebeneinander angeordneten Eingabeelementen
- **Drag-and-drop**: Spielerreihenfolge kann im Startbildschirm per Drag-and-drop geändert werden

## 4. Technische Umsetzung

- **State Management**: StatefulWidget mit setState (einfache App)
- **Datenmodell**:
  - Player-Klasse mit `name`, `score`, `hasEnteredScore`, `lastRoundScore` (für Undo)
  - Round-Klasse mit `roundNumber`, `scores` (Map<SpielerName, Punkte>) und `lastPlayerIndex` (für Runde-Undo)
  - Statistics-Klasse für Spielstatistiken
- **Navigation**: Navigator mit anonymen Routes (MaterialPageRoute)
- **Widgets**: Material Design Components
- **Persistenz**: shared_preferences für Spieleranzahl, aktive Spielernamen, Namensverlauf (`recentNames`), Statistiken und Einstellungen
- **Themes**: ThemeData für Hell/Dunkel-Modus mit CupertinoThemeBar
- **Animationen**: AnimationController für:
  - Runde-Wechsel (Fade/Scale)
  - Score-Eingabe (kurzes Aufleuchten)
  - Gewinner-Anzeige (Konfetti-Effekt mit confetti_widget)
- **Haptisches Feedback**: HapticFeedback aus flutter/services für Vibrieren
