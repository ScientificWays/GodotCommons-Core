@tool
extends VHSFX

@export var label_text: String = "Press any key to restart":
	set(InText):
		label_text = InText
		Update()

@export var target_texture: TextureRect 
@export var sub_viewport: SubViewport

func GetPositionTarget() -> Control:
	return target_texture

func Update() -> void:
	
	super()
	
	var label_target := target as Label
	label_target.text = label_text
	
	sub_viewport.size = label_target.size * (1.0 + scale_offset)
