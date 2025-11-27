@tool
extends BTAction

@export var target_var: StringName = &"chase_target"

var owner_sprite: Pawn2D_Sprite

func _enter() -> void:
	owner_sprite = Pawn2D_Sprite.try_get_from(agent)

func _exit() -> void:
	if is_instance_valid(owner_sprite):
		owner_sprite.LookAtTarget = null
		owner_sprite = null

func _tick(in_delta: float) -> Status:
	
	if not is_instance_valid(owner_sprite):
		return Status.FAILURE
	
	var look_at_target = blackboard.get_var(target_var)
	if is_instance_valid(look_at_target) and look_at_target is Node2D:
		owner_sprite.LookAtTarget = look_at_target
		return Status.RUNNING
	else:
		return Status.FAILURE
