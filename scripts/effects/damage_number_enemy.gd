# Inside DamageNumber.gd (example structure)
extends Label

var travel_distance_y: float = -40.0 
var animation_duration: float = 0.3 # <--- THIS IS THE VARIABLE TO CHANGE
var horizontal_jitter: float = 15.0 

func show_damage(damage_amount: int, start_global_position: Vector2):
	text = "-" + str(damage_amount)
	var random_offset_x = randf_range(-horizontal_jitter, horizontal_jitter)
	# Adjust start position slightly if your label's pivot isn't centered
	# For example, if pivot is top-left:
	# global_position = start_global_position + Vector2(random_offset_x - size.x / 2, 0)
	# Or better, set pivot_offset = size / 2.0 after setting text, then set global_position.
	# For now, assuming simple offset:
	global_position = start_global_position + Vector2(random_offset_x, 0)


	var tween = create_tween()
	var target_position = global_position + Vector2(0, travel_distance_y)

	# Movement tween
	tween.tween_property(self, "global_position", target_position, animation_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Fade out tween (modulate alpha from 1 to 0)
	# Example: Start fading after 30% of total duration, fade over the remaining 70%
	var fade_start_delay = animation_duration * 0.3 
	var actual_fade_duration = animation_duration - fade_start_delay
	tween.tween_property(self, "modulate:a", 0.0, actual_fade_duration)\
		.set_delay(fade_start_delay)

	tween.connect("finished", Callable(self, "queue_free"))
