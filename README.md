# TowerEcho — 2D Tower Defense (Godot 4)

TowerEcho is a 2D tower defense game built in **Godot Engine 4.5** using **GDScript**. Defend your base with a mouse-aimed turret against waves of enemies that follow path-based routes, with emphasis on responsive combat, UI, VFX, and SFX.

- Genre: 2D Tower Defense
- Platforms: PC, macOS, Linux
- Team: Solo Developer
- Duration: May 2025 – Present

**Links**
- Demo Video: https://www.youtube.com/watch?v=o0rbP4KEBjw
- Download exe: https://drive.google.com/drive/folders/1c3aYWJNMp83Iuo8QpqoFJHxdrZtkFTsD?usp=sharing

MainMenu:
<img width="1163" height="725" alt="MainMenu" src="https://github.com/user-attachments/assets/9693990c-ef0d-40f8-8023-42a6d80cdaa0" />

inGame:
<img width="1164" height="722" alt="inGame" src="https://github.com/user-attachments/assets/9f49517e-65c6-4573-8dce-3ad279765f30" />

EnemyAi:
<img width="2560" height="1440" alt="enemyai" src="https://github.com/user-attachments/assets/10c04a3a-fecc-42ce-aad3-ba41a4953c36" />

---

## Getting started

1. Clone the repository:
   ```bash
   git clone https://github.com/Siddwayy/minimilisttd.git
   cd minimilisttd
   ```
2. Open the project in Godot 4.5 (`project.godot`).
3. Press **F5** or click **Play** to run from the main menu.

## Key Features

- Mouse-aimed turret: hold to fire continuously toward the cursor
- WASD movement: fly the tower in all directions
- HUD: health, ammo, score
- Enemy waves along randomized paths
- Pause/save: Esc saves and returns to menu; resume from main menu
- Polish: VFX, floating damage numbers, camera shake, SFX

## Tech Stack

- Godot Engine 4.5 + GDScript
- Path-based enemy spawning and projectile combat
- `GameSettings` autoload for bullet count and save state

## Controls

| Input | Action |
|-------|--------|
| **W A S D** | Move the tower |
| **Mouse** | Aim |
| **Left click** | Shoot |
| **Esc** | Save and return to menu |

## Project structure

```
assets/     Art, audio, fonts
scenes/     Game scenes (levels, UI, entities, effects)
scripts/    GDScript source
```

## License

MIT License — see [LICENSE](LICENSE).
