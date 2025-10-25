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
@export var debris_ids: Array[int]
@export var debris_weights: Array[float]

func get_random_debris_id_or_null(in_random_fraction: float = randf()) -> int:
	
	if randf() > debris_probability:
		return -1
	
	return debris_ids[GameGlobals_Class.ArrayGetRandomIndexWeighted(debris_weights, in_random_fraction)]
