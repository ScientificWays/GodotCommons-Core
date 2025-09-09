@tool
extends Marker2D

@export var HintLabel: Label

func _ready() -> void:
	HintLabel.visible = Engine.is_editor_hint()
