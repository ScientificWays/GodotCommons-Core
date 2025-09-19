extends CanvasLayer
class_name TransitionUI

@export_category("Score")
@export var score_ui: ScoreUI

@export_category("Continue")
@export var ContinueLabel: VHSLabel

signal ContinueRequested()

func _ready() -> void:
	set_process_input(false)
	ContinueLabel.SetInstantLerpVisible(false)

func _input(InEvent: InputEvent) -> void:
	
	if not InEvent.is_echo():
		
		if GameGlobals.IsPC():
			if InEvent.is_action_pressed(&"Continue"):
				pass
			else:
				return
		elif InEvent is InputEventScreenTouch:
			pass
		else:
			return
		
		ContinueLabel.lerp_visible = false
		set_process_input(false)
		
		ContinueRequested.emit()

func HandleAnimatedSequence() -> void:
	
	assert(is_node_ready())
	
	await score_ui.HandleAnimatedSequence()
	
	ContinueLabel.lerp_visible = true
	set_process_input(true)
