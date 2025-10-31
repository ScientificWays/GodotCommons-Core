@tool
extends Node
class_name DamageReceiver

const BoundsRadiusMeta: StringName = &"DamageReceiver_BoundsRadius"

static func try_get_from(in_node: Node) -> DamageReceiver:
	return ModularGlobals.try_get_from(in_node, DamageReceiver)

@export_category("Owner")
@export var owner_body_2d: Node2D
@export var owner_attribute_set: AttributeSet

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

signal receive_damage(in_source: Node, in_damage: float, in_ignored_immunity_time: bool)
signal receive_damage_lethal(in_source: Node, in_damage: float, in_ignored_immunity_time: bool)

func _ready():
	
	if Engine.is_editor_hint():
		if not owner_body_2d:
			owner_body_2d = get_parent()
		if not owner_attribute_set:
			owner_attribute_set = get_parent().find_child("*?ttribute*")
	else:
		assert(owner_body_2d)
		#assert(owner_attribute_set)
		
		if SpawnDamageImmunityDuration > 0.0:
			DamageImmunityEndTime = Time.get_unix_time_from_system() + SpawnDamageImmunityDuration

func _enter_tree():
	if not Engine.is_editor_hint():
		ModularGlobals.init_modular_node(self)

func _exit_tree():
	if not Engine.is_editor_hint():
		ModularGlobals.deinit_modular_node(self)

func get_health() -> float:
	return owner_attribute_set.get_attribute_current_value(AttributeSet.Health) if owner_attribute_set else 0.0

func get_max_health() -> float:
	return owner_attribute_set.get_attribute_current_value(AttributeSet.MaxHealth) if owner_attribute_set else 0.0

func get_health_fraction() -> float:
	
	if owner_attribute_set.has_attribute(AttributeSet.Health) and owner_attribute_set.has_attribute(AttributeSet.MaxHealth):
		return get_health() / get_max_health()
	else:
		return -1.0

func set_health(in_value: float) -> void:
	return owner_attribute_set.set_attribute_base_value(AttributeSet.Health, clampf(in_value, 0.0, get_max_health()))

func set_max_health(in_value: float) -> void:
	return owner_attribute_set.set_attribute_base_value(AttributeSet.MaxHealth, in_value)

func IsDamageLethal(in_damage: float) -> bool:
	return get_health() <= in_damage

func CanReceiveDamage(in_source: Node, in_instigator: Node, in_damage: float, InDamageType: int, in_should_ignore_immunity_time: bool) -> bool:
	
	var CurrentTime := Time.get_unix_time_from_system()
	if not in_should_ignore_immunity_time and CurrentTime < DamageImmunityEndTime:
		return false
	else:
		return InDamageType & DamageImmunityMask == 0

func AdjustReceivedDamage(in_source: Node, in_instigator: Node, in_damage: float, InDamageType: int, in_should_ignore_immunity_time: bool) -> float:
	return in_damage

## Can be called in physics frame in BarrelPawn.HandleImpactWith()
func try_receive_damage(in_source: Node, in_instigator: Node, in_damage: float, InDamageType: int, in_should_ignore_immunity_time: bool) -> bool:
	
	in_damage = AdjustReceivedDamage(in_source, in_instigator, in_damage, InDamageType, in_should_ignore_immunity_time)
	assert(in_damage > 0.0)
	
	if CanReceiveDamage(in_source, in_instigator, in_damage, InDamageType, in_should_ignore_immunity_time):
		
		LastDamage = in_damage
		LastDamageTime = Time.get_unix_time_from_system()
		LastDamageSource = in_source
		LastDamageInstigator = in_instigator
		LastDamageType = InDamageType
		DamageImmunityEndTime = LastDamageTime + PostDamageImmunityDuration
		
		HandleReceivedDamage(in_should_ignore_immunity_time)
		receive_damage.emit(in_source, in_damage, in_should_ignore_immunity_time)
		
		if ReceivedLethalDamage:
			receive_damage_lethal.emit(in_source, in_damage, in_should_ignore_immunity_time)
		GameGlobals.post_damage_receiver_receive_damage.emit(self, in_source, in_damage, in_should_ignore_immunity_time)
		return true
	return false

func CalcLastDamageImpulse2D() -> Vector2:
	
	if not is_instance_valid(LastDamageSource):
		return Vector2.ZERO
	
	var Source2D := LastDamageSource as Node2D
	if not Source2D:
		return Vector2.ZERO
	
	var FromSourceDirection := Source2D.global_position.direction_to(owner_body_2d.global_position)
	return FromSourceDirection * LastDamage * DamageToImpulseMagnitudeMul

func HandleReceivedDamage(in_ignored_immunity_time: bool):
	ReceivedLethalDamage = IsDamageLethal(LastDamage)
	set_health(get_health() - LastDamage)

func AddDamageImmunityTo(InMask: int):
	DamageImmunityMask |= InMask

func RemoveDamageImmunityFrom(InMask: int):
	DamageImmunityMask &= ~InMask
