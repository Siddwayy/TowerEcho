extends Control


# --- UI Element References ---
@onready var play_game_button: TextureButton = $PlayGameButton # Adjust path if needed
@onready var quit_game_button: TextureButton = $QuitGameButton # Adjust path
@onready var sound_toggle_button: TextureButton = $SoundToggleButton # Adjust path
@onready var resume_game_button: TextureButton = $ResumeButton # Path to your Resume Button


# --- Sound Player References ---
@onready var hover_sound_player: AudioStreamPlayer2D = $HoverSoundPlayer
@onready var click_sound_player: AudioStreamPlayer2D = $ClickButtonsound
@onready var mute_sound_player: AudioStreamPlayer2D = $ClickButtonsound
@onready var menu_music_player: AudioStreamPlayer2D = $MenuMusicPlayer


# --- Preload Icons for Sound Toggle Button ---
const SOUND_ON_ICON: Texture2D = preload("res://Menu Buttons/Square Buttons/Square Buttons/Audio Square Button.png")
const SOUND_OFF_ICON: Texture2D = preload("res://Menu Buttons/Square Buttons/Colored Square Buttons/Audio col_Square Button.png")

var _is_changing_scene: bool = false
var _is_music_playing: bool = true

const MAIN_LEVEL_SCENE_PATH = "res://main_level.tscn" # Your game level path


func _ready():
	_is_changing_scene = false

	if play_game_button:
		play_game_button.connect("pressed", Callable(self, "_on_PlayGameButton_pressed"))
		play_game_button.connect("mouse_entered", Callable(self, "_on_any_button_mouse_entered"))
	else:
		print_rich("[color=red]MainMenu.gd: PlayGameButton not found! Check path.[/color]")


	if quit_game_button:
		quit_game_button.connect("pressed", Callable(self, "_on_QuitGameButton_pressed"))
		quit_game_button.connect("mouse_entered", Callable(self, "_on_any_button_mouse_entered"))
	else:
		print_rich("[color=red]MainMenu.gd: QuitGameButton not found! Check path.[/color]")
		
	if sound_toggle_button:
		sound_toggle_button.connect("pressed", Callable(self, "_on_SoundToggleButton_pressed"))
		sound_toggle_button.connect("mouse_entered", Callable(self, "_on_any_button_mouse_entered"))
	else:
		print_rich("[color=red]MainMenu.gd: SoundToggleButton not found! Check path.[/color]")

	if resume_game_button:
		resume_game_button.connect("pressed", Callable(self, "_on_ResumeButton_pressed"))
		resume_game_button.connect("mouse_entered", Callable(self, "_on_any_button_mouse_entered"))
		# Show/hide Resume button based on saved state
		if get_node("/root/GameSettings").has_saved_state:
			resume_game_button.visible = true
			resume_game_button.disabled = false
		else:
			resume_game_button.visible = false
			resume_game_button.disabled = true
	else:
		print_rich("[color=red]MainMenu.gd: ResumeButton not found![/color]")

	if not hover_sound_player:
		print_rich("[color=orange]MainMenu.gd: HoverSoundPlayer node not found.[/color]")
	if not click_sound_player: # Checks first reference to $ClickButtonsound
		print_rich("[color=orange]MainMenu.gd: ClickSoundPlayer node not found.[/color]")
	# mute_sound_player points to the same node, so if click_sound_player is found, it is too.

	if not menu_music_player:
		print_rich("[color=red]MainMenu.gd: MenuMusicPlayer not found! Music control will fail.[/color]")

	_initialize_music_and_sound_button()
	_update_all_button_states() # Initial button states


func _on_any_button_mouse_entered():
	if hover_sound_player:
		hover_sound_player.play()


func _on_PlayGameButton_pressed():
	if _is_changing_scene: return
	_disable_all_buttons()

	if click_sound_player: click_sound_player.play()

	var gs = get_node("/root/GameSettings")
	gs.clear_saved_state()
	gs.load_saved_game_on_next_start = false

	_start_scene_change_timer(MAIN_LEVEL_SCENE_PATH)
	print("Start Game button pressed - New Game")


func _on_ResumeButton_pressed():
	if _is_changing_scene: return
	var gs = get_node("/root/GameSettings")
	if not gs.has_saved_state:
		return
	_disable_all_buttons()

	if click_sound_player: click_sound_player.play()

	gs.flag_for_resume()

	_start_scene_change_timer(MAIN_LEVEL_SCENE_PATH)
	print("Resume Game button pressed")


func _on_QuitGameButton_pressed():
	if _is_changing_scene: return
	_disable_all_buttons()

	if click_sound_player:
		click_sound_player.play()
		var quit_timer = Timer.new()
		quit_timer.wait_time = 0.2
		quit_timer.one_shot = true
		quit_timer.connect("timeout", Callable(self, "_proceed_to_quit_game").bind(quit_timer))
		add_child(quit_timer)
		quit_timer.start()
	else:
		_proceed_to_quit_game(null)

	print("Exit Game button pressed!")


func _on_SoundToggleButton_pressed():
	# Use mute_sound_player or click_sound_player consistently. Let's use click_sound_player.
	if click_sound_player:
		click_sound_player.play()

	if not menu_music_player:
		print_rich("[color=red]MainMenu.gd: MenuMusicPlayer not found, cannot toggle music.[/color]")
		return

	_is_music_playing = not _is_music_playing

	if _is_music_playing:
		if not menu_music_player.playing: menu_music_player.play()
	else:
		menu_music_player.stop()

	_update_sound_button_icon()


func _update_sound_button_icon():
	if not sound_toggle_button: return
	if not SOUND_ON_ICON or not SOUND_OFF_ICON:
		print_rich("[color=red]MainMenu.gd: Sound ON/OFF icon textures not preloaded or paths are wrong![/color]")
		return

	if _is_music_playing:
		sound_toggle_button.texture_normal = SOUND_ON_ICON
	else:
		sound_toggle_button.texture_normal = SOUND_OFF_ICON


func _start_scene_change_timer(scene_path: String):
	_is_changing_scene = true
	var scene_change_timer = Timer.new()
	scene_change_timer.wait_time = 0.2
	scene_change_timer.one_shot = true
	scene_change_timer.connect("timeout", Callable(self, "_proceed_to_change_scene").bind([scene_path, scene_change_timer]))
	add_child(scene_change_timer)
	scene_change_timer.start()


func _proceed_to_change_scene(data: Array):
	var scene_path = data[0]
	var timer_node = data[1]

	print("Proceeding to change scene to: ", scene_path)
	var error_code = get_tree().change_scene_to_file(scene_path)
	if error_code != OK:
		print_rich("[color=red]MainMenu.gd: Error changing scene. Code: ", error_code, "[/color]")
		_is_changing_scene = false # Reset if scene change failed
		_update_all_button_states()

	if timer_node:
		timer_node.queue_free()


func _proceed_to_quit_game(timer_node: Timer = null):
	get_tree().quit()
	if timer_node: timer_node.queue_free()


func _disable_all_buttons():
	if play_game_button: play_game_button.disabled = true
	if quit_game_button: quit_game_button.disabled = true
	if sound_toggle_button: sound_toggle_button.disabled = true
	if resume_game_button: resume_game_button.disabled = true


func _update_all_button_states():
	var disable_buttons = _is_changing_scene
	if play_game_button: play_game_button.disabled = disable_buttons
	if quit_game_button: quit_game_button.disabled = disable_buttons
	if sound_toggle_button: sound_toggle_button.disabled = disable_buttons

	if resume_game_button:
		var gs = get_node("/root/GameSettings")
		if gs.has_saved_state and not _is_changing_scene:
			resume_game_button.visible = true
			resume_game_button.disabled = false
		else:
			resume_game_button.visible = false
			resume_game_button.disabled = true


func _initialize_music_and_sound_button():
	if menu_music_player:
		# Sync _is_music_playing with actual player state only if it's different from expectation
		if menu_music_player.playing != _is_music_playing:
			_is_music_playing = menu_music_player.playing

		# Ensure music plays or stops based on the _is_music_playing state
		if _is_music_playing and not menu_music_player.playing:
			menu_music_player.play()
		elif not _is_music_playing and menu_music_player.playing:
			menu_music_player.stop()

	_update_sound_button_icon()


func _notification(what):
	if what == NOTIFICATION_ENTER_TREE or (what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree()):
		print("MainMenu visibility changed or entered tree. Updating button states.")
		_is_changing_scene = false
		_update_all_button_states()
		if menu_music_player and _is_music_playing and not menu_music_player.playing:
			menu_music_player.play()
