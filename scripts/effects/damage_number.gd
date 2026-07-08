# DamageNumber.gd
extends Label

# How much the damage number floats upwards (in pixels)
var travel_distance_y: float = -40.0 # Negative Y is upwards
# How long the number stays visible and animates (in seconds)
var animation_duration: float = 0.75 
# How much horizontal jitter/offset (0 for no jitter)
var horizontal_jitter: float = 15.0 

# This function will be called by whatever spawns this damage number (e.g., the Tower)
func show_damage(damage_amount: int, start_global_position: Vector2):
	text = "-" + str(damage_amount) # Set the text like "-20"

	# Apply a little random horizontal offset for variety
	var random_offset_x = randf_range(-horizontal_jitter, horizontal_jitter)
	global_position = start_global_position + Vector2(random_offset_x, 0)

	# Optional: Center the label on its spawn point based on its actual size
	# This makes it appear more neatly at the spawn_position.
	# Do this after setting text and before starting tween if label resizes.
	# Ensure your Label's Control > Size Flags are set to not expand if you do this,
	# or call size_to_text() if available and needed.
	# For simplicity, we'll assume default label sizing.
	# A more robust way:
	# call_deferred("set_pivot_offset_to_center") 
	# func set_pivot_offset_to_center():
	#     pivot_offset = size / 2.0
	#     global_position -= pivot_offset # Adjust global position after setting pivot


	# Create a Tween for animation
	var tween = create_tween()

	# Animate movement: move upwards
	# Target position is current position + travel_distance_y
	var target_position = global_position + Vector2(0, travel_distance_y)
	tween.tween_property(self, "global_position", target_position, animation_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT) # Smooth easing out

	# Animate fade out: change modulate.a (alpha/transparency) from 1 to 0
	# Start fading a bit after it starts moving, e.g., after 30% of total duration
	var fade_delay = animation_duration * 0.3
	var actual_fade_duration = animation_duration - fade_delay
	tween.tween_property(self, "modulate:a", 0.0, actual_fade_duration)\
		.set_delay(fade_delay)

	# When the tween has completed all its animations, queue_free this damage number instance.
	tween.connect("finished", Callable(self, "queue_free"))
