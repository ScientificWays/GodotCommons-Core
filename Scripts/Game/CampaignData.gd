extends Resource
class_name CampaignData

const run_data_inventory_data: String = "inventory_data"

const challenge_time_arg: StringName = "challenge_time"
const challenge_time_desc: StringName = "CHALLENGE_TIME_DESC"

@export_category("Info")
@export var display_title: String = "CAMPAIGN_TUTORIAL"
@export var start_confirm_title: String = "CAMPAIGN_START_PROMPT"
@export var continue_confirm_title: String = "CAMPAIGN_CONTINUE_PROMPT"
@export var can_start: bool = true
@export var unique_identifier: String = "tutorial"

@export_category("Game Mode")
@export var game_mode_data: GameModeData = preload("res://Assets/Game/MainGameMode.tres")
@export var game_mode_args: Dictionary

@export_category("Levels")
@export var start_prompt_level_path: String = "res://Scenes/Levels/StartPromptLevel.tscn"
@export var levels_path_array: Array[String] = [
	"res://Scenes/Levels/Tutorial/Level001.tscn",
	"res://Scenes/Levels/Tutorial/Level002.tscn",
	"res://Scenes/Levels/Tutorial/Level003.tscn"
]

@export_category("Music")
@export var start_prompt_music: MusicTrackResource
#@export var play_level_music_on_continue: bool = true

@export_category("Cache")
@export var pre_game_caching_scene_path: String = "res://Scenes/Levels/PreGameCaching.tscn"
@export var cache_stream_array: Array[AudioStream]

func _get_last_level_index_key() -> String:
	return "c_%s_last_lvl" % unique_identifier

func _get_last_run_data_key() -> String:
	return "c_%s_last_run_data" % unique_identifier

func _get_completions_key() -> String:
	return "c_%s_completions" % unique_identifier

func _get_best_score_key() -> String:
	return "c_%s_best_score" % unique_identifier

func _get_goal_level_key(in_level_index: int) -> String:
	return "c_%s_lvl_%d" % [ unique_identifier, (in_level_index + 1) ]

var last_level_index: int = 0:
	set(in_index):
		
		var new_index := clampi(in_index, 0, levels_path_array.size() - 1)
		if last_level_index != new_index:
			last_level_index = new_index
			save_storage_data()

var last_run_data: Dictionary = {}:
	set(in_data):
		
		if last_run_data != in_data:
			last_run_data = in_data
			save_storage_data()

var completions: int = 0:
	set(in_completions):
		
		if completions != in_completions:
			completions = in_completions
			save_storage_data()

var best_score: int = 0:
	set(in_score):
		
		if best_score != in_score:
			best_score = in_score
			save_storage_data()

func load_storage_data() -> void:
	
	var data_array := await SaveGlobals.get_data_from_storage(
	{
		_get_last_level_index_key(): 0,
		_get_last_run_data_key(): JSON.stringify({}),
		_get_completions_key(): 0,
		_get_best_score_key(): 0
	})
	disable_save_storage_data = true
	
	last_level_index = data_array[0]
	
	#print("%s load_storage_data() data_array[1] = %s " % [ unique_identifier, data_array[1] ])
	last_run_data = JSON.parse_string(data_array[1])
	
	completions = data_array[2]
	best_score = data_array[3]
	
	disable_save_storage_data = false

var disable_save_storage_data: bool = false

func save_storage_data() -> void:
	
	if disable_save_storage_data:
		return
	
	#print("%s save_storage_data() last_run_data = %s " % [ unique_identifier, last_run_data ])
	#print("%s save_storage_data() JSON.stringify(last_run_data) = %s " % [ unique_identifier, JSON.stringify(last_run_data) ])
	
	SaveGlobals.set_data_in_storage({
		_get_last_level_index_key(): last_level_index,
		#_get_last_run_data_key(): last_run_data,
		_get_last_run_data_key(): JSON.stringify(last_run_data),
		_get_completions_key(): completions,
		_get_best_score_key(): best_score
	})

func get_current_level_index() -> int:
	return levels_path_array.find(WorldGlobals._level.scene_file_path)

func get_pending_level_index() -> int:
	return levels_path_array.find(WorldGlobals.pending_scene_path)

func get_saved_last_level_path() -> String:
	
	if last_level_index >= 0 and last_level_index < levels_path_array.size():
		return levels_path_array[last_level_index]
	else:
		#push_error("%s get_saved_last_level_path() invalid index '%d'!" % [ self, last_level_index ])
		return levels_path_array[0]

func get_leaderboard_best_score() -> String:
	return ("campaign%sbestscore" % unique_identifier).remove_chars("_-")

func get_leaderboard_best_time() -> String:
	return ("campaign%sbesttime" % unique_identifier).remove_chars("_-")

signal init_game_finished()

func start_game(in_game_seed: int, in_extra_game_mode_args: Dictionary = {}) -> void:
	
	last_level_index = 0
	last_run_data = {}
	
	## wait for last_level_index, last_run_data saving
	if SaveGlobals.is_saving_data_in_storage:
		await SaveGlobals.saved_data_in_storage
	
	await _handle_init_game(in_game_seed, in_extra_game_mode_args)

func continue_game(in_game_seed: int, in_extra_game_mode_args: Dictionary = {}) -> void:
	await _handle_init_game(in_game_seed, in_extra_game_mode_args)

func _handle_init_game(in_game_seed: int, in_extra_game_mode_args: Dictionary) -> void:
	
	var final_args := game_mode_args.merged(in_extra_game_mode_args, true)
	
	WorldGlobals._campaign_data = self
	
	assert(not WorldGlobals._game_state)
	WorldGlobals._game_state = game_mode_data.init_new_game_state(in_game_seed, final_args)
	
	WorldGlobals._game_state.on_begin_play.connect(_handle_begin_play)
	WorldGlobals._game_state.on_end_play.connect(_handle_end_play)
	WorldGlobals._game_state.current_score_changed.connect(_handle_current_score_changed)
	
	if not WorldGlobals.pending_scene_path_changed.is_connected(_handle_pending_scene_path_changed):
		WorldGlobals.pending_scene_path_changed.connect(_handle_pending_scene_path_changed)
	
	if final_args.get("start_prompt", false) or true: ## Always use start prompt for now
		await WorldGlobals.load_scene_by_path(start_prompt_level_path)
	else:
		await WorldGlobals.load_scene_by_path(levels_path_array[last_level_index])
	init_game_finished.emit()

func load_relevant_level() -> void:
	
	await _handle_caching()
	
	await WorldGlobals.load_scene_by_path(get_saved_last_level_path())

func _handle_caching() -> void:
	
	#print("_handle_shader_compiling_scene()")
	
	var async_loader := AsyncResourceLoader.new(pre_game_caching_scene_path, false)
	var pre_game_caching_scene := await async_loader.get_after_finished() as PackedScene
	
	var pre_game_caching := pre_game_caching_scene.instantiate()
	pre_game_caching.cache_stream_array = cache_stream_array
	
	WorldGlobals.add_child.call_deferred(pre_game_caching)
	
	await pre_game_caching.finished

func _handle_begin_play() -> void:
	last_level_index = get_current_level_index()

func _handle_end_play() -> void:
	
	var current_level := get_current_level_index()
	
	if WorldGlobals._level.was_completed:
		
		PlatformGlobals.send_metrics(104372225, "reachGoal", _get_goal_level_key(current_level))
		
		if current_level == levels_path_array.size() - 1:
			completions += 1
			last_level_index = 0
			last_run_data = {}
			# remove last_level

func _handle_current_score_changed() -> void:
	
	var current_score := WorldGlobals._game_state.current_score
	if current_score > best_score:
		
		best_score = current_score
		Bridge.leaderboards.set_score(get_leaderboard_best_score(), best_score)

func _handle_pending_scene_path_changed() -> void:
	
	if WorldGlobals._campaign_data == self:
		var pending_level_index := get_pending_level_index()
		if pending_level_index != -1:
			last_level_index = pending_level_index

func get_run_data(in_key: String, in_default_data: Variant) -> Variant:
	return last_run_data[in_key] if last_run_data.has(in_key) else in_default_data

func set_run_data(in_key: String, in_value: Variant) -> void:
	last_run_data[in_key] = in_value
	save_storage_data()
