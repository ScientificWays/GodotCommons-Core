@tool
extends TileMapLayer
class_name LevelTileMapLayer_Generated

@export var request_generate: bool = false
@export var floor_layer: LevelTileMapLayer:
	get():
		if not floor_layer:
			var pivot := find_parent("*?ivot*")
			if pivot: return pivot.find_child("*?loor*")
		return floor_layer

@export var wall_layer: LevelTileMapLayer:
	get():
		if not wall_layer:
			var pivot := find_parent("*?ivot*")
			if pivot: return pivot.find_child("*?all*")
		return wall_layer

var generated_tile_set: LevelTileSet_Generated:
	get():
		return tile_set

func _ready():
	request_generate = true

func _process(in_delta: float) -> void:
	
	if request_generate:
		handle_generate()

func handle_generate() -> void:
	
	if not is_node_ready() \
	or not request_generate \
	or not floor_layer \
	or not wall_layer:
		return
	
	clear()
	
	for sample_cell: Vector2i in floor_layer.get_used_cells():
		
		if wall_layer.has_cell(sample_cell):
			continue
		
		var terrain_data := floor_layer.get_cell_terrain_data(sample_cell)
		var sample_id := terrain_data.get_random_debris_id_or_null()
		if sample_id > 0:
			set_cell(sample_cell, generated_tile_set.debris_source_id, Vector2i.ZERO, sample_id)
	request_generate = false
