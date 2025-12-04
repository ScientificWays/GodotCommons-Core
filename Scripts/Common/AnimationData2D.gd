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

func GetNewDirectionForLookAtTarget(in_sprite: Pawn2D_Sprite) -> Direction:
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
@export var IdleAnimationDefault: StringName = &"Idle"

@export var IdleAnimationDirectionDictionary: Dictionary = {
	Direction.None: &"Idle",
	Direction.Right: &"Idle",
	Direction.Left: &"Idle",
	Direction.Up: &"Idle_Up",
	Direction.Down: &"Idle_Down"
}

func GetIdleAnimationName(in_sprite: Pawn2D_Sprite) -> StringName:
	return IdleAnimationDirectionDictionary.get(in_sprite.current_move_direction, IdleAnimationDefault)

@export_category("Move")
@export var MoveAnimationDefault: StringName = &"Move"

@export var MoveAnimationDirectionDictionary: Dictionary = {
	Direction.None: &"Move",
	Direction.Right: &"Move",
	Direction.Left: &"Move",
	Direction.Up: &"Move_Up",
	Direction.Down: &"Move_Down"
}

func GetMoveAnimationName(in_sprite: Pawn2D_Sprite) -> StringName:
	return MoveAnimationDirectionDictionary.get(in_sprite.current_move_direction, MoveAnimationDefault)

@export_category("IdleToMove")
@export var UseIdleToMoveTransition: bool = false
@export var IdleToMoveAnimationDefault: StringName = &"IdleToMove"

@export var IdleToMoveAnimationDirectionDictionary: Dictionary = {
	Direction.None: &"IdleToMove",
	Direction.Right: &"IdleToMove",
	Direction.Left: &"IdleToMove",
	Direction.Up: &"IdleToMove_Up",
	Direction.Down: &"IdleToMove_Down"
}

func GetIdleToMoveAnimationName(in_sprite: Pawn2D_Sprite) -> StringName:
	return IdleToMoveAnimationDirectionDictionary.get(in_sprite.current_move_direction, IdleToMoveAnimationDefault)

@export_category("MoveToIdle")
@export var UseMoveToIdleTransition: bool = false
@export var MoveToIdleAnimationDefault: StringName = &"MoveToIdle"

@export var MoveToIdleAnimationDirectionDictionary: Dictionary = {
	Direction.None: &"MoveToIdle",
	Direction.Right: &"MoveToIdle",
	Direction.Left: &"MoveToIdle",
	Direction.Up: &"MoveToIdle_Up",
	Direction.Down: &"MoveToIdle_Down"
}

func GetMoveToIdleAnimationName(in_sprite: Pawn2D_Sprite) -> StringName:
	return MoveToIdleAnimationDirectionDictionary.get(in_sprite.current_move_direction, MoveToIdleAnimationDefault)

@export_category("Death")

const DeathAnimationPostfixMeta: StringName = &"DeathAnimationPostfix"

@export var UseDeathAnimation: bool = true
@export var DeathAnimationDefault: StringName = &"Death"

@export var DeathAnimationDirectionDictionary: Dictionary = {
	Direction.None: &"Death",
	Direction.Right: &"Death",
	Direction.Left: &"Death",
	Direction.Up: &"Death_Up",
	Direction.Down: &"Death_Down"
}

func GetDeathAnimationName(in_sprite: Pawn2D_Sprite) -> StringName:
	
	if in_sprite.has_meta(DeathAnimationPostfixMeta):
		return DeathAnimationDirectionDictionary.get(in_sprite.current_move_direction, DeathAnimationDefault) + in_sprite.get_meta(DeathAnimationPostfixMeta)
	else:
		return DeathAnimationDirectionDictionary.get(in_sprite.current_move_direction, DeathAnimationDefault)
