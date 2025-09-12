@tool
extends VHSFX

@export var label_text: String = "Press any key to restart":
	set(InText):
		label_text = InText
		Update()

@export var label_settings: LabelSettings:
	set(InSettings):
		label_settings = InSettings
		Update()

@export var label_horizontal_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER:
	set(InAlignment):
		label_horizontal_alignment = InAlignment
		Update()

@export var label_vertical_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER:
	set(InAlignment):
		label_vertical_alignment = InAlignment
		Update()

@export var target_texture: TextureRect 
@export var sub_viewport: SubViewport

func GetPositionTarget() -> Control:
	return target_texture

func Update() -> void:
	
	super()
	
	var label_target := target as Label
	label_target.text = label_text
	
	label_target.label_settings = label_settings
	label_target.horizontal_alignment = label_horizontal_alignment
	label_target.vertical_alignment = label_vertical_alignment
	
	sub_viewport.size = label_target.size * (1.0 + scale_offset)
