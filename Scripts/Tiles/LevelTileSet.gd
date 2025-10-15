extends TileSet
class_name LevelTileSet

@export var TerrainData: Dictionary[String, LeveTileSet_TerrainData]

func GetTerrainData(InID: int) -> LeveTileSet_TerrainData:
	return TerrainData[BetterTerrain.get_terrain(self, InID).name]

func GetTerrainID(in_name: String) -> int:
	
	for SampleID: int in range(BetterTerrain.terrain_count(self)):
		
		var SampleData := BetterTerrain.get_terrain(self, SampleID)
		
		if SampleData.name == in_name:
			return SampleID
	return -1
