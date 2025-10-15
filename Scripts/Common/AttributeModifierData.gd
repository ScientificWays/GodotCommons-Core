extends Resource
class_name AttributeModifierData

enum OperationType
{
	Add,
	Multiply
}

@export var attribute_name: StringName
@export_enum("Add", "Multiply") var operation_type: int
@export var magnitude: float = 1.0
@export var magnitude_per_level_gain: float = 0.0

func get_magnitude(in_level: int) -> float:
	return magnitude + magnitude_per_level_gain * in_level
