extends Node
class_name PawnGlobals_Class

const team_none: StringName = &"None"
const team_player: StringName = &"Player"

var default_attribute_values: Dictionary = {
	Health = -1.0,
	MaxHealth = -1.0,
	MoveSpeedMul = 1.0,
	DamageResistance = 0.0,
	FireDamageMul = 1.0,
	PoisonDamageMul = 1.0,
	RollSpeedAdditive = 0.0,
	RamDamageMul = 1.0,
}

signal pawn_spawned(in_pawn: Pawn2D)
signal pawn_died(in_pawn: Pawn2D, in_immediately: bool)

signal init_pawn_healthbar(in_pawn: Pawn2D)

func get_default_attribute_value(in_name: StringName) -> float:
	return default_attribute_values.get(in_name, 0.0)

func _ready():
	pass

func are_teams_hostile(in_a: StringName, in_b: StringName) -> bool:
	
	if in_a == team_none or in_b == team_none:
		return false
	return in_a != in_b
