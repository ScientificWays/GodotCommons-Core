@tool
extends TileMapLayer
class_name LevelTileMapLayer_Damage

@export var TargetLayer: LevelTileMapLayer
@export var health_fraction_remap_curve: Curve

class PerCellData:
	var health: float
	func _init(InLayer: LevelTileMapLayer, in_cell: Vector2i):
		health = InLayer.level_tile_set.get_terrain_data(BetterTerrain.get_cell(InLayer, in_cell)).health

var PerCellDataDictionary: Dictionary[Vector2i, PerCellData]

func get_cell_data(in_cell: Vector2i) -> PerCellData:
	
	if not PerCellDataDictionary.has(in_cell):
		PerCellDataDictionary[in_cell] = PerCellData.new(TargetLayer, in_cell)
	return PerCellDataDictionary[in_cell]

func get_cell_damage_fraction(in_cell: Vector2i) -> float:
	return 1.0 - get_cell_data(in_cell).health / TargetLayer.level_tile_set.get_terrain_data(BetterTerrain.get_cell(TargetLayer, in_cell)).health

func SubtractCellHealth(in_cell: Vector2i, InHealth: float) -> void:
	
	var CellData := get_cell_data(in_cell)
	CellData.health -= InHealth
	
	var damage_fraction := get_cell_damage_fraction(in_cell)
	if health_fraction_remap_curve:
		damage_fraction = health_fraction_remap_curve.sample_baked(damage_fraction)
	
	if damage_fraction > 0.0:
		var DamageTileIndex := floori(damage_fraction * 4.0)
		var AlternativeTile := randi_range(0, 2)
		set_cell(in_cell, 0, Vector2i(DamageTileIndex, 0), AlternativeTile)

func SetCellHealth(in_cell: Vector2i, InHealth: float) -> void:
	get_cell_data(in_cell).health = InHealth

func ClearCellData(in_cell: Vector2i) -> void:
	PerCellDataDictionary.erase(in_cell)
	erase_cell(in_cell)
