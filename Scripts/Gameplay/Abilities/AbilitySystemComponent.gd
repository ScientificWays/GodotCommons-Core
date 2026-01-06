extends Node
class_name AbilitySystemComponent

static func try_get_from(in_node: Node) -> AbilitySystemComponent:
	return ModularGlobals.try_get_from(in_node, AbilitySystemComponent)

@export_category("Owner")
@export var owner_pawn: Pawn2D

@export_category("Tags")
@export var tags_container: TagsContainer

@export_category("Animations")
@export var animation_player: AnimationPlayer

signal gameplay_event(in_tag: StringName)

var _abilities_instances: Array[GameplayAbility]

func _ready() -> void:
	
	assert(owner_pawn)
	assert(tags_container)
	
	if animation_player:
		animation_player.remove_animation_library(&"")
	else:
		animation_player = AnimationPlayer.new()
		add_child(animation_player)
	
	#_update_abilities_list()

func _enter_tree() -> void:
	ModularGlobals.init_modular_node(self)

func _exit_tree() -> void:
	ModularGlobals.deinit_modular_node(self)

func _notification(in_what: int) -> void:
	
	if in_what == NOTIFICATION_CHILD_ORDER_CHANGED:
		_update_abilities_list()

func _update_abilities_list() -> void:
	
	_abilities_instances.clear()
	
	for sample_child: Node in get_children():
		if sample_child is GameplayAbility:
			_abilities_instances.append(sample_child)

func give_ability(in_script: GDScript) -> GameplayAbility:
	var new_ability_instance := in_script.new()
	add_child(new_ability_instance)
	return new_ability_instance

func remove_ability(in_ability: GameplayAbility) -> void:
	assert(in_ability.owner_asc == self)
	in_ability.queue_free()

func try_activate_abilities_by_tag(in_tag: StringName, in_payload: Variant = null) -> bool:
	
	var out_success := false
	
	for sample_ability: GameplayAbility in _abilities_instances:
		if sample_ability.has_tag(in_tag):
			var sample_activated := sample_ability.try_activate(in_payload)
			out_success = (out_success or sample_activated)
	return out_success

func try_end_abilities_by_tag(in_tag: StringName, in_cancel: bool = false) -> bool:
	
	var out_success := false
	
	for sample_ability: GameplayAbility in _abilities_instances:
		if sample_ability.has_tag(in_tag):
			var sample_ended := sample_ability.end_ability(in_cancel)
			out_success = (out_success or sample_ended)
	return out_success
