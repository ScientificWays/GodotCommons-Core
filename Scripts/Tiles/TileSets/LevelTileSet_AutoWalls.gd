@tool
extends LevelTileSet_Auto_Base
class_name LevelTileSet_AutoWalls

var coords_to_peering_types: Dictionary[Vector2i, Array] = {
	
	Vector2i(0, 0): [ CELL_NEIGHBOR_BOTTOM_SIDE ],
	Vector2i(0, 1): [ CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE ],
	Vector2i(0, 2): [ CELL_NEIGHBOR_TOP_SIDE ],
	Vector2i(0, 3): [],
	
	Vector2i(1, 0): [ CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_RIGHT_SIDE ],
	Vector2i(1, 1): [ CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_RIGHT_SIDE ],
	Vector2i(1, 2): [ CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_RIGHT_SIDE ],
	Vector2i(1, 3): [ CELL_NEIGHBOR_RIGHT_SIDE ],
	
	Vector2i(2, 0): [ CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE ],
	Vector2i(2, 1): [ CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE ],
	Vector2i(2, 2): [ CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE ],
	Vector2i(2, 3): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE ],
	
	Vector2i(3, 0): [ CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_LEFT_SIDE ],
	Vector2i(3, 1): [ CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_LEFT_SIDE ],
	Vector2i(3, 2): [ CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_LEFT_SIDE ],
	Vector2i(3, 3): [ CELL_NEIGHBOR_LEFT_SIDE ],
	
	Vector2i(4, 0): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
	Vector2i(4, 1): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER ],
	Vector2i(4, 2): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_TOP_RIGHT_CORNER ],
	Vector2i(4, 3): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER ],
	
	Vector2i(5, 0): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER ],
	Vector2i(5, 1): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, CELL_NEIGHBOR_TOP_RIGHT_CORNER ],
	Vector2i(5, 2): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, CELL_NEIGHBOR_TOP_LEFT_CORNER, CELL_NEIGHBOR_TOP_RIGHT_CORNER ],
	Vector2i(5, 3): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_TOP_RIGHT_CORNER ],
	
	Vector2i(6, 0): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER ],
	Vector2i(6, 1): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
	Vector2i(6, 2): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, CELL_NEIGHBOR_TOP_RIGHT_CORNER, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
	Vector2i(6, 3): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
	
	Vector2i(7, 0): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_TOP_RIGHT_CORNER ],
	Vector2i(7, 1): [ CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER ],
	Vector2i(7, 2): [ CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
	Vector2i(7, 3): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER ],
	
	Vector2i(8, 0): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER ],
	Vector2i(8, 1): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, CELL_NEIGHBOR_TOP_RIGHT_CORNER ],
	Vector2i(8, 2): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, CELL_NEIGHBOR_TOP_RIGHT_CORNER ],
	Vector2i(8, 3): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_TOP_RIGHT_CORNER ],
	
	Vector2i(9, 0): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER ],
	Vector2i(9, 1): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, CELL_NEIGHBOR_TOP_RIGHT_CORNER ],
	Vector2i(9, 2): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, CELL_NEIGHBOR_TOP_RIGHT_CORNER, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
	Vector2i(9, 3): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_TOP_RIGHT_CORNER, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
	
	Vector2i(10, 0): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER ],
	Vector2i(10, 1): [ ],
	Vector2i(10, 2): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_TOP_LEFT_CORNER, CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER ],
	Vector2i(10, 3): [ CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_TOP_RIGHT_CORNER, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
	
	Vector2i(11, 0): [ CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER ],
	Vector2i(11, 1): [ CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_RIGHT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
	Vector2i(11, 2): [ CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_BOTTOM_SIDE, CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
	Vector2i(11, 3): [ CELL_NEIGHBOR_LEFT_SIDE, CELL_NEIGHBOR_TOP_SIDE, CELL_NEIGHBOR_TOP_LEFT_CORNER ],
}

var collision_polygon_points: PackedVector2Array = [
	Vector2(-8.0, -8.0),
	Vector2(8.0, -8.0),
	Vector2(8.0, 8.0),
	Vector2(-8.0, 8.0),
]

func _init(in_data_array: Array[LevelTileSet_TerrainData] = []) -> void:
	
	if in_data_array.is_empty():
		return
	
	#var performance_start := Time.get_ticks_usec()
	
	for sample_data: LevelTileSet_TerrainData in in_data_array:
		
		for sample_index: int in range(sample_data.categories.size()):
			var sample_category := sample_data.categories[sample_index]
			if not all_categories.has(sample_category):
				BetterTerrain.add_terrain(self, sample_category, sample_data.ui_color, BetterTerrain.TerrainType.CATEGORY, [], { "path": sample_data.icon_path })
				all_categories[sample_category] = all_categories.size()
	
	add_physics_layer()
	set_physics_layer_collision_layer(0, GameGlobals_Class.collision_layer_world)
	set_physics_layer_collision_mask(0, GameGlobals_Class.collision_layer_none)
	
	for sample_data: LevelTileSet_TerrainData in in_data_array:
		
		var new_source := TileSetAtlasSource.new()
		new_source.resource_name = sample_data.name
		new_source.texture = sample_data.atlas
		new_source.texture_region_size = Vector2(18.0, 18.0)
		new_source.use_texture_padding = false
		var source_id := add_source(new_source, sample_data.source_id_override)
		
		var category_indices := categories_to_indices(sample_data.categories)
		BetterTerrain.add_terrain(self, sample_data.name, sample_data.ui_color, BetterTerrain.TerrainType.MATCH_TILES, category_indices, { "path": sample_data.icon_path })
		var sample_terrain_id := get_terrain_id(sample_data.name)
		
		for x: int in range(12):
			for y: int in range(4):
				
				var sample_coords := Vector2i(x, y)
				if sample_coords == Vector2i(10, 1):
					continue
				
				new_source.create_tile(sample_coords)
				assert(new_source.has_tile(sample_coords))
				
				var sample_tile_data := new_source.get_tile_data(sample_coords, 0)
				sample_tile_data.material = sample_data.tile_material
				sample_tile_data.z_index = sample_data.tile_z_index
				sample_tile_data.add_collision_polygon(0)
				sample_tile_data.set_collision_polygon_points(0, 0, collision_polygon_points)
				
				BetterTerrain.set_tile_terrain_type_queue(self, sample_tile_data, sample_terrain_id)
		
		BetterTerrain.set_tile_terrain_type_flush(self)
		
		for x: int in range(12):
			for y: int in range(4):
				
				var sample_coords := Vector2i(x, y)
				if sample_coords == Vector2i(10, 1):
					continue
				
				var sample_tile_data := new_source.get_tile_data(sample_coords, 0)
				if sample_coords == Vector2i(9, 2):
					BetterTerrain.set_tile_symmetry_type(self, sample_tile_data, BetterTerrain.SymmetryType.ALL)
				
				if not coords_to_peering_types.has(sample_coords):
					continue
				
				BetterTerrain.set_tile_peering_types_bulk(self, sample_tile_data, coords_to_peering_types[sample_coords], category_indices)
		
		terrain_data[sample_terrain_id] = sample_data
	
	#var performance_finish := Time.get_ticks_usec()
	#print(self, "_init() performance: ", ceili(float(performance_finish - performance_start) * 0.001), " msec")
