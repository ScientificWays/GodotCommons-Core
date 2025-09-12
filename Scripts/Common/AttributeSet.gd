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

static func TryGetFrom(InNode: Node) -> AttributeSet:
	return ModularGlobals.TryGetFrom(InNode, AttributeSet)

func _enter_tree():
	ModularGlobals.InitModularNode(self)

func _exit_tree():
	ModularGlobals.DeInitModularNode(self)

class AttributeData:
	
	var BaseValue: float
	var CurrentValue: float:
		set(InValue):
			var OldValue = CurrentValue
			CurrentValue = InValue
			CurrentValueChanged.emit(OldValue, CurrentValue)
	
	signal CurrentValueChanged(InOldValue: float, InNewValue: float)
	
	func _init(InValue: float):
		BaseValue = InValue
		Reset()
	
	func Reset() -> void:
		CurrentValue = BaseValue

var AttributesDictionary: Dictionary[StringName, AttributeData] = {}

func HasAttribute(InName: StringName):
	return AttributesDictionary.has(InName)

func GetAttributeCurrentValue(InName: StringName) -> float:
	if HasAttribute(InName):
		return AttributesDictionary[InName].CurrentValue
	return PawnGlobals.GetDefaultAttributeValue(InName)

func GetOrInitAttribute(InName: StringName) -> AttributeData:
	
	if not AttributesDictionary.has(InName):
		AttributesDictionary[InName] = AttributeData.new(PawnGlobals.GetDefaultAttributeValue(InName))
	return AttributesDictionary[InName]

func SetAttributeBaseValue(InName: StringName, InValue: float) -> void:
	var SampleAttribute := GetOrInitAttribute(InName)
	SampleAttribute.BaseValue = InValue
	RecalcAttributes()

func AddAttributeBaseValue(InName: StringName, InValue: float) -> void:
	var SampleAttribute := GetOrInitAttribute(InName)
	SetAttributeBaseValue(InName, SampleAttribute.BaseValue + InValue)

signal PostRecalcAttributes()

func RecalcAttributes() -> void:
	
	for SampleAttributeName in AttributesDictionary.keys():
		AttributesDictionary[SampleAttributeName].Reset()
	
	#for SampleInstance: StatusEffectInstance in StatusEffectInstanceArray:
	#	SampleInstance.HandleRecalcAttributes()
	PostRecalcAttributes.emit()
