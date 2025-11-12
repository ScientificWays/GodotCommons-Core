extends Control
class_name LeaderboardUI

@export_category("List")
@export var entries_container: Container
@export var entry_scene_path: String = "res://Scenes/UI/Menu/LeaderboardUI_Entry.tscn"
@export var tabs: TabContainer

var entry_scene: PackedScene
var last_campaign_data: CampaignData

func _ready():
	
	assert(entries_container)
	
	assert(tabs)
	
	tabs.current_tab = 1
	tabs.visible = false
	
	if PlatformGlobals.is_in_game_leaderboards_type():
		
		entry_scene = load(entry_scene_path)
		assert(entry_scene)
		
		_on_set_score_finished(true)
	else:
		queue_free()

func _enter_tree() -> void:
	if PlatformGlobals.is_in_game_leaderboards_type():
		PlatformGlobals.leaderboard_set_score_finished.connect(_on_set_score_finished)

func _exit_tree() -> void:
	if PlatformGlobals.is_in_game_leaderboards_type():
		PlatformGlobals.leaderboard_set_score_finished.disconnect(_on_set_score_finished)

func handle_animated_sequence() -> void:
	
	#await GameGlobals.spawn_await_timer(self, 0.5).timeout
	
	await update_for_campaign_data(WorldGlobals._campaign_data)

func update_for_campaign_data(in_data: CampaignData) -> void:
	
	last_campaign_data = in_data
	PlatformGlobals.request_get_leaderboard_entries(in_data.get_leaderboard_best_score(), _on_leaderboard_get_entries_completed)

func _on_leaderboard_get_entries_completed(in_success: bool, in_entries: Array):
	
	for sample_child: Node in entries_container.get_children():
		sample_child.queue_free()
	
	print("%s _on_leaderboard_get_entries_completed() in_success == %s" % [ self, in_success ])
	
	if in_entries.is_empty():
		tabs.current_tab = 1
	else:
		tabs.current_tab = 0
		
		for sample_entry_index: int in range(in_entries.size()):
			
			var new_entry := entry_scene.instantiate() as LeaderboardUI_Entry
			new_entry.photo_process_delay = float(sample_entry_index) * 0.2
			new_entry.data = in_entries[sample_entry_index]
			entries_container.add_child(new_entry)
	tabs.visible = true

func _on_set_score_finished(in_success: bool) -> void:
	if in_success and is_instance_valid(last_campaign_data):
		update_for_campaign_data(last_campaign_data)
