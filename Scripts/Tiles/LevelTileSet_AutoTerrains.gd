extends TileSet
class_name LevelTileSet_AutoWalls

var all_categories: Dictionary[String, int] = {}
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
}

func _init(in_data_array: Array[LevelTileSet_TerrainData]) -> void:
	
	for sample_data: LevelTileSet_TerrainData in in_data_array:
		
		for sample_index: int in range(sample_data.categories.size()):
			var sample_category := sample_data.categories[sample_index]
			if not all_categories.has(sample_category):
				BetterTerrain.add_terrain(self, sample_category, sample_data.ui_color, BetterTerrain.TerrainType.CATEGORY, [], { "path": sample_data.icon_path })
				all_categories[sample_category] = all_categories.size()
	
	add_physics_layer()
	
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
				new_source.create_tile(sample_coords)
				
				assert(new_source.has_tile(sample_coords))
				
				var sample_tile_data := new_source.get_tile_data(sample_coords, 0)
				sample_tile_data.material = sample_data.tile_material
				sample_tile_data.z_index = sample_data.z_index
				sample_tile_data.add_collision_polygon(0)
				
				BetterTerrain.set_tile_terrain_type(self, sample_tile_data, sample_terrain_id)
				
				if not coords_to_peering_types.has(sample_coords):
					continue
				
				for sample_peering_type: int in coords_to_peering_types[sample_coords]:
					
					for sample_category_index: int in category_indices:
						BetterTerrain.add_tile_peering_type(self, sample_tile_data, sample_peering_type, sample_category_index)
		terrain_data[source_id] = sample_data

@export var terrain_data: Dictionary[int, LevelTileSet_TerrainData]

func get_terrain_data(in_id: int) -> LevelTileSet_TerrainData:
	return terrain_data[BetterTerrain.get_terrain(self, in_id).name]

func get_terrain_id(in_name: String) -> int:
	
	for SampleID: int in range(BetterTerrain.terrain_count(self)):
		
		var SampleData := BetterTerrain.get_terrain(self, SampleID)
		
		if SampleData.name == in_name:
			return SampleID
	return -1

func categories_to_indices(in_array: Array[String]) -> Array[int]:
	
	var out_array: Array[int] = []
	for sample_category: String in in_array:
		out_array.append(all_categories[sample_category])
	return out_array
