extends Area2D
class_name Explosion2D

const BaseRadius: float = 48.0
const BaseDamage: float = 50.0
const BaseImpulse: float = 100.0

static func Spawn(InGlobalPosition: Vector2, InScene: PackedScene, InLevel: int, InRadius: float, InMaxDamage: float, InMaxImpulse: float, InInstigator: Node):
	
	assert(InScene)
	
	var NewExplosion := InScene.instantiate() as Explosion2D
	NewExplosion._Level = InLevel
	NewExplosion._Radius = InRadius
	NewExplosion._MaxDamage = InMaxDamage
	NewExplosion._MaxImpulse = InMaxImpulse
	NewExplosion._Instigator = InInstigator
	NewExplosion.set_position(InGlobalPosition)
	
	WorldGlobals._Level.call_deferred("add_child", NewExplosion)
	return NewExplosion

@export_category("Audio")
@export var SoundBankLabel: String = "Explosion"

@export_category("Synergy")
@export var _SynergyPriority: int = 0

var _Instigator: Node
var _Level: int = 0

var _Radius: float = BaseRadius
var _MaxDamage: float = BaseDamage
var _MaxImpulse: float = BaseImpulse

var DamageReceiverCallableArray: Array[Callable]

func _ready():
	
	reset_physics_interpolation()
