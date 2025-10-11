extends Node
class_name DamageReceiver

const BoundsRadiusMeta: StringName = &"DamageReceiver_BoundsRadius"

static func try_get_from(in_node: Node) -> DamageReceiver:
	return ModularGlobals.try_get_from(in_node, DamageReceiver)

@export_category("Owner")
@export var OwnerBody2D: Node2D
@export var OwnerAttributes: AttributeSet

@export_category("Damage")
const DamageType_Any: int = 0
const DamageType_MeleeHit: int = 1
const DamageType_RangedHit: int = 2
const DamageType_Explosion: int = 4
const DamageType_Fire: int = 8
const DamageType_Poison: int = 16
const DamageType_Impact: int = 32
const DamageType_Fall: int = 64
@export_flags("MeleeHit", "RangedHit", "Explosion", "Fire", "Poison", "Impact", "Fall") var DamageImmunityMask: int = 0
@export var DamageToImpulseMagnitudeMul: float = 1.0

@export var SpawnDamageImmunityDuration: float = 0.0
@export var PostDamageImmunityDuration: float = 0.0

var LastDamage: float
var LastDamageTime: float
var LastDamageSource: Node
var LastDamageInstigator: Node
var LastDamageType: int

func TryGetLastDamagePosition(InPrioritiseInstigator: bool) -> Vector2:
	if InPrioritiseInstigator and is_instance_valid(LastDamageInstigator) and LastDamageInstigator is Node2D:
		return LastDamageInstigator.global_position
	elif is_instance_valid(LastDamageSource):
		return LastDamageSource.global_position
	elif is_inside_tree() and get_parent() is Node:
		return get_parent().global_position
	return Vector2.ZERO

var DamageImmunityEndTime: float = 0.0
var ReceivedLethalDamage: bool = false

signal ReceiveDamage(in_source: Node, InDamage: float, InIgnoredImmunityTime: bool)
signal ReceiveLethalDamage(in_source: Node, InDamage: float, InIgnoredImmunityTime: bool)

func _ready():
	
	assert(OwnerAttributes)
	
	if SpawnDamageImmunityDuration > 0.0:
		DamageImmunityEndTime = Time.get_unix_time_from_system() + SpawnDamageImmunityDuration

func _enter_tree():
	ModularGlobals.init_modular_node(self)

func _exit_tree():
	ModularGlobals.deinit_modular_node(self)

func GetHealth() -> float:
	return OwnerAttributes.GetAttributeCurrentValue(AttributeSet.Health)

func GetMaxHealth() -> float:
	return OwnerAttributes.GetAttributeCurrentValue(AttributeSet.MaxHealth)

func IsDamageLethal(InDamage: float) -> bool:
	return GetHealth() <= InDamage

func CanReceiveDamage(in_source: Node, InInstigator: Node, InDamage: float, InDamageType: int, InShouldIgnoreImmunityTime: bool) -> bool:
	
	var CurrentTime := Time.get_unix_time_from_system()
	if not InShouldIgnoreImmunityTime and CurrentTime < DamageImmunityEndTime:
		return false
	else:
		return InDamageType & DamageImmunityMask == 0

func AdjustReceivedDamage(in_source: Node, InInstigator: Node, InDamage: float, InDamageType: int, InShouldIgnoreImmunityTime: bool) -> float:
	return InDamage

## Can be called in physics frame in BarrelPawn.HandleImpactWith()
func TryReceiveDamage(in_source: Node, InInstigator: Node, InDamage: float, InDamageType: int, InShouldIgnoreImmunityTime: bool) -> bool:
	
	InDamage = AdjustReceivedDamage(in_source, InInstigator, InDamage, InDamageType, InShouldIgnoreImmunityTime)
	assert(InDamage > 0.0)
	
	if CanReceiveDamage(in_source, InInstigator, InDamage, InDamageType, InShouldIgnoreImmunityTime):
		
		LastDamage = InDamage
		LastDamageTime = Time.get_unix_time_from_system()
		LastDamageSource = in_source
		LastDamageInstigator = InInstigator
		LastDamageType = InDamageType
		DamageImmunityEndTime = LastDamageTime + PostDamageImmunityDuration
		
		HandleReceivedDamage(InShouldIgnoreImmunityTime)
		ReceiveDamage.emit(in_source, InDamage, InShouldIgnoreImmunityTime)
		
		if ReceivedLethalDamage:
			ReceiveLethalDamage.emit(in_source, InDamage, InShouldIgnoreImmunityTime)
		return true
	return false

func CalcLastDamageImpulse2D() -> Vector2:
	
	if not is_instance_valid(LastDamageSource):
		return Vector2.ZERO
	
	var Source2D := LastDamageSource as Node2D
	if not Source2D:
		return Vector2.ZERO
	
	var FromSourceDirection := Source2D.global_position.direction_to(OwnerBody2D.global_position)
	return FromSourceDirection * LastDamage * DamageToImpulseMagnitudeMul

func HandleReceivedDamage(InIgnoredImmunityTime: bool):
	
	ReceivedLethalDamage = IsDamageLethal(LastDamage)
	
	var Health := GetHealth()
	var MaxHealth := GetMaxHealth()
	Health = clampf(Health - LastDamage, 0.0, MaxHealth)

func AddDamageImmunityTo(InMask: int):
	DamageImmunityMask |= InMask

func RemoveDamageImmunityFrom(InMask: int):
	DamageImmunityMask &= ~InMask
