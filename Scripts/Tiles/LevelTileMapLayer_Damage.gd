extends TileMapLayer
class_name LevelTileMapLayer_Damage

@export var TargetLayer: LevelTileMapLayer

class PerCellData:
	var Health: float
	func _init(InLayer: LevelTileMapLayer, InCell: Vector2i):
		Health = InLayer._LevelTileSet.GetTerrainData(BetterTerrain.get_cell(InLayer, InCell)).Health

var PerCellDataDictionary: Dictionary[Vector2i, PerCellData]

func GetCellData(InCell: Vector2i) -> PerCellData:
	
	if not PerCellDataDictionary.has(InCell):
		PerCellDataDictionary[InCell] = PerCellData.new(TargetLayer, InCell)
	return PerCellDataDictionary[InCell]

func GetCellHealthFraction(InCell: Vector2i) -> float:
	return GetCellData(InCell).Health / TargetLayer._LevelTileSet.GetTerrainData(BetterTerrain.get_cell(TargetLayer, InCell)).Health

func SubtractCellHealth(InCell: Vector2i, InHealth: float) -> void:
	
	var CellData := GetCellData(InCell)
	CellData.Health -= InHealth
	
	var CellHealthFraction := GetCellHealthFraction(InCell)
	if CellHealthFraction < 1.0:
		var DamageTileIndex := floori((1.0 - CellHealthFraction) * 4.0)
		var AlternativeTile := randi_range(0, 2)
		set_cell(InCell, 0, Vector2i(DamageTileIndex, 0), AlternativeTile)

func SetCellHealth(InCell: Vector2i, InHealth: float) -> void:
	GetCellData(InCell).Health = InHealth

func ClearCellData(InCell: Vector2i) -> void:
	PerCellDataDictionary.erase(InCell)
	erase_cell(InCell)
