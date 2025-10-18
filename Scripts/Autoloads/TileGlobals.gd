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

func GetTileDirection(InLayer: TileMapLayer, InCoords: Vector2) -> int:
	
	var AlternativeTile := InLayer.get_cell_alternative_tile(InCoords)
	
	match AlternativeTile:
		0: return TileDirection.Right
		1: return TileDirection.Left
		2: return TileDirection.Up
		3: return TileDirection.Down
	assert(false, "GetTileDirection() Bad AlternativeTile ID!")
	return TileDirection.Invalid

func ApplyTileDirection(in_cell: Vector2i, InDirection: TileDirection) -> Vector2i:
	
	match InDirection:
		TileDirection.Right: in_cell.x += 1
		TileDirection.Down: in_cell.y -= 1
		TileDirection.Left: in_cell.x -= 1
		TileDirection.Up: in_cell.y += 1
		_: assert(false, "CheckLayout() Bad TileDirection value!")
	return in_cell

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

func GenerateNeighborCellArray(in_cell: Vector2i) -> Array[Vector2i]:
	var OutArray: Array[Vector2i] = []
	for SampleNeighborCell: Vector2i in _OffsetCellArray_AllAngles:
		OutArray.append(in_cell + SampleNeighborCell)
	return OutArray
