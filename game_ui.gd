extends Control

# --- UI Element References ---
@onready var tower_health_bar: ProgressBar = $TowerHealthBar
@onready var score_label: Label = $ScoreLabel
@onready var end_game_message_label: Label = $EndGameMessageLabel
@onready var bullet_count_label: Label = $Sprite2D/BulletCountLabel

func _ready():
	# --- Node Verification ---
	if tower_health_bar:
		print("GameUI _ready: TowerHealthBar node FOUND.")
	else:
		print_rich("[color=red]GameUI _ready ERROR: TowerHealthBar node NOT FOUND.[/color]")

	if score_label:
		print("GameUI _ready: ScoreLabel node FOUND.")
		update_score(0) # Initialize score display
	else:
		print_rich("[color=red]GameUI _ready ERROR: ScoreLabel node NOT FOUND.[/color]")

	if end_game_message_label:
		print("GameUI _ready: EndGameMessageLabel node FOUND.")
		end_game_message_label.hide()
	else:
		print_rich("[color=red]GameUI _ready ERROR: EndGameMessageLabel node NOT FOUND.[/color]")

	if bullet_count_label:
		print("GameUI _ready: BulletCountLabel node FOUND.")
	else:
		print_rich("[color=red]GameUI _ready ERROR: BulletCountLabel node NOT FOUND.[/color]")
	
	# --- Button Setup ---
	var restart_button_node = get_node_or_null("RestartButton")
	if restart_button_node and restart_button_node is Button:
		print("GameUI _ready: RestartButton node FOUND.")
		restart_button_node.connect("pressed", Callable(self, "_on_RestartButton_pressed"))
		restart_button_node.hide()

	# --- Connect to GameSettings Signals ---
	# This is the modern, clean way to keep the UI in sync with the game state.
	if GameSettings:
		# Connect the bullet count label to the signal in GameSettings
		GameSettings.bullet_count_changed.connect(update_bullet_count)
		# Initialize the bullet count label with the starting value
		update_bullet_count(GameSettings.current_bullets)

func update_tower_health_bar(current_health: float, max_health: float):
	if tower_health_bar:
		tower_health_bar.max_value = max_health
		tower_health_bar.value = current_health
	else:
		print_rich("[color=orange]GameUI.gd: TowerHealthBar node reference is NULL.[/color]")

func update_score(new_score: int):
	if score_label:
		score_label.text = "Enemies Down: " + str(new_score)
	else:
		print_rich("[color=orange]GameUI.gd: ScoreLabel node reference is NULL.[/color]")

func update_bullet_count(count: int):
	if bullet_count_label:
		bullet_count_label.text = ": " + str(count)
	else:
		print_rich("[color=orange]GameUI.gd: BulletCountLabel node not found.[/color]")

func show_game_over():
	if end_game_message_label:
		end_game_message_label.text = "GAME OVER!"
		end_game_message_label.show()
	
	var restart_button_node = get_node_or_null("RestartButton")
	if restart_button_node and restart_button_node is Button:
		restart_button_node.text = "Restart"
		restart_button_node.show()

func show_win_screen():
	if end_game_message_label:
		end_game_message_label.text = "YOU WIN!"
		end_game_message_label.show()

	var restart_button_node = get_node_or_null("RestartButton")
	if restart_button_node and restart_button_node is Button:
		restart_button_node.text = "Play Again?"
		restart_button_node.show()

func _on_RestartButton_pressed():
	get_tree().paused = false
	var error_code = get_tree().reload_current_scene()
	if error_code != OK:
		print_rich("[color=red]GameUI.gd: Error reloading scene. Code: ", error_code, "[/color]")
