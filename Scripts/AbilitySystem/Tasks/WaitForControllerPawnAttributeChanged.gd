extends Node
class_name WaitForControllerPawnAttributeChanged

func _init(in_outer: Node, in_controller: PlayerController, in_attribute: StringName) -> void:
	target_controller = in_controller
	target_attribute = in_attribute
	in_outer.add_child(self)

signal attribute_changed(in_old_value: float, in_new_value: float)

var target_controller: PlayerController
var target_attribute: StringName

var target_attribute_set: AttributeSet

func _ready() -> void:
	assert(target_controller)
	_on_controlled_pawn_changed()

func _enter_tree() -> void:
	assert(target_controller)
	target_controller.controlled_pawn_changed.connect(_on_controlled_pawn_changed)
	_on_controlled_pawn_changed()

func _exit_tree() -> void:
	if target_controller:
		target_controller.controlled_pawn_changed.disconnect(_on_controlled_pawn_changed)

func _on_controlled_pawn_changed() -> void:
	
	if target_attribute_set:
		target_attribute_set.get_or_init_attribute(target_attribute).current_value_changed.disconnect(_on_attribute_changed)
	
	var new_pawn := target_controller.controlled_pawn
	if new_pawn and not new_pawn.is_node_ready():
		await new_pawn.ready
	
	target_attribute_set = AttributeSet.try_get_from(new_pawn)
	
	if target_attribute_set:
		target_attribute_set.get_or_init_attribute(target_attribute).current_value_changed.connect(_on_attribute_changed)

func _on_attribute_changed(in_old_value: float, in_new_value: float) -> void:
	attribute_changed.emit(in_old_value, in_new_value)
