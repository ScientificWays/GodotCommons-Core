extends Node
class_name WaitForControllerPawnReceiveDamage

func _init(in_outer: Node, in_controller: PlayerController) -> void:
	target_controller = in_controller
	in_outer.add_child.call_deferred(self)

signal receive_damage(in_source: Node, in_damage: float, in_ignored_immunity_time: bool)
signal receive_damage_lethal(in_source: Node, in_damage: float, in_ignored_immunity_time: bool)

var target_controller: PlayerController
var target_damage_receiver: DamageReceiver

func _ready() -> void:
	assert(target_controller)

func _enter_tree() -> void:
	assert(target_controller)
	target_controller.controlled_pawn_changed.connect(_on_controlled_pawn_changed)
	_on_controlled_pawn_changed()

func _exit_tree() -> void:
	if target_controller:
		target_controller.controlled_pawn_changed.disconnect(_on_controlled_pawn_changed)

func _on_controlled_pawn_changed() -> void:
	
	if target_damage_receiver:
		target_damage_receiver.receive_damage.disconnect(_on_receive_damage)
		target_damage_receiver.receive_damage_lethal.disconnect(_on_receive_damage_lethal)
	
	var new_pawn := target_controller.controlled_pawn
	if new_pawn and not new_pawn.is_node_ready():
		await new_pawn.ready
	
	target_damage_receiver = DamageReceiver.try_get_from(new_pawn)
	
	if target_damage_receiver:
		target_damage_receiver.receive_damage.connect(_on_receive_damage)
		target_damage_receiver.receive_damage_lethal.connect(_on_receive_damage_lethal)

func _on_receive_damage(in_source: Node, in_damage: float, in_ignored_immunity_time: bool) -> void:
	receive_damage.emit(in_source, in_damage, in_ignored_immunity_time)

func _on_receive_damage_lethal(in_source: Node, in_damage: float, in_ignored_immunity_time: bool) -> void:
	receive_damage_lethal.emit(in_source, in_damage, in_ignored_immunity_time)
