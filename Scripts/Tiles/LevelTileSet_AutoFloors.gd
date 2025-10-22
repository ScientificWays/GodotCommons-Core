extends LevelTileSet_Auto_Base
class_name LevelTileSet_AutoFloors

func _init(in_data_array: Array[LevelTileSet_TerrainData]) -> void:
	
	for sample_data: LevelTileSet_TerrainData in in_data_array:
		
		for sample_index: int in range(sample_data.categories.size()):
			var sample_category := sample_data.categories[sample_index]
			if not all_categories.has(sample_category):
				BetterTerrain.add_terrain(self, sample_category, sample_data.ui_color, BetterTerrain.TerrainType.CATEGORY, [], { "path": sample_data.icon_path })
				all_categories[sample_category] = all_categories.size()
	
	for sample_data: LevelTileSet_TerrainData in in_data_array:
		
		var new_source := TileSetAtlasSource.new()
		new_source.resource_name = sample_data.name
		new_source.texture = sample_data.atlas
		new_source.texture_region_size = Vector2(18.0, 18.0)
		new_source.use_texture_padding = false
		var source_id := add_source(new_source, sample_data.source_id_override)
		
		var category_indices := categories_to_indices(sample_data.categories)
		BetterTerrain.add_terrain(self, sample_data.name, sample_data.ui_color, BetterTerrain.TerrainType.MATCH_VERTICES, category_indices, { "path": sample_data.icon_path })
		var sample_terrain_id := get_terrain_id(sample_data.name)
		
		for x: int in range(1):
			for y: int in range(1):
				
				var sample_coords := Vector2i(x, y)
				new_source.create_tile(sample_coords)
				
				assert(new_source.has_tile(sample_coords))
				
				var sample_tile_data := new_source.get_tile_data(sample_coords, 0)
				sample_tile_data.material = sample_data.tile_material
				sample_tile_data.z_index = sample_data.tile_z_index
				
				BetterTerrain.set_tile_terrain_type(self, sample_tile_data, sample_terrain_id)
		terrain_data[sample_terrain_id] = sample_data
