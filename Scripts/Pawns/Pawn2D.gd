@tool
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
@export var size_scale: float = 1.0
@export var size_scale_per_level_gain: float = 0.0
@export var size_scale_image: float = 1.0

@export_category("Attributes")
@export var max_health: float = 10.0
@export var attribute_set: AttributeSet

@export_category("Damage")
@export var damage_receiver: DamageReceiver
@export var LethalDamageSoundEvent: SoundEventResource
@export var die_on_lethal_damage: bool = true
@export var remove_on_death: bool = true

@export_category("Movement")
@export var character_movement: Pawn2D_CharacterMovement

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

signal died()

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not attribute_set:
			attribute_set = find_child("*ttribute*et*")
		if not damage_receiver:
			damage_receiver = find_child("*amage*eceiver*")
	else:
		if damage_receiver:
			
			damage_receiver.ReceiveLethalDamage.connect(OnReceiveLethalDamage)
			
			assert(damage_receiver.owner_attribute_set)
			damage_receiver.set_max_health(max_health)
			damage_receiver.set_health(max_health)

func get_size_scale() -> float:
	return size_scale + size_scale_per_level_gain * _level

func get_image_size_scale() -> float:
	return size_scale_image + size_scale_per_level_gain * _level

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	
	if character_movement:
		character_movement.launch(in_impulse)
		return true
	else:
		return false

func DamageArea2D_receive_impulse(in_damage_area: DamageArea2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	
	if character_movement:
		character_movement.launch(in_impulse)
		return true
	else:
		return false

func OnReceiveLethalDamage(in_source: Node, in_damage: float, in_ignored_immunity_time: bool):
	handle_died()

func kill() -> void:
	handle_died()

var has_died: bool = false

func handle_died() -> void:
	
	if has_died:
		return
	
	has_died = true
	died.emit()
	
	if LethalDamageSoundEvent:
		AudioGlobals.try_play_sound_at_global_position(sound_bank_label, LethalDamageSoundEvent, global_position)
	
	if remove_on_death:
		queue_free()

func teleport_to(in_position: Vector2, in_rotation: float = global_rotation, in_reset_camera: bool = false) -> bool:
	
	var new_transform := Transform2D(in_rotation, in_position)
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, new_transform)
	
	if _Controller:
		_Controller.ControlledPawnTeleport.emit(in_reset_camera)
	return true
