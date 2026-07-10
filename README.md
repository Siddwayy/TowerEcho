<div align="center">
  <h1>TowerEcho</h1>
  <p><b>A fast-paced, arcade-inspired 2D Tower Defense game built in Godot 4.5.</b></p>
  
  <!-- Badges -->
  <a href="https://godotengine.org/"><img src="https://img.shields.io/badge/Godot-4.5-478cbf?logo=godot-engine&logoColor=white&style=flat-square" alt="Godot 4.5"></a>
  <img src="https://img.shields.io/badge/Language-GDScript-blue?style=flat-square" alt="GDScript">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey?style=flat-square" alt="Platforms">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"></a>
</div>

<br>

**TowerEcho** replaces autonomous turrets with direct player control. Defend a central base using a mouse-aimed turret while surviving increasingly difficult, path-based enemy waves. This project emphasizes responsive combat, rapid target prioritization, and arcade-style game feel.

> 🎮 **[Play the Demo / Download Latest Build](https://drive.google.com/drive/folders/1c3aYWJNMp83Iuo8QpqoFJHxdrZtkFTsD?usp=drive_link)**
> 
> 🍿 **[Watch the Trailer](https://www.youtube.com/watch?v=o0rbP4KEBjw)**

---

## 📑 Table of Contents
- [Features](#-features)
- [Media Gallery](#-media-gallery)
- [Technical Overview](#-technical-overview)
- [Getting Started (Source Code)](#-getting-started)
- [Controls](#-controls)
- [License](#-license)

---

## ✨ Features
* **Mouse-Aimed Combat:** Direct continuous fire control for precise target prioritization.
* **Path-Based AI Waves:** Dynamic enemy spawning utilizing Godot's `Path2D` navigation.
* **Responsive Game Feel:** Highly polished visual and auditory feedback including floating damage numbers, screen shake, hit-stop, and particle effects.
* **Robust Save/State System:** Seamlessly pause, return to the main menu, and resume gameplay without state loss or memory leaks.

---

## 📸 Media Gallery

### Intense Action
<div align="center">
  <img width="100%" alt="TowerEcho gameplay screen" src="https://github.com/user-attachments/assets/58f7df22-cde0-4de3-9904-1b46ec606213" />
</div>

### Path-based AI & Wave Pressure
<div align="center">
  <img width="100%" alt="TowerEcho enemy AI and pathing" src="https://github.com/user-attachments/assets/e8b119b0-659a-45c4-8ad3-ccf2da63c239" />
</div>

### Clean UI & State Management
<div align="center">
  <img width="100%" alt="TowerEcho main menu" src="https://github.com/user-attachments/assets/73c48c17-66b3-483d-9828-662dfd9ebb0d" />
</div>

---

## 🛠️ Technical Overview

TowerEcho was developed as a solo project to explore responsive gameplay architecture in Godot 4.5. Key technical implementations include:

* **Signal-Driven UI:** The HUD (health, ammo, score) is fully decoupled from core gameplay logic, relying entirely on Godot's Signal system for asynchronous updates.
* **`GameSettings` Autoload:** A persistent Singleton manages global state (current wave, total score, player health) allowing safe transitions between the main menu and game scenes.
* **Wave Manager:** A custom wave spawner that parses data to control spawn rates, enemy types, and difficulty scaling dynamically over time.
* **Physics-Based Projectiles:** Engineered for high performance to maintain 60+ FPS even with dozens of active projectiles and enemies on screen.

---

## 🚀 Getting Started

If you want to explore the source code or build the game yourself:

### Prerequisites
* [Godot Engine 4.5](https://godotengine.org/download) (Standard Version)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Siddwayy/minimilisttd.git
   ```
2. Open **Godot 4.5**.
3. Click **Import** and navigate to the cloned folder.
4. Select the `project.godot` file.
5. Press `F5` (or click the Play button in the top right) to run the project.

---

## ⌨️ Controls

| Action | Input (Keyboard & Mouse) |
| :--- | :--- |
| **Aim Turret** | Mouse Movement |
| **Shoot** | Left Mouse Button (Hold) |
| **Pause / Menu** | `Esc` |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
