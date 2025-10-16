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
	MAX = 5
}

enum Direction
{
	None = -1,
	Right = 0,
	Left = 1,
	Up = 2,
	Down = 3
}

func Init(InSprite: Pawn2D_Sprite):
	InSprite.ShouldUpdateVelocityBasedAnimations = CanUpdateVelocityBasedAnimations

@export var CanUpdateVelocityBasedAnimations: bool = true

@export_category("Directions")
@export var UseHorizontalDirections: bool = true
@export var UseHorizontalDirectionFlip: bool = true
@export var UseVerticalDirections: bool = false
@export var DirectionUpdateAbsThreshold: float = 2.0
@export var DirectionUpdateAxisDifferenceThreshold: float = 8.0

func GetNewDirectionForVelocity(InSprite: Pawn2D_Sprite) -> Direction:
	return UtilGetNewDirectionForVector(InSprite.linear_velocity, InSprite._Direction)

func GetNewDirectionForLookAtTarget(InSprite: Pawn2D_Sprite) -> Direction:
	var TargetVector := InSprite.LookAtTarget.global_position - InSprite.global_position
	return UtilGetNewDirectionForVector(TargetVector, InSprite._Direction)

func UtilGetNewDirectionForVector(InVector: Vector2, InDefault: Direction) -> Direction:
	
	var AbsVector := InVector.abs()
	var NewDirection := InDefault
	
	if UseHorizontalDirections:
		
		if AbsVector.x > DirectionUpdateAbsThreshold:
			if UseVerticalDirections and AbsVector.x - AbsVector.y < DirectionUpdateAxisDifferenceThreshold:
				pass
			else:
				NewDirection = Direction.Right if InVector.x > 0.0 else Direction.Left
	
	if UseVerticalDirections:
		
		if AbsVector.y > DirectionUpdateAbsThreshold:
			if UseHorizontalDirections and AbsVector.y - AbsVector.x < DirectionUpdateAxisDifferenceThreshold:
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

func GetIdleAnimationName(InSprite: Pawn2D_Sprite) -> StringName:
	return IdleAnimationDirectionDictionary.get(InSprite._Direction, IdleAnimationDefault)

@export_category("Move")
@export var MoveAnimationDefault: StringName = &"Move"

@export var MoveAnimationDirectionDictionary: Dictionary = {
	Direction.None: &"Move",
	Direction.Right: &"Move",
	Direction.Left: &"Move",
	Direction.Up: &"Move_Up",
	Direction.Down: &"Move_Down"
}

func GetMoveAnimationName(InSprite: Pawn2D_Sprite) -> StringName:
	return MoveAnimationDirectionDictionary.get(InSprite._Direction, MoveAnimationDefault)

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

func GetIdleToMoveAnimationName(InSprite: Pawn2D_Sprite) -> StringName:
	return IdleToMoveAnimationDirectionDictionary.get(InSprite._Direction, IdleToMoveAnimationDefault)

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

func GetMoveToIdleAnimationName(InSprite: Pawn2D_Sprite) -> StringName:
	return MoveToIdleAnimationDirectionDictionary.get(InSprite._Direction, MoveToIdleAnimationDefault)

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

func GetDeathAnimationName(InSprite: Pawn2D_Sprite) -> StringName:
	
	if InSprite.has_meta(DeathAnimationPostfixMeta):
		return DeathAnimationDirectionDictionary.get(InSprite._Direction, DeathAnimationDefault) + InSprite.get_meta(DeathAnimationPostfixMeta)
	else:
		return DeathAnimationDirectionDictionary.get(InSprite._Direction, DeathAnimationDefault)
