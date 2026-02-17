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

### 2.2 Runde erfassen
- Pro Runde werden die Punkte jedes Spielers eingegeben
- Punkte werden zum Gesamtscore addiert
- Anzeige der aktuellen Runde (Runde 1, 2, ...)
- Jeder Spieler kann nur einmal pro Runde Punkte eintragen
- Spieler können in beliebiger Reihenfolge ausgewählt werden
- Leere Eingabe wird als 0 interpretiert
- Farbliche Markierung (grün) zeigt Spieler mit bereits eingetragenem Score
- Automatischer Runde-Wechsel sobald alle Spieler einen Score haben

### 2.3 Gewinnbedingung
- Sobald ein Spieler ≥ 200 Punkte erreicht, gewinnt dieser
- Gewinner-Anzeige mit Namen und Punktestand
- Option für neue Partie mit gleichen Spielern

### 2.4 Neue Partie
- Nach Spielende: Dialog "Mit gleichen Mitspielern weiterspielen?"
- Ja: Alle Scores und Runde-Status zurücksetzen, Runde auf 1
- Nein: Zurück zum Startbildschirm für neue Spielerauswahl

## 3. UI/UX Design

### 3.1 Bildschirme
1. **Startbildschirm**: Spielerauswahl (Anzahl + Namen)
2. **Spielbildschirm**: Aktueller Spielstand, Runde, Punkteeingabe
3. **Gewinnerbildschirm**: Gewinner-Anzeige, "Neue Partie"-Option

### 3.2 Farbschema
- Primär: Blau (#2196F3)
- Sekundär: Orange (#FF9800)
- Hintergrund: Weiß/Grau
- Gewinner: Gold (#FFD700)

### 3.3 Layout
- Übersichtliche Tabellenansicht der Spielstände
- Große, gut lesbare Schrift
- Einfache Navigation mit Zurück-Button

## 4. Technische Umsetzung

- **State Management**: StatefulWidget mit setState (einfache App)
- **Datenmodell**: Player-Klasse mit name, score und hasEnteredScore
- **Navigation**: Navigator mit named routes
- **Widgets**: Material Design Components
- **Persistenz**: shared_preferences für Spielernamen und Anzahl
