extends Marker2D
class_name Projectile2D_Split

const is_owner_from_split_meta: StringName = &"jectile2D_Split_is_owner_from_split"

@export_category("Owner")
@export var owner_projectile: Projectile2D

@export_category("Spawn")
@export var split_num_base: int = 3
@export var split_num_per_level_gain: float = 1.0
@export_range(0.0, 1.0, 0.01) var split_spread: float = 0.0
@export var split_spawn_offset: float = 8.0

@export_category("Projectile")
@export var override_split_projectile_data: ProjectileData2D
@export var split_power_mul: float = 0.6
@export_flags_2d_physics var split_collision_layer: int = 0

func get_split_num() -> float:
	return split_num_base + roundi(split_num_per_level_gain * owner_projectile._level)

func _ready() -> void:
	
	assert(owner_projectile)
	
	if owner_projectile.get_meta(is_owner_from_split_meta, false):
		init_owner_as_split()
	else:
		owner_projectile.pre_removed_from_scene.connect(_on_owner_pre_removed_from_scene)

func _on_owner_pre_removed_from_scene(in_reason: Projectile2D.RemoveReason) -> void:
	
	match in_reason:
		Projectile2D.RemoveReason.Hit:
			handle_split()
		Projectile2D.RemoveReason.Lifetime:
			handle_split()
		Projectile2D.RemoveReason.Damage:
			handle_split()

func handle_split() -> void:
	
	var spawn_origin := owner_projectile.global_position
	var split_num := get_split_num()
	
	assert(not owner_projectile.get_meta(is_owner_from_split_meta, false), "handle_split() owner_projectile is from split!")
	
	var projectile_data := override_split_projectile_data if override_split_projectile_data else owner_projectile.data
	var spawn_rotation_offset := randf() * TAU
	
	for sample_index: int in range(split_num):
		
		var spawn_rotation := spawn_rotation_offset + float(sample_index) / float(split_num) * TAU
		if split_spread > 0.0:
			spawn_rotation += randf_range(-PI, PI) * split_spread
		
		var spawn_offset := Vector2.from_angle(spawn_rotation) * split_spawn_offset
		var spawn_transform := Transform2D(spawn_rotation, spawn_origin + spawn_offset)
		
		var new_projectile := Projectile2D.spawn(spawn_transform, projectile_data, owner_projectile._level, owner_projectile._instigator) as Projectile2D
		assert(not new_projectile.is_node_ready())
		
		new_projectile.set_meta(is_owner_from_split_meta, true)
		new_projectile.set_meta(Projectile2D_Collision.monitor_hits_start_delay_meta, 0.4)
		new_projectile.set_meta(Projectile2D_Collision.receive_explosions_delay_meta, 0.4)
		
		new_projectile._power *= split_power_mul
		new_projectile.collision_layer = split_collision_layer

func init_owner_as_split() -> void:
	pass
