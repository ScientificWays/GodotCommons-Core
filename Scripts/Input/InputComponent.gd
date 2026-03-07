extends Node
class_name InputComponent

static func try_get_from(in_node: Node) -> InputComponent:
	return ModularGlobals.try_get_from(in_node, InputComponent)

@export_category("Input")
@export var input_handlers: Array[InputHandlerBase] = []

var last_input_action_events: Dictionary[StringName, InputEvent] = {}

signal input_event_handled(in_event: InputEvent)

func _ready() -> void:
	pass

func _process(in_delta: float) -> void:
	
	for sample_handler: InputHandlerBase in input_handlers:
		if sample_handler.try_handle_process(self, in_delta):
			if sample_handler.consume_on_handled:
				break

func _enter_tree() -> void:
	ModularGlobals.init_modular_node(self)

func _exit_tree() -> void:
	ModularGlobals.deinit_modular_node(self)

func is_input_action_pressed(in_action: StringName) -> bool:
	return last_input_action_events[in_action].is_pressed() if last_input_action_events.has(in_action) else false

func try_handle_input_event(in_event: InputEvent) -> bool:
	
	var out_handled := false
	
	for sample_handler: InputHandlerBase in input_handlers:
		
		if sample_handler.try_handle_event(self, in_event):
			
			get_viewport().set_input_as_handled()
			input_event_handled.emit(in_event)
			
			out_handled = true
			
			var sample_handler_action_name := sample_handler.get_action_name()
			if not sample_handler_action_name.is_empty():
				last_input_action_events[sample_handler_action_name] = in_event
			
			if sample_handler.consume_on_handled:
				break
	
	return out_handled
