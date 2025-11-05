extends Node
class_name Pawn2D_ModifierBase

var owner_pawn: Pawn2D

func _ready() -> void:
	owner_pawn.modifiers.append(self)
