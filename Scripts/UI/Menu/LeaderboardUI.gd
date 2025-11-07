extends Control
class_name LeaderboardUI

@export_category("List")
@export var entries_container: Container
@export var entry_scene: PackedScene = preload("res://Scenes/UI/Menu/LeaderboardUI_Entry.tscn")
@export var tabs: TabContainer

var last_campaign_data: CampaignData

func _ready():
	
	assert(entries_container)
	assert(entry_scene)
	
	assert(tabs)
	
	tabs.current_tab = 1
	tabs.visible = false
	
	if Bridge.leaderboards.type == Bridge.LeaderboardType.IN_GAME:
		on_set_score_finished(true)
	else:
		queue_free()

func _enter_tree() -> void:
	if PlatformGlobals_Class.is_web():
		if Bridge.leaderboards.type == Bridge.LeaderboardType.IN_GAME:
			Bridge.leaderboards.on_set_score_finished.connect(on_set_score_finished)

func _exit_tree() -> void:
	if PlatformGlobals_Class.is_web():
		if Bridge.leaderboards.type == Bridge.LeaderboardType.IN_GAME:
			Bridge.leaderboards.on_set_score_finished.disconnect(on_set_score_finished)

func handle_animated_sequence() -> void:
	
	#await GameGlobals.spawn_await_timer(self, 0.5).timeout
	
	await update_for_campaign_data(WorldGlobals._campaign_data)

func update_for_campaign_data(in_data: CampaignData) -> void:
	
	last_campaign_data = in_data
	Bridge.leaderboards.get_entries(in_data.get_leaderboard_best_score(), _on_leaderboard_get_entries_completed)

func _on_leaderboard_get_entries_completed(in_success: bool, in_entries: Array):
	
	for sample_child: Node in entries_container.get_children():
		sample_child.queue_free()
	
	print("%s _on_leaderboard_get_entries_completed() in_success == %s" % [ self, in_success ])
	
	if in_entries.is_empty():
		tabs.current_tab = 1
	else:
		tabs.current_tab = 0
		
		for sample_entry_data: Dictionary in in_entries:
			
			var new_entry := entry_scene.instantiate() as LeaderboardUI_Entry
			new_entry.data = sample_entry_data
			entries_container.add_child(new_entry)
	tabs.visible = true

func on_set_score_finished(in_success: bool) -> void:
	if in_success and is_instance_valid(last_campaign_data):
		update_for_campaign_data(last_campaign_data)
