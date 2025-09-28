@tool
extends CanvasLayer
class_name ConfirmUI

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
		
		if is_enabled != in_is_enabled or not is_node_ready():
			
			is_enabled = in_is_enabled
			
			if is_enabled:
				_handle_enabled()
			else:
				_handle_disabled()

@export_category("Prompt")
@export var prompt_label: VHSLabel

@export_category("Options")
@export var confirm_option: Button
@export var cancel_option: Button

var confirm_callable: Callable = _dummy_callable
var cancel_callable: Callable = _dummy_callable

func _ready() -> void:
	
	visibility_changed.connect(on_visibility_changed)
	
	if Engine.is_editor_hint():
		return
	
	skip_lerp_visible()
	
	assert(confirm_option)
	assert(cancel_option)
	
	confirm_option.pressed.connect(_resolve_callable.bind(true))
	cancel_option.pressed.connect(_resolve_callable.bind(false))

func _process(in_delta: float) -> void:
	
	if lerp_visible:
		visibility_control.modulate.a = minf(visibility_control.modulate.a + lerp_visible_speed * in_delta, 1.0)
	else:
		visibility_control.modulate.a = maxf(visibility_control.modulate.a - lerp_visible_speed * in_delta, 0.0)
	
	if visibility_control.modulate.a > 0.0:
		pass
	else:
		visible = false

func _handle_enabled() -> void:
	
	lerp_visible = true
	
	if not Engine.is_editor_hint():
		GameGlobals.AddPauseSource(self)

func _handle_disabled() -> void:
	
	lerp_visible = false
	
	if not Engine.is_editor_hint():
		GameGlobals.RemovePauseSource(self)

func toggle(in_prompt_text: String, in_confirm_callable: Callable, in_cancel_callable: Callable = _dummy_callable) -> void:
	
	if is_enabled:
		_resolve_callable(false)
	else:
		prompt_label.label_text = in_prompt_text
		
		confirm_callable = in_confirm_callable
		cancel_callable = in_cancel_callable
		
		is_enabled = true

func skip_lerp_visible() -> void:
	
	if lerp_visible:
		visibility_control.modulate.a = 1.0
	else:
		visibility_control.modulate.a = 0.0

func on_visibility_changed() -> void:
	set_process(visible)

func _resolve_callable(in_confirmed: bool) -> void:
	
	if in_confirmed:
		confirm_callable.call()
	else:
		cancel_callable.call()
	
	confirm_callable = _dummy_callable
	cancel_callable = _dummy_callable
	
	is_enabled = false

func _dummy_callable() -> void:
	#push_warning("%s _dummy_callable() was called!" % self)
	pass
