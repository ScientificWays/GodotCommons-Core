@tool
extends PhysicsBody2D
class_name Pawn2D

enum Type
{
	Common = 0,
	Boss = 1
}

@export_category("Common")
@export var unique_name: StringName = &"None"
@export var display_data: ResourceDisplayData
@export var _Type: Type = Type.Common
@export var spawn_value: float = 1.0
@export var danger_value: float = 1.0
@export var size_scale: float = 1.0
@export var size_scale_per_level_gain: float = 0.0
@export var size_scale_image: float = 1.0
#@export var is_flying: bool = false

@export_category("Attributes")
@export var attribute_set: AttributeSet
@export var max_health: float = 100.0
@export var init_health_bar: bool = false
@export var health_bar_size_mul: float = 1.0

@export_category("Damage")
@export var damage_receiver: DamageReceiver
@export var damage_sound_event: SoundEventResource
@export var damage_animation_player: AnimationPlayer
@export var damage_animation_name: StringName = &"hurt"
@export var lethal_damage_sound_event: SoundEventResource
@export var die_on_lethal_damage: bool = true
@export var remove_on_death: bool = true

@export_category("Movement")
@export var character_movement: Pawn2D_CharacterMovement

@export_category("AI")
@export var bt_player: BTPlayer
#@export var chase_target_var: StringName = &"chase_target"

@export_category("Audio")
@export var sound_bank_label: String = "Pawn"
@export var override_level_music: MusicTrackResource
@export var set_override_level_music_on_spawn: bool = true
@export var reset_override_level_music_on_death: bool = false
@export var add_override_level_music_delay: float = 0.0
@export var remove_override_level_music_delay: float = 0.0

@export_category("Drop")
@export var death_drop_scene: PackedScene# = preload("res://Scenes/Items/Experience001.tscn")
@export var death_drop_num_min_max: Vector2i = Vector2i.ONE

var _level: int = 0

var last_controller: PlayerController
var controller: PlayerController:
	set(InController):
		
		controller = InController
		
		if is_instance_valid(controller):
			set_meta(PlayerController.PlayerControllerMeta, controller)
			last_controller = controller
		else:
			remove_meta(PlayerController.PlayerControllerMeta)
		
		controller_changed.emit()

signal controller_changed()
signal controller_tap_input(in_tap_screen_position: Vector2, in_tap_global_position: Vector2)

signal died(in_immediately: bool)

var is_alive: bool = true

var modifiers: Array[Pawn2D_ModifierBase]

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not attribute_set:
			attribute_set = find_child("*ttribute*et*") as AttributeSet
		if not damage_receiver:
			damage_receiver = find_child("*amage*eceiver*") as DamageReceiver
		if not character_movement:
			character_movement = find_child("*arachter*ovement*") as Pawn2D_CharacterMovement
		if not bt_player:
			bt_player = find_child("???layer") as BTPlayer ## "for BTPlayer-like"
		if not bt_player:
			bt_player = find_child("??_?layer") as BTPlayer ## "for bt_player-like"
	else:
		if damage_receiver:
			damage_receiver.receive_damage.connect(_on_receive_damage)
			damage_receiver.receive_damage_lethal.connect(_on_receive_damage_lethal)
			
			assert(damage_receiver.owner_attribute_set)
			damage_receiver.set_max_health(max_health)
			damage_receiver.set_health(max_health)
		
		if init_health_bar:
			PawnGlobals.init_pawn_healthbar.emit.call_deferred(self)
		
		if override_level_music and set_override_level_music_on_spawn:
			WorldGlobals._level.set_override_level_music(override_level_music)
		
		PawnGlobals.pawn_spawned.emit(self)

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		if override_level_music:
			WorldGlobals._level.add_override_level_music_source(self, add_override_level_music_delay)

func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		if override_level_music:
			WorldGlobals._level.remove_override_level_music_source(self, remove_override_level_music_delay)

func handle_controller_tap_input(in_screen_position: Vector2, in_global_position: Vector2, in_released: bool) -> void:
	controller_tap_input.emit(in_screen_position, in_global_position, in_released)

var last_movement_input: Vector2 = Vector2.ZERO

func handle_controller_movement_input(in_input: Vector2) -> void:
	
	last_movement_input = in_input
	
	if character_movement:
		character_movement.apply_movement_input(in_input)

func handle_controller_jump_input(in_pressed: bool) -> void:
	if character_movement:
		character_movement.apply_jump_input(1.0 if in_pressed else 0.0)

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

func _on_receive_damage_lethal(in_source: Node, in_damage: float, in_ignored_immunity_time: bool):
	handle_died(false)

func _on_receive_damage(in_source: Node, in_damage: float, in_ignored_immunity_time: bool):
	
	if not damage_receiver.received_lethal_damage:
		
		if damage_sound_event:
			AudioGlobals.try_play_sound_at_global_position(sound_bank_label, damage_sound_event, global_position)
		
		if damage_animation_player:
			damage_animation_player.stop()
			damage_animation_player.play(damage_animation_name)

func kill(in_immediately: bool = false) -> void:
	handle_died(in_immediately)

func handle_died(in_immediately: bool) -> void:
	
	if not is_alive:
		return
	
	if override_level_music and reset_override_level_music_on_death:
		WorldGlobals._level.reset_override_level_music()
	
	is_alive = false
	died.emit(in_immediately)
	PawnGlobals.pawn_died.emit(self, in_immediately)
	
	var sound_event := lethal_damage_sound_event if lethal_damage_sound_event else damage_sound_event
	if sound_event:
		AudioGlobals.try_play_sound_at_global_position(sound_bank_label, sound_event, global_position)
	
	handle_death_drop()
	
	if remove_on_death:
		queue_free()

func handle_death_drop() -> void:
	
	if death_drop_scene:
		
		var spawn_num := randi_range(death_drop_num_min_max.x, death_drop_num_min_max.y)
		for sample_index: int in range(spawn_num):
			
			var death_drop := death_drop_scene.instantiate() as Node2D
			
			var spawn_direction := Vector2.from_angle(randf_range(0.0, TAU))
			death_drop.position = position + (spawn_direction * float(sample_index) * 8.0)
			add_sibling.call_deferred(death_drop)
			
			if death_drop is RigidBody2D:
				death_drop.ready.connect(death_drop.apply_central_impulse.bind(spawn_direction / death_drop.mass * randf_range(0.2, 0.8)))

func teleport_to(in_position: Vector2, in_rotation: float = global_rotation, in_reset_camera: bool = false) -> bool:
	
	var new_transform := Transform2D(in_rotation, in_position)
	
	transform = new_transform ## For CharacterBody2D pawns
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, new_transform)
	
	if controller:
		controller.ControlledPawnTeleport.emit(in_reset_camera)
	return true

#func override_chase_target(in_target: Node2D) -> void:
#	
#	assert(bt_player)
#	bt_player.blackboard.set_var(chase_target_var, in_target)

func has_modifier(in_modifier_script: Script) -> bool:
	for sample_modifier: Pawn2D_ModifierBase in modifiers:
		if sample_modifier.get_script() == in_modifier_script:
			return true
	return false
