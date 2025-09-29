extends Control
class_name LeaderboardUI

@export_category("List")
@export var entries_container: Container
@export var entry_scene: PackedScene = preload("res://Scenes/UI/Menu/LeaderboardUI_Entry.tscn")
@export var empty_label: VHSLabel

func _ready():
	
	assert(entries_container)
	assert(entry_scene)
	
	if Bridge.leaderboards.type == Bridge.LeaderboardType.IN_GAME:
		pass
	else:
		queue_free()

func handle_animated_sequence() -> void:
	update_for_campaign_data(WorldGlobals._campaign_data)

func update_for_campaign_data(in_data: CampaignData) -> void:
	Bridge.leaderboards.get_entries(in_data.get_leaderboard_best_score(), _on_leaderboard_get_entries_completed)

func _on_leaderboard_get_entries_completed(in_success: bool, in_entries: Array):
	
	for sample_child: Node in entries_container.get_children():
		sample_child.queue_free()
	
	print("%s _on_leaderboard_get_entries_completed() in_success == %s" % [ self, in_success ])
	
	if in_entries.is_empty():
		entries_container.visible = false
		empty_label.lerp_visible = true
	else:
		entries_container.visible = true
		empty_label.lerp_visible = false
		
		for sample_entry_data: Dictionary in in_entries:
			
			var new_entry := entry_scene.instantiate() as LeaderboardUI_Entry
			new_entry.data = sample_entry_data
			entries_container.add_child(new_entry)
