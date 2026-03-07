@abstract
extends Resource
class_name AnimStateModifier

@export var disabled: bool = false

@abstract func _enter_state(in_state: AnimState) -> void
@abstract func _exit_state(in_state: AnimState) -> void

@abstract func _tick_state(in_state: AnimState, in_delta: float) -> void
