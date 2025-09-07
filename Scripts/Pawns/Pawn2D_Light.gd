extends PointLight2D
class_name Pawn2D_Light

@export var OwnerPawn: Pawn2D

func Init() -> void:
	
	assert(OwnerPawn)
	
