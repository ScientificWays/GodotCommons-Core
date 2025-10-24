@tool
extends Marker2D

@export var label: Label

@export_multiline var label_text: String = "Player\nSpawn":
	set(in_text):
		label_text = in_text
		_update()

@export var label_settings: LabelSettings:
	set(in_settings):
		
		if Engine.is_editor_hint():
			if label_settings and label_settings.changed.is_connected(_update):
				label_settings.changed.disconnect(_update)
		
		label_settings = in_settings
		
		if Engine.is_editor_hint():
			if label_settings:
				label_settings.changed.connect(_update)
		
		_update()

func _ready() -> void:
	_update()

func _update() -> void:
	
	if not is_node_ready():
		return
	
	label.text = label_text
	label.label_settings = label_settings
	label.visible = Engine.is_editor_hint()
