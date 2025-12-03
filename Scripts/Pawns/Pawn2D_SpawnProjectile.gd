extends Node2D
class_name Pawn2D_SpawnProjectile

@export_category("Owner")
@export var owner_body: Node2D
@export var owner_sprite: Pawn2D_Sprite
@export var owner_bt_player: BTPlayer
@export var owner_target_blackboard_var: StringName = &"chase_target"

@export_category("Projectile")
@export var projectile_data: ProjectileData2D
@export var projectile_level: int = 0

func _ready() -> void:
	
	assert(owner_body)
	assert(owner_sprite)
	assert(owner_bt_player)

func get_target_position() -> Vector2:
	
	var target = owner_bt_player.blackboard.get_var(owner_target_blackboard_var)
	if not is_instance_valid(target):
		return Vector2.INF
	
	if target is Node2D:
		target = target.global_position
	return target

func spawn_projectile() -> Projectile2D:
	
	var target_position := get_target_position()
	if target_position == Vector2.INF:
		return null
	
	if owner_sprite.current_look_direction == AnimationData2D.Direction.Left:
		position.x = absf(position.x)
	else:
		position.x = -absf(position.x)
	
	var spawn_position := global_position
	var spawn_rotation := spawn_position.angle_to_point(target_position)
	var new_projectile := Projectile2D.spawn(Transform2D(spawn_rotation, spawn_position), projectile_data, projectile_level, owner_body)
	return new_projectile
