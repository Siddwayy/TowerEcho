extends Area2D

# --- Health Variables ---
@export var max_health: float = 100.0
var current_health: float
var is_dying: bool = false # To prevent die() or taking damage multiple times

# Track score milestones for health boosts
var last_score_checkpoint: int = 0

# --- Shooting Variables ---
@export var fire_rate: float = 15.0
var can_shoot: bool = true

# --- Existing Variables ---
var target_enemy: Node2D = null

# Node references, assigned when the node is ready.
@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_sound_player: AudioStreamPlayer2D = $ShootSoundPlayer
@onready var hurtbox: Area2D = $HurtBox
@onready var hit_sound_player: AudioStreamPlayer2D = $HitSoundPlayer
@onready var shoot_effect_sprite: AnimatedSprite2D = $Muzzle/ShootEffectSprite
@onready var laser_trace: Line2D = $Muzzle/LaserTrace
@onready var laser_raycast: RayCast2D = $Muzzle/LaserRayCast

# Scene Preloads
var bullet_scene: PackedScene = preload("res://Bullet.tscn")
const TURRET_DESTRUCTION_PARTICLE = preload("res://Destruction_Effect.tscn")
const TURRET_DESTRUCTION_SOUND = preload("res://TowerExplosionSound.tscn")
const DamageNumberScene = preload("res://DamageNumber.tscn")

# --- Camera Shake Variable ---
var camera_shake_tween: Tween

func _input(event: InputEvent):
	if is_dying:
		return
	pass

func _ready():
	randomize()

	print("--- TOWER READY ---")

	# If resuming from a saved state, override current_health before updating UI
	if GameSettings.load_saved_game_on_next_start and GameSettings.has_saved_state:
		current_health = GameSettings.saved_tower_health
		print("Tower._ready: Loaded saved health:", current_health)
	else:
		current_health = max_health
		print("Tower._ready: No saved state, default health:", current_health)

	if is_dying:
		return

	# Update UI with whatever health we have (resume or new)
	var main_level = get_tree().current_scene
	if main_level and main_level.has_method("update_tower_health_display"):
		main_level.update_tower_health_display(current_health, max_health)
	else:
		print_rich("[color=orange]Tower _ready: MainLevel or update_tower_health_display method NOT FOUND.[/color]")

	# Connect the rest as before
	var targeting_detection_shape = CircleShape2D.new()
	targeting_detection_shape.radius = 1000
	var targeting_collision_shape = CollisionShape2D.new()
	targeting_collision_shape.shape = targeting_detection_shape
	add_child(targeting_collision_shape)
	connect("body_entered", Callable(self, "_on_targeting_area_body_entered"))
	connect("body_exited", Callable(self, "_on_targeting_area_body_exited"))

	if hurtbox:
		hurtbox.connect("body_entered", Callable(self, "_on_hurtbox_body_entered"))
	else:
		print_rich("[color=red]ERROR: Tower.gd - Hurtbox node (expected name 'HurtBox') not found![/color]")

	if shoot_effect_sprite:
		shoot_effect_sprite.connect("animation_finished", Callable(self, "_on_shoot_effect_sprite_animation_finished"))
		shoot_effect_sprite.visible = false
	else:
		print_rich("[color=orange]Tower.gd: ShootEffectSprite node not found. Shooting animation will not play.[/color]")

	if not laser_trace:
		print_rich("[color=orange]Tower.gd: LaserTrace Line2D node not found.[/color]")
	else:
		laser_trace.visible = false

	if not laser_raycast:
		print_rich("[color=red]ERROR: Tower.gd - LaserRayCast node not found! Laser will not detect enemies.[/color]")

func _on_targeting_area_body_entered(body: Node2D):
	if is_dying: return
	if body.is_in_group("enemies") and (target_enemy == null or not is_instance_valid(target_enemy)):
		target_enemy = body

func _on_targeting_area_body_exited(body: Node2D):
	if is_dying: return
	if body == target_enemy:
		target_enemy = null
		find_new_target_in_range()

func find_new_target_in_range():
	if is_dying: return
	var bodies_in_range: Array = get_overlapping_bodies()
	var closest_enemy_candidate: Node2D = null
	var min_dist_sq: float = INF
	for body_in_range in bodies_in_range:
		if body_in_range.is_in_group("enemies") and is_instance_valid(body_in_range):
			var dist_sq: float = global_position.distance_squared_to(body_in_range.global_position)
			if dist_sq < min_dist_sq:
				min_dist_sq = dist_sq
				closest_enemy_candidate = body_in_range
	target_enemy = closest_enemy_candidate

func _on_hurtbox_body_entered(body: Node2D):
	if is_dying:
		return

	if body.is_in_group("enemies"):
		print("--- TOWER HURTBOX COLLISION with: ", body.name, " ---")

		if hit_sound_player:
			hit_sound_player.play()
		else:
			print_rich("[color=orange]Tower.gd: HitSoundPlayer node not found or not ready.[/color]")

		take_damage(20.0)

		if body and is_instance_valid(body):
			print("Enemy '", body.name, "' collided with tower and is being removed directly.")
			body.queue_free()

func take_damage(amount: float):
	if is_dying:
		return

	print("--- TOWER TAKE_DAMAGE ---")
	print("  Before damage - Current Health: ", current_health, " | Damage Amount: ", amount)
	current_health -= amount
	current_health = max(0, current_health)
	print("  After damage - Current Health: ", current_health)

	var main_level = get_tree().current_scene
	if main_level and main_level.has_method("update_tower_health_display"):
		main_level.update_tower_health_display(current_health, max_health)
	else:
		print_rich("[color=orange]Tower take_damage: MainLevel or update_tower_health_display method NOT FOUND.[/color]")

	if DamageNumberScene:
		var dmg_num_instance = DamageNumberScene.instantiate()
		get_tree().current_scene.add_child(dmg_num_instance)
		var spawn_offset = Vector2(randf_range(-20.0, 20.0), -40.0)
		var spawn_position = self.global_position + spawn_offset
		if dmg_num_instance.has_method("show_damage"):
			dmg_num_instance.show_damage(int(amount), spawn_position)
	else:
		print_rich("[color=red]ERROR: Tower.gd - DamageNumberScene not preloaded![/color]")

	_start_camera_shake(5.0, 0.15, 20.0)

	if current_health <= 0:
		print("  Health depleted! Calling die() for tower.")
		die()
	else:
		print("  Tower survived hit. Health remaining: ", current_health)

func die():
	if is_dying:
		print("--- TOWER DIE (already dying, returning) ---")
		return
	is_dying = true

	print("--- TOWER DIE (EXECUTING) ---")

	var visual_node = get_node_or_null("Sprite2D")
	if visual_node:
		visual_node.hide()
		print("  Tower visuals hidden.")
	if hurtbox and hurtbox.has_node("CollisionShape2D"):
		var hurtbox_shape = hurtbox.get_node_or_null("CollisionShape2D")
		if hurtbox_shape:
			hurtbox_shape.disabled = true
			print("  Tower hurtbox disabled.")

	print("Tower DESTROYED! Spawning particle effect.")

	if TURRET_DESTRUCTION_PARTICLE:
		var particle_instance = TURRET_DESTRUCTION_PARTICLE.instantiate()
		get_tree().current_scene.add_child(particle_instance)
		particle_instance.global_position = self.global_position
		print("  Particle effect should be spawned now.")
	else:
		print_rich("[color=red]ERROR: Tower.gd - TURRET_DESTRUCTION_PARTICLE not loaded![/color]")

	if TURRET_DESTRUCTION_SOUND:
		var sound_instance = TURRET_DESTRUCTION_SOUND.instantiate()
		get_tree().current_scene.add_child(sound_instance)
		print("  Tower destruction sound instance created.")
	else:
		print_rich("[color=red]ERROR: Tower.gd - TURRET_DESTRUCTION_SOUND not loaded![/color]")

	if shoot_sound_player and shoot_sound_player.playing:
		shoot_sound_player.stop()

	var actual_shake_duration = 0.4
	_start_camera_shake(15.0, actual_shake_duration, 20.0)
	print("  Major camera shake initiated.")

	var main_level = get_tree().current_scene
	if main_level and main_level.has_method("game_over"):
		main_level.game_over()
	else:
		print_rich("[color=orange]Tower die: MainLevel or game_over method NOT FOUND.[/color]")

	var death_timer = Timer.new()
	death_timer.wait_time = actual_shake_duration + 0.1
	death_timer.one_shot = true
	death_timer.connect("timeout", Callable(self, "queue_free"))
	add_child(death_timer)
	death_timer.start()
	print("  Tower (now visually hidden) self-destruction timer started for ", death_timer.wait_time, "s.")

func _start_camera_shake(amplitude: float = 10.0, duration: float = 0.3, frequency: float = 15.0):
	var camera = get_viewport().get_camera_2d()
	if not camera:
		print_rich("[color=orange]Tower.gd: Camera shake couldn't find an active Camera2D.[/color]")
		return

	if camera_shake_tween and camera_shake_tween.is_valid():
		camera_shake_tween.kill()

	camera_shake_tween = create_tween()
	var original_offset: Vector2 = camera.offset
	var shake_count = int(duration * frequency)
	if shake_count <= 0: shake_count = 1

	var time_per_shake_step = duration / float(shake_count)

	for i in range(shake_count):
		var random_x = randf_range(-amplitude, amplitude)
		var random_y = randf_range(-amplitude, amplitude)
		var target_offset = original_offset + Vector2(random_x, random_y)

		camera_shake_tween.tween_property(camera, "offset", target_offset, time_per_shake_step).set_trans(Tween.TRANS_SINE)

	camera_shake_tween.tween_property(camera, "offset", original_offset, time_per_shake_step).set_trans(Tween.TRANS_SINE)

func _process(delta: float):
	# Check MainLevel's score and boost health every 10 points
	var main_level = get_tree().current_scene
	if main_level and "score" in main_level:
		var current_score = main_level.score
		if current_score >= last_score_checkpoint + 10:
			last_score_checkpoint += 10
			max_health += 20.0
			current_health = min(current_health + 20.0, max_health)
			print("Tower.gd: Score reached ", current_score, ". max_health now ", max_health, ", current_health now ", current_health)
			if main_level.has_method("update_tower_health_display"):
				main_level.update_tower_health_display(current_health, max_health)

	if is_dying:
		if laser_trace: laser_trace.visible = false
		return

	look_at(get_global_mouse_position())

	if laser_trace and laser_raycast:
		laser_trace.visible = true
		var laser_end_point_local = laser_raycast.target_position
		laser_raycast.force_raycast_update()
		if laser_raycast.is_colliding():
			var collider = laser_raycast.get_collider()
			if collider and collider.is_in_group("enemies"):
				var collision_global_point = laser_raycast.get_collision_point()
				var local_hit_point = muzzle.to_local(collision_global_point)
				laser_end_point_local = local_hit_point
		laser_trace.set_point_position(1, laser_end_point_local)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if can_shoot:
			shoot()

	if not target_enemy or not is_instance_valid(target_enemy):
		if get_overlapping_bodies().size() > 0:
			find_new_target_in_range()

func shoot():
	if is_dying: return

	# Check for bullets before doing anything else
	if GameSettings.current_bullets <= 0:
		# Optional: Play an "out of ammo" sound effect here
		return # Exit the function; no shooting allowed

	can_shoot = false

	# Decrement bullet count since we are about to fire
	GameSettings.use_bullet()

	if shoot_sound_player: shoot_sound_player.play()
	if shoot_effect_sprite:
		shoot_effect_sprite.visible = true
		shoot_effect_sprite.frame = 0
		shoot_effect_sprite.play("shoot")
	if laser_trace and not laser_trace.visible:
		laser_trace.visible = true

	if not bullet_scene: can_shoot = true; return
	if not muzzle: can_shoot = true; return

	var bullet_instance: Node2D = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	var spawn_pos = self.global_position
	if is_instance_valid(muzzle): spawn_pos = muzzle.global_position
	bullet_instance.global_position = spawn_pos
	var mouse_pos = get_global_mouse_position()
	var shoot_direction: Vector2 = (mouse_pos - spawn_pos).normalized()
	if bullet_instance.has_method("set_direction"):
		bullet_instance.set_direction(shoot_direction)

	var fire_timer = Timer.new()
	fire_timer.wait_time = 1.0 / fire_rate
	fire_timer.one_shot = true
	fire_timer.connect("timeout", Callable(self, "_on_fire_timer_timeout"))
	add_child(fire_timer)
	fire_timer.start()
	fire_timer.connect("timeout", Callable(fire_timer, "queue_free"))

func _on_fire_timer_timeout():
	can_shoot = true

func _on_shoot_effect_sprite_animation_finished():
	if shoot_effect_sprite and shoot_effect_sprite.animation == "shoot":
		shoot_effect_sprite.visible = false
