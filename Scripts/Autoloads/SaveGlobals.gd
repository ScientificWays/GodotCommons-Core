extends Node
class_name SaveGlobals_Class

var shaders_compiled_flag: bool = false

const ALL_STORAGE_KEYS: String = "ALL_STORAGE_KEYS"

var music_volume_linear_key: String = "music_volume_linear"
var game_volume_linear_key: String = "game_volume_linear"
var ui_volume_linear_key: String = "ui_volume_linear"

var locale_key: String = "auto"

var default_camera_zoom_key: String = "default_camera_zoom"

func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(not storage_save_queued_data.is_empty())
	
	AudioGlobals.music_volume_linear_changed.connect(on_music_volume_linear_changed)
	AudioGlobals.game_volume_linear_changed.connect(on_game_volume_linear_changed)
	AudioGlobals.ui_volume_linear_changed.connect(on_ui_volume_linear_changed)
	PlayerGlobals.default_camera_zoom_changed.connect(on_default_camera_zoom_changed)
	
	load_settings()

func _process(in_delta: float) -> void:
	flush_set_data_in_storage()
	set_process(false)

func _notification(in_what: int) -> void:
	
	if in_what == NOTIFICATION_TRANSLATION_CHANGED:
		if is_node_ready():
			save_settings()

func on_music_volume_linear_changed() -> void:
	save_settings()

func on_game_volume_linear_changed() -> void:
	save_settings()

func on_ui_volume_linear_changed() -> void:
	save_settings()

func on_default_camera_zoom_changed() -> void:
	save_settings()

func load_settings() -> void:
	
	var data_array := await SaveGlobals.get_data_from_storage({
		ALL_STORAGE_KEYS: used_keys_dictionary,
		music_volume_linear_key: AudioGlobals.music_volume_linear,
		game_volume_linear_key: AudioGlobals.game_volume_linear,
		ui_volume_linear_key: AudioGlobals.ui_volume_linear,
		locale_key: TranslationServer.get_locale(),
		default_camera_zoom_key: PlayerGlobals.default_camera_zoom
	})
	used_keys_dictionary = data_array[0]
	
	AudioGlobals.music_volume_linear = data_array[1]
	AudioGlobals.game_volume_linear = data_array[2]
	AudioGlobals.ui_volume_linear = data_array[3]
	
	if PlatformGlobals.is_web():
		pass
	else:
		if data_array[4] != TranslationServer.get_locale():
			TranslationServer.set_locale(data_array[4])
	
	PlayerGlobals.default_camera_zoom = data_array[5]

func save_settings() -> void:
	
	set_data_in_storage({
		music_volume_linear_key: AudioGlobals.music_volume_linear,
		game_volume_linear_key: AudioGlobals.game_volume_linear,
		ui_volume_linear_key: AudioGlobals.ui_volume_linear,
		locale_key: TranslationServer.get_locale(),
		default_camera_zoom_key: PlayerGlobals.default_camera_zoom
	})

##
## Storage
##
var is_loading_data_from_storage: bool = false
signal loaded_data_from_storage(in_success: bool)

func get_data_from_storage(in_keys_with_defaults: Dictionary[String, Variant]) -> Array[Variant]:
	
	while is_loading_data_from_storage:
		await loaded_data_from_storage
	
	#print(in_keys_with_defaults)
	var out_array := in_keys_with_defaults.values()
	#print(loading_data_from_storage_array)
	
	is_loading_data_from_storage = true
	Bridge.storage.get(in_keys_with_defaults.keys(), _get_data_from_storage_callback.bind(out_array))
	
	if is_loading_data_from_storage:
		await loaded_data_from_storage
	return out_array

func _get_data_from_storage_callback(in_success: bool, in_data: Array, out_array: Array[Variant]) -> void:
		
	if not in_success:
		push_error("get_data_from_storage() failed!")
	
	for sample_index: int in range(in_data.size()):
		
		var sample_data = in_data[sample_index]
		#print(in_data.size(), " ", sample_index)
		var sample_default = out_array[sample_index]
		
		if sample_data == null:
			pass
		else:
			if typeof(sample_data) == typeof(sample_default):
				out_array[sample_index] = sample_data
			else:
				if typeof(sample_data) == TYPE_STRING:
					out_array[sample_index] = str_to_var(sample_data)
				else:
					out_array[sample_index] = type_convert(sample_data, typeof(sample_default))
	
	is_loading_data_from_storage = false
	loaded_data_from_storage.emit(in_success)

var storage_save_queued_data: Dictionary[String, Variant]

func set_data_in_storage(in_data: Dictionary[String, Variant]) -> void:
	storage_save_queued_data.merge(in_data, true)
	set_process(true)

var is_saving_data_in_storage: bool = false
signal saved_data_in_storage(in_success: bool)

var used_keys_dictionary: Dictionary

func flush_set_data_in_storage() -> void:
	
	if is_saving_data_in_storage:
		await saved_data_in_storage
		if not storage_save_queued_data.is_empty():
			set_process(true)
		return
	
	is_saving_data_in_storage = true
	
	assert(not storage_save_queued_data.is_empty())
	assert(not storage_save_queued_data.has(ALL_STORAGE_KEYS))
	
	var save_keys := storage_save_queued_data.keys()
	var save_values := storage_save_queued_data.values()
	
	for sample_key: String in save_keys:
		if not used_keys_dictionary.has(sample_key):
			used_keys_dictionary[sample_key] = true
	
	save_keys.append(ALL_STORAGE_KEYS)
	save_values.append(used_keys_dictionary)
	print("flush_set_data_in_storage() saving %s" % storage_save_queued_data)
	Bridge.storage.set(save_keys, save_values, _set_data_in_storage_callback)
	storage_save_queued_data.clear()

func _set_data_in_storage_callback(in_success: bool) -> void:
	
	if not in_success:
		push_error("_set_data_in_storage_callback() failed!")
	
	is_saving_data_in_storage = false
	saved_data_in_storage.emit(in_success)

func delete_all_storage_data() -> void:
	## TODO: is_saving_data_in_storage / is_deleting_data_in_storage check
	var keys_to_delete := used_keys_dictionary.keys()
	keys_to_delete.append(ALL_STORAGE_KEYS)
	
	Bridge.storage.delete(keys_to_delete, _delete_all_storage_data_callback.bind(keys_to_delete))

func _delete_all_storage_data_callback(in_success: bool, in_deleted_keys: Array) -> void:
	
	if in_success:
		
		print("Keys were deleted from storage:\n%s" % var_to_str(in_deleted_keys))
		
		for sample_key in in_deleted_keys:
			used_keys_dictionary.erase(sample_key)
	else:
		printerr("Failed to delete keys from storage:\n%s" % var_to_str(in_deleted_keys))
