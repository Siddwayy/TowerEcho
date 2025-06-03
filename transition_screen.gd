# transition_screen.gd
extends Control

# This variable will hold the scene we want to transition TO.
# We make it an @export var so we can set it in the Inspector.
@export var next_level_scene: PackedScene


func _ready():
	# We connect the timer's "timeout" signal to our function via code.
	# This is an alternative to using the Node tab.
	$Timer.timeout.connect(load_next_level)


func load_next_level():
	# This function is called when the timer finishes.
	if next_level_scene:
		# If a next level is assigned, change to it.
		get_tree().change_scene_to_packed(next_level_scene)
	else:
		# As a fallback, if we forgot to assign a level, print an error
		# and go back to the main menu so the game doesn't get stuck.
		print("ERROR: No next level scene was assigned to the TransitionScreen!")
		get_tree().change_scene_to_file("res://main_menu.tscn")
