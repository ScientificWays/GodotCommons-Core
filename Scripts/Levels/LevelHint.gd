@tool
extends Marker2D

@export var hint_label: Label
@export_multiline var hint_label_text: String = "Player\nSpawn":
	set(in_text):
		hint_label_text = in_text
		if is_node_ready():
			hint_label.text = hint_label_text

func _ready() -> void:
	hint_label.text = hint_label_text
	hint_label.visible = Engine.is_editor_hint()
