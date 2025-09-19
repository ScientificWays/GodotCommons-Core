@tool
extends VHSFX
class_name VHSLabel

@export var label_text: String = "START_PROMPT":
	set(InText):
		label_text = InText
		Update()

@export var label_text_mobile: String:
	set(InText):
		label_text_mobile = InText
		Update()

@export var label_settings: LabelSettings:
	set(InSettings):
		
		if label_settings and label_settings.changed.is_connected(Update):
			label_settings.changed.disconnect(Update)
		
		label_settings = InSettings
		
		if label_settings:
			label_settings.changed.connect(Update)
		
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
@export var use_forced_anchors_preset: bool = false:
	set(InUse):
		use_forced_anchors_preset = InUse
		Update()

@export var forced_anchors_preset: LayoutPreset = Control.PRESET_CENTER:
	set(InPreset):
		forced_anchors_preset = InPreset
		Update()

func _exit_tree() -> void:
	if label_settings and label_settings.changed.is_connected(Update):
		label_settings.changed.disconnect(Update)

func GetPositionTarget() -> Control:
	return target_texture

func Update() -> void:
	
	var use_mobile_text := (not label_text_mobile.is_empty()) and GameGlobals_Class.IsMobile()
	
	var label_target := target as Label
	if not label_target:
		return
	
	label_target.text = label_text_mobile if use_mobile_text else label_text
	
	label_target.label_settings = label_settings
	label_target.horizontal_alignment = label_horizontal_alignment
	label_target.vertical_alignment = label_vertical_alignment
	
	sub_viewport.size = label_target.size * (1.1 + scale_offset)
	custom_minimum_size = label_target.size
	pivot_offset = custom_minimum_size * 0.5
	
	if get_parent() is Container:
		pass
	else:
		size = custom_minimum_size
		if use_forced_anchors_preset:
			set_anchors_and_offsets_preset(forced_anchors_preset, Control.PRESET_MODE_MINSIZE)
	label_target.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	
	if target_texture:
		target_texture.size = sub_viewport.size
		target_texture.pivot_offset = target_texture.size * 0.5
	
	super()
