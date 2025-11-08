@tool
extends Area2D
class_name Debris2D

@export_category("Sprite")
@export var sprite: Node2D
@export var can_flip_h: bool = true
@export var can_flip_v: bool = true

@export_category("Collision")
@export var static_body: StaticBody2D
@export var can_static_body_receive_damage: bool = true
@export var static_body_damage_to_break_threshold: float = 10.0
var static_body_damage_receiver: DamageReceiver

@export_category("Gibs")
@export var break_gibs: Array[PackedScene] = [
	preload("res://Scenes/Env/Gibs/Stone/StoneGib001.tscn")
]
@export var break_gibs_num_min_max: Vector2i = Vector2i(1, 2)
@export var break_gibs_direction_spread: Vector2 = Vector2(-0.4, 0.4)

@export_category("Stages")
@export var break_stages_num: int = 0
@export var break_stages_animation_name: StringName = &"Break"
@export var disable_collision_on_last_break_stage: bool = true
@export var z_index_on_last_break_stage: int = 0
@export var remove_on_last_break_stage: bool = true

@export_category("Post Break")
@export var apply_post_last_break_stage_effects: bool = true
@export var post_last_break_stage_darkening: float = 0.2
@export var post_last_break_stage_shrinking_speed: float = 0.1

@export_category("Particles")
@export var break_particles_scene_path: String = "res://addons/GodotCommons-Core/Scenes/Particles/Dust/Dust001_GPU.tscn"
@export var break_particles_scene_path_web: String = "res://addons/GodotCommons-Core/Scenes/Particles/Dust/Dust001_CPU.tscn"
@export var break_particles_min_max: Vector2i = Vector2i(0, 2)
@export var spawn_break_particles_on_mobile_web: bool = false

@export_category("Tile Map Layer")
@export var local_occupation_coords: Array[Vector2i] = [ Vector2i.ZERO ]

@export_category("Drop")
@export var break_drop_scene: PackedScene# = preload("res://Scenes/Items/Experience001.tscn")
@export var break_drop_num_min_max: Vector2i = Vector2i.ONE

var break_current_stage: int = 0

func _ready() -> void:
	
	if Engine.is_editor_hint():
		
		if not sprite:
			sprite = find_child("*?prite*") as Sprite2D
		
		if not static_body:
			static_body = find_child("*atic*ody*") as StaticBody2D
		
		if static_body and (get_parent() is TileMapLayer):
			static_body.visible = false
			_update_sprite()
	else:
		break_current_stage = -1
		
		area_entered.connect(_on_target_entered)
		body_entered.connect(_on_target_entered)
		
		_update_sprite()
		
		if static_body:
			if can_static_body_receive_damage:
				static_body_damage_receiver = DamageReceiver.new()
				static_body_damage_receiver.owner_body_2d = static_body
				static_body_damage_receiver.show_damage_numbers = false
				static_body_damage_receiver.receive_damage.connect(_on_static_body_receive_damage)
				static_body.add_child(static_body_damage_receiver)
	
	var procedurals_layer := get_parent() as LevelTileMapLayer_Procedurals
	if procedurals_layer:
		var this_cell := procedurals_layer.local_to_map(position)
		for sample_occupation: Vector2i in local_occupation_coords:
			
			var occupied_cell := this_cell + sample_occupation
			if procedurals_layer.is_cell_occupied(occupied_cell) or procedurals_layer.wall_layer.has_cell(occupied_cell):
				procedurals_layer.erase_cell(this_cell)
				queue_free()
				return
			else:
				procedurals_layer.mark_cell_occupied(occupied_cell, self)

func _update_sprite() -> void:
	
	assert(sprite)
	
	if sprite is Sprite2D:
		
		sprite.frame = randi_range(0, sprite.hframes * sprite.vframes - 1)
		
		if can_flip_h:
			sprite.flip_h = ((randi() % 2) == 0)
		if can_flip_v:
			sprite.flip_v = ((randi() % 2) == 0)
		
	elif sprite is AnimatedSprite2D:
		
		if can_flip_h:
			sprite.flip_h = ((randi() % 2) == 0)
		if can_flip_v:
			sprite.flip_v = ((randi() % 2) == 0)

func _on_target_entered(in_target: Node2D) -> void:
	pass

func _on_static_body_receive_damage(in_source: Node, in_damage: float, in_ignored_immunity_time: bool) -> void:
	
	if in_damage >= static_body_damage_to_break_threshold:
		handle_break(static_body_damage_receiver.CalcLastDamageImpulse2D(), false)

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	handle_break(in_impulse, true)
	return true

func handle_break(in_impulse: Vector2, in_try_ignite: bool) -> void:
	
	if break_current_stage > break_stages_num:
		if apply_post_last_break_stage_effects:
			modulate = modulate.darkened(post_last_break_stage_darkening)
			sprite.scale = sprite.scale.lerp(Vector2(0.5, 0.5), post_last_break_stage_shrinking_speed)
		return
	
	break_current_stage += 1
	
	try_spawn_break_gibs(in_impulse, in_try_ignite)
	try_spawn_break_particles(in_impulse, in_try_ignite)
	
	if break_current_stage == break_stages_num:
		
		z_index = z_index_on_last_break_stage
		
		if remove_on_last_break_stage:
			queue_free()
		elif disable_collision_on_last_break_stage:
			if is_instance_valid(static_body):
				static_body.queue_free()
		
		if static_body:
			WorldGlobals._level.request_nav_update()
		
		handle_break_drop()
	else:
		if sprite is AnimatedSprite2D:
			sprite.animation = break_stages_animation_name
			sprite.frame = break_current_stage
			sprite.pause()

func handle_break_drop() -> void:
	
	if break_drop_scene:
		
		var spawn_num := randi_range(break_drop_num_min_max.x, break_drop_num_min_max.y)
		for sample_index: int in range(spawn_num):
			
			var break_drop := break_drop_scene.instantiate() as Node2D
			
			var spawn_direction := Vector2.from_angle(randf_range(0.0, TAU))
			break_drop.position = position + (spawn_direction * float(sample_index) * 8.0)
			add_sibling.call_deferred(break_drop)
			
			if break_drop is RigidBody2D:
				break_drop.ready.connect(break_drop.apply_central_impulse.bind(spawn_direction / break_drop.mass * randf_range(0.2, 0.8)))

func try_spawn_break_gibs(in_impulse: Vector2, in_try_ignite: bool) -> bool:
	
	if break_gibs.is_empty():
		return false
	
	var impulse_magnitude := in_impulse.length()
	
	for sample_index: int in range(randi_range(break_gibs_num_min_max.x, break_gibs_num_min_max.y)):
		
		var sample_gib := break_gibs.pick_random().instantiate() as Gib2D
		sample_gib.position = position
		sample_gib.rotation = randf_range(-PI, PI)
		add_sibling.call_deferred(sample_gib)
		
		sample_gib.ready.connect(func():
			sample_gib.apply_central_impulse(in_impulse.rotated(randf_range(break_gibs_direction_spread.x, break_gibs_direction_spread.y)) * randf_range(0.5, 1.5))
			sample_gib.apply_torque_impulse(randf_range(-PI, PI))
		, Object.CONNECT_DEFERRED)
		
		if in_try_ignite:
			sample_gib.try_ignite(impulse_magnitude * randf_range(0.04, 0.08))
	return true

func try_spawn_break_particles(in_impulse: Vector2, in_try_ignite: bool) -> bool:
	
	if not spawn_break_particles_on_mobile_web and PlatformGlobals_Class.is_mobile_web():
		return false
	
	var particles_scene_path := break_particles_scene_path_web if PlatformGlobals_Class.is_web() else break_particles_scene_path
	if particles_scene_path.is_empty():
		return false
	
	var particles_scene := ResourceLoader.load(particles_scene_path, "PackedScene")
	
	var particles_num := randi_range(break_particles_min_max.x, break_particles_min_max.y)
	if particles_num > 0:
		
		var particles = particles_scene.instantiate()
		if particles is ParticleSystem2D:
			particles.InitAsOneShot(global_position, 0, 4.0)
			particles.EmitParticlesWithVelocity(particles_num, in_impulse * 0.5)
		elif particles is ParticleSystem2D_CPU:
			particles.InitAsOneShot(global_position, particles_num, 4.0)
	return true
