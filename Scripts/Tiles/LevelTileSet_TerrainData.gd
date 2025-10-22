@tool
extends Resource
class_name LevelTileSet_TerrainData

@export_category("Source")
@export var name: String = "Dirt"
@export var source_id_override: int = -1
@export var atlas: Texture2D = preload("res://addons/GodotCommons-Core/Assets/Tiles/TileSet_Mask001a.tres")
@export var tile_material: Material = preload("res://addons/GodotCommons-Core/Assets/Tiles/Walls/Dirt001_Wall_M.tres")
@export var z_index: int = 0

@export_category("Terrain")
@export var categories: Array[String] = [ "Primary" ]
@export var ui_color: Color = Color.SADDLE_BROWN
@export var icon_path: String = "res://addons/GodotCommons-Core/Assets/Tiles/Walls/Dirt001_Wall.png"

@export_category("Health")
@export var Health: float = 50.0
@export var IsUnbreakable: bool = false
@export var break_floor_terrain_name: StringName = &"Floor: Dirt"

@export_category("Ignite")
@export var CanIgnite: bool = false
@export var IgniteDamageThreshold: float = 20.0
@export var IgniteDamageProbabilityMul: float = 0.4
@export var IgniteDamageToBreakProbabilityMul: float = 0.02
@export var post_ignite_terrain_name: StringName = &"Floor: Dirt"

@export_category("Physics")
@export var CanFall: bool = false
@export var GibsScene: PackedScene

@export_category("Debris")
@export var debris_probability: float = 0.0
@export var debris_ids: Array[int]
@export var debris_weights: Array[float]

func get_random_debris_id_or_null(in_random_fraction: float = randf()) -> int:
	
	if randf() > debris_probability:
		return -1
	
	return debris_ids[GameGlobals_Class.ArrayGetRandomIndexWeighted(debris_weights, in_random_fraction)]
