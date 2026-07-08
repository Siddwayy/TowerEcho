# EnemyBullet.gd
extends Area2D

var speed: float = 350.0 # Speed of the enemy bullet
var direction: Vector2 = Vector2.RIGHT # Will be set by the enemy
var lifetime: float = 3.5  # How long it lives before disappearing
const DAMAGE_TO_TOWER: int = 5 # Damage this bullet does to the tower

func _ready():
	add_to_group("enemy_bullets") # Ensure it's in the group
	connect("area_entered", Callable(self, "_on_area_entered"))

	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "queue_free"))
	add_child(timer)
	timer.start()

func _physics_process(delta: float):
	global_position += direction * speed * delta

# Called by the Enemy when it fires this bullet
func set_target_direction(target_global_pos: Vector2, start_global_pos: Vector2):
	direction = (target_global_pos - start_global_pos).normalized()
	# Rotate the visual to match the direction
	# var visual_node = get_node_or_null("Visual") # Or your sprite's name
	# if visual_node:
	#     visual_node.rotation = direction.angle() # THIS WAS COMMENTED OUT IN MY PREVIOUS FULL SCRIPT FOR ENEMYBULLET
												 # BUT THE USER'S PASTED SCRIPT HAD IT UNCOMMENTED.




func _on_area_entered(area: Area2D):
	print("EnemyBullet collided with Area: ", area.name, " in groups: ", area.get_groups()) # DEBUG

	# Hit the Tower's Hurtbox
	if area.is_in_group("tower_hurtbox"):
		var tower_node = area.get_parent() # Assuming HurtBox is child of the main Tower node
		if tower_node and tower_node.has_method("take_damage"):
			print("EnemyBullet: Damaging tower.")
			tower_node.take_damage(DAMAGE_TO_TOWER)
		queue_free() # Enemy bullet disappears

	# Hit a Player's Bullet
	elif area.is_in_group("player_bullets"):
		print("EnemyBullet: Collided with player_bullet. Both destroyed.")
		area.queue_free() # Destroy the player's bullet
		queue_free() # Destroy this enemy bullet
