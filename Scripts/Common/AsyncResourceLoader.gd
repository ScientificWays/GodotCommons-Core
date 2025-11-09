extends Node
class_name AsyncResourceLoader

func _init(in_path: String, in_should_pause: bool, in_parent: Node = WorldGlobals) -> void:
	
	path = in_path
	should_pause = in_should_pause
	
	in_parent.add_child.call_deferred(self)

var path: String
var should_pause: bool

signal progress(in_percentage: float)
signal finished(in_status: ResourceLoader.ThreadLoadStatus)

func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var error := ResourceLoader.load_threaded_request(path)
	if error != OK:
		_handle_finish(ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED)

func _enter_tree() -> void:
	if should_pause:
		GameGlobals.AddPauseSource(self)

func _exit_tree() -> void:
	if should_pause:
		GameGlobals.RemovePauseSource(self)

func _process(in_delta: float) -> void:
	
	var progress_array := []
	var status := ResourceLoader.load_threaded_get_status(path, progress_array)
	
	progress.emit(progress_array[0])
	
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		pass
	else:
		_handle_finish(status)

func _handle_finish(in_status: ResourceLoader.ThreadLoadStatus) -> void:
	finished.emit(in_status)
	queue_free()

func get_after_finished() -> Resource:
	await finished
	return ResourceLoader.load_threaded_get(path)
