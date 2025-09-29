@tool
extends Control
class_name StartGameEntryUI

@export_category("Elements")
@export var completed_label: VHSLabel
@export var foldable_container: FoldableContainer
@export var start_button: Button

@export_category("Data")
@export var data: CampaignData:
	set(in_data):
		data = in_data
		if is_node_ready():
			_update()
@export var extra_game_mode_args: Dictionary:
	set(in_args):
		extra_game_mode_args = in_args
		if is_node_ready():
			_update()

func _ready() -> void:
	
	assert(data)
	
	_update()
	
	if Engine.is_editor_hint():
		return
	

func _update() -> void:
	
	if extra_game_mode_args.has(CampaignData.challenge_time_arg):
		foldable_container.title = "%s (%s)" % [ tr(data.display_title), tr(CampaignData.challenge_time_desc) ]
	else:
		foldable_container.title = data.display_title
	
	if data.can_start:
		
		start_button.modulate.a = 1.0
		
		if not Engine.is_editor_hint():
			start_button.pressed.connect(_on_start_button_pressed)
	else:
		start_button.modulate.a = 0.5
	
	if Engine.is_editor_hint():
		return
	
	if extra_game_mode_args.is_empty():
		var completions := await data.get_saved_completions()
		completed_label.lerp_visible = completions > 0
	else:
		completed_label.lerp_visible = false

func _on_start_button_pressed() -> void:
	UIGlobals.confirm_ui.toggle(data.confirm_title, _handle_confirm_start)

func _handle_confirm_start() -> void:
	data.start_game(randi(), extra_game_mode_args)
