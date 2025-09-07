extends TileSet
class_name LevelTileSet

@export var TerrainData: Dictionary[String, LeveTileSet_TerrainData]

func GetTerrainData(InID: int) -> LeveTileSet_TerrainData:
	return TerrainData[get_source(InID).resource_name]

func GetTerrainID(InName: String) -> int:
	
	for SampleID: int in range(BetterTerrain.terrain_count(self)):
		
		var SampleData := BetterTerrain.get_terrain(self, SampleID)
		
		if SampleData.name == InName:
			return SampleID
	return -1
