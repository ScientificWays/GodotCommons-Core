extends Resource
class_name AnimationData2D

enum Type
{
	Idle = 0,
	IdleToMove = 1,
	Move = 2,
	MoveToIdle = 3,
	Death = 4,
	Override = 5,
	MAX = 5,
}

enum Direction
{
	None = -1,
	Right = 0,
	Left = 1,
	Up = 2,
	Down = 3,
}

var direction_to_vector: Dictionary[Direction, Vector2] = {
	Direction.None: Vector2.ZERO,
	Direction.Right: Vector2.RIGHT,
	Direction.Left: Vector2.LEFT,
	Direction.Up: Vector2.UP,
	Direction.Down: Vector2.DOWN,
}

enum LookDirection
{
	Forward = 0,
	Up = 2,
	Down = 3,
}

enum DirectionUpdateSource
{
	MovementInput = 0,
	LinearVelocity = 1
}

@export_category("Directions")
@export var direction_update_source: DirectionUpdateSource = DirectionUpdateSource.MovementInput
@export var use_horizontal_directions: bool = true
@export var use_horizontal_direction_flip: bool = true
@export var use_vertical_directions: bool = false
@export var direction_update_abs_threshold: float = 0.1
@export var direction_update_axis_difference_threshold: float = 0.1

func calc_move_direction(in_sprite: Pawn2D_Sprite) -> Direction:
	
	match direction_update_source:
		DirectionUpdateSource.MovementInput:
			return UtilGetNewDirectionForVector(in_sprite.owner_pawn.last_movement_input, in_sprite.current_move_direction)
		DirectionUpdateSource.LinearVelocity:
			return UtilGetNewDirectionForVector(in_sprite.linear_velocity, in_sprite.current_move_direction)
	assert(false)
	return Direction.None

func calc_look_direction_vector(in_sprite: Pawn2D_Sprite) -> Vector2:
	
	match in_sprite.current_look_direction:
		LookDirection.Forward:
			return direction_to_vector[in_sprite.current_move_direction]
		LookDirection.Up:
			return Vector2.UP
		LookDirection.Down:
			return Vector2.DOWN
	assert(false)
	return Vector2.ZERO

func get_new_direction_for_look_at_target(in_sprite: Pawn2D_Sprite) -> Direction:
	var TargetVector := in_sprite.look_at_target.global_position - in_sprite.global_position
	return UtilGetNewDirectionForVector(TargetVector, in_sprite.current_move_direction)

func UtilGetNewDirectionForVector(InVector: Vector2, InDefault: Direction) -> Direction:
	
	var AbsVector := InVector.abs()
	var NewDirection := InDefault
	
	if use_horizontal_directions:
		
		if AbsVector.x > direction_update_abs_threshold:
			if use_vertical_directions and ((AbsVector.x - AbsVector.y) < direction_update_axis_difference_threshold):
				pass
			else:
				NewDirection = Direction.Right if InVector.x > 0.0 else Direction.Left
	
	if use_vertical_directions:
		
		if AbsVector.y > direction_update_abs_threshold:
			if use_horizontal_directions and ((AbsVector.y - AbsVector.x) < direction_update_axis_difference_threshold):
				pass
			else:
				NewDirection = Direction.Down if InVector.y > 0.0 else Direction.Up
	return NewDirection

@export_category("Idle")
@export var idle_animation_default: StringName = &"idle"
@export var idle_look_up_animation: StringName = &""

@export var idle_animation_direction_dictionary: Dictionary = {
	Direction.None: &"idle",
	Direction.Right: &"idle",
	Direction.Left: &"idle",
	Direction.Up: &"idle_up",
	Direction.Down: &"idle_down"
}

func get_idle_animation_name(in_sprite: Pawn2D_Sprite) -> StringName:
	
	if in_sprite.current_look_direction == LookDirection.Up and not idle_look_up_animation.is_empty():
		return idle_look_up_animation
	
	return idle_animation_direction_dictionary.get(in_sprite.current_move_direction, idle_animation_default)

@export_category("Move")
@export var move_animation_default: StringName = &"move"

@export var move_animation_direction_dictionary: Dictionary = {
	Direction.None: &"move",
	Direction.Right: &"move",
	Direction.Left: &"move",
	Direction.Up: &"move_up",
	Direction.Down: &"move_down"
}

func get_move_animation_name(in_sprite: Pawn2D_Sprite) -> StringName:
	return move_animation_direction_dictionary.get(in_sprite.current_move_direction, move_animation_default)

@export_category("IdleToMove")
@export var use_idle_to_move_transition: bool = false
@export var idle_to_Move_animation_default: StringName = &"idle_to_move"

@export var idle_to_move_animation_direction_dictionary: Dictionary = {
	Direction.None: &"idle_to_move",
	Direction.Right: &"idle_to_move",
	Direction.Left: &"idle_to_move",
	Direction.Up: &"idle_to_move_up",
	Direction.Down: &"idle_to_move_down"
}

func get_idle_to_move_animation_name(in_sprite: Pawn2D_Sprite) -> StringName:
	return idle_to_move_animation_direction_dictionary.get(in_sprite.current_move_direction, idle_to_Move_animation_default)

@export_category("MoveToIdle")
@export var use_move_to_idle_transition: bool = false
@export var move_to_idle_animation_default: StringName = &"move_to_idle"

@export var move_to_idle_animation_direction_dictionary: Dictionary = {
	Direction.None: &"move_to_idle",
	Direction.Right: &"move_to_idle",
	Direction.Left: &"move_to_idle",
	Direction.Up: &"move_to_idle_up",
	Direction.Down: &"move_to_idle_down"
}

func get_move_to_idle_animation_name(in_sprite: Pawn2D_Sprite) -> StringName:
	return move_to_idle_animation_direction_dictionary.get(in_sprite.current_move_direction, move_to_idle_animation_default)

@export_category("Death")

const death_animation_postfix_meta: StringName = &"AnimationData2D_death_animation_postfix"

@export var use_death_animation: bool = true
@export var death_animation_default: StringName = &"death"

@export var death_animation_direction_dictionary: Dictionary = {
	Direction.None: &"death",
	Direction.Right: &"death",
	Direction.Left: &"death",
	Direction.Up: &"death_up",
	Direction.Down: &"death_down"
}

func get_death_animation_name(in_sprite: Pawn2D_Sprite) -> StringName:
	
	if in_sprite.has_meta(death_animation_postfix_meta):
		return death_animation_direction_dictionary.get(in_sprite.current_move_direction, death_animation_default) + in_sprite.get_meta(death_animation_postfix_meta)
	else:
		return death_animation_direction_dictionary.get(in_sprite.current_move_direction, death_animation_default)
