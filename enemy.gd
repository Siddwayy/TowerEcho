# Enemy.gd
extends CharacterBody2D

# --- ADD THIS SIGNAL ---
# This signal will be broadcasted when the enemy dies.
signal died

@export var max_health: int = 2 # Enemy's maximum health
var current_health: int
var is_dying: bool = false # To manage state and prevent actions when dying

var speed = 180.0 # How fast the enemy moves along the path

var path_follow_node: PathFollow2D = null

@onready var visual_sprite: Sprite2D = $Sprite2D
var hit_flash_tween: Tween

# --- Enemy Shooting Variables ---
@onready var muzzle: Marker2D = $Muzzle
const EnemyBulletScene: PackedScene = preload("res://enemy_bullet.tscn")
var can_shoot_bullet: bool = false
@export var enemy_fire_rate: float = 1.5
var tower_target: Node2D = null
@onready var enemy_shoot_sound_player: AudioStreamPlayer2D = $EnemyShootSoundPlayer

const DestructionParticleEffect = preload("res://Destruction_Effect.tscn")
const ENEMY_DESTRUCTION_SOUND = preload("res://EnemyExplosionSound.tscn")
const DamageNumberScene = preload("res://DamageNumber2.tscn")

func _ready():
	randomize()
	add_to_group("enemies")
	current_health = max_health
	is_dying = false

	if not visual_sprite: print_rich("[color=red]Enemy.gd _ready: 'Sprite2D' node not found![/color]")
	if not muzzle: print_rich("[color=red]Enemy.gd _ready: 'Muzzle' Marker2D node not found! Enemy cannot shoot.[/color]")
	if not EnemyBulletScene: print_rich("[color=red]Enemy.gd _ready: EnemyBullet.tscn not preloaded![/color]")
	if not enemy_shoot_sound_player:
		print_rich("[color=orange]Enemy.gd _ready: EnemyShootSoundPlayer node not found. Enemy shoot sounds will not play.[/color]")

	var towers = get_tree().get_nodes_in_group("player_tower")
	if towers.size() > 0:
		tower_target = towers[0]
	else:
		print_rich("[color=orange]Enemy '", name, "': No node in group 'player_tower' to target.[/color]")

	if enemy_fire_rate > 0:
		var initial_shoot_timer = Timer.new()
		initial_shoot_timer.wait_time = (1.0 / enemy_fire_rate) * randf_range(0.5, 1.5)
		initial_shoot_timer.one_shot = true
		initial_shoot_timer.connect("timeout", Callable(self, "_on_enemy_fire_rate_timer_timeout"))
		initial_shoot_timer.connect("timeout", Callable(initial_shoot_timer, "queue_free"))
		add_child(initial_shoot_timer)
		initial_shoot_timer.start()
	else:
		can_shoot_bullet = false

func set_path_follow_node(pf_node: PathFollow2D):
	path_follow_node = pf_node

func _physics_process(delta):
	if is_dying or is_queued_for_deletion():
		return

	if path_follow_node:
		if is_instance_valid(tower_target):
			look_at(tower_target.global_position)

		path_follow_node.progress += speed * delta
		if path_follow_node.progress_ratio >= 1.0:
			var main_level = get_tree().current_scene
			if main_level and main_level.has_method("game_over"): main_level.game_over()
			if get_parent() is PathFollow2D: get_parent().queue_free()
			else: queue_free()

	if is_instance_valid(tower_target) and can_shoot_bullet:
		_enemy_shoot()

func _enemy_shoot():
	if is_dying or not is_instance_valid(tower_target) or \
	   not is_instance_valid(muzzle) or not EnemyBulletScene:
		return

	can_shoot_bullet = false

	if enemy_shoot_sound_player:
		enemy_shoot_sound_player.play()

	var bullet = EnemyBulletScene.instantiate() as Node
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position

	if bullet.has_method("set_target_direction"):
		bullet.set_target_direction(tower_target.global_position, muzzle.global_position)
	else:
		print_rich("[color=orange]Enemy '", name, "': EnemyBullet instance has no set_target_direction method.[/color]")

	if enemy_fire_rate > 0:
		var fire_timer = Timer.new()
		fire_timer.wait_time = 1.0 / enemy_fire_rate
		fire_timer.one_shot = true
		fire_timer.connect("timeout", Callable(self, "_on_enemy_fire_rate_timer_timeout"))
		fire_timer.connect("timeout", Callable(fire_timer, "queue_free"))
		add_child(fire_timer)
		fire_timer.start()

func _on_enemy_fire_rate_timer_timeout():
	can_shoot_bullet = true

func take_damage(amount: int):
	if is_dying or current_health <= 0:
		return

	current_health -= amount
	print("Enemy '", name, "' took ", amount, " damage, health now: ", current_health, "/", max_health)

	if DamageNumberScene:
		var dmg_num_instance = DamageNumberScene.instantiate()
		get_tree().current_scene.add_child(dmg_num_instance)
		var spawn_offset = Vector2(randf_range(-15.0, 15.0), -30.0)
		var spawn_position = self.global_position + spawn_offset
		if dmg_num_instance.has_method("show_damage"):
			dmg_num_instance.show_damage(amount, spawn_position)

	if current_health <= 0:
		if not is_dying:
			die()
	else:
		_play_hit_flash_and_shake()

func _play_hit_flash_and_shake():
	if not is_instance_valid(visual_sprite): return
	if hit_flash_tween and hit_flash_tween.is_valid(): hit_flash_tween.kill()
	var original_modulate: Color = visual_sprite.modulate
	var flash_modulate_color: Color = Color(1.0, 0.5, 0.5, 0.7)
	var original_sprite_position: Vector2 = visual_sprite.position
	var jiggle_amplitude: float = 4.0
	var num_full_jiggles: int = 2
	var total_jiggle_segments: int = num_full_jiggles * 2
	var single_jiggle_segment_duration: float = 0.07
	var flash_on_duration: float = 0.02
	var fade_back_modulate_duration: float = 0.15
	hit_flash_tween = create_tween()
	hit_flash_tween.tween_property(visual_sprite, "modulate", flash_modulate_color, flash_on_duration)
	for i in range(total_jiggle_segments):
		var target_pos: Vector2
		if i % 2 == 0:
			var random_offset_x = randf_range(-jiggle_amplitude, jiggle_amplitude)
			var random_offset_y = randf_range(-jiggle_amplitude, jiggle_amplitude)
			target_pos = original_sprite_position + Vector2(random_offset_x, random_offset_y)
		else:
			target_pos = original_sprite_position
		hit_flash_tween.tween_property(visual_sprite, "position", target_pos, single_jiggle_segment_duration)
	hit_flash_tween.tween_property(visual_sprite, "modulate", original_modulate, fade_back_modulate_duration)

func die():
	if is_dying or is_queued_for_deletion(): return
	is_dying = true

	print("Enemy '", name, "' died!")
	
	# --- MODIFIED SECTION ---
	# Announce that this enemy has died. MainLevel will handle the rewards.
	emit_signal("died")
	# The direct call to add_score has been removed from here.
	# --- END MODIFICATION ---

	if hit_flash_tween and hit_flash_tween.is_valid():
		hit_flash_tween.kill()
		if is_instance_valid(visual_sprite):
			visual_sprite.modulate = Color(1,1,1,1)
			visual_sprite.position = Vector2.ZERO

	if DestructionParticleEffect:
		var particle_effect_instance = DestructionParticleEffect.instantiate()
		get_tree().current_scene.add_child(particle_effect_instance)
		particle_effect_instance.global_position = self.global_position

	if ENEMY_DESTRUCTION_SOUND:
		var sound_instance = ENEMY_DESTRUCTION_SOUND.instantiate()
		get_tree().current_scene.add_child(sound_instance)

	if path_follow_node and get_parent() == path_follow_node:
		path_follow_node.queue_free()
	else:
		queue_free()
