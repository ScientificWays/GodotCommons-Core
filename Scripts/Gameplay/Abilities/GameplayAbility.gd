@abstract
@tool
extends Node
class_name GameplayAbility

@export_category("Owner")
var owner_asc: AbilitySystemComponent
#@export var required_pawn_to_activate: bool = true
#@export var should_cancel_on_pawn_changed: bool = true

@export_category("Ability Tags")
@export var ability_tags: Array[StringName]
#@export var block_abilities_with_tags: Array[StringName]
#@export var cancel_abilities_with_tags: Array[StringName]

@export_category("Owner Tags")
@export var owner_granted_tags: Array[StringName]
@export var owner_must_have_tags: Array[StringName]
@export var owner_must_not_have_tags: Array[StringName]

@export_category("Cooldown")
@export var default_cooldown_time: float = 0.0

var _is_active: bool = false:
	set(in_is_active):
		
		if in_is_active != _is_active:
			
			_is_active = in_is_active
			
			if _is_active: apply_owner_tags()
			else: remove_owner_tags()

var current_payload: Variant = null

signal activated()
signal activation_failed()

var cooldown_time_left: float = 0.0
signal cooldown_finished()

func _ready() -> void:
	
	if Engine.is_editor_hint():
		pass
	else:
		pass

func _enter_tree() -> void:
	owner_asc = get_parent()

func _exit_tree() -> void:
	owner_asc = null

func _process(in_delta: float) -> void:
	
	if cooldown_time_left > in_delta:
		cooldown_time_left -= in_delta
	else:
		cooldown_time_left = 0.0
		cooldown_finished.emit()

#func handle_added(in_asc: AbilitySystemComponent) -> void:
#	
#	owner_asc = in_asc
#	#owner_asc.owner_controller.controlled_pawn_changed.connect(_handle_owner_pawn_changed)

#func handle_removed(in_asc: AbilitySystemComponent) -> void:
#	
#	assert(in_asc == owner_asc)
#	
#	#owner_asc.owner_controller.controlled_pawn_changed.disconnect(_handle_owner_pawn_changed)
#	owner_asc = null

#func _handle_owner_pawn_changed() -> void:
#	
#	if should_cancel_on_pawn_changed:
#		cancel_ability()

func is_active() -> bool:
	return _is_active

func get_owner_pawn() -> Pawn2D:
	return owner_asc.owner_pawn

func get_owner_body() -> CharacterBody2D:
	return owner_asc.owner_pawn as Node as CharacterBody2D

func has_tag(in_tag: StringName) -> bool:
	return ability_tags.has(in_tag)

func check_cooldown(in_payload: Variant) -> bool:
	return cooldown_time_left <= 0.0

func check_cost(in_payload: Variant) -> bool:
	return true

func check_tags(in_payload: Variant) -> bool:
	return not owner_asc.tags_container.has_any_tag(owner_must_not_have_tags) \
		and owner_asc.tags_container.has_all_tags(owner_must_have_tags)

func can_activate(in_payload: Variant) -> bool:
	return check_cooldown(in_payload) and check_cost(in_payload) and check_tags(in_payload)

func try_activate(in_payload: Variant = null) -> bool:
	
	if not _is_active and can_activate(in_payload):
		
		#print("Activated ability %s" % self)
		
		_is_active = true
		current_payload = in_payload
		
		last_input_since_activaion = AbilityInput.None
		
		activated.emit()
		
		apply_cost()
		apply_cooldown()
		
		commit_ability()
		return true
	activation_failed.emit()
	return false

func apply_cost() -> void:
	pass

func apply_cooldown() -> void:
	cooldown_time_left = default_cooldown_time

@abstract
func commit_ability() -> void

@abstract
func on_ability_ended(in_was_cancelled: bool) -> void

func end_ability(in_was_cancelled: bool = false) -> bool:
	
	if not _is_active:
		return false
	
	_is_active = false
	current_payload = null
	on_ability_ended(in_was_cancelled)
	return true

func cancel_ability() -> void:
	end_ability(true)

func apply_owner_tags() -> void:
	owner_asc.tags_container.apply_tags(owner_granted_tags)

func remove_owner_tags() -> void:
	owner_asc.tags_container.remove_tags(owner_granted_tags)

func is_input_action_pressed(in_action: StringName) -> bool:
	return owner_asc.owner_pawn.is_input_action_pressed(in_action)

@export_category("Input")
enum AbilityInput
{
	None = 0,
	Press = 1,
	Release = 2
}
var last_input_since_activaion: AbilityInput = AbilityInput.None

signal received_input(in_type: AbilityInput)

func send_ability_input(in_type: AbilityInput) -> void:
	last_input_since_activaion = in_type
	received_input.emit(in_type)
