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

@export_category("Abilities")
@export var asc: AbilitySystemComponent

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

@export_category("Input")
@export var pawn_input_actions: Array[StringName] = [
	CommonInputActions.primary_attack,
	CommonInputActions.secondary_attack,
	CommonInputActions.special_attack,
	CommonInputActions.jump,
]
@export var pawn_input_callables: Array[StringName] = [
	&"handle_primary_attack_input",
	&"handle_secondary_attack_input",
	&"handle_special_attack_input",
	&"handle_jump_input",
]

@export_category("Movement")
@export var character_movement: Pawn2D_CharacterMovement

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

signal input_action_handled(in_action_event: InputEvent)

var is_alive: bool = true

var modifiers: Array[Pawn2D_ModifierBase]

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not asc:
			asc = find_child("*bility*ystem*") as AbilitySystemComponent
		if not attribute_set:
			attribute_set = find_child("*ttribute*et*") as AttributeSet
		if not damage_receiver:
			damage_receiver = find_child("*amage*eceiver*") as DamageReceiver
		if not character_movement:
			character_movement = find_child("*arachter*ovement*") as Pawn2D_CharacterMovement
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

##
## Transforms
##
@export_category("Transforms")
@export var sync_aim_with_body_direction: bool = true
@export var sync_body_with_aim_direction: bool = true

var body_direction: Vector2 = Vector2.RIGHT:
	set(in_direction):
		
		in_direction = adjust_body_direction(in_direction)
		
		if not in_direction.is_equal_approx(body_direction):
			body_direction = in_direction
			body_direction_changed.emit()
			if sync_aim_with_body_direction: aim_direction = body_direction
signal body_direction_changed()

func adjust_body_direction(in_direction: Vector2) -> Vector2:
	return in_direction

var aim_direction: Vector2 = Vector2.RIGHT:
	set(in_direction):
		
		if asc.tags_container.has_tag(CommonTags.lock_aim_direction):
			return
		
		in_direction = adjust_aim_direction(in_direction)
		
		if not in_direction.is_equal_approx(aim_direction):
			aim_direction = in_direction
			aim_direction_changed.emit()
			if sync_body_with_aim_direction: body_direction = aim_direction
signal aim_direction_changed()

func adjust_aim_direction(in_direction: Vector2) -> Vector2:
	return in_direction

func turn_to_target(in_target: Node2D) -> void:
	body_direction = (in_target.global_position - global_position).normalized()

func aim_at_target(in_target: Node2D) -> void:
	aim_direction = (in_target.global_position - global_position).normalized()

##
## Input
##
var last_movement_input: Vector2 = Vector2.ZERO
var last_input_action_events: Dictionary[StringName, InputEvent] = {}

func is_input_action_pressed(in_action: StringName) -> bool:
	return last_input_action_events[in_action].is_pressed() if last_input_action_events.has(in_action) else false

func handle_controller_movement_input(in_input: Vector2) -> void:
	
	last_movement_input = in_input
	
	if character_movement:
		character_movement.apply_movement_input(in_input)

func handle_controller_tap_input(in_screen_position: Vector2, in_global_position: Vector2, in_released: bool) -> void:
	controller_tap_input.emit(in_screen_position, in_global_position, in_released)

func _unhandled_controller_input(in_event: InputEvent) -> void:
	
	for sample_index: int in range(pawn_input_actions.size()):
		
		if in_event.is_action(pawn_input_actions[sample_index]):
			
			last_input_action_events[pawn_input_actions[sample_index]] = in_event
			
			if call(pawn_input_callables[sample_index], in_event):
				get_viewport().set_input_as_handled()
				input_action_handled.emit(in_event)
				break

func handle_primary_attack_input(in_event: InputEvent) -> bool:
	return false

func handle_secondary_attack_input(in_event: InputEvent) -> bool:
	return false

func handle_special_attack_input(in_event: InputEvent) -> bool:
	return false

func handle_jump_input(in_event: InputEvent) -> bool:
	if in_event.is_pressed() and not in_event.is_echo():
		return asc.try_activate_abilities_by_tag(CommonTags.jump_ability)
	return false

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

func has_modifier(in_modifier_script: Script) -> bool:
	for sample_modifier: Pawn2D_ModifierBase in modifiers:
		if sample_modifier.get_script() == in_modifier_script:
			return true
	return false
