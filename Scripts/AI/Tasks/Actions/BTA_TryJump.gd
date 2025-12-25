@tool
extends BTAction

@export var jump_variant: PawnJumpVariantData2D
@export var check_relevant_target: bool = true
@export var check_navigation_position: bool = true

var owner_jump: Pawn2D_Jump
var was_ended: bool = false
var was_failed: bool = false

func _enter() -> void:
	
	owner_jump = Pawn2D_Jump.try_get_from(agent)
	
	owner_jump.jump_end.connect(_on_jump_end)
	owner_jump.jump_fail.connect(_on_jump_fail)
	
	was_ended = false
	was_failed = false

func _exit() -> void:
	
	owner_jump.jump_end.disconnect(_on_jump_end)
	owner_jump.jump_fail.disconnect(_on_jump_fail)
	
	owner_jump = null
	
	was_ended = false
	was_failed = false

func _tick(in_delta: float) -> Status:
	
	if was_ended:
		return Status.SUCCESS
	elif was_failed:
		return Status.FAILURE
	
	if owner_jump.current_variant:
		if owner_jump.current_variant == jump_variant:
			return Status.RUNNING
		else:
			return Status.FAILURE
	
	var success := owner_jump.try_jump(jump_variant, check_relevant_target, check_navigation_position)
	
	if success:
		return Status.RUNNING
	else:
		return Status.FAILURE

func _on_jump_end() -> void:
	was_ended = true

func _on_jump_fail() -> void:
	was_failed = true
