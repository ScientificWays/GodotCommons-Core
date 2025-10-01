@tool
extends CanvasLayer
class_name PauseMenuUI

@export_category("Visiblity")
@export var visibility_control: Control

@export var lerp_visible: bool = false:
	set(in_visible):
		
		lerp_visible = in_visible
		
		if lerp_visible:
			visible = true

@export var lerp_visible_speed: float = 4.0

@export var is_enabled: bool = false:
	set(in_is_enabled):
		
		if not can_be_enabled and in_is_enabled:
			return
		
		if is_enabled != in_is_enabled or not is_node_ready():
			
			is_enabled = in_is_enabled
			
			if is_enabled:
				_handle_enabled()
			else:
				_handle_disabled()

@export_category("Options")
@export var continue_option: Button
@export var main_menu_option: Button

var can_be_enabled: bool = false:
	set(in_can):
		
		can_be_enabled = in_can
		
		if not can_be_enabled:
			is_enabled = false

func _ready() -> void:
	
	visibility_changed.connect(_on_visibility_changed)
	
	if Engine.is_editor_hint():
		return
	
	skip_lerp_visible()
	
	assert(continue_option)
	assert(main_menu_option)
	
	continue_option.pressed.connect(_on_continue_option_pressed)
	
	#if GameGlobals_Class.IsWeb():
	#	main_menu_option.queue_free()
	#else:
	main_menu_option.pressed.connect(_on_main_menu_option_pressed)

func _process(in_delta: float) -> void:
	
	if lerp_visible:
		visibility_control.modulate.a = minf(visibility_control.modulate.a + lerp_visible_speed * in_delta, 1.0)
	else:
		visibility_control.modulate.a = maxf(visibility_control.modulate.a - lerp_visible_speed * in_delta, 0.0)
	
	if visibility_control.modulate.a > 0.0:
		pass
	else:
		visible = false

func _notification(in_what: int) -> void:
	
	if in_what == NOTIFICATION_WM_GO_BACK_REQUEST:
		toggle()

func _unhandled_input(in_event: InputEvent) -> void:
	
	if in_event.is_action_pressed(&"Back"):
		if not is_enabled:
			toggle()
			get_viewport().set_input_as_handled()

func _handle_enabled() -> void:
	
	lerp_visible = true
	
	if not Engine.is_editor_hint():
		GameGlobals.AddPauseSource(self)

func _handle_disabled() -> void:
	
	lerp_visible = false
	
	if not Engine.is_editor_hint():
		GameGlobals.RemovePauseSource(self)

func toggle() -> void:
	is_enabled = not is_enabled

func skip_lerp_visible() -> void:
	
	if lerp_visible:
		visibility_control.modulate.a = 1.0
	else:
		visibility_control.modulate.a = 0.0

func _on_visibility_changed() -> void:
	set_process(visible)

func _on_continue_option_pressed() -> void:
	is_enabled = false

func _on_main_menu_option_pressed() -> void:
	UIGlobals.confirm_ui.toggle("QUIT_PROMPT", _handle_confirm_main_menu)

func _handle_confirm_main_menu() -> void:
	
	var main_menu_level_path := ProjectSettings.get_setting(GodotCommonsCore_Settings.MAIN_MENU_LEVEL_SETTING_NAME, GodotCommonsCore_Settings.MAIN_MENU_LEVEL_SETTING_DEFAULT) as String
	WorldGlobals.load_scene_by_path(main_menu_level_path)
