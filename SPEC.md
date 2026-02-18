# Flip 7 Score App - Spezifikation

## 1. Projektübersicht

- **Projektname**: flip7_score
- **Projekttyp**: Flutter Android App
- **Kernfunktion**: Spielstand-Verwaltung für das Kartenspiel Flip 7 - Punkte pro Runde erfassen und aufaddieren, Gewinner bei 200 Punkten ermitteln

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
- **Undo**: Langer Druck auf einen bereits eingetragenen Spieler macht dessen letzten Score rückgängig

### 2.3 Gewinnbedingung
- Sobald ein Spieler ≥ 200 Punkte erreicht, gewinnt dieser
- Gewinner-Anzeige mit Namen und Punktestand
- Option für neue Partie mit gleichen oder neuen Spielern

### 2.4 Spiel abbrechen
- Button zum Abbrechen des laufenden Spiels
- Dialog mit Optionen: Mit gleichen Spielern / Neue Spieler / Weiterspielen

### 2.5 Neue Partie
- Nach Spielende: Gewinnerbildschirm mit Endstand (sortiert nach Punkten)
- "Mit gleichen Spielern weiterspielen": Alle Scores und Runde-Status zurücksetzen, Runde auf 1
- "Neue Spieler auswählen": Zurück zum Startbildschirm für neue Spielerauswahl

### 2.6 Round History
- Alle abgeschlossenen Runden werden gespeichert
- Eingeklappte History-Ansicht im Spielbildschirm zeigt vergangene Runden
- Pro Runde werden die Scores aller Spieler angezeigt

## 3. UI/UX Design

### 3.1 Bildschirme
1. **Startbildschirm**: Spielerauswahl (Anzahl + Namen)
2. **Spielbildschirm**: Aktueller Spielstand, Runde, Punkteeingabe
3. **Gewinnerbildschirm**: Gewinner-Anzeige, Endstand-Tabelle, "Neue Partie"-Option

### 3.2 Farbschema
- Primär: Blau (#2196F3)
- Sekundär: Orange (#FF9800)
- Hintergrund: Weiß/Grau
- Gewinner: Gold (#FFD700)

### 3.3 Layout
- Übersichtliche Tabellenansicht der Spielstände
- Große, gut lesbare Schrift
- Kein Zurück-Button auf beiden Bildschirmen (Startbildschirm ist erster Screen, Spielbildschirm wird abgebrochen über Schaltfläche)

## 4. Technische Umsetzung

- **State Management**: StatefulWidget mit setState (einfache App)
- **Datenmodell**:
  - Player-Klasse mit `name`, `score`, `hasEnteredScore`, `lastRoundScore` (für Undo)
  - Round-Klasse mit `roundNumber` und `scores` (Map<SpielerName, Punkte>)
- **Navigation**: Navigator mit anonymen Routes (MaterialPageRoute)
- **Widgets**: Material Design Components
- **Persistenz**: shared_preferences für Spieleranzahl, aktive Spielernamen und Namensverlauf (`recentNames`)
