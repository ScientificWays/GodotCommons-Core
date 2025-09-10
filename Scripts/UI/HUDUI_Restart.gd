extends Control
class_name HUDUI_Restart

@export_category("Owner")
@export var OwnerPlayerController: PlayerController

func _ready() -> void:
	
	assert(OwnerPlayerController)
	
	OwnerPlayerController.ControlledPawnChanged.connect(OnOwnerControlledPawnChanged)
	OnOwnerControlledPawnChanged()

func _input(InEvent: InputEvent) -> void:
	
	if InEvent.is_pressed():
		OwnerPlayerController.Restart()

func OnOwnerControlledPawnChanged():
	
	if is_instance_valid(OwnerPlayerController.ControlledPawn):
		HideRestart()
	else:
		ShowRestart()

func ShowRestart():
	visible = true
	set_process_input(true)

func HideRestart():
	visible = false
	set_process_input(false)
