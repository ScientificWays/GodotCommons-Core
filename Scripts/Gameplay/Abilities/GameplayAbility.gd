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

signal activated()
signal activation_failed()

var cooldown_time_left: float = 0.0

func _ready() -> void:
	pass

func _process(in_delta: float) -> void:
	
	if cooldown_time_left > in_delta:
		cooldown_time_left -= in_delta
	else:
		cooldown_time_left = 0.0

func handle_added(in_asc: AbilitySystemComponent) -> void:
	
	owner_asc = in_asc
	#owner_asc.owner_controller.controlled_pawn_changed.connect(_handle_owner_pawn_changed)

func handle_removed(in_asc: AbilitySystemComponent) -> void:
	
	assert(in_asc == owner_asc)
	
	#owner_asc.owner_controller.controlled_pawn_changed.disconnect(_handle_owner_pawn_changed)
	owner_asc = null

#func _handle_owner_pawn_changed() -> void:
#	
#	if should_cancel_on_pawn_changed:
#		cancel_ability()

func has_tag(in_tag: StringName) -> bool:
	return ability_tags.has(in_tag)

func can_activate() -> bool:
	
	if cooldown_time_left > 0.0:
		return false
	
	#if required_pawn_to_activate and owner_asc.owner_pawn == null:
	#	return false
	
	if owner_asc.tags_container.has_any_tag(owner_must_not_have_tags):
		return false
	
	if not owner_asc.tags_container.has_all_tags(owner_must_have_tags):
		return false
	
	return true

func try_activate() -> bool:
	
	if not _is_active and can_activate():
		
		_is_active = true
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

func on_ability_ended(in_was_cancelled: bool) -> void:
	pass

func end_ability(in_was_cancelled: bool = false) -> void:
	_is_active = false
	on_ability_ended(in_was_cancelled)

func cancel_ability() -> void:
	end_ability(true)

func apply_owner_tags() -> void:
	owner_asc.tags_container.apply_tags(owner_granted_tags)

func remove_owner_tags() -> void:
	owner_asc.tags_container.remove_tags(owner_granted_tags)
