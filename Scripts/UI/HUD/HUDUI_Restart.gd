extends Control
class_name HUDUI_Restart

@export_category("Owner")
@export var OwnerHUD: HUDUI

@export_category("Label")
@export var TextLabel: VHSFX

func _ready() -> void:
	
	assert(OwnerHUD)
	
	TextLabel.SetInstantLerpVisible(false)
	
	OwnerHUD.OwnerPlayerController.ControlledPawnChanged.connect(OnOwnerControlledPawnChanged)
	OnOwnerControlledPawnChanged()

var RestartEnableTicksMs: int = 0
var ScreenTouchWasPressed: bool = false

func _input(InEvent: InputEvent) -> void:
	
	if Time.get_ticks_msec() > RestartEnableTicksMs and not InEvent.is_echo():
		
		if PlatformGlobals_Class.IsPC():
			if InEvent.is_action_pressed(&"Restart"):
				pass
			else:
				return
		elif InEvent is InputEventScreenTouch:
			if InEvent.is_released() and ScreenTouchWasPressed:
				pass
			else:
				ScreenTouchWasPressed = InEvent.is_pressed()
				return
		else:
			return
		
		OwnerHUD.OwnerPlayerController.Restart()

func OnOwnerControlledPawnChanged():
	
	if is_instance_valid(OwnerHUD.OwnerPlayerController.ControlledPawn):
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
