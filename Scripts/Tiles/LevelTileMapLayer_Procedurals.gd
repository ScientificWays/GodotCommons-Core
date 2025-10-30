@tool
extends TileMapLayer
class_name LevelTileMapLayer_Procedurals

@export_category("Actions")
@export_tool_button("Generate") var generate_action: Callable = handle_generate
@export_tool_button("Reset") var reset_action: Callable = reset_generate

@export_category("Layers")
@export var floor_layer: LevelTileMapLayer
@export var wall_layer: LevelTileMapLayer

@export_category("Noise")
@export var noise_data: Array[LevelTileSet_ProceduralData]

@export_category("Fog")
@export var fog_density: float = 0.0

var procedurals_tile_set: LevelTileSet_Procedurals:
	get(): return tile_set

func _ready():
	
	if Engine.is_editor_hint():
		if not floor_layer:
			floor_layer = get_parent().find_child("*?loor*")
		if not wall_layer:
			wall_layer = get_parent().find_child("*?all*")
	
	wall_layer.regenerated_tile_set.connect(handle_generate)
	handle_generate()

func _exit_tree() -> void:
	clear()

func _notification(in_what: int) -> void:
	
	if in_what == NOTIFICATION_EDITOR_PRE_SAVE:
		reset_generate()
		update_internals()
	elif in_what == NOTIFICATION_EDITOR_POST_SAVE:
		handle_generate.call_deferred()

func handle_generate() -> void:
	
	if not is_node_ready() \
	or not floor_layer \
	or not wall_layer \
	or not wall_layer.is_node_ready():
		return
	
	reset_generate()
	
	if not Engine.is_editor_hint():
		print(name, " handle_generate()")
	
	var fog_dynamic_grid_size := procedurals_tile_set.get_random_fog_grid_size()
	
	for sample_cell: Vector2i in floor_layer.get_used_cells():
		
		if wall_layer.has_cell(sample_cell):
			continue
		
		if not floor_layer.has_cell(sample_cell):
			continue
		
		var terrain_data := floor_layer.get_cell_terrain_data(sample_cell)
		var cell_fog_density := fog_density * terrain_data.fog_density_mul
		
		if sample_cell % fog_dynamic_grid_size == Vector2i.ZERO and cell_fog_density > randf():
			set_cell(sample_cell, procedurals_tile_set.fog_source_id, Vector2i.ZERO, 1)
			fog_dynamic_grid_size = procedurals_tile_set.get_random_fog_grid_size()
		else:
			
			var sample_id := terrain_data.get_random_debris_id_or_null()
			if sample_id > 0:
				set_cell(sample_cell, procedurals_tile_set.debris_source_id, Vector2i.ZERO, sample_id)
	
	var wall_updates: Array[Dictionary] = []
	for sample_noise_data: LevelTileSet_ProceduralData in noise_data:
		
		sample_noise_data.noise.set_deferred(&"seed", sample_noise_data.noise.seed)
		sample_noise_data.noise.seed = randi()
		
		var prev_id := wall_layer.level_tile_set.get_terrain_id(sample_noise_data.target_terrain_name)
		var new_id := wall_layer.level_tile_set.get_terrain_id(sample_noise_data.generated_terrain_name)
		wall_updates.append({ "cells": [], "new_id": new_id, "prev_id": prev_id })
	
	for sample_cell: Vector2i in wall_layer.get_used_cells():
		
		var sample_terrain_id := BetterTerrain.get_cell(wall_layer, sample_cell)
		
		for sample_index: int in range(noise_data.size()):
			
			if sample_terrain_id == wall_updates[sample_index].prev_id:
				
				var sample_noise_data := noise_data[sample_index]
				var sample_noise_value := sample_noise_data.noise.get_noise_2d(sample_cell.x, sample_cell.y)
				
				if sample_noise_value > sample_noise_data.noise_threshold:
					wall_updates[sample_index].cells.append(sample_cell)
	
	for sample_wall_update: Dictionary in wall_updates:
		BetterTerrain.set_cells(wall_layer, sample_wall_update.cells, sample_wall_update.new_id)
		BetterTerrain.update_terrain_cells(wall_layer, sample_wall_update.cells, false)

func reset_generate() -> void:
	
	if not Engine.is_editor_hint():
		print(name, " reset_generate()")
	
	if not wall_layer.level_tile_set:
		return
	
	var wall_updates: Array[Dictionary] = []
	for sample_noise_data: LevelTileSet_ProceduralData in noise_data:
		
		sample_noise_data.noise.seed = 0
		
		var prev_id := wall_layer.level_tile_set.get_terrain_id(sample_noise_data.target_terrain_name)
		var new_id := wall_layer.level_tile_set.get_terrain_id(sample_noise_data.generated_terrain_name)
		wall_updates.append({ "cells": [], "new_id": new_id, "prev_id": prev_id })
	
	for sample_cell: Vector2i in wall_layer.get_used_cells():
		var sample_terrain_id := BetterTerrain.get_cell(wall_layer, sample_cell)
		for sample_index: int in range(noise_data.size()):
			if sample_terrain_id == wall_updates[sample_index].new_id:
				wall_updates[sample_index].cells.append(sample_cell)
	
	for sample_wall_update: Dictionary in wall_updates:
		BetterTerrain.set_cells(wall_layer, sample_wall_update.cells, sample_wall_update.prev_id)
		BetterTerrain.update_terrain_cells(wall_layer, sample_wall_update.cells, false)
	
	wall_updates.clear()
	clear()
