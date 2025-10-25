extends Node
class_name Pawn2D_Jump

static func try_get_from(in_node: Node) -> Pawn2D_Jump:
	return ModularGlobals.try_get_from(in_node, Pawn2D_Jump)

@export_category("Owner")
@export var owner_pawn: Pawn2D
@export var owner_movement: Pawn2D_CharacterMovement
@export var owner_sprite: Pawn2D_Sprite
@export var owner_status_effect_receiver: StatusEffectReceiver
@export var owner_perception: Pawn2D_Perception
@export var owner_navigation: Pawn2D_Navigation

func calc_impulse() -> float:
	
	var out_impulse := current_variant.impulse
	if current_variant.ignore_mass:
		out_impulse *= owner_movement.mass
	return out_impulse

var current_variant: PawnJumpVariantData2D
var current_target_position: Vector2

signal jump_begin()
signal jump_end()
signal jump_fail()

func _ready() -> void:
	assert(owner_pawn)
	assert(owner_movement)
	assert(owner_sprite)
	assert(owner_perception)
	assert(owner_navigation)

func _enter_tree() -> void:
	ModularGlobals.init_modular_node(self)

func _exit_tree() -> void:
	ModularGlobals.deinit_modular_node(self)

func get_jump_target_position(in_check_relevant_target: bool, in_check_navigation_position: bool) -> Vector2:
	
	if in_check_relevant_target:
		var relevant_target := owner_perception.get_relevant_sight_target()
		if is_instance_valid(relevant_target):
			return relevant_target.global_position
	
	if in_check_navigation_position:
		return owner_navigation.get_next_path_position()
	return Vector2.INF

func try_jump(in_jump_variant: PawnJumpVariantData2D, in_check_relevant_target: bool, in_check_navigation_position: bool) -> bool:
	
	assert(in_jump_variant)
	
	if current_variant:
		jump_fail.emit()
		return false
	
	var target_position := get_jump_target_position(in_check_relevant_target, in_check_navigation_position)
	if target_position.is_equal_approx(Vector2.INF):
		jump_fail.emit()
		return false
	
	_begin_jump(in_jump_variant, target_position)
	return true

func _begin_jump(in_jump_variant: PawnJumpVariantData2D, in_target_position: Vector2) -> void:
	
	current_variant = in_jump_variant
	current_target_position = in_target_position
	
	if not owner_sprite.frame_changed.is_connected(_on_owner_sprite_frame_changed):
		owner_sprite.frame_changed.connect(_on_owner_sprite_frame_changed)
	
	owner_sprite.play_override_animation(current_variant.animation_name, 1.0, false, current_variant.should_reset_animation_on_finish)
	
	if not owner_sprite.animation_changed.is_connected(_on_owner_sprite_animation_changed):
		owner_sprite.animation_changed.connect(_on_owner_sprite_animation_changed, Object.CONNECT_ONE_SHOT)

func _on_owner_sprite_frame_changed() -> void:
	
	if owner_sprite.animation == current_variant.animation_name:
		
		if owner_sprite.frame == current_variant.start_frame:
			_start_jump()
		if owner_sprite.frame == current_variant.end_frame:
			_end_jump()

func _on_owner_sprite_animation_changed() -> void:
	if owner_sprite.frame_changed.is_connected(_on_owner_sprite_frame_changed):
		owner_sprite.frame_changed.disconnect(_on_owner_sprite_frame_changed)

var pre_launch_damage_initial_delay: float = 0.0
var pre_launch_velocity_damp: float = 0.0
var pre_launch_collision_layer: int = 0
var pre_launch_collision_mask: int = 0

func _start_jump() -> void:
	
	owner_navigation.increment_disable_movement()
	
	pre_launch_velocity_damp = owner_movement.launch_velocity_damp
	owner_movement.launch_velocity_damp = current_variant.launch_velocity_damp
	
	pre_launch_collision_layer = owner_pawn.collision_layer
	owner_pawn.collision_layer = current_variant.launch_collision_layer
	
	pre_launch_collision_mask = owner_pawn.collision_mask
	owner_pawn.collision_mask = current_variant.launch_collision_mask
	
	owner_pawn.z_index += current_variant.z_index_additive
	
	var target_vector := current_target_position - owner_pawn.global_position
	var jump_impulse := target_vector.normalized() * calc_impulse()
	
	owner_movement.launch(jump_impulse, true)
	
	jump_begin.emit()

func _end_jump() -> void:
	
	if owner_sprite.frame_changed.is_connected(_on_owner_sprite_frame_changed):
		owner_sprite.frame_changed.disconnect(_on_owner_sprite_frame_changed)
	
	owner_navigation.decrement_disable_movement()
	
	owner_movement.launch_velocity_damp = pre_launch_velocity_damp
	pre_launch_velocity_damp = 0.0
	
	owner_pawn.collision_layer = pre_launch_collision_layer
	pre_launch_collision_layer = 0
	
	owner_pawn.collision_mask = pre_launch_collision_mask
	pre_launch_collision_mask = 0
	
	owner_pawn.z_index -= current_variant.z_index_additive
	
	if current_variant.land_explosion_data:
		var land_explosion := Explosion2D.spawn(owner_pawn.global_position, current_variant.land_explosion_data, owner_pawn._level, current_variant.get_land_explosion_radius(owner_pawn._level), current_variant.get_land_explosion_damage(owner_pawn._level), current_variant.get_land_explosion_impulse(owner_pawn._level), owner_pawn)
		land_explosion.should_ignore_instigator = true
	
	if current_variant.land_owner_status_effect:
		owner_status_effect_receiver.try_apply_status_effect(current_variant.land_owner_status_effect, owner_pawn, owner_pawn, owner_pawn._level, current_variant.land_owner_status_effect_duration)
	
	current_variant = null
	current_target_position = Vector2.INF
	
	jump_end.emit()
