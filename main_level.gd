extends Node2D

# --- Enemy Spawning Configuration ---
@export var enemy_scene: PackedScene = preload("res://enemy.tscn")
@export var enemy_paths: Array[NodePath] = []
@export var total_enemies_to_spawn: int = 10
@export var spawn_interval: float = 2.0

# --- ADD THIS EXPORT VARIABLE FOR THE NEXT LEVEL ---
# You will drag your next level scene (e.g., main_level2.tscn) into this slot
# in the Godot Inspector for your current level scene (e.g., main_level.tscn).
@export var next_level_scene: PackedScene = null

# --- UI Reference ---
@onready var game_ui = $GameUI

# --- Tower Reference ---
@onready var tower_node: Area2D = $Platform/Tower

# --- Game State Variables ---
var score: int = 0
var game_is_over: bool = false

# --- Internal Spawning State ---
var enemies_spawned_count: int = 0
var time_since_last_spawn: float = 0.0

const MAIN_MENU_SCENE_PATH = "res://main_menu.tscn"


func _ready():
	randomize()

	# --- Load Saved State or Initialize New Game ---
	if GameSettings.load_saved_game_on_next_start and GameSettings.has_saved_state:
		print("MainLevel _ready: Loading saved game state...")
		score = GameSettings.saved_score
		enemies_spawned_count = GameSettings.saved_enemies_spawned_count
		game_is_over = false
		time_since_last_spawn = 0.0
		print("MainLevel: Loaded Score:", score, "Enemies Spawned:", enemies_spawned_count)
		_restore_active_enemies(GameSettings.saved_enemies_data)
		GameSettings.consume_resume_flag_and_invalidate_save()
	else:
		print("MainLevel _ready: Starting new game.")
		score = 0
		enemies_spawned_count = 0
		time_since_last_spawn = 0.0
		game_is_over = false
		if not GameSettings.load_saved_game_on_next_start:
			GameSettings.clear_saved_state()
		GameSettings.load_saved_game_on_next_start = false

	# Error checks
	if enemy_paths.is_empty(): print_rich("[color=red]ERROR: MainLevel.gd - No enemy paths assigned![/color]")
	if enemy_scene == null: print_rich("[color=red]ERROR: MainLevel.gd - Enemy scene not assigned![/color]")

	# --- Initialize UI ---
	if game_ui:
		if game_ui.has_method("update_score"):
			game_ui.update_score(score)
		if is_instance_valid(tower_node) and "current_health" in tower_node and "max_health" in tower_node:
			update_tower_health_display(tower_node.current_health, tower_node.max_health)
	else:
		print_rich("[color=red]ERROR: MainLevel.gd - GameUI node not found![/color]")
	if not is_instance_valid(tower_node):
		print_rich("[color=red]ERROR: MainLevel.gd - Tower node ($Platform/Tower) not found![/color]")

func _unhandled_input(event: InputEvent):
	if game_is_over: return
	if Input.is_action_just_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		save_and_return_to_menu()

func save_and_return_to_menu():
	print("MainLevel: Saving state and returning to menu...")
	var current_tower_health = 0.0
	if is_instance_valid(tower_node) and "current_health" in tower_node:
		current_tower_health = tower_node.current_health

	var active_enemies_data_to_save: Array = []
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy_node) and enemy_node.has_method("set_path_follow_node") and \
		   "current_health" in enemy_node and "path_follow_node" in enemy_node and \
		   is_instance_valid(enemy_node.path_follow_node) and is_instance_valid(enemy_node.path_follow_node.get_parent()):
			var path_2d_node = enemy_node.path_follow_node.get_parent()
			var enemy_data = {
				"health": enemy_node.current_health,
				"path_nodepath_str": str(path_2d_node.get_path()),
				"progress": enemy_node.path_follow_node.progress
			}
			active_enemies_data_to_save.append(enemy_data)
	GameSettings.save_game_state(current_tower_health, score, enemies_spawned_count, active_enemies_data_to_save)
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func _restore_active_enemies(enemies_data_array: Array):
	print("MainLevel: Restoring ", enemies_data_array.size(), " active enemies...")
	for enemy_data in enemies_data_array:
		var path_node = get_node_or_null(NodePath(enemy_data.path_nodepath_str))
		if not path_node or not path_node is Path2D: continue
		if not enemy_scene: continue

		var enemy_instance = enemy_scene.instantiate()
		var path_follow = PathFollow2D.new()
		path_node.add_child(path_follow)
		path_follow.add_child(enemy_instance)
		enemy_instance.position = Vector2.ZERO
		
		enemy_instance.died.connect(_on_enemy_died)

		if enemy_instance.has_method("set_path_follow_node"):
			enemy_instance.set_path_follow_node(path_follow)
		if "current_health" in enemy_instance and "max_health" in enemy_instance:
			enemy_instance.current_health = min(enemy_data.health, enemy_instance.max_health)
		path_follow.progress = enemy_data.progress

func _process(delta: float):
	if game_is_over: return
	if enemies_spawned_count >= total_enemies_to_spawn:
		if get_tree().get_nodes_in_group("enemies").size() == 0:
			win_condition_met()
		return
	if enemy_paths.is_empty() or enemy_scene == null: return

	time_since_last_spawn += delta
	if time_since_last_spawn >= spawn_interval:
		spawn_one_enemy_on_random_path()
		enemies_spawned_count += 1
		time_since_last_spawn = 0.0

func spawn_one_enemy_on_random_path():
	if enemy_paths.is_empty(): return
	var random_path_index = randi() % enemy_paths.size()
	var selected_path_nodepath = enemy_paths[random_path_index]
	var actual_path_node = get_node_or_null(selected_path_nodepath)
	if not actual_path_node or not actual_path_node is Path2D: return

	var enemy_instance = enemy_scene.instantiate()
	
	enemy_instance.died.connect(_on_enemy_died)
	
	var path_follow = PathFollow2D.new()
	actual_path_node.add_child(path_follow)
	path_follow.add_child(enemy_instance)
	enemy_instance.position = Vector2.ZERO
	if enemy_instance.has_method("set_path_follow_node"):
		enemy_instance.set_path_follow_node(path_follow)

func _on_enemy_died():
	if game_is_over: return
	
	score += 1
	print("Score: ", score)
	
	GameSettings.add_bullets(5)
	
	if game_ui and game_ui.has_method("update_score"):
		game_ui.update_score(score)

func update_tower_health_display(current_health: float, max_health: float):
	if game_is_over and current_health > 0: return
	if game_ui and game_ui.has_method("update_tower_health_bar"):
		game_ui.update_tower_health_bar(current_health, max_health)

# --- SIMPLIFIED SCENE CHANGE FUNCTION ---
func _initiate_scene_change(target_scene: PackedScene, delay: float):
	print("DEBUG: Initiating scene change to '", target_scene.resource_path, "' in ", delay, " seconds.")
	
	# Create a new timer
	var change_timer = Timer.new()
	change_timer.wait_time = delay
	change_timer.one_shot = true

	# When the timer finishes, change the scene
	change_timer.connect("timeout", func():
		print("DEBUG: Timer finished! Changing scene now.")
		get_tree().change_scene_to_packed(target_scene)
	)
	
	# Clean up the timer node after it has done its job
	change_timer.connect("timeout", Callable(change_timer, "queue_free"))
	
	# Add the timer to the scene and start it
	add_child(change_timer)
	change_timer.start()

# --- UPDATED GAME OVER AND WIN CONDITION FUNCTIONS ---
func game_over():
	if game_is_over: return
	game_is_over = true
	print("GAME OVER triggered.")
	GameSettings.clear_saved_state()
	
	# Clean up any active projectiles
	get_tree().call_group("enemy_bullets", "queue_free", true)
	
	var menu_scene = load(MAIN_MENU_SCENE_PATH) as PackedScene
	if menu_scene:
		# Use the 3-second delay to return to the menu
		_initiate_scene_change(menu_scene, 3.0)
	else:
		print_rich("[color=red]Error: Main Menu scene path is invalid for game_over![/color]")

func win_condition_met():
	if game_is_over: return
	game_is_over = true
	print("WIN_CONDITION_MET called.")

	# Clean up any active projectiles that could interfere during the delay
	get_tree().call_group("enemy_bullets", "queue_free", true)
	
	GameSettings.clear_saved_state()

	if next_level_scene:
		print("Next level scene is assigned. Loading in 3 seconds...")
		# Call the scene change function with the 3-second delay
		_initiate_scene_change(next_level_scene, 3.0)
	else:
		# If no next level is set, go back to menu after 3 seconds
		print("No next level scene assigned. Returning to Main Menu in 3 seconds...")
		var menu_scene = load(MAIN_MENU_SCENE_PATH) as PackedScene
		if menu_scene:
			_initiate_scene_change(menu_scene, 3.0)
		else:
			print_rich("[color=red]Error: Main Menu scene path is invalid for win_condition_met![/color]")
