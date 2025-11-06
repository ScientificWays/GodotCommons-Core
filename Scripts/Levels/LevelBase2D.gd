@tool
extends Node2D
class_name LevelBase2D

@export_category("Game Mode")
@export var DefaultGameMode: GameModeData
@export var DefaultGameModeArgs: Dictionary

@export_category("Players")
@export var default_player_spawn: Node2D
@export var RespawnAllPlayersOnBeginPlay: bool = true

@export_category("Music")
@export var LevelMusicBankLabel: String = "Music"
@export var LevelMusic: MusicTrackResource
@export var start_default_level_music_on_begin_play: bool = true
@export var stop_level_music_on_end_play: bool = true

@export_category("Navigation")
@export var level_navigation_region: LevelNavigationRegion2D

@export_category("Tiles")
@export var floor_tile_map_layer: LevelTileMapLayer

var _y_sorted: Node2D

#var enter_tree_ticks_ms: int = 0
#var begin_play_ticks_ms: int = 0

signal post_init_game_state()

signal post_begin_play()
signal post_end_play()

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not default_player_spawn:
			default_player_spawn = find_child("*layer*pawn*") as Node2D
			if not default_player_spawn:
				default_player_spawn = find_child("*layer*awn*") as Node2D
		if not level_navigation_region:
			level_navigation_region = find_child("*avigation*") as LevelNavigationRegion2D
	else:
		_y_sorted = YSorted2D.new()
		add_child(_y_sorted)
		move_child(_y_sorted, 0)
		
		if not UIGlobals.pause_menu_ui:
			await UIGlobals.pause_menu_ui_created
		UIGlobals.pause_menu_ui.can_be_enabled = true
		UIGlobals.pause_menu_ui.skip_lerp_visible()
		
		_init_game_state()
		WorldGlobals._game_state.handle_level_ready()
		
		#print(self, " _ready() WorldGlobals._game_state._game_args = ", WorldGlobals._game_state._game_args)

func _enter_tree() -> void:
	
	if Engine.is_editor_hint():
		return
	
	#enter_tree_ticks_ms = Time.get_ticks_msec()
	
	WorldGlobals._level = self

func _exit_tree() -> void:
	
	if Engine.is_editor_hint():
		return
	
	WorldGlobals._level = null

func _init_game_state() -> void:
	
	if WorldGlobals._game_state:
		pass
	else:
		var new_game_seed := 2729052680
		#var new_game_seed := randi()
		
		assert(DefaultGameMode)
		WorldGlobals._game_state = DefaultGameMode.init_new_game_state(new_game_seed, DefaultGameModeArgs)
	
	assert(WorldGlobals._game_state)
	WorldGlobals._game_state.on_begin_play.connect(_handle_begin_play)
	WorldGlobals._game_state.on_end_play.connect(_handle_end_play)
	
	post_init_game_state.emit()

func _handle_begin_play() -> void:
	
	if RespawnAllPlayersOnBeginPlay:
		PlayerGlobals.RespawnAllPlayers()
	
	if start_default_level_music_on_begin_play:
		start_default_level_music()
	
	Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STARTED)
	post_begin_play.emit()
	
	#begin_play_ticks_ms = Time.get_ticks_msec()
	#print("Level _handle_begin_play() from enter_tree_ticks_ms to begin_play_ticks_ms took %d ms" % (begin_play_ticks_ms - enter_tree_ticks_ms))

func _handle_end_play() -> void:
	
	if stop_level_music_on_end_play and MusicManager._is_playing_music():
		MusicManager.stop(1.0)
	
	Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STOPPED)
	post_end_play.emit()

func get_player_spawn_position(in_player: PlayerController) -> Vector2:
	return default_player_spawn.global_position if default_player_spawn else Vector2.ZERO

##
## Music
##
var default_level_music_started: bool = false

func start_default_level_music() -> void:
	default_level_music_started = true
	update_level_music()

func update_level_music() -> void:
	
	var current_music: MusicTrackResource = null
	
	if default_level_music_started:
		current_music = LevelMusic
	
	if override_level_music and not override_level_music_source_ids.is_empty():
		current_music = override_level_music
	
	if current_music:
		if not AudioGlobals.IsMusicPlaying(LevelMusicBankLabel, current_music):
			AudioGlobals.TryPlayMusic(LevelMusicBankLabel, current_music)
	else:
		AudioGlobals.TryStopMusic()

var override_level_music: MusicTrackResource
var override_level_music_source_ids: Array[int]

func set_override_level_music(in_music: MusicTrackResource) -> void:
	
	override_level_music = in_music
	
	update_level_music()

func reset_override_level_music() -> void:
	
	override_level_music = null
	override_level_music_source_ids.clear()
	
	update_level_music()

func add_override_level_music_source(in_source: Node2D, in_update_delay: float = 0.0) -> void:
	
	in_source.tree_exited.connect(remove_override_level_music_source.bind(in_source))
	
	var source_id := in_source.get_instance_id()
	
	if in_update_delay > 0.0:
		await GameGlobals.spawn_await_timer(self, in_update_delay).timeout
	
	assert(not override_level_music_source_ids.has(source_id))
	override_level_music_source_ids.append(source_id)
	
	update_level_music()

func remove_override_level_music_source(in_source: Node2D, in_update_delay: float = 0.0) -> void:
	
	in_source.tree_exited.disconnect(remove_override_level_music_source.bind(in_source))
	
	var source_id := in_source.get_instance_id()
	
	if in_update_delay > 0.0:
		await GameGlobals.spawn_await_timer(self, in_update_delay).timeout
	
	assert(override_level_music_source_ids.has(source_id))
	override_level_music_source_ids.erase(source_id)
	
	update_level_music()

##
## Tile Floor
##
func snap_position_to_tile_floor(in_global_position: Vector2) -> Vector2:
	
	var local_position := floor_tile_map_layer.to_local(in_global_position)
	var center_coords := floor_tile_map_layer.local_to_map(local_position)
	return floor_tile_map_layer.to_global(floor_tile_map_layer.map_to_local(center_coords))

func has_available_tile_floor_extent_at(in_global_position: Vector2, in_extent: int) -> bool:
	
	if not floor_tile_map_layer:
		return false
	
	var local_position := floor_tile_map_layer.to_local(in_global_position)
	var center_coords := floor_tile_map_layer.local_to_map(local_position)
	
	for sample_x: int in range(-in_extent + 1, in_extent):
		for sample_y: int in range(-in_extent + 1, in_extent):
			
			var sample_coords := center_coords + Vector2i(sample_x, sample_y)
			var sample_terrain := BetterTerrain.get_cell(floor_tile_map_layer, sample_coords)
			
			if sample_terrain == BetterTerrain.TileCategory.EMPTY:
				return false
	return true

##
## Navigation
##
func request_nav_update(in_is_on_thread: bool = true):
	
	if level_navigation_region:
		
		if Engine.is_editor_hint():
			if level_navigation_region.is_baking():
				await level_navigation_region.bake_finished
			level_navigation_region.bake_navigation_polygon.call_deferred(in_is_on_thread)
		else:
			if in_is_on_thread:
				level_navigation_region.request_update()
			else:
				level_navigation_region.bake_navigation_polygon(false)

func get_random_nav_pos_in_radius(in_center: Vector2, in_radius: float) -> Vector2:
	
	var map := level_navigation_region.get_navigation_map()
	if NavigationServer2D.map_get_iteration_id(map) <= 0:
		return in_center
	
	for i: int in range(10):
		var dir = Vector2.RIGHT.rotated(randf() * TAU)
		var test_pos = in_center + dir * randf() * in_radius
		var nav_pos = NavigationServer2D.map_get_closest_point(map, test_pos)
		if in_center.distance_to(nav_pos) <= in_radius:
			return nav_pos
	return Vector2.INF # fallback
