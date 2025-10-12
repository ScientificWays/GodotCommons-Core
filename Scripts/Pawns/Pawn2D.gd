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
@export var LethalDamageSoundEvent: SoundEventResource

@export_category("Audio")
@export var sound_bank_label: String = "Pawn"

var _level: int = 0

var _LastController: PlayerController
var _Controller: PlayerController:
	set(InController):
		
		_Controller = InController
		
		if is_instance_valid(_Controller):
			set_meta(PlayerController.PlayerControllerMeta, _Controller)
			_LastController = _Controller
		else:
			remove_meta(PlayerController.PlayerControllerMeta)
		
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

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	assert(false)
	return false

func OnReceiveLethalDamage(in_source: Node, in_damage: float, InIgnoredImmunityTime: bool):
	HandleLethalDamage()

func HandleLethalDamage():
	
	if LethalDamageSoundEvent:
		AudioGlobals.try_play_sound_at_global_position(sound_bank_label, LethalDamageSoundEvent, global_position)
	
	queue_free()

func TeleportTo(InPosition: Vector2) -> bool:
	
	var NewTransform := global_transform
	NewTransform.origin = InPosition
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, NewTransform)
	
	if _Controller:
		_Controller.ControlledPawnTeleport.emit()
	return true
