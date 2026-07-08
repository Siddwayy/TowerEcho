# TowerEcho — 2D Tower Defense (Godot 4)

**TowerEcho** is a solo-developed 2D tower defense game built with **Godot Engine 4.5** and **GDScript**. The project focuses on responsive turret combat, enemy wave pressure, path-based AI, and polished moment-to-moment feedback through UI, visual effects, and sound design [file:16].

- **Genre:** 2D Tower Defense
- **Platform:** PC, macOS
- **Engine:** Godot 4.5
- **Language:** GDScript
- **Developer:** Solo project
- **Development Period:** May 2025 – Present

## Links

- **Demo Video:** [YouTube](https://www.youtube.com/watch?v=o0rbP4KEBjw)
- **Download:** [Google Drive build folder](https://drive.google.com/drive/folders/1c3aYWJNMp83Iuo8QpqoFJHxdrZtkFTsD?usp=sharing)

---

## Screenshots

### Main Menu
<img width="1163" height="725" alt="TowerEcho main menu" src="https://github.com/user-attachments/assets/73c48c17-66b3-483d-9828-662dfd9ebb0d" />

### Gameplay
<img width="2560" height="1440" alt="TowerEcho gameplay screen" src="https://github.com/user-attachments/assets/58f7df22-cde0-4de3-9904-1b46ec606213" />

### Enemy AI / Pathing
<img width="2560" height="1440" alt="TowerEcho enemy AI and pathing" src="https://github.com/user-attachments/assets/e8b119b0-659a-45c4-8ad3-ccf2da63c239" />

---

## Overview

In **TowerEcho**, the player defends a base using a mouse-aimed turret while surviving increasingly difficult enemy waves. Enemies follow path-based routes, and the game emphasizes fast combat feedback, readable UI, and arcade-style polish [file:16].

---

## Features

- **Mouse-aimed shooting** with continuous fire control.
- **Wave-based enemy pressure** with path-following behavior.
- **HUD systems** for core gameplay feedback, including health, ammo, and score.
- **Pause and save flow** that returns the player to the menu and supports resuming progress.
- **Game feel polish** including VFX, floating damage numbers, camera shake, and SFX.

---

## Controls

| Input | Action |
|-------|--------|
| **Mouse** | Aim |
| **Left Click** | Shoot |
| **Esc** | Save and return to menu |

---

## Tech Stack

- **Engine:** Godot Engine 4.5
- **Language:** GDScript
- **Gameplay Systems:** Path-based enemy spawning, projectile combat, HUD systems
- **Project Architecture:** `GameSettings` autoload for bullet count and save-state handling

---

## Project Structure

```text
assets/     Art, audio, fonts
scenes/     Game scenes, UI, entities, effects
scripts/    GDScript source files
```

---

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/Siddwayy/minimilisttd.git
cd minimilisttd
```

2. Open the project in **Godot 4.5** using `project.godot`.
3. Press **F5** or click **Play** to run the game from the main menu.

---
