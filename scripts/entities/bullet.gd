# Bullet.gd
extends Area2D

var speed = 500.0  # How fast the bullet moves (pixels per second)
var direction = Vector2.RIGHT # Default direction; tower will set the actual direction
var lifetime = 3.0 # How many seconds the bullet will exist if it hits nothing

# This function runs once when the bullet is created (instantiated).
func _ready():
	# --- Collision Detection Setup ---
	connect("body_entered", Callable(self, "_on_body_entered"))

	# --- Lifetime Timer Setup ---
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "queue_free"))
	add_child(timer)
	timer.start()

# This function runs every frame. 'delta' is the time since the last frame.
func _process(delta):
	global_position += direction * speed * delta

# This function will be called by the Tower to tell the bullet which way to go.
func set_direction(dir_vector):
	direction = dir_vector.normalized()
	rotation = direction.angle()

# This function is automatically called when something enters the bullet's Area2D
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(1) # Deal 1 damage (or any amount)
		queue_free() # Bullet disappears on hit
	# Optional: if it hits a wall or something else
	# elif body.is_in_group("obstacles"):
	#     queue_free()
