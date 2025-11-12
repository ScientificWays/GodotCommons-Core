@tool
extends TileMapLayer
class_name LevelTileMapLayer_Procedurals

@export_category("Actions")
@export_tool_button("Generate") var generate_action: Callable = handle_generate
@export_tool_button("Reset") var reset_action: Callable = reset_generate

@export_category("Debug")
@export var debug_label_settings: LabelSettings = preload("res://addons/GodotCommons-Core/Assets/UI/Common/DefaultDebugLabelSettings.tres")
@export var debug_distance_to_walls: bool = false

@export_category("Layers")
@export var floor_layer: LevelTileMapLayer
@export var wall_layer: LevelTileMapLayer
@export var other_occupation_layers: Array[TileMapLayer]

@export_category("Noise")
@export var noise_data: Array[LevelTileSet_ProceduralData]

@export_category("Distances")
@export var max_distance_to_walls: int = 4

@export_category("Debris")
@export var override_debris_probability: Dictionary[int, float]

@export_category("Foliage")
@export var override_foliage_probability: Dictionary[int, float]
@export var foliage_distance_to_walls_to_density_mul: Curve = preload("res://addons/GodotCommons-Core/Assets/Tiles/DefaultFoliageDensityMul.tres")

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
		
		z_index = 0
		z_as_relative = true
		y_sort_enabled = true
	else:
		#if not WorldGlobals._level.is_node_ready():
		#	await WorldGlobals._level.ready
		
		#if WorldGlobals._level._y_sorted:
		#	reparent(WorldGlobals._level._y_sorted)
		pass
	
	wall_layer.regenerated_tile_set.connect(handle_generate)
	
	if wall_layer.is_node_ready():
		handle_generate.call_deferred()

var queued_callables: Array[Callable]

func _process(in_delta: float) -> void:
	
	if queued_callables.is_empty():
		set_process(false)
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		var sample_index = 0
		while not queued_callables.is_empty() and sample_index < 4:
			var callable := queued_callables.pop_back()
			callable.call()
			sample_index += 1

func _exit_tree() -> void:
	clear()

func _notification(in_what: int) -> void:
	
	if in_what == NOTIFICATION_EDITOR_PRE_SAVE:
		reset_generate()
		update_internals()
	elif in_what == NOTIFICATION_EDITOR_POST_SAVE:
		handle_generate.call_deferred()

var occupied_cells: Dictionary[Vector2i, Node2D]

func is_cell_occupied(in_cell: Vector2i) -> bool:
	return occupied_cells.has(in_cell)

func get_cell_occupant(in_cell: Vector2i) -> Node2D:
	return occupied_cells[in_cell] if occupied_cells.has(in_cell) else null

func mark_cell_occupied(in_cell: Vector2i, by_target: Node2D) -> void:
	assert(not occupied_cells.has(in_cell))
	occupied_cells[in_cell] = by_target

var debug_labels: Array[Label]

func handle_generate() -> void:
	
	if not is_inside_tree() \
	or not is_node_ready() \
	or not floor_layer \
	or not wall_layer \
	or not wall_layer.is_node_ready():
		return
	
	reset_generate()
	
	var generate_start_ticks_ms := Time.get_ticks_msec()
	
	if not Engine.is_editor_hint():
		print(name, " handle_generate()")
	
	for sample_other_layer: TileMapLayer in other_occupation_layers:
		for sample_cell: Vector2i in sample_other_layer.get_used_cells():
			mark_cell_occupied(sample_cell, sample_other_layer)
	
	#print("handle_generate() after mark occupied cells at %d ms" % (Time.get_ticks_msec() - generate_start_ticks_ms))
	
	var distance_unmarked_cells := floor_layer.get_used_cells()
	var distance_to_walls: Dictionary[Vector2i, int]
	
	var has_wall_cache: Dictionary[Vector2i, bool]
	
	#var floor_no_walls_cells: Array[Vector2i] = []
	
	for sample_distance: int in range(max_distance_to_walls):
		
		var new_distance_unmarked_cells: Array[Vector2i] = []
		for sample_cell: Vector2i in distance_unmarked_cells:
			
			if has_wall_cache.has(sample_cell):
				if has_wall_cache[sample_cell] == true:
					continue
			elif wall_layer.has_cell(sample_cell):
				has_wall_cache[sample_cell] = true
				continue
			
			#if not floor_layer.has_cell(sample_cell):
			#	continue
			
			#if distance_to_walls.has(sample_cell):
			#	continue
			
			var has_wall_nearby := false
			
			for sample_offset: Vector2i in TileGlobals._OffsetCellArray_RightAngles:
				
				var sample_neighbor := sample_cell + sample_offset
				if (sample_distance == 0 and has_wall_cache.has(sample_neighbor)) \
				or (distance_to_walls.has(sample_neighbor) and distance_to_walls[sample_neighbor] == (sample_distance - 1)):
					has_wall_nearby = true
					break
			
			if not has_wall_nearby:
				new_distance_unmarked_cells.append(sample_cell)
				continue
			
			distance_to_walls[sample_cell] = sample_distance
			
			if debug_distance_to_walls and randf() < 0.5:
				
				var new_debug_label := Label.new()
				new_debug_label.label_settings = debug_label_settings
				new_debug_label.position = map_to_local(sample_cell) - (Vector2(tile_set.tile_size) * Vector2(0.2, 0.5))
				new_debug_label.text = String.num_int64(sample_distance)
				new_debug_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				new_debug_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				new_debug_label.set_anchors_preset(Control.PRESET_CENTER)
				
				add_child(new_debug_label)
				
				debug_labels.append(new_debug_label)
		distance_unmarked_cells = new_distance_unmarked_cells
		#await get_tree().process_frame
	
	#print("handle_generate() after wall distances at %d ms" % (Time.get_ticks_msec() - generate_start_ticks_ms))
	#await get_tree().process_frame
	
	var fog_dynamic_grid_size := procedurals_tile_set.get_random_fog_grid_size()
	
	for sample_cell: Vector2i in floor_layer.get_used_cells():
		
		if is_cell_occupied(sample_cell):
			continue
		
		if has_wall_cache.has(sample_cell):
			continue
		
		#if not floor_layer.has_cell(sample_cell):
		#	continue
		
		var terrain_data := floor_layer.get_cell_terrain_data(sample_cell)
		
		## Try set foliage
		if distance_to_walls.has(sample_cell):
			var sample_foliage_density := foliage_distance_to_walls_to_density_mul.sample_baked(float(distance_to_walls[sample_cell]))
			if sample_foliage_density > randf():
				var sample_foliage_id := terrain_data.get_random_foliage_id_or_null(procedurals_tile_set)
				if sample_foliage_id >= 0:
					if override_foliage_probability.get(sample_foliage_id, 1.0) > randf():
						#set_cell(sample_cell, procedurals_tile_set.foliage_source_id, Vector2i.ZERO, sample_foliage_id)
						queued_callables.append(set_cell.bind(sample_cell, procedurals_tile_set.foliage_source_id, Vector2i.ZERO, sample_foliage_id))
						continue
		
		## Try set fog
		if sample_cell % fog_dynamic_grid_size == Vector2i.ZERO:
			
			var cell_fog_density := terrain_data.fog_density_mul * fog_density
			if cell_fog_density > randf():
				#set_cell(sample_cell, procedurals_tile_set.fog_source_id, Vector2i.ZERO, 0)
				queued_callables.append(set_cell.bind(sample_cell, procedurals_tile_set.fog_source_id, Vector2i.ZERO, 0))
				fog_dynamic_grid_size = procedurals_tile_set.get_random_fog_grid_size()
				continue
		
		## Try set debris
		var sample_debris_id := terrain_data.get_random_debris_id_or_null(procedurals_tile_set)
		if sample_debris_id >= 0:
			if override_debris_probability.get(sample_debris_id, 1.0) > randf():
				#set_cell(sample_cell, procedurals_tile_set.debris_source_id, Vector2i.ZERO, sample_debris_id)
				queued_callables.append(set_cell.bind(sample_cell, procedurals_tile_set.debris_source_id, Vector2i.ZERO, sample_debris_id))
				continue
	
	#print("handle_generate() after set scenes at %d ms" % (Time.get_ticks_msec() - generate_start_ticks_ms))
	#await get_tree().process_frame
	
	var wall_updates: Array[Dictionary] = []
	for sample_noise_data: LevelTileSet_ProceduralData in noise_data:
		
		sample_noise_data.noise.set_deferred(&"seed", sample_noise_data.noise.seed)
		sample_noise_data.noise.seed = randi()
		
		var prev_id := wall_layer.level_tile_set.get_terrain_id(sample_noise_data.target_terrain_name)
		var new_id := wall_layer.level_tile_set.get_terrain_id(sample_noise_data.generated_terrain_name)
		
		if new_id == BetterTerrain.TileCategory.EMPTY:
			printerr("Noise data %s has unknown generated_terrain_name %s!" % [ sample_noise_data.resource_path, sample_noise_data.generated_terrain_name ])
			new_id = prev_id
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
	
	#print("handle_generate() after apply noise cells at %d ms" % (Time.get_ticks_msec() - generate_start_ticks_ms))
	
	if Engine.is_editor_hint():
		pass
	else:
		var tree_current_scene := get_tree().current_scene
		if tree_current_scene is LevelBase2D:
			#print("tree_current_scene.request_nav_update()")
			tree_current_scene.request_nav_update()
	
	queued_callables.reverse()
	set_process(true)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("handle_generate() took %d ms" % (Time.get_ticks_msec() - generate_start_ticks_ms))

func reset_generate() -> void:
	
	if not Engine.is_editor_hint():
		print(name, " reset_generate()")
	
	queued_callables.clear()
	
	for sample_debug_label: Label in debug_labels:
		sample_debug_label.queue_free()
	debug_labels.clear()
	
	for sample_terrain_data: LevelTileSet_TerrainData in (floor_layer.terrain_data_array + wall_layer.terrain_data_array):
		sample_terrain_data.reset_random_id_cache()
	
	if wall_layer.level_tile_set:
		
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
	
	occupied_cells.clear()
	clear()
