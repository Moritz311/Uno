# VisionOS UNO – Mixed-Reality Kartenspiel

Ein VisionOS-Projekt, das das klassische **UNO-Kartenspiel** in die Mixed-Reality-Welt hebt.  
Spieler können in einer immersiven 3D-Arena gegeneinander antreten, Karten per Handgesten aufnehmen, legen und Aktionen auslösen.  
Die App kombiniert VisionOS-Interaktionen, Spatial Computing und ein digitales UNO-Kartendeck.

---

## 🚀 Features

### 🎮 Spielmodi
- **Arcade Modus – Full Immersion (Boxing Arena)**
- Unterstützt **2–4 Spieler**
- Einstellbare Handkarten (**6–10 Karten** pro Spieler)

### 🃏 Kartensystem
- Vollständiges UNO-Kartendeck  
  → Zahlenkarten + Aktionskarten  
- Unterstützte Aktionen:
  - +2
  - +4
  - Richtungswechsel
  - Aussetzen
  - Farbwahl
- Digitales Mischen und Austeilen über die App
- Kartenlayout basiert auf **TableTopKit Assets**

### 🖐 VisionOS Interaktion
- Karten **per Handgeste** aufnehmen (z. B. Blick + Pinch)
- Karten **anschauen**, **umdrehen** und **ablegen**
- Automatische Regelprüfung beim Ablegen
- Idee: **„UNO!“**-Ruf über Handgeste oder Sprache (in Planung)

### 🛡 Abdeckmechanik
- Karten sind durch ein **sichtbasiertes Shield** geschützt  
- Wenn man nicht direkt auf eine Karte schaut, wird sie ausgeblendet  
  → ähnlich einem Laser-Targeting-System

---

## 🏗 Technologien
- **visionOS / RealityKit**
- **SwiftUI**
- **TableTopKit** (für Kartendarstellung) -- https://developer.apple.com/documentation/tabletopkit/creating-tabletop-games
- **HandTracking & Gesture Recognition**
- **Spatial Anchors / 3D UI Layouts**

---

## ▶️ Getting Started

### Installation
1. Projekt in **Xcode** öffnen  
2. **visionOS-Simulator** oder Apple Vision Pro auswählen  
3. **Build & Run** ausführen

### Spielstart
1. Spielerzahl wählen (**2–4**)  
2. Handkartenzahl einstellen (**6–10**)  
3. Spiel starten → Karten werden automatisch gemischt und ausgeteilt

---

## 📝 Roadmap
- [ ] Sprach- oder Handgestenerkennung für **„UNO!“**
- [ ] Online-Multiplayer
- [ ] Erweiterte Animationen für Kartenbewegungen
- [ ] Custom Arenas / Themes

---

## 📸 Screenshots
*Beispiel aus aktueller Demo*  
UNO-Karten basieren auf **TableTopKit** (Platzhaltergrafiken)

---

## 📜 Lizenz
Dieses Projekt dient zu Forschungs- und Entwicklungszwecken im Bereich VisionOS und Mixed Reality.  
Kartendesigns sind Platzhalter und müssen entsprechend der Rechteinhaber final ersetzt werden.

---
