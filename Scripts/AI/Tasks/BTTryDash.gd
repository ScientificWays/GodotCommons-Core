@tool
extends BTAction

@export var dash_variant: PawnDashVariantData
@export var check_relevant_target: bool = true
@export var check_navigation_position: bool = true

var owner_dash: Pawn2D_Dash
var was_ended: bool = false
var was_failed: bool = false

func _enter() -> void:
	
	owner_dash = Pawn2D_Dash.try_get_from(agent)
	
	owner_dash.dash_end.connect(_on_dash_end)
	owner_dash.dash_fail.connect(_on_dash_fail)
	
	was_ended = false
	was_failed = false

func _exit() -> void:
	
	owner_dash.dash_end.disconnect(_on_dash_end)
	owner_dash.dash_fail.disconnect(_on_dash_fail)
	
	owner_dash = null
	
	was_ended = false
	was_failed = false

func _tick(in_delta: float) -> Status:
	
	if was_ended:
		return Status.SUCCESS
	elif was_failed:
		return Status.FAILURE
	
	if owner_dash.current_variant:
		if owner_dash.current_variant == dash_variant:
			return Status.RUNNING
		else:
			return Status.FAILURE
	
	var success := owner_dash.try_dash(dash_variant, check_relevant_target, check_navigation_position)
	
	if success:
		return Status.RUNNING
	else:
		return Status.FAILURE

func _on_dash_end() -> void:
	was_ended = true

func _on_dash_fail() -> void:
	was_failed = true
