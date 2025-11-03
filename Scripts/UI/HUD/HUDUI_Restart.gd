@tool
extends Control
class_name HUDUI_Restart

@export_category("Owner")
@export var owner_hud: HUDUI

@export_category("Label")
@export var TextLabel: VHSFX

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not owner_hud:
			owner_hud = find_parent("*HUD*")
	else:
		assert(owner_hud)
		
		TextLabel.SetInstantLerpVisible(false)
		
		owner_hud.owner_player_controller.controlled_pawn_changed.connect(_on_owner_controlled_pawn_changed)
		_on_owner_controlled_pawn_changed()

var RestartEnableTicksMs: int = 0
var ScreenTouchWasPressed: bool = false

func _input(in_event: InputEvent) -> void:
	
	if Time.get_ticks_msec() > RestartEnableTicksMs and not in_event.is_echo():
		
		if PlatformGlobals_Class.IsPC():
			if in_event.is_action_pressed(&"Restart"):
				pass
			else:
				return
		elif in_event is InputEventScreenTouch:
			if in_event.is_released() and ScreenTouchWasPressed:
				pass
			else:
				ScreenTouchWasPressed = in_event.is_pressed()
				return
		else:
			return
		
		owner_hud.owner_player_controller.Restart()

func _on_owner_controlled_pawn_changed():
	
	if is_instance_valid(owner_hud.owner_player_controller.ControlledPawn):
		HideRestart()
	else:
		ShowRestart()

func ShowRestart():
	
	TextLabel.lerp_visible_speed = 4.0
	TextLabel.lerp_visible = true
	
	set_process_input(true)
	
	RestartEnableTicksMs = Time.get_ticks_msec() + 500
	ScreenTouchWasPressed = false

func HideRestart():
	TextLabel.lerp_visible_speed = 8.0
	TextLabel.lerp_visible = false
	
	set_process_input(false)
