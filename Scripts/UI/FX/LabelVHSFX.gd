@tool
extends VHSFX
class_name VHSLabel

@export var label_text: String = "-":
	set(InText):
		label_text = InText
		Update.call_deferred()

@export var label_text_mobile: String:
	set(InText):
		label_text_mobile = InText
		Update.call_deferred()

@export var label_settings: LabelSettings:
	set(InSettings):
		
		if Engine.is_editor_hint():
			if label_settings and label_settings.changed.is_connected(Update):
				label_settings.changed.disconnect(Update)
		
		label_settings = InSettings
		
		if Engine.is_editor_hint():
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

@export var label_autowrap_mode: TextServer.AutowrapMode = TextServer.AutowrapMode.AUTOWRAP_OFF:
	set(in_mode):
		label_autowrap_mode = in_mode
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

func _ready() -> void:
	Update()

func _notification(in_what: int) -> void:
	
	if is_node_ready():
		if in_what == NOTIFICATION_RESIZED \
		or in_what == NOTIFICATION_VISIBILITY_CHANGED \
		or in_what == NOTIFICATION_TRANSLATION_CHANGED \
		or in_what == NOTIFICATION_RESIZED:
			Update()

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		if label_settings and label_settings.changed.is_connected(Update):
			label_settings.changed.disconnect(Update)

func GetPositionTarget() -> Control:
	return target_texture

var _doing_update: bool = false

func Update() -> void:
	
	if not is_node_ready() or not is_inside_tree():
		return
	
	if not Engine.is_editor_hint():
		while _doing_update:
			await get_tree().process_frame
			if not is_inside_tree():
				return
	
	var use_mobile_text := (not label_text_mobile.is_empty()) and PlatformGlobals_Class.is_mobile()
	
	var label_target := target as Label
	if not label_target:
		return
	
	_doing_update = true
	
	label_target.text = label_text_mobile if use_mobile_text else label_text
	
	label_target.label_settings = label_settings
	label_target.horizontal_alignment = label_horizontal_alignment
	label_target.vertical_alignment = label_vertical_alignment
	label_target.autowrap_mode = label_autowrap_mode
	
	if not Engine.is_editor_hint():
		await get_tree().process_frame ## Wait for label_target update
		if not is_inside_tree():
			return
	
	var new_size := label_target.size * (1.1 + scale_offset)
	sub_viewport.size = new_size
	custom_minimum_size = label_target.size
	pivot_offset = custom_minimum_size * 0.5
	
	target_texture.set_deferred("size", new_size)
	target_texture.pivot_offset = new_size * 0.5
	
	if get_parent() is Container:
		target_texture.set_anchors_and_offsets_preset.call_deferred(forced_anchors_preset, Control.PRESET_MODE_KEEP_SIZE)
	else:
		target_texture.set_anchors_and_offsets_preset.call_deferred(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
		
		if use_forced_anchors_preset:
			set_anchors_and_offsets_preset(forced_anchors_preset, Control.PRESET_MODE_KEEP_SIZE)
	
	if label_target.autowrap_mode != TextServer.AutowrapMode.AUTOWRAP_OFF:
		label_target.size = size
	label_target.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	
	super()
	
	_doing_update = false
