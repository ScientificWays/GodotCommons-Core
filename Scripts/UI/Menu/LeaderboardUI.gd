extends Control
class_name LeaderboardUI

@export_category("List")
@export var entries_container: Container
@export var entry_scene: PackedScene = preload("res://Scenes/UI/Menu/LeaderboardUI_Entry.tscn")

func _ready():
	
	assert(entries_container)
	assert(entry_scene)
	
	if Bridge.leaderboards.type == Bridge.LeaderboardType.IN_GAME:
		pass
	else:
		queue_free()

func handle_animated_sequence() -> void:
	
	Bridge.leaderboards.get_entries(WorldGlobals._campaign_data.get_leaderboard_best_score(), _on_leaderboard_get_entries_completed)

func _on_leaderboard_get_entries_completed(in_success: bool, in_entries: Array):
	
	for sample_child: Node in entries_container.get_children():
		sample_child.queue_free()
	
	print("%s _on_leaderboard_get_entries_completed() in_success == %s" % [ self, in_success ])
	
	for sample_entry_data: Dictionary in in_entries:
		
		var new_entry := entry_scene.instantiate() as LeaderboardUI_Entry
		new_entry.data = sample_entry_data
		entries_container.add_child(new_entry)
