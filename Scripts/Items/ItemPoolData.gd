extends Resource
class_name ItemPoolData

func _init() -> void:
	WorldGlobals.load_scene_finished.connect(reset)
	reset.call_deferred()

@export_category("Pick Ups")
@export var scene_paths: Array[String]
@export var weights: Array[float]

var random_number_generator: RandomNumberGenerator
var adjusted_weights: Array[float]

func reset() -> void:
	
	if not is_instance_valid(random_number_generator):
		random_number_generator = RandomNumberGenerator.new()
	random_number_generator.randomize()
	
	adjusted_weights = weights.duplicate()
	assert(adjusted_weights.size() == scene_paths.size())

func get_random_scene(in_async_loading: bool, in_remove_from_pool: bool) -> PackedScene:
	
	var sample_index := GameGlobals_Class.array_get_random_index_weighted(adjusted_weights)
	
	assert(GameGlobals_Class.ArrayIsValidIndex(scene_paths, sample_index))
	var sample_path := scene_paths[sample_index]
	
	if in_remove_from_pool:
		remove_from_pool(sample_path)
	
	assert(ResourceLoader.exists(sample_path, "PackedScene"))
	if in_async_loading:
		var async_loader := AsyncResourceLoader.new(sample_path, false)
		return await async_loader.get_after_finished()
	else:
		return ResourceLoader.load(sample_path, "PackedScene")

func remove_from_pool(in_scene_path: String) -> void:
	
	var target_index := scene_paths.find(in_scene_path)
	
	assert(GameGlobals_Class.ArrayIsValidIndex(adjusted_weights, target_index))
	adjusted_weights[target_index] = 0.0
