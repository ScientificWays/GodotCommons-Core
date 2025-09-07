extends Node

enum TileDirection
{
	Right = 1,
	Down = -2,
	Left = -1,
	Up = 2,
	Invalid = 0
}

func IsOppositeTileDirections(InA: TileDirection, InB: TileDirection) -> bool:
	return InA == -InB

func GetTileDirection(InTileMap: TileMap, InLayer: int, InCoords: Vector2) -> int:
	
	var AlternativeTile := InTileMap.get_cell_alternative_tile(InLayer, InCoords)
	
	match AlternativeTile:
		0: return TileDirection.Right
		1: return TileDirection.Left
		2: return TileDirection.Up
		3: return TileDirection.Down
	assert(false, "GetTileDirection() Bad AlternativeTile ID!")
	return TileDirection.Invalid

func ApplyTileDirection(InCell: Vector2i, InDirection: TileDirection) -> Vector2i:
	
	match InDirection:
		TileDirection.Right: InCell.x += 1
		TileDirection.Down: InCell.y -= 1
		TileDirection.Left: InCell.x -= 1
		TileDirection.Up: InCell.y += 1
		_: assert(false, "CheckLayout() Bad TileDirection value!")
	return InCell

const _OffsetCellArray_RightAngles: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0)
]

const _OffsetCellArray_AllAngles: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(1, 1),
	Vector2i(-1, -1),
	Vector2i(1, -1),
	Vector2i(-1, 1)
]

func GenerateNeighborCellArray(InCell: Vector2i) -> Array[Vector2i]:
	var OutArray: Array[Vector2i] = []
	for SampleNeighborCell: Vector2i in _OffsetCellArray_AllAngles:
		OutArray.append(InCell + SampleNeighborCell)
	return OutArray
