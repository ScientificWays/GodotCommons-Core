extends PhysicsBody2D
class_name Pawn2D

enum Type
{
	Common = 0,
	Boss = 1
}

@export_category("Common")
@export var UniqueName: StringName = &"None"
@export var _DisplayData: ResourceDisplayData
@export var _Type: Type = Type.Common
@export var SpawnValue: float = 1.0
@export var DangerValue: float = 1.0
@export var SizeScale_PerLevelGain: float = 0.0
@export var SizeScale_Image: float = 1.0

@export_category("Health")
@export var HealthDamageReceiver: DamageReceiver

@export_category("Audio")
@export var SoundBankLabel: String = "Pawn"

var _Level: int = 0

var _LastController: PlayerController
var _Controller: PlayerController:
	set(InController):
		
		var OldPlayerCommon := _Controller
		_Controller = InController
		
		if _Controller:
			_LastController = _Controller
		else:
			pass
		ControllerChanged.emit()

signal ControllerChanged()
signal ControllerTapInput(InTapScreenPosition: Vector2, InTapGlobalPosition: Vector2)

func GetSizeScale() -> float:
	return 1.0

func GetImageSizeScale() -> float:
	return SizeScale_Image * (1.0 + SizeScale_PerLevelGain)

func _ready() -> void:
	if HealthDamageReceiver:
		HealthDamageReceiver.ReceiveLethalDamage.connect(OnReceiveLethalDamage)

func Explosion2D_ReceiveImpulse(InExplosion: Explosion2D, InImpulse: Vector2, InOffset: Vector2) -> bool:
	assert(false)
	return false

func OnReceiveLethalDamage(InSource: Node, InDamage: float, InIgnoredImmunityTime: bool):
	HandleLethalDamage()

func HandleLethalDamage():
	queue_free()
