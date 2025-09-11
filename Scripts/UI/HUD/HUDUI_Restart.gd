extends Control
class_name HUDUI_Restart

@export_category("Owner")
@export var OwnerHUD: HUDUI

func _ready() -> void:
	
	assert(OwnerHUD)
	
	OwnerHUD.OwnerPlayerController.ControlledPawnChanged.connect(OnOwnerControlledPawnChanged)
	OnOwnerControlledPawnChanged()

var RestartEnableTicksMs: int = 0

func _input(InEvent: InputEvent) -> void:
	
	if Time.get_ticks_msec() > RestartEnableTicksMs:
		if InEvent.is_pressed() and not InEvent.is_echo():
			OwnerHUD.OwnerPlayerController.Restart()

func OnOwnerControlledPawnChanged():
	
	if is_instance_valid(OwnerHUD.OwnerPlayerController.ControlledPawn):
		HideRestart()
	else:
		ShowRestart()

func ShowRestart():
	
	visible = true
	set_process_input(true)
	
	RestartEnableTicksMs = Time.get_ticks_msec() + 500

func HideRestart():
	visible = false
	set_process_input(false)
