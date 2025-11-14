extends Node

@export var _FlatColorMaterial: Material = preload("res://addons/GodotCommons-Core/Assets/UI/Common/FlatColorMaterial.tres")

@export var OutlineButtonDataManifest: Array[OutlineButtonData] = [
	preload("res://addons/GodotCommons-Core/Assets/UI/Buttons/Styles/Button001a.tres"),
	preload("res://addons/GodotCommons-Core/Assets/UI/Buttons/Styles/Button001b.tres"),
	preload("res://addons/GodotCommons-Core/Assets/UI/Buttons/Styles/Button001c.tres"),
	preload("res://addons/GodotCommons-Core/Assets/UI/Buttons/Styles/Button002a.tres"),
	preload("res://addons/GodotCommons-Core/Assets/UI/Buttons/Styles/Button002b.tres"),
	preload("res://addons/GodotCommons-Core/Assets/UI/Buttons/Styles/Button002c.tres")
]

@export var mouse_cursor_arrow: Resource = preload("res://addons/GodotCommons-Core/Assets/UI/Cursors/Arrow001a.png")
@export var mouse_cursor_cross: Resource = preload("res://addons/GodotCommons-Core/Assets/UI/Cursors/Crosshair001a.png")

#var _MainMenu: MainMenu:
#	set(InMainMenu):
#		assert(is_instance_valid(InMainMenu) != is_instance_valid(_MainMenu))
#		_MainMenu = InMainMenu

## Settings can reside both in MainMenu and PauseMenu (in game)
#var _SettingsUI: SettingsUI:
#	set(InSettingsUI):
#		assert(is_instance_valid(InSettingsUI) != is_instance_valid(_SettingsUI))
#		_SettingsUI = InSettingsUI

func _ready() -> void:
	
	init_custom_cursors()
	
	try_create_pause_menu_ui.call_deferred()
	try_create_confirm_ui.call_deferred()
	
	GameGlobals.post_damage_receiver_receive_damage.connect(_handle_post_damage_receiver_receive_damage)

func _process(in_delta: float) -> void:
	_process_pending_damage_numbers(in_delta)

func _notification(in_code: int) -> void:
	match in_code:
		Node.NOTIFICATION_WM_GO_BACK_REQUEST:
			Input.parse_input_event(load("res://addons/GodotCommons-Core/Assets/UI/Shortcuts/BackAction.tres"))

##
## Cursors
##
func init_custom_cursors() -> void:
	
	Input.set_custom_mouse_cursor(mouse_cursor_arrow, Input.CURSOR_ARROW, Vector2(0.0, 0.0))
	Input.set_custom_mouse_cursor(mouse_cursor_cross, Input.CURSOR_CROSS, Vector2(16.0, 16.0))
	Input.set_custom_mouse_cursor(mouse_cursor_cross, Input.CURSOR_POINTING_HAND, Vector2(16.0, 16.0))

##
## PauseMenuUI
##
var pause_menu_ui: PauseMenuUI
signal pause_menu_ui_created()

func try_create_pause_menu_ui() -> bool:
	
	var pause_menu_scene_path := ProjectSettings.get_setting(GodotCommonsCore_Settings.PAUSE_MENU_UI_SETTING_NAME, GodotCommonsCore_Settings.PAUSE_MENU_UI_SETTING_DEFAULT) as String
	if ResourceLoader.exists(pause_menu_scene_path, "PackedScene"):
		var pause_menu_ui_scene := ResourceLoader.load(pause_menu_scene_path) as PackedScene
		pause_menu_ui = pause_menu_ui_scene.instantiate()
		pause_menu_ui.is_enabled = false
		add_child(pause_menu_ui)
		pause_menu_ui_created.emit()
		return is_instance_valid(pause_menu_ui)
	assert(false, "UIGlobals.try_create_pause_menu_ui(): Failed to create PauseMenuUI!")
	return false

##
## ConfirmUI
##
var confirm_ui: ConfirmUI
signal confirm_ui_created()

func try_create_confirm_ui() -> bool:
	
	var confirm_scene_path := ProjectSettings.get_setting(GodotCommonsCore_Settings.CONFIRM_UI_SETTING_NAME, GodotCommonsCore_Settings.CONFIRM_UI_SETTING_DEFAULT) as String
	if ResourceLoader.exists(confirm_scene_path, "PackedScene"):
		var confirm_ui_scene := ResourceLoader.load(confirm_scene_path) as PackedScene
		confirm_ui = confirm_ui_scene.instantiate()
		confirm_ui.is_enabled = false
		add_child(confirm_ui)
		confirm_ui_created.emit()
		return is_instance_valid(confirm_ui)
	push_error("UIGlobals.try_create_confirm_ui(): Failed to create PauseMenuUI!")
	return false

func IsPointInsideControlArea(InPoint: Vector2, InControl: Control) -> bool:
	var x: bool = InPoint.x >= InControl.global_position.x and InPoint.x <= InControl.global_position.x + (InControl.size.x * InControl.get_global_transform_with_canvas().get_scale().x)
	var y: bool = InPoint.y >= InControl.global_position.y and InPoint.y <= InControl.global_position.y + (InControl.size.y * InControl.get_global_transform_with_canvas().get_scale().y)
	return x and y

func is_left_mouse_button_press_event(in_event: InputEvent) -> bool:
	return (in_event is InputEventMouseButton) and in_event.is_pressed() and (in_event.button_index == MouseButton.MOUSE_BUTTON_LEFT)

signal BombStockPreferenceChanged()

var BombStockPreference: int = 1:
	set(in_value):
		if in_value != BombStockPreference:
			BombStockPreference = in_value
			BombStockPreferenceChanged.emit()

signal ShowHardcoreStatsChanged()

var ShowHardcoreStats: bool = false:
	set(in_value):
		if in_value != ShowHardcoreStats:
			ShowHardcoreStats = in_value
			ShowHardcoreStatsChanged.emit()

func SetOutlineButtonColor(InColor: Color):
	
	var NormalColor := Color.from_hsv(InColor.h, 0.6, 0.15, 0.75)
	var HoverColor := NormalColor.lightened(0.25)
	var FocusColor := InColor
	
	for SampleData: OutlineButtonData in OutlineButtonDataManifest:
		
		SampleData.Normal.modulate_color = NormalColor
		SampleData.Hover.modulate_color = HoverColor
		
		for SampleFocusStyleBox: StyleBox in SampleData.FocusVariants:
			SampleFocusStyleBox.modulate_color = FocusColor

func format_time_seconds(in_time_seconds: int) -> String:
	
	var seconds := in_time_seconds % 60
	var minutes := (in_time_seconds / 60) % 60
	var hours := in_time_seconds / (60 * 60)
	
	if hours > 0:
		return "%02d:%02d:%02d" % [ hours, minutes, seconds ]
	else:
		return "%02d:%02d" % [ minutes, seconds ]

func format_time_milliseconds(in_time_seconds: float) -> String:
	return "%s:%s" % [ format_time_seconds(floori(in_time_seconds)), String.num(fmod(in_time_seconds, 1.0), 3).pad_decimals(3) ]

##
## BackgroundUI
##
var BackgroundTextureOverride: Texture2D:
	set(InTexture):
		BackgroundTextureOverride = InTexture
		BackgroundTextureOverrideChanged.emit()

signal BackgroundTextureOverrideChanged()

##
## DamageNumberUI
##
var damage_number_ui_scene_path: String = "res://addons/GodotCommons-Core/Scenes/UI/World/DefaultDamageNumber.tscn"
var damage_number_ui: DamageNumberUI
signal damage_number_ui_created()

var pending_damage_numbers_damage: Dictionary[int, float]
var pending_damage_numbers_positions: Dictionary[int, Vector2]

func _process_pending_damage_numbers(in_delta: float) -> void:
	
	if pending_damage_numbers_damage.is_empty():
		return
	
	for sample_instance_id: int in pending_damage_numbers_damage.keys():
		try_create_damage_number_ui(pending_damage_numbers_damage[sample_instance_id], pending_damage_numbers_positions[sample_instance_id])
	pending_damage_numbers_damage.clear()

func _handle_post_damage_receiver_receive_damage(in_damage_receiver: DamageReceiver, in_source: Node, in_damage: float, in_ignored_immunity_time: bool) -> void:
	
	if in_damage_receiver.show_damage_numbers:
		var instance_id := in_damage_receiver.get_instance_id()
		pending_damage_numbers_damage[instance_id] = pending_damage_numbers_damage.get(instance_id, 0.0) + in_damage
		pending_damage_numbers_positions[instance_id] = in_damage_receiver.owner_body_2d.global_position

func try_create_damage_number_ui(in_damage: float, in_position: Vector2) -> void:
	
	assert(not damage_number_ui_scene_path.is_empty())
	
	var damage_number_ui_scene := ResourceLoader.load(damage_number_ui_scene_path)
	var new_damage_number_ui := damage_number_ui_scene.instantiate() as DamageNumberUI
	new_damage_number_ui.position = in_position
	new_damage_number_ui.damage = in_damage
	
	WorldGlobals._level.add_child(new_damage_number_ui)

##
## DialogueUI
##
signal request_dialogue_sequence(in_sequence: DialogueSequence)
signal request_cancel_dialogue()
