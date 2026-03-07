extends Node
class_name InputComponent

static func try_get_from(in_node: Node) -> InputComponent:
	return ModularGlobals.try_get_from(in_node, InputComponent)

@export_category("Input")
@export var input_handlers: Array[InputHandlerBase] = []

#var last_input_action_events: Dictionary[StringName, InputEvent] = {}

signal input_event_handled(in_event: InputEvent)

class RepeatData:
	
	var handler: InputHandlerBase
	var time_left: float
	var current_repeats: int
	
	func _init(in_handler: InputHandlerBase, in_time_left: float) -> void:
		handler = in_handler
		time_left = in_time_left
		current_repeats = 0

var pending_repeats_data: Array[RepeatData]

func _ready() -> void:
	pass

func _process(in_delta: float) -> void:
	
	for sample_handler: InputHandlerBase in input_handlers:
		if sample_handler.try_handle_process(self, in_delta):
			if sample_handler.consume_on_handled:
				break
	
	var pending_removes: Array[RepeatData] = []
	
	for sample_repeat_data: RepeatData in pending_repeats_data:
		if sample_repeat_data.time_left > in_delta:
			sample_repeat_data.time_left -= in_delta
		else:
			pending_removes.append(sample_repeat_data)
	
	for sample_repeat_data: RepeatData in pending_removes:
		pending_repeats_data.erase(sample_repeat_data)

func _enter_tree() -> void:
	ModularGlobals.init_modular_node(self)

func _exit_tree() -> void:
	ModularGlobals.deinit_modular_node(self)

func push_repeat_for(in_handler: InputHandlerBase, in_reset_time: float) -> int:
	
	for sample_repeat_data: RepeatData in pending_repeats_data:
		if sample_repeat_data.handler == in_handler:
			sample_repeat_data.time_left = in_reset_time
			sample_repeat_data.current_repeats += 1
			return sample_repeat_data.current_repeats
	
	pending_repeats_data.append(RepeatData.new(in_handler, in_reset_time))
	return 1

func reset_repeat_for(in_handler: InputHandlerBase) -> void:
	
	for sample_repeat_data: RepeatData in pending_repeats_data:
		if sample_repeat_data.handler == in_handler:
			pending_repeats_data.erase(sample_repeat_data)
			break

#func is_input_action_pressed(in_action: StringName) -> bool:
#	return last_input_action_events[in_action].is_pressed() if last_input_action_events.has(in_action) else false

func try_handle_input_event(in_event: InputEvent) -> bool:
	
	var out_handled := false
	
	for sample_handler: InputHandlerBase in input_handlers:
		
		if sample_handler.try_handle_event(self, in_event):
			
			get_viewport().set_input_as_handled()
			input_event_handled.emit(in_event)
			
			out_handled = true
			
			#var sample_handler_action_name := sample_handler.get_action_name()
			#if not sample_handler_action_name.is_empty():
			#	last_input_action_events[sample_handler_action_name] = in_event
			
			if sample_handler.consume_on_handled:
				break
	
	return out_handled
