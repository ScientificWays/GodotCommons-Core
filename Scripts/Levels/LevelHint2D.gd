@tool
extends Marker2D
class_name LevelHint2D

@export var label: Label

@export_multiline var label_text: String = "Hint":
	set(in_text):
		label_text = in_text
		_update_hint()

@export var label_settings: LabelSettings:
	set(in_settings):
		
		if Engine.is_editor_hint():
			if label_settings and label_settings.changed.is_connected(_update_hint):
				label_settings.changed.disconnect(_update_hint)
		
		label_settings = in_settings
		
		if Engine.is_editor_hint():
			if label_settings:
				label_settings.changed.connect(_update_hint)
		
		_update_hint()

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not label:
			label = find_child("*abel") as Label
	else:
		pass
	
	_update_hint()
	
	label.resized.connect(_on_label_resized)
	_on_label_resized()

func _update_hint() -> void:
	
	if not is_node_ready():
		return
	
	label.text = label_text
	label.label_settings = label_settings
	label.visible = Engine.is_editor_hint()
	
	label.rotation = -global_rotation

func _on_label_resized() -> void:
	label.pivot_offset = label.size * 0.5
