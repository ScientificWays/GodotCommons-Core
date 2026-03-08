extends Resource
class_name LevelTileSet_ProceduralData

@export_category("Terrain")
@export var target_terrain_name: String = "Stone"
@export var generated_terrain_name: String = "Copper"

@export_category("Noise")
@export var noise: FastNoiseLite
@export var noise_threshold: float = 0.5
