extends CanvasLayer
class_name TransitionUI

@export_category("Score")
@export var score_ui: ScoreUI
@export var leaderboard_ui: LeaderboardUI

@export_category("Continue")
@export var ContinueLabel: VHSLabel

signal ContinueRequested()

func _ready() -> void:
	set_process_input(false)
	ContinueLabel.SetInstantLerpVisible(false)

func _input(in_event: InputEvent) -> void:
	
	if not in_event.is_echo():
		
		if PlatformGlobals_Class.is_pc():
			if in_event.is_action_pressed(&"Continue"):
				pass
			else:
				return
		elif in_event is InputEventScreenTouch:
			pass
		else:
			return
		
		ContinueLabel.lerp_visible = false
		set_process_input(false)
		
		ContinueRequested.emit()

func handle_animated_sequence() -> void:
	
	assert(is_node_ready())
	
	if is_instance_valid(score_ui):
		await score_ui.handle_animated_sequence()
	
	if is_instance_valid(leaderboard_ui):
		await leaderboard_ui.handle_animated_sequence()
	
	ContinueLabel.lerp_visible = true
	set_process_input(true)
