extends Node
class_name Pawn2D_Dash

static func try_get_from(in_node: Node) -> Pawn2D_Dash:
	return ModularGlobals.try_get_from(in_node, Pawn2D_Dash)

@export_category("Owner")
@export var owner_movement: Pawn2D_CharacterMovement
@export var owner_contact_damage: DamageArea2D
@export var owner_sprite: Pawn2D_Sprite
@export var owner_perception: Pawn2D_Perception
@export var owner_navigation: Pawn2D_Navigation

func calc_impulse() -> float:
	
	var out_impulse := current_variant.impulse
	if current_variant.ignore_mass:
		out_impulse *= owner_movement.mass
	return out_impulse

var current_variant: PawnDashVariantData2D

signal dash_begin()
signal dash_end()
signal dash_fail()

func _ready() -> void:
	assert(owner_movement)
	#assert(owner_contact_damage)
	assert(owner_sprite)
	assert(owner_perception)
	assert(owner_navigation)

func _enter_tree() -> void:
	ModularGlobals.init_modular_node(self)

func _exit_tree() -> void:
	ModularGlobals.deinit_modular_node(self)

func get_dash_target_position(in_check_relevant_target: bool, in_check_navigation_position: bool) -> Vector2:
	
	if in_check_relevant_target:
		var relevant_target := owner_perception.get_relevant_sight_target()
		if is_instance_valid(relevant_target):
			return relevant_target.global_position
	
	if in_check_navigation_position:
		return owner_navigation.get_next_path_position()
	return Vector2.INF

func try_dash(in_dash_variant: PawnDashVariantData2D, in_check_relevant_target: bool, in_check_navigation_position: bool) -> bool:
	
	assert(in_dash_variant)
	
	if current_variant:
		dash_fail.emit()
		return false
	
	var target_position := get_dash_target_position(in_check_relevant_target, in_check_navigation_position)
	if target_position.is_equal_approx(Vector2.INF):
		dash_fail.emit()
		return false
	
	_begin_dash(in_dash_variant, target_position)
	return true

var pre_dash_damage_initial_delay: float = 0.0
var pre_dash_launch_velocity_damp: float = 0.0

func _begin_dash(in_dash_variant: PawnDashVariantData2D, in_target_position: Vector2) -> void:
	
	current_variant = in_dash_variant
	
	var target_vector := in_target_position - owner_movement.owner_body.global_position
	var dash_impulse := target_vector.normalized() * calc_impulse()
	
	owner_sprite.play_override_animation(current_variant.animation_name, 1.0, false, current_variant.should_reset_animation_on_finish)
	
	if current_variant.launch_delay > 0.0:
		await GameGlobals.spawn_await_timer(self, current_variant.launch_delay).timeout
	
	pre_dash_launch_velocity_damp = owner_movement.launch_velocity_damp
	owner_movement.launch_velocity_damp = current_variant.launch_velocity_damp
	
	owner_movement.launch(dash_impulse, true)
	
	if is_instance_valid(owner_contact_damage):
		if current_variant.instant_contact_damage:
			pre_dash_damage_initial_delay = owner_contact_damage.damage_initial_delay
			owner_contact_damage.damage_initial_delay = 0.0
	
	dash_begin.emit()
	GameGlobals.spawn_one_shot_timer_for(self, _end_dash, current_variant.duration)

func _end_dash() -> void:
	
	if is_instance_valid(owner_contact_damage):
		if current_variant.instant_contact_damage:
			owner_contact_damage.damage_initial_delay = pre_dash_damage_initial_delay
			pre_dash_damage_initial_delay = 0.0
	
	owner_movement.launch_velocity_damp = pre_dash_launch_velocity_damp
	pre_dash_launch_velocity_damp = 0.0
	
	current_variant = null
	dash_end.emit()
