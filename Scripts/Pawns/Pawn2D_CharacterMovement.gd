extends Node
class_name Pawn2D_CharacterMovement

@export_category("Owner")
@export var owner_body: CharacterBody2D
@export var owner_sprite: Pawn2D_Sprite
@export var owner_attribute_set: AttributeSet

@export_category("Physics")
@export var mass: float = 1.0
@export var should_bounce: bool = false
@export var launch_velocity_reset_threshold: float = 10.0

var pending_launch_velocity: Vector2 = Vector2.ZERO
var pending_launch_velocity_damp: float = 4.0

var movement_velocity: Vector2 = Vector2.ZERO:
	set(in_velocity):
		assert(in_velocity.is_finite())
		movement_velocity = in_velocity

func set_movement_velocity(in_velocity: Vector2, in_scale_by_movement_speed_mul: bool):
	
	if in_scale_by_movement_speed_mul:
		movement_velocity = in_velocity * owner_attribute_set.get_attribute_current_value(AttributeSet.MoveSpeedMul)
	else:
		movement_velocity = in_velocity

signal bounce(in_bounce_collision: KinematicCollision2D)

func launch(in_velocity: Vector2, in_scale_by_movement_speed_mul: bool = false) -> bool:
	
	if in_scale_by_movement_speed_mul:
		var movement_speed_mul := owner_attribute_set.get_attribute_current_value(AttributeSet.MoveSpeedMul)
		in_velocity *= movement_speed_mul
	assert(in_velocity.is_finite())
	pending_launch_velocity += in_velocity
	return true

var prev_velocity: Vector2 = Vector2.ZERO

func _physics_process(InDelta: float):
	
	prev_velocity = owner_body.get_real_velocity()
	var external_velocity := Vector2.ZERO
	
	assert(pending_launch_velocity.is_finite())
	if pending_launch_velocity.is_zero_approx():
		pass
	else:
		external_velocity += pending_launch_velocity / mass
		pending_launch_velocity = pending_launch_velocity.lerp(Vector2.ZERO, InDelta * pending_launch_velocity_damp)
		
		if pending_launch_velocity.length_squared() < (launch_velocity_reset_threshold * launch_velocity_reset_threshold):
			pending_launch_velocity = Vector2.ZERO
	
	owner_body.velocity = movement_velocity + external_velocity
	
	if should_bounce:
		var collision_info := owner_body.move_and_collide(owner_body.velocity * InDelta)
		if collision_info:
			pending_launch_velocity = pending_launch_velocity.bounce(collision_info.get_normal())
			bounce.emit(collision_info)
		owner_sprite.linear_velocity = owner_body.velocity
	else:
		owner_body.move_and_slide()
		owner_sprite.linear_velocity = owner_body.get_real_velocity()
