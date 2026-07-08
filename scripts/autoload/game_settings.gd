# GameSettings.gd
extends Node

# --- Bullet Count Management ---
signal bullet_count_changed(new_count)

var current_bullets: int = 150:
	set(value):
		current_bullets = value
		emit_signal("bullet_count_changed", current_bullets)

# --- Save State Variables ---
var has_saved_state: bool = false
var saved_tower_health: float = 100.0
var saved_score: int = 0
var saved_enemies_spawned_count: int = 0
var saved_enemies_data: Array = []
var saved_bullet_count: int = 150 # <-- ADDED: To save bullet count

var load_saved_game_on_next_start: bool = false

func _ready():
	# When the game starts, decide the initial bullet count
	if load_saved_game_on_next_start and has_saved_state:
		self.current_bullets = saved_bullet_count
	else:
		# This is a new game, so reset to the default
		self.current_bullets = 150 # Default starting bullets

# --- Bullet Functions ---
func use_bullet():
	self.current_bullets -= 1

func add_bullets(amount: int):
	self.current_bullets += amount


# MODIFIED: Now saves the current bullet count
func save_game_state(tower_health: float, current_score: int, enemies_spawned: int, active_enemies_data: Array):
	print("GameSettings: Saving game state...")
	saved_tower_health = tower_health
	saved_score = current_score
	saved_enemies_spawned_count = enemies_spawned
	saved_enemies_data = active_enemies_data
	saved_bullet_count = current_bullets # <-- ADDED: Save the live bullet count

	has_saved_state = true
	load_saved_game_on_next_start = false
	print("GameSettings: State SAVED. Tower Health:", saved_tower_health, "Score:", saved_score, "Bullets:", saved_bullet_count)
	print("  Enemies Spawned Count:", saved_enemies_spawned_count, "Active Enemies Saved:", saved_enemies_data.size())


# MODIFIED: Also clears the saved bullet count
func clear_saved_state():
	print("GameSettings: Clearing saved state.")
	has_saved_state = false
	load_saved_game_on_next_start = false
	# Reset saved values to defaults
	saved_tower_health = 100.0
	saved_score = 0
	saved_enemies_spawned_count = 0
	saved_bullet_count = 150 # <-- ADDED: Reset bullet count
	saved_enemies_data.clear()


func flag_for_resume():
	if has_saved_state:
		load_saved_game_on_next_start = true
		print("GameSettings: Flagged for RESUMING game.")
	else:
		load_saved_game_on_next_start = false
		print_rich("[color=orange]GameSettings: Flag for resume called, but NO saved state exists.[/color]")


func consume_resume_flag_and_invalidate_save():
	print("GameSettings: Resume flag consumed. Invalidating current save state.")
	load_saved_game_on_next_start = false
	has_saved_state = false
