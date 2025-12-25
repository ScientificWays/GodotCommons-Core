extends RefCounted
class_name GameState

var _game_mode: GameModeData
var _game_seed: int = 0
var _game_args: Dictionary = {}

func _init(in_game_mode: GameModeData, in_game_seed: int, in_game_args: Dictionary):
	
	assert(not is_instance_valid(WorldGlobals._game_state))
	WorldGlobals._game_state = self
	
	_game_mode = in_game_mode
	_game_seed = in_game_seed
	_game_args = in_game_args

const STATE_UNKNOWN: int = -1
const STATE_BEGAN_PLAYING: int = 0
const STATE_ENDED_PLAYING: int = 1

var _state: int = STATE_UNKNOWN

var ShouldCreateGlobalTimer: bool = true
var _global_timer: GameState_GlobalTimer
const GlobalTimer_OverrideTimeMeta: StringName = &"GlobalTimer_OverrideTime"

signal GlobalTimerCreated()
signal GlobalTimerDestroyed()

var current_restarts_num: int = 0

var BeginPlayOnLevelReady: bool = true

var OwnedArtifactDictionary: Dictionary = {}
var FoundArtifactDictionary: Dictionary = {}
var SpawnedArtifactDictionary: Dictionary = {}

func OnNewSceneLoaded():
	OwnedArtifactDictionary = {}
	FoundArtifactDictionary = {}
	SpawnedArtifactDictionary = {}

func handle_level_ready():
	
	current_restarts_num = 0
	
	InitNewLocalPlayer()
	
	if BeginPlayOnLevelReady:
		begin_play()

signal on_begin_play()
signal on_end_play()

signal on_init_new_local_player(in_player: PlayerController)

func has_began_playing() -> bool:
	return _state == STATE_BEGAN_PLAYING

func has_ended_playing() -> bool:
	return _state == STATE_ENDED_PLAYING

func begin_play():
	
	_state = STATE_BEGAN_PLAYING
	
	assert(not _global_timer)
	if ShouldCreateGlobalTimer:
		_global_timer = GameState_GlobalTimer.new()
		GlobalTimerCreated.emit()
		WorldGlobals._level.add_child(_global_timer)
	
	on_begin_play.emit()

func end_play():
	
	_state = STATE_ENDED_PLAYING
	
	if is_instance_valid(_global_timer):
		SetGameStatValue(LevelFinishTimeStat, _global_timer.time_seconds)
		_global_timer.queue_free()
		_global_timer = null
		GlobalTimerDestroyed.emit()
	
	on_end_play.emit()

func InitNewLocalPlayer() -> PlayerController:
	
	var NewLocalPlayer = _game_mode.PlayerControllerScene.instantiate() as PlayerController
	WorldGlobals._level.add_child(NewLocalPlayer)
	on_init_new_local_player.emit(NewLocalPlayer)
	return NewLocalPlayer

#func GetNewCreatureModifierNames(InCreature: Creature) -> Array[StringName]:
#	return []

#func InitCreature(InCreature: Creature):
#	pass

#func GetDefaultCreatureLevel() -> int:
#	return 0

func GetDebugStatsFileNamePostfix() -> String:
	return _game_mode.unique_name

##
## Game Stats
##
const LevelFinishTimeStat: StringName = &"LevelFinishTime"

var GameStatsDictionary: Dictionary[StringName, Variant]

func GetGameStatValue(InStat: StringName) -> Variant:
	return GameStatsDictionary.get(InStat, 0)

func SetGameStatValue(InStat: StringName, in_value: Variant) -> void:
	GameStatsDictionary[InStat] = in_value

func ResetGameStatValue(InStat: StringName) -> void:
	GameStatsDictionary.erase(InStat)

##
## Leaderboards
##
var current_score: int = 0:
	set(in_score):
		current_score = in_score
		current_score_changed.emit()

signal current_score_changed()

func add_score(in_score: int) -> void:
	current_score += in_score
