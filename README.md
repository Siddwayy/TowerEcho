# Minimalistic 2D Tower Defense (Godot Project)

A 2D tower defense game where the player controls a central turret to defend against waves of enemies across multiple levels. This project was developed incrementally, focusing on core gameplay mechanics, visual feedback, and UI elements.

---![Screenshot 2025-06-03 at 4 32 23 PM](https://github.com/user-attachments/assets/ece82d53-918a-4ca8-b14d-32b94c8ccc0f)
![Screenshot 2025-06-03 at 4 32 04 PM](https://github.com/user-attachments/assets/d2382240-7ae2-4fb0-8566-f328d2ad713d)

![Screenshot 2025-06-03 at 4 31 53 PM](https://github.com/user-attachments/assets/55091f66-3a32-4665-9b3f-e2056bec3f78)

![Screenshot 2025-06-03 at 4 31 37 PM](https://github.com/user-attachments/assets/5b5447e3-e7fc-4f64-9647-b1ba2e590a0d)
![Screenshot 2025-06-03 at 4 31 27 PM](https://github.com/user-attachments/assets/0465dda9-b454-4ffb-8a29-632e18d93cf3)
![Screenshot 2025-06-03 at 4 31 18 PM](https://github.com/user-attachments/assets/dabb7174-b3a7-4ec0-97ed-3fbaa3d59ead)


---

## 📜 About The Game

This is a 2D tower defense game built with the Godot Engine. Players control a central tower using the mouse to aim and shoot at enemies that advance along predefined paths. The goal is to survive by destroying all enemies before they reach their destination or before the tower's health is depleted. The game features multiple levels with increasing difficulty, a save/resume system, and various feedback mechanisms for an engaging experience.

---

## ✨ Key Features

Here's a breakdown of the features implemented in this project:

**Core Gameplay & Controls:**
* **Tower Defense:** Defend a central point against incoming enemies.
* **Mouse-Controlled Tower:** Aim and fire the tower using the mouse.
* **Continuous Fire:** Hold the mouse button for continuous shooting, governed by an adjustable fire rate.
* **Multiple Levels:** The game includes **2 levels, each with different enemy paths and spawning patterns, offering increased difficulty.**
* **Path-Based Enemies:** Enemies follow predefined `Path2D`s, with options for multiple random paths within a level.
* **Win/Loss Conditions:** Game ends if the tower is destroyed, an enemy reaches the goal (lose), or all enemies in a level are defeated (win), returning the player to the Main Menu.

**Player Tower Mechanics:**
* **Health System:** The tower has health and can take damage.
* **Health Regeneration:** Tower health **regenerates by 10 points for every 10 enemies killed.**
* **Ammunition System:**
    * The tower has a limited bullet count, displayed on the UI.
    * Bullets **increase by 5 for every 1 enemy killed.**
    * Shooting is prevented if out of bullets.
* **Shooting:** Fires bullets with sound and a muzzle flash animation.
* **Laser Line Trace:** A continuous visual line points from the muzzle in the aiming direction, shortening when it detects an enemy.
* **Damage Feedback:**
    * Displays floating damage numbers when hit.
    * Plays a hit sound.
    * Triggers a minor camera shake on impact.
* **Destruction Sequence:** When destroyed, the tower hides visually, plays a particle explosion, a destruction sound, and triggers a major camera shake before being removed.
* **Score-Based Perk:** Tower's maximum health and current health can increase at score milestones (this was a previously implemented feature, distinct from the per-kill health regeneration).

**Enemy Units & AI:**
* **Pathfinding:** Enemies navigate along multiple, randomly selected `Path2D`s.
* **Multi-Hit Health:** Enemies have health (e.g., 3 hits) and require multiple hits to be defeated.
* **Hit Feedback:**
    * Sprite flashes red with transparency.
    * Sprite performs a "vibration" or jiggle animation.
    * Floating damage numbers appear.
* **Destruction Effects:** Enemies play a particle effect and sound upon death.
* **Shooting Capability:** Enemies can aim and fire their own bullets back at the player's tower with a defined fire rate.
* **Player Interaction:**
    * Award score to the player when defeated by player bullets.
    * Trigger a "Game Over" if an enemy reaches the end of its path.

**Interactive Combat:**
* Player bullets damage enemies.
* Enemy bullets damage the player's tower.
* Player bullets and enemy bullets collide with and destroy each other.
* Bullets have a limited lifetime and self-destruct.

**User Interface (UI) & Game Flow:**
* **Main Menu Scene:**
    * "Start New Game" button (clears previous save).
    * "Resume Game" button (appears if a saved game state exists).
    * "Exit Game" button.
    * Sound (Music) Toggle button with **distinct visual feedback for hover and normal states (icon changes).**
    * **Click sounds for all UI buttons.**
* **In-Game UI (`GameUI.tscn` on a `CanvasLayer`):**
    * Tower Health Bar display.
    * Score Display.
    * **Bullet Count Display.**
* **Smooth Scene Transitions:** Fade-in/fade-out effect when transitioning between Main Menu and Game Level, managed by a `ScreenFader` Autoload.

**Save & Resume System:**
* Pressing "Escape" in the game level saves the current state and returns to the Main Menu.
* Saved data includes: tower's current health, player score, number of enemies already spawned for the current level, the state of all *active* enemies on screen (their individual health, current path, and progress along that path), and the background music's playback position.
* "Resume Game" from the Main Menu loads this state.
* Starting a "New Game" or reaching a "Game Over"/"You Win" state clears the resumable save.

**Audio & Visual Polish:**
* Background music for both the Main Menu and the Game Level (with volume control via editor and resume functionality for level music).
* A suite of sound effects for tower actions, enemy actions, and UI interactions.
* Multiple particle systems for hits and destructions.
* Shooting animation for the tower.
* Visual hit flash and jiggle for enemies.
* Camera shake effects for impacts and tower destruction.

---

## 🎮 Controls

* **Aim Tower:** Mouse cursor position.
* **Shoot:** Hold Left Mouse Button (or tap screen for continuous fire).
* **Pause & Return to Menu (with Save):** Press `Escape` key during gameplay.

---

## 🛠️ Technology Used

* **Engine:** Godot Engine (Version X.Y - *Specify your Godot version, e.g., 4.2*)
* **Language:** GDScript

---

## 🚀 How to Run

1.  Download or clone this repository.
2.  Open the Godot Engine project manager.
3.  Click "Import" and navigate to the `project.godot` file in this project's root directory.
4.  Once imported, select the project and click "Edit".
5.  The main menu scene (`MainMenu.tscn` or `main_menu.tscn`) should be set as the default scene to run. If not, you can set it via `Project > Project Settings > Application > Run > Main Scene`.
6.  Press `F5` (or the "Play" button in the editor) to run the game.

---

## 📝 (Optional) To-Do / Future Ideas

* Implement more distinct enemy waves with clear progression.
* Add more enemy types with unique behaviors or resistances.
* Introduce tower upgrades or different tower types.
* Further visual and audio polish (e.g., different hit particles, more varied sounds).
* Add a dedicated options screen for volume, etc.

---

## 🙏 (Optional) Credits

* **Game Design & Programming:** [Your Name/Handle]
* **Art Assets:** [If you used any assets from packs or other creators, credit them here - e.g., "UI Buttons from AssetPackName by CreatorName (link)"]
* **Sound Effects:** [Credit sources if applicable]
* **Music:** [Credit sources if applicable]

---

## 📄 (Optional) License

This project is under the [Choose a License, e.g., MIT License, CC0] - see the `LICENSE.md` file for details.
*(If you add a license, create a `LICENSE.md` file with the license text).*
