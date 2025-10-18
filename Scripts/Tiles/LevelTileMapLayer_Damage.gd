extends TileMapLayer
class_name LevelTileMapLayer_Damage

@export var TargetLayer: LevelTileMapLayer

class PerCellData:
	var Health: float
	func _init(InLayer: LevelTileMapLayer, in_cell: Vector2i):
		Health = InLayer._LevelTileSet.get_terrain_data(BetterTerrain.get_cell(InLayer, in_cell)).Health

var PerCellDataDictionary: Dictionary[Vector2i, PerCellData]

func GetCellData(in_cell: Vector2i) -> PerCellData:
	
	if not PerCellDataDictionary.has(in_cell):
		PerCellDataDictionary[in_cell] = PerCellData.new(TargetLayer, in_cell)
	return PerCellDataDictionary[in_cell]

func GetCellHealthFraction(in_cell: Vector2i) -> float:
	return GetCellData(in_cell).Health / TargetLayer._LevelTileSet.get_terrain_data(BetterTerrain.get_cell(TargetLayer, in_cell)).Health

func SubtractCellHealth(in_cell: Vector2i, InHealth: float) -> void:
	
	var CellData := GetCellData(in_cell)
	CellData.Health -= InHealth
	
	var CellHealthFraction := GetCellHealthFraction(in_cell)
	if CellHealthFraction < 1.0:
		var DamageTileIndex := floori((1.0 - CellHealthFraction) * 4.0)
		var AlternativeTile := randi_range(0, 2)
		set_cell(in_cell, 0, Vector2i(DamageTileIndex, 0), AlternativeTile)

func SetCellHealth(in_cell: Vector2i, InHealth: float) -> void:
	GetCellData(in_cell).Health = InHealth

func ClearCellData(in_cell: Vector2i) -> void:
	PerCellDataDictionary.erase(in_cell)
	erase_cell(in_cell)
