@tool
extends Control
class_name PositionLerpControl

@export_category("Lerp")
@export var PendingPositionLerpSpeed: float = 32.0
@export var pending_position: Vector2
@export var ForceNormalPositionInEditor: bool = true

#func _ready() -> void:
#	pending_position = position

func _process(InDelta: float) -> void:
	
	if Engine.is_editor_hint() and ForceNormalPositionInEditor:
		pending_position = position
	else:
		if not HasReachedPendingPosition():
			position = position.lerp(pending_position, PendingPositionLerpSpeed * InDelta)
			if HasReachedPendingPosition():
				position = pending_position

func HasReachedPendingPosition() -> bool:
	return absf(pending_position.x - position.x) < 0.01

func ForcePendingPosition() -> void:
	position = pending_position
