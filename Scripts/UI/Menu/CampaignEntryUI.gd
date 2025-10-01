@tool
extends Control
class_name StartGameEntryUI

@export_category("Elements")
@export var completed_label: VHSLabel
@export var foldable_container: FoldableContainer
@export var leaderboard_button: Button
@export var leaderboard_ui: LeaderboardUI
@export var start_button: Button
@export var continue_button: Button

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
	
	await _update()
	
	if Engine.is_editor_hint():
		return
	
	if Bridge.leaderboards.type == Bridge.LeaderboardType.IN_GAME:
		leaderboard_button.toggled.connect(_on_leaderboard_button_toggled)
		_on_leaderboard_button_toggled(leaderboard_button.button_pressed)
	else:
		leaderboard_button.queue_free()
	
	start_button.pressed.connect(_on_start_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)

func _update() -> void:
	
	if extra_game_mode_args.has(CampaignData.challenge_time_arg):
		foldable_container.title = "%s (%s)" % [ tr(data.display_title), tr(CampaignData.challenge_time_desc) ]
	else:
		foldable_container.title = data.display_title
	
	if data.can_start:
		start_button.visible = true
	else:
		start_button.visible = false
	
	if Engine.is_editor_hint():
		return
	
	await data.load_storage_data()
	
	if data.completions > 0:
		completed_label.lerp_visible = true
		completed_label.label_text = tr("COMPLETIONS") % data.completions
	else:
		completed_label.lerp_visible = false
	
	#print(data.unique_identifier, " last_level_index ", data.last_level_index)
	if data.last_level_index > 0:
		continue_button.lerp_visible = true
		continue_button.label_text = tr("CONTINUE_FROM") % (data.last_level_index + 1)
	else:
		continue_button.lerp_visible = false

func _on_leaderboard_button_toggled(in_toggled_on: bool) -> void:
	leaderboard_ui.visible = in_toggled_on
	leaderboard_ui.update_for_campaign_data(data)

func _on_start_button_pressed() -> void:
	UIGlobals.confirm_ui.toggle(data.start_confirm_title, _handle_confirm_start)

func _handle_confirm_start() -> void:
	data.start_game(randi(), extra_game_mode_args)

func _on_continue_button_pressed() -> void:
	UIGlobals.confirm_ui.toggle(data.continue_confirm_title, _handle_confirm_continue)

func _handle_confirm_continue() -> void:
	#print(data.unique_identifier, " _handle_confirm_continue() last_level_index ", data.last_level_index)
	await data.continue_game(randi(), extra_game_mode_args)
