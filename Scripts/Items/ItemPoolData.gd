extends Resource
class_name ItemPoolData

func _init() -> void:
	WorldGlobals.load_scene_finished.connect(reset_adjusted)
	reset_adjusted.call_deferred()

@export_category("Pick Ups")
@export var scene_paths: Array[String]
@export var weights: Array[float]

var adjusted_weights: Array[float]

func reset_adjusted() -> void:
	adjusted_weights = weights.duplicate()
	assert(adjusted_weights.size() == scene_paths.size())

func get_random_scene() -> PackedScene:
	
	var sample_index := GameGlobals_Class.array_get_random_index_weighted(adjusted_weights)
	
	assert(GameGlobals_Class.ArrayIsValidIndex(scene_paths, sample_index))
	var sample_path := scene_paths[sample_index]
	
	assert(ResourceLoader.exists(sample_path, "PackedScene"))
	return ResourceLoader.load(sample_path, "PackedScene")

func remove_from_pool(in_scene_path: String) -> void:
	
	var target_index := scene_paths.find(in_scene_path)
	
	assert(GameGlobals_Class.ArrayIsValidIndex(adjusted_weights, target_index))
	adjusted_weights[target_index] = 0.0
