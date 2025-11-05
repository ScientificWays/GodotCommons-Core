extends Node
class_name AttributeSet

const Health: StringName = &"Health"
const MaxHealth: StringName = &"MaxHealth"
const MoveSpeedMul: StringName = &"MoveSpeedMul"
const RamDamageMul: StringName = &"RamDamageMul"
const DamageResistance: StringName = &"DamageResistance"
const HighDamageResistance: StringName = &"HighDamageResistance"
const FireDamageMul: StringName = &"FireDamageMul"
const PoisonDamageMul: StringName = &"PoisonDamageMul"
const RollSpeedAdditive: StringName = &"RollSpeedAdditive"

static func try_get_from(in_node: Node) -> AttributeSet:
	return ModularGlobals.try_get_from(in_node, AttributeSet)

class AttributeData:
	
	var base_value: float:
		set(in_value):
			base_value = in_value
			reset()
	
	var current_value: float:
		set(in_value):
			var old_value = current_value
			current_value = in_value
			current_value_changed.emit(old_value, current_value)
	
	signal current_value_changed(in_old_value: float, in_new_value: float)
	
	func _init(in_value: float):
		base_value = in_value
		reset()
	
	func reset() -> void:
		current_value = base_value

var attributes_dictionary: Dictionary[StringName, AttributeData] = {}

signal base_value_set()

func _ready() -> void:
	pass

func _enter_tree():
	ModularGlobals.init_modular_node(self)

func _exit_tree():
	ModularGlobals.deinit_modular_node(self)

func has_attribute(in_name: StringName):
	return attributes_dictionary.has(in_name)

func get_attribute_current_value(in_name: StringName) -> float:
	if has_attribute(in_name):
		return attributes_dictionary[in_name].current_value
	return PawnGlobals.get_default_attribute_value(in_name)

func get_or_init_attribute(in_name: StringName) -> AttributeData:
	
	if not attributes_dictionary.has(in_name):
		attributes_dictionary[in_name] = AttributeData.new(PawnGlobals.get_default_attribute_value(in_name))
	return attributes_dictionary[in_name]

func set_attribute_base_value(in_name: StringName, in_value: float) -> void:
	var SampleAttribute := get_or_init_attribute(in_name)
	SampleAttribute.base_value = in_value
	base_value_set.emit()

func add_attribute_base_value(in_name: StringName, in_value: float) -> void:
	var SampleAttribute := get_or_init_attribute(in_name)
	set_attribute_base_value(in_name, SampleAttribute.base_value + in_value)

func reset_all() -> void:
	for sample_attribute_name: StringName in attributes_dictionary.keys():
		attributes_dictionary[sample_attribute_name].reset()
