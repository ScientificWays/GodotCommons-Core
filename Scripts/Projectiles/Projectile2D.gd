extends RigidBody2D
class_name Projectile2D

static func Spawn(InTransform: Transform2D, InScene: PackedScene, InLevel: int, InInstigator: Node, InParent: Node = WorldGlobals._Level._YSorted) -> Projectile2D:
	
	assert(InScene)
	var NewProjectile := InScene.instantiate() as Projectile2D
	NewProjectile._Level = InLevel
	NewProjectile._Instigator = InInstigator
	NewProjectile.transform = InTransform
	InParent.add_child.call_deferred(NewProjectile)
	return NewProjectile

@export_category("Size")
@export var SizeMul: float = 1.0
@export var SizeMul_PerLevelGain: float = 0.0
@export var SizeMulMassScaleFactor: float = 2.0

@export_category("Audio")
@export var SoundBankLabel: String = "Projectile"

func GetSizeMul() -> float:
	return SizeMul + SizeMul_PerLevelGain * _Level

##
## Instigator
##
var _Instigator: Node = null:
	set(InInstigator):
		if _Instigator:
			_Instigator.tree_exited.disconnect(OnInstigatorExitedTree)
		_Instigator = InInstigator
		if _Instigator:
			_Instigator.tree_exited.connect(OnInstigatorExitedTree)

func OnInstigatorExitedTree():
	_Instigator = null

var _Level: int = 0
var _Power: float = 1.0

func _ready() -> void:
	
	var SizeMul := GetSizeMul()
	var ScaledSizeMul := SizeMul * _Power
	
	mass *= pow(SizeMul, SizeMulMassScaleFactor)
	
	if _Instigator is PhysicsBody2D:
		add_collision_exception_with(_Instigator)
		GameGlobals.SpawnOneShotTimerFor(self, func():
			if is_instance_valid(_Instigator):
				remove_collision_exception_with(_Instigator), 1.0)
	
	if MaxLifetime > 0.0:
		SetLifetime(MaxLifetime)

##
## Lifetime
##
@export_category("Lifetime")
@export var MaxLifetime: float = -1.0

var _LifetimeTimer: Timer

func SetLifetime(InLifetime: float):
	
	if InLifetime > 0.0:
		if not _LifetimeTimer:
			_LifetimeTimer = GameGlobals.SpawnOneShotTimerFor(self, OnLifetimeTimerTimeout, InLifetime)
	else:
		OnLifetimeTimerTimeout.call_deferred()

func OnLifetimeTimerTimeout():
	HandleRemoveFromScene(RemoveReason.Lifetime)

##
## Remove
##
enum RemoveReason
{
	Default = 0,
	Hit = 1,
	Damage = 2,
	Lifetime = 3,
	Detonate = 4
}
signal PreRemovedFromScene(InReason: RemoveReason)

func HandleRemoveFromScene(InReason: RemoveReason):
	
	PreRemovedFromScene.emit(InReason)
	
	queue_free()
