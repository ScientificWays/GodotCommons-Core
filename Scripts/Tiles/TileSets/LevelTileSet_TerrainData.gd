@tool
extends Resource
class_name LevelTileSet_TerrainData

@export_category("Source")
@export var name: String = "Dirt"
@export var source_id_override: int = -1
@export var atlas: Texture2D = preload("res://addons/GodotCommons-Core/Assets/Tiles/TileSet_Mask001a.tres")
@export var tile_material: Material
@export var tile_z_index: int = 0

@export_category("Terrain")
@export var categories: Array[String] = [ "Primary" ]
@export var ui_color: Color = Color.SADDLE_BROWN
@export var icon_path: String = ""

@export_category("Health")
@export var health: float = 30.0
@export var is_unbreakable: bool = false
@export var post_break_floor_terrain_name: String = "Dirt"

@export_category("Ignite")
@export var can_ignite: bool = false
@export var ignite_damage_threshold: float = 20.0
@export var ignite_damage_probability_mul: float = 0.4
@export var ignite_damage_to_break_probability_mul: float = 0.02
@export var post_ignite_terrain_name: String = "Dirt"

@export_category("Physics")
@export var can_fall: bool = false
@export var gib_scene_path: String
@export var is_gibs_template: bool = false

func load_gib_scene() -> PackedScene:
	return null if gib_scene_path.is_empty() else ResourceLoader.load(gib_scene_path, "PackedScene")

@export_category("Debris")
@export var debris_probability: float = 0.0
@export var debris_ids_custom_weights: Dictionary[int, float] = {
	0: 1.0,
	1: 0.0
}

func get_random_debris_id_or_null(in_tile_set: LevelTileSet_Procedurals, in_random_fraction: float = randf()) -> int:
	
	if randf() > debris_probability:
		return -1
	return get_random_id_or_null(in_tile_set.get_debris_scenes_collection(), in_random_fraction, debris_ids_custom_weights)

@export_category("Foliage")
@export var foliage_probability: float = 0.0
@export var foliage_ids_custom_weights: Dictionary[int, float] = {
	0: 0.5,
	1: 1.0,
	2: 0.5,
	3: 1.0,
}

func get_random_foliage_id_or_null(in_tile_set: LevelTileSet_Procedurals, in_random_fraction: float = randf()) -> int:
	
	if randf() > foliage_probability:
		return -1
	return get_random_id_or_null(in_tile_set.get_foliage_scenes_collection(), in_random_fraction, foliage_ids_custom_weights)

@export_category("Fog")
@export var fog_density_mul: float = 1.0

var per_scene_collection_cache: Dictionary[TileSetScenesCollectionSource, Dictionary]

func reset_random_id_cache() -> void:
	per_scene_collection_cache.clear()

func get_random_id_or_null(in_scenes_collection: TileSetScenesCollectionSource, in_random_fraction: float, in_default_weights: Dictionary[int, float]) -> int:
	
	var ids: Array[int]
	var weights: Array[float]
	
	if per_scene_collection_cache.has(in_scenes_collection):
		ids = per_scene_collection_cache[in_scenes_collection].ids
		weights = per_scene_collection_cache[in_scenes_collection].weights
	else:
		var final_weights: Dictionary[int, float] = in_default_weights.duplicate()
		
		for sample_index: int in range(in_scenes_collection.get_scene_tiles_count()):
			
			var sample_id := in_scenes_collection.get_scene_tile_id(sample_index)
			if final_weights.has(sample_id):
				continue
			else:
				final_weights[sample_id] = 1.0
		
		for sample_id: int in final_weights.keys():
			if not in_scenes_collection.has_scene_tile_id(sample_id):
				final_weights.erase(sample_id)
		
		ids = final_weights.keys()
		weights = final_weights.values()
		
		per_scene_collection_cache[in_scenes_collection] = { "ids": ids, "weights": weights }
		#print(name, per_scene_collection_cache[in_scenes_collection])
	return ids[GameGlobals_Class.array_get_random_index_weighted(weights, in_random_fraction)]
