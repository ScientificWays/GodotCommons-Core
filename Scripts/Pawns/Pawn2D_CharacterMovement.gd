@tool
extends Node
class_name Pawn2D_CharacterMovement

static func try_get_from(in_node: Node) -> Pawn2D_CharacterMovement:
	return ModularGlobals.try_get_from(in_node, Pawn2D_CharacterMovement)

@export_category("Owner")
@export var owner_pawn: Pawn2D
@export var owner_body: CharacterBody2D
@export var owner_attribute_set: AttributeSet

@export_category("Physics")
@export var apply_gravity: bool = true
@export var mass: float = 1.0
@export var should_bounce: bool = false
@export var launch_velocity_reset_threshold: float = 10.0

var cached_gravity_velocity: Vector2

@export_category("Velocity")
@export var move_speed: float = 32.0
@export var launch_velocity_damp: float = 4.0

@export_category("Rotation")
@export var rotate_body_to_movement_x: bool = true
@export var rotate_body_to_movement_x_threshold: float = 2.0

@export_category("Input")
@export var input_vector_mul: Vector2 = Vector2.ONE
@export var input_threshold: float = 0.3

signal landed()

func _ready() -> void:
	
	if Engine.is_editor_hint():
		
		set_physics_process(false)
		
		if not owner_pawn:
			owner_pawn = get_parent() as Pawn2D
		if not owner_body:
			owner_body = get_parent() as CharacterBody2D
		if owner_pawn:
			if not owner_attribute_set:
				owner_attribute_set = owner_pawn.find_child("*ttribute*et*") as AttributeSet
	else:
		
		if apply_gravity == (owner_body.motion_mode == CharacterBody2D.MotionMode.MOTION_MODE_FLOATING):
			push_warning("Applying gravity to floating body! (%s)" % owner_body)
		
		if apply_gravity:
			cached_gravity_velocity = ProjectSettings.get_setting("physics/2d/default_gravity_vector") * ProjectSettings.get_setting("physics/2d/default_gravity")
		
		mass *= owner_pawn.get_size_scale()

func _enter_tree():
	if not Engine.is_editor_hint():
		ModularGlobals.init_modular_node(self)

func _exit_tree():
	if not Engine.is_editor_hint():
		ModularGlobals.deinit_modular_node(self)

var pending_launch_velocity: Vector2 = Vector2.ZERO

var movement_velocity: Vector2 = Vector2.ZERO:
	set(in_velocity):
		
		assert(in_velocity.is_finite())
		movement_velocity = in_velocity
		
		if rotate_body_to_movement_x and absf(movement_velocity.x) >= rotate_body_to_movement_x_threshold:
			owner_pawn.body_direction = movement_velocity.normalized()

func set_movement_velocity(in_velocity: Vector2, in_scale_by_movement_speed_mul: bool) -> void:
	
	if in_scale_by_movement_speed_mul and owner_attribute_set:
		movement_velocity = in_velocity * owner_attribute_set.get_attribute_current_value(AttributeSet.MoveSpeedMul)
	else:
		movement_velocity = in_velocity

var pending_force: Vector2 = Vector2.ZERO

func apply_force(in_force: Vector2) -> void:
	pending_force += in_force

var pending_input: Vector2 = Vector2.ZERO

func apply_movement_input(in_input: Vector2) -> void:
	pending_input = in_input

signal bounce(in_bounce_collision: KinematicCollision2D)

func launch(in_velocity: Vector2, in_scale_by_movement_speed_mul: bool = false) -> bool:
	
	if in_scale_by_movement_speed_mul:
		var movement_speed_mul := owner_attribute_set.get_attribute_current_value(AttributeSet.MoveSpeedMul)
		in_velocity *= movement_speed_mul
	assert(in_velocity.is_finite())
	pending_launch_velocity += in_velocity
	return true

func launch_forward(in_magnitude: float, in_scale_by_movement_speed_mul: bool = false) -> bool:
	var velocity := owner_pawn.body_direction * in_magnitude
	return launch(velocity, in_scale_by_movement_speed_mul)

var prev_velocity: Vector2 = Vector2.ZERO

func _physics_process(in_delta: float):
	
	prev_velocity = owner_body.get_real_velocity()
	
	var final_input := pending_input * input_vector_mul
	pending_input = Vector2.ZERO
	
	if final_input.length_squared() < (input_threshold * input_threshold):
		movement_velocity = Vector2.ZERO
	else:
		movement_velocity = move_speed * final_input.normalized()
	
	var external_velocity := pending_force
	pending_force = Vector2.ZERO
	
	if apply_gravity and not owner_body.is_on_floor():
		if prev_velocity.y > 0.0:
			external_velocity += cached_gravity_velocity * mass * 1.5
		else:
			external_velocity += cached_gravity_velocity * mass
	
	assert(pending_launch_velocity.is_finite())
	if pending_launch_velocity.is_zero_approx():
		pass
	else:
		external_velocity += pending_launch_velocity / mass
		pending_launch_velocity = pending_launch_velocity.lerp(Vector2.ZERO, in_delta * launch_velocity_damp)
		
		if pending_launch_velocity.length_squared() < (launch_velocity_reset_threshold * launch_velocity_reset_threshold):
			pending_launch_velocity = Vector2.ZERO
	
	var was_on_floor = owner_body.is_on_floor()
	owner_body.velocity = movement_velocity + external_velocity
	
	if should_bounce:
		var collision_info := owner_body.move_and_collide(owner_body.velocity * in_delta)
		if collision_info:
			pending_launch_velocity = pending_launch_velocity.bounce(collision_info.get_normal())
			bounce.emit(collision_info)
	else:
		owner_body.move_and_slide()
	
	if not was_on_floor and owner_body.is_on_floor():
		landed.emit()
