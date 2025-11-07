extends Logger
class_name CustomLogger

func _init() -> void:
	OS.add_logger(self)

signal error_caught(in_message: String)
signal message_caught(in_message: String, in_error: bool)

static var _mutex := Mutex.new()

static var _error_type_name := ClassDB.class_get_enum_constants("Logger", "ErrorType")

func _log_error(
	in_function: String, 
	in_file: String, 
	in_line: int, 
	in_code: String, 
	in_rationale: String, 
	in_editor_notify: bool, 
	in_error_type: int, 
	in_script_backtraces: Array[ScriptBacktrace]
) -> void:
	
	if not Output.config.debug_enabled:
		return
	
	_mutex.lock()
	
	var sb := PackedStringArray()
	sb.append("Caught an error:")
	sb.append("function: {0}".format([in_function]))
	sb.append("file: {0}".format([in_file]))
	sb.append("line: {0}".format([in_line]))
	sb.append("code: {0}".format([in_code]))
	sb.append("rationale: {0}".format([in_rationale]))
	sb.append("editor notify: {0}".format([in_editor_notify]))
	sb.append("error type: {0}".format([_error_type_name[in_error_type]]))
	
	if not in_script_backtraces.is_empty():
		
		sb.append("script backtraces:")
		
		for sample_backtrace: ScriptBacktrace in in_script_backtraces:
			sb.append(sample_backtrace.format())

	var error_message = "\n".join(sb)
	#var filestream = FileAccess.open("user://error_log.txt", FileAccess.WRITE)
	#filestream.store_string(error_message)
	#filestream.close()
	
	Output.print(error_message)
	
	_mutex.unlock()

func _log_message(in_message: String, in_error: bool) -> void:
	
	if not Output.config.debug_enabled:
		return
	
	_mutex.lock()
	
	if in_error:
		Output.print(in_message)
	
	_mutex.unlock()
