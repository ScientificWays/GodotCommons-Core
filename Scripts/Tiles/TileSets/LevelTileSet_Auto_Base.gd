@tool
extends TileSet
class_name LevelTileSet_Auto_Base

var all_categories: Dictionary[String, int] = {}

@export var terrain_data: Dictionary[int, LevelTileSet_TerrainData]

func get_terrain_data(in_id: int) -> LevelTileSet_TerrainData:
	return terrain_data[in_id]

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
