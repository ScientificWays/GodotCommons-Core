extends AnimationPlayer
class_name FallTriggerTile_Sequence

const is_falling_meta: StringName = &"FallTriggerArea2D_is_falling"

static func try_get_from(in_node: Node) -> FallTriggerTile_Sequence:
	return ModularGlobals.try_get_from(in_node, FallTriggerTile_Sequence)

@export_category("Animation")
@export var fall_animation_name: StringName = &"fall"

@export_category("Impact")
@export var fall_damage: float = 1000.0
@export var fallback_to_remove_owner_on_finish: bool = true

signal sequence_triggered(in_source: Node)
signal sequence_failed(in_source: Node)
signal sequence_finished(in_source: Node)

var fall_target: Node2D

func _ready() -> void:
	pass

func _notification(in_what: int) -> void:
	
	if in_what == NOTIFICATION_PARENTED:
		fall_target = get_parent()
	elif in_what == NOTIFICATION_UNPARENTED:
		fall_target = null

func _enter_tree() -> void:
	ModularGlobals.init_modular_node(self, FallTriggerTile_Sequence, fall_target)

func _exit_tree() -> void:
	ModularGlobals.deinit_modular_node(self, FallTriggerTile_Sequence, fall_target)

func try_trigger_sequence(in_source: Node) -> bool:
	
	if fall_target.get_meta(is_falling_meta, false):
		sequence_failed.emit()
		return false
	
	animation_finished.connect(finish_sequence.bind(in_source), Object.CONNECT_ONE_SHOT)
	
	fall_target.set_meta(is_falling_meta, true)
	play(fall_animation_name)
	
	sequence_triggered.emit(in_source)
	return true

func finish_sequence(in_animation_name: StringName, in_source: Node) -> void:
	
	assert(in_animation_name == fall_animation_name)
	
	var target_damage_receiver := DamageReceiver.try_get_from(fall_target)
	if target_damage_receiver:
		target_damage_receiver.try_receive_damage(in_source, in_source, fall_damage, DamageReceiver.DamageType_Fall, true)
	elif fallback_to_remove_owner_on_finish:
		fall_target.queue_free()
	
	fall_target.remove_meta(is_falling_meta)
	stop()
	
	sequence_finished.emit(in_source)
