extends Node
class_name DialogueSequence

@export_category("Sequence")
@export var data_array: Array[DialogueData]

var current_index: int = -1

signal finished()

var was_finished: bool = false

func _ready() -> void:
	assert(not data_array.is_empty())

func move_to_next_data() -> bool:
	
	var next_index := current_index + 1
	if GameGlobals_Class.ArrayIsValidIndex(data_array, next_index):
		current_index = next_index
		return true
	return false

func get_current_data() -> DialogueData:
	return data_array[current_index]

func begin_sequence() -> void:
	
	was_finished = false
	current_index = 0
	
	UIGlobals.request_cancel_dialogue.connect(_on_cancelled)
	UIGlobals.request_dialogue_sequence.emit(self)

func _on_cancelled() -> void:
	handle_finished()

func handle_finished() -> void:
	
	if was_finished:
		return
	
	was_finished = true
	
	UIGlobals.request_cancel_dialogue.disconnect(_on_cancelled)
	finished.emit()
