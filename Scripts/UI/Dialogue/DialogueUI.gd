extends Control
class_name DialogueUI

@export_category("Text")
@export var text_label: Label

@export_category("Animations")
@export var animation_player: AnimationPlayer
@export var show_animation_name: StringName = &"show"
@export var hide_animation_name: StringName = &"hide"
@export var display_animation_name: StringName = &"display"

var current_sequence: DialogueSequence
var current_data: DialogueData

func _ready() -> void:
	
	assert(text_label)
	assert(animation_player)
	
	UIGlobals.request_dialogue_sequence.connect(start_sequence)
	UIGlobals.request_cancel_dialogue.connect(cancel_dialogue)
	
	reset()

func _gui_input(in_event: InputEvent) -> void:
	
	if in_event is InputEventScreenTouch:
		
		if animation_player.is_playing() and \
			animation_player.current_animation == display_animation_name:
			animation_player.advance(0.25)
		else:
			finish_dialogue(current_data, false)
		
		get_viewport().set_input_as_handled()

func start_sequence(in_sequence: DialogueSequence) -> void:
	
	assert(in_sequence)
	
	current_sequence = in_sequence
	start_dialogue(current_sequence.get_current_data())

func start_dialogue(in_data: DialogueData) -> void:
	
	current_data = in_data
	
	assert(current_data)
	
	if not visible:
		animation_player.play(show_animation_name)
		await GameGlobals.spawn_await_timer(self, 0.5).timeout
	
	assert(not current_data.text.is_empty())
	text_label.text = current_data.text
	
	assert(current_data.text_display_speed > 0.0)
	var display_duration := float(text_label.text.length()) / current_data.text_display_speed
	
	animation_player.play(display_animation_name, -1.0, 1.0 / display_duration)
	animation_player.advance(0.0)
	
	set_process_input(true)
	
	await GameGlobals.spawn_await_timer(self, display_duration).timeout

func finish_dialogue(in_data: DialogueData, in_force_cancel: bool) -> void:
	
	assert(visible)
	
	if in_force_cancel:
		cancel_dialogue()
	else:
		if current_sequence:
			if current_sequence.move_to_next_data():
				start_dialogue(current_sequence.get_current_data())
			else:
				current_sequence.handle_finished()
				hide_and_reset()
		else:
			hide_and_reset()

func cancel_dialogue() -> void:
	hide_and_reset()

func hide_and_reset() -> void:
	
	set_process_input(false)
	
	animation_player.play(hide_animation_name)
	await GameGlobals.spawn_await_timer(self, 1.0).timeout
	
	reset()

func reset() -> void:
	
	current_sequence = null
	current_data = null
	
	set_process_input(false)
	
	visible = false
	text_label.text = ""
