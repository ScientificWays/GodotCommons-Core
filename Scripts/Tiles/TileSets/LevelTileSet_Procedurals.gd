@tool
extends TileSet
class_name LevelTileSet_Procedurals

@export_category("Debris")
@export var debris_source_id: int = 0

@export_category("Fog")
@export var fog_source_id: int = 2
@export var fog_grid_size_base: Vector2i = Vector2i(6, 3)
@export var fog_grid_size_max_offset: int = 1

func get_random_fog_grid_size() -> Vector2i:
	return Vector2i(fog_grid_size_base.x + randi_range(-fog_grid_size_max_offset, fog_grid_size_max_offset), fog_grid_size_base.y + randi_range(-fog_grid_size_max_offset, fog_grid_size_max_offset))

#@export_category("Triggers")
#@export var triggers_source_id: int = 0
#@export var fall_trigger_source_id: int = 1
