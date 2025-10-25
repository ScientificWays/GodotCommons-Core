extends Node
class_name PawnGlobals_Class

@export var CommonModifiersDictionary: Dictionary = {
	#&"Giant": preload("res://Creatures/Content/Common/Modifiers/Giant.tres"),
	#&"Tiny": preload("res://Creatures/Content/Common/Modifiers/Tiny.tres"),
	#&"Crystal": preload("res://Creatures/Content/Common/Modifiers/Crystal.tres"),
	#&"Blue": preload("res://Creatures/Content/Common/Modifiers/Blue.tres"),
	#&"Red": preload("res://Creatures/Content/Common/Modifiers/Red.tres"),
}

const TeamNone: StringName = &"None"
const TeamPlayer: StringName = &"Player"
const TeamCrystal: StringName = &"Crystal"

var DefaultAttributeValues: Dictionary = {
	Health = -1.0,
	MaxHealth = -1.0,
	MoveSpeedMul = 1.0,
	DamageResistance = 0.0,
	FireDamageMul = 1.0,
	PoisonDamageMul = 1.0,
	RollSpeedAdditive = 0.0,
	RamDamageMul = 1.0,
}

func GetDefaultAttributeValue(in_name: StringName) -> float:
	return DefaultAttributeValues.get(in_name, 0.0)

func _ready():
	pass

func AreTeamsHostile(InA: StringName, InB: StringName) -> bool:
	
	if InA == TeamNone or InB == TeamNone:
		return false
	return InA != InB
