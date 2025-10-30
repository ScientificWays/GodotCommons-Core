extends Node

signal change_level_transition_begin(InTransitionArea: LevelTransitionArea2D)
signal change_level_transition_finished(InTransitionArea: LevelTransitionArea2D)

var _campaign_data: CampaignData
var _game_state: GameState
var _level: LevelBase2D

signal load_scene_finished

func _enter_tree() -> void:
	if _game_state:
		_game_state.OnNewSceneLoaded()

func load_scene_by_path(in_path: String, in_async: bool = true) -> void:
	
	if ResourceLoader.exists(in_path, "PackedScene"):
		
		var packed_scene: PackedScene = null
		
		if in_async:
			var async_loader := AsyncResourceLoader.new(in_path, true)
			packed_scene = await async_loader.get_after_finished()
		else:
			packed_scene = ResourceLoader.load(in_path)
		await load_scene_by_packed(packed_scene)

func load_scene_by_packed(in_packed: PackedScene) -> void:
	
	if _game_state and _game_state._state == GameState.STATE_BEGAN_PLAYING:
		_game_state.end_play()
	
	Bridge.platform.send_message(Bridge.PlatformMessage.IN_GAME_LOADING_STARTED)
	
	GameGlobals.RemoveAllPauseSources()
	
	if get_tree().change_scene_to_packed(in_packed) == OK:
		await get_tree().scene_changed
	
	Bridge.platform.send_message(Bridge.PlatformMessage.IN_GAME_LOADING_STOPPED)
	load_scene_finished.emit()

var pending_scene_path: StringName:
	set(in_path):
		pending_scene_path = in_path
		pending_scene_path_changed.emit()
signal pending_scene_path_changed()

func load_pending_scene(in_async: bool = true) -> void:
	
	var path := pending_scene_path
	pending_scene_path = StringName()
	
	await load_scene_by_path(path, in_async)

func calc_body_combined_linear_damp(in_body: RigidBody2D) -> float:
	
	assert(ProjectSettings.has_setting("physics/2d/default_linear_damp"))
	var default_damp := ProjectSettings.get_setting("physics/2d/default_linear_damp")
	
	var body_damp := in_body.linear_damp
	
	match in_body.linear_damp_mode:
		RigidBody2D.DAMP_MODE_REPLACE:
			return body_damp
		RigidBody2D.DAMP_MODE_COMBINE:
			return default_damp + body_damp
		_:
			return default_damp
