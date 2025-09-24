@tool
extends CanvasLayer
class_name PauseMenuUI

@export_category("Visiblity")
@export var visibility_control: Control

@export var lerp_visible: bool = true:
	set(in_visible):
		
		lerp_visible = in_visible
		
		if lerp_visible:
			visible = true

@export var lerp_visible_speed: float = 4.0

@export var is_enabled: bool = false:
	set(in_is_enabled):
		
		is_enabled = in_is_enabled
		
		if is_enabled:
			_handle_enabled()
		else:
			_handle_disabled()

@export_category("Options")
@export var continue_option: Button
@export var quit_option: Button

@export_category("Sliders")
@export var game_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var default_camera_zoom_slider: HSlider

func _ready() -> void:
	
	visibility_changed.connect(on_visibility_changed)
	
	if Engine.is_editor_hint():
		return
	
	assert(continue_option)
	assert(quit_option)
	
	continue_option.pressed.connect(on_continue_option_pressed)
	
	if GameGlobals_Class.IsWeb():
		quit_option.queue_free()
	else:
		quit_option.pressed.connect(on_quit_option_pressed)
	
	assert(game_volume_slider)
	assert(music_volume_slider)
	
	game_volume_slider.value_changed.connect(on_game_volume_slider_value_changed)
	music_volume_slider.value_changed.connect(on_music_volume_slider_value_changed)
	default_camera_zoom_slider.value_changed.connect(on_default_camera_zoom_slider_value_changed)
	
	AudioGlobals.game_volume_linear_changed.connect(on_game_volume_linear_changed)
	AudioGlobals.music_volume_linear_changed.connect(on_music_volume_linear_changed)
	PlayerGlobals.default_camera_zoom_changed.connect(on_default_camera_zoom_changed)
	
	on_game_volume_linear_changed()
	on_music_volume_linear_changed()
	on_default_camera_zoom_changed()

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

func on_visibility_changed() -> void:
	set_process(visible)

func on_continue_option_pressed() -> void:
	is_enabled = false

func on_quit_option_pressed() -> void:
	SaveGlobals.save_local_data(true)
	get_tree().quit()

func on_game_volume_slider_value_changed(in_value: float) -> void:
	AudioGlobals.game_volume_linear = in_value

func on_music_volume_slider_value_changed(in_value: float) -> void:
	AudioGlobals.music_volume_linear = in_value

func on_default_camera_zoom_slider_value_changed(in_value: float) -> void:
	PlayerGlobals.default_camera_zoom = in_value

func on_game_volume_linear_changed() -> void:
	game_volume_slider.set_value_no_signal(AudioGlobals.game_volume_linear)

func on_music_volume_linear_changed() -> void:
	music_volume_slider.set_value_no_signal(AudioGlobals.music_volume_linear)

func on_default_camera_zoom_changed() -> void:
	default_camera_zoom_slider.set_value_no_signal(PlayerGlobals.default_camera_zoom)
