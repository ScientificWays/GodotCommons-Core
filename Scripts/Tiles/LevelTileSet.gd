extends TileSet
class_name LevelTileSet

@export var terrain_data: Dictionary[String, LeveTileSet_TerrainData]

func get_terrain_data(in_id: int) -> LeveTileSet_TerrainData:
	return terrain_data[BetterTerrain.get_terrain(self, in_id).name]

func get_terrain_id(in_name: String) -> int:
	
	for SampleID: int in range(BetterTerrain.terrain_count(self)):
		
		var SampleData := BetterTerrain.get_terrain(self, SampleID)
		
		if SampleData.name == in_name:
			return SampleID
	return -1
