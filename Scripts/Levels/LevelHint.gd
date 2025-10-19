@tool
extends Marker2D

@export var hint_label: Label
@export_multiline var hint_label_text: String = "Player\nSpawn"

func _ready() -> void:
	hint_label.visible = Engine.is_editor_hint()
