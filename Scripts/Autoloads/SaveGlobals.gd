extends Node
class_name SaveGlobals_Class

var local_data_path: String = "user://local-data.save"

var last_level_path_key: String = "last_level_path"

var music_volume_linear_key: String = "music_volume_linear"
var game_volume_linear_key: String = "game_volume_linear"
var ui_volume_linear_key: String = "ui_volume_linear"

var default_camera_zoom_key: String = "default_camera_zoom"

var local_data: Dictionary

var save_delay_time_left: float = 0.0:
	set(in_time):
		save_delay_time_left = in_time
		set_process(save_delay_time_left > 0.0)
var pending_save: bool = false

func _ready() -> void:
	
	load_local_data()
	
	get_tree().scene_changed.connect(on_scene_changed)
	
	WorldGlobals.PendingScenePathChanged.connect(on_pending_scene_path_changed)
	
	AudioGlobals.music_volume_linear_changed.connect(on_music_volume_linear_changed)
	AudioGlobals.game_volume_linear_changed.connect(on_game_volume_linear_changed)
	AudioGlobals.ui_volume_linear_changed.connect(on_ui_volume_linear_changed)
	
	PlayerGlobals.default_camera_zoom_changed.connect(on_default_camera_zoom_changed)

func _notification(in_what: int) -> void:
	
	if in_what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_local_data(true)

func _process(in_delta: float) -> void:
	
	save_delay_time_left -= in_delta
	
	if save_delay_time_left > 0.0:
		pass
	elif pending_save:
		pending_save = false
		save_local_data()

func on_scene_changed() -> void:
	
	var CurrentScene := get_tree().current_scene
	if CurrentScene is LevelBase2D:
		local_data[last_level_path_key] = CurrentScene.scene_file_path
		save_local_data(true)

func on_pending_scene_path_changed() -> void:
	
	if ResourceLoader.exists(WorldGlobals.PendingScenePath):
		local_data[last_level_path_key] = WorldGlobals.PendingScenePath

func on_music_volume_linear_changed() -> void:
	local_data[music_volume_linear_key] = AudioGlobals.music_volume_linear
	save_local_data()

func on_game_volume_linear_changed() -> void:
	local_data[game_volume_linear_key] = AudioGlobals.game_volume_linear
	save_local_data()

func on_ui_volume_linear_changed() -> void:
	local_data[ui_volume_linear_key] = AudioGlobals.ui_volume_linear
	save_local_data()

func on_default_camera_zoom_changed() -> void:
	local_data[default_camera_zoom_key] = PlayerGlobals.default_camera_zoom
	save_local_data()

func save_local_data(in_forced: bool = false) -> void:
	
	if (save_delay_time_left > 0.0) and (not in_forced):
		pending_save = true
		return
	
	var NewFile = FileAccess.open(local_data_path, FileAccess.WRITE)
	NewFile.store_var(local_data)
	NewFile.close()
	
	#print("Saved local data")
	
	save_delay_time_left = 4.0

func load_local_data() -> void:
	
	if not FileAccess.file_exists(local_data_path):
		return
	
	var LoadedFile = FileAccess.open(local_data_path, FileAccess.READ)
	local_data = LoadedFile.get_var()
	LoadedFile.close()
	
	if local_data.has(music_volume_linear_key):
		AudioGlobals.music_volume_linear = local_data[music_volume_linear_key]
	if local_data.has(game_volume_linear_key):
		AudioGlobals.game_volume_linear = local_data[game_volume_linear_key]
	if local_data.has(ui_volume_linear_key):
		AudioGlobals.ui_volume_linear = local_data[ui_volume_linear_key]
	
	if local_data.has(default_camera_zoom_key):
		PlayerGlobals.default_camera_zoom = local_data[default_camera_zoom_key]

func IsLastLevelFromSaveDataValid() -> bool:
	var LastLevelPath := GetLastLevelFromSaveData()
	return ResourceLoader.exists(LastLevelPath, "PackedScene")

func GetLastLevelFromSaveData() -> String:
	return local_data.get(last_level_path_key, "")
