extends RefCounted
class_name GameState

var _GameModeData: GameModeData
var GameSeed: int = 0
var GameArgs: Array = []

func _init(InGameMode: GameModeData, InGameSeed: int, InGameArgs: Array):
	
	assert(not is_instance_valid(WorldGlobals._game_state))
	WorldGlobals._game_state = self
	
	_GameModeData = InGameMode
	GameSeed = InGameSeed
	GameArgs = InGameArgs

const STATE_UNKNOWN: int = -1
const STATE_BEGAN_PLAYING: int = 0
const STATE_ENDED_PLAYING: int = 1

var _state: int = STATE_UNKNOWN

var ShouldCreateGlobalTimer: bool = true
var _GlobalTimer: GameState_GlobalTimer
const GlobalTimer_OverrideTimeMeta: StringName = &"GlobalTimer_OverrideTime"

signal GlobalTimerCreated()
signal GlobalTimerDestroyed()

var BeginPlayOnLevelReady: bool = true

var OwnedArtifactDictionary: Dictionary = {}
var FoundArtifactDictionary: Dictionary = {}
var SpawnedArtifactDictionary: Dictionary = {}

func OnNewSceneLoaded():
	OwnedArtifactDictionary = {}
	FoundArtifactDictionary = {}
	SpawnedArtifactDictionary = {}

func handle_level_ready():
	
	LoadPlayerScore()
	
	InitNewLocalPlayer()
	
	if BeginPlayOnLevelReady:
		begin_play()

func begin_play():
	
	_state = STATE_BEGAN_PLAYING
	
	assert(not _GlobalTimer)
	if ShouldCreateGlobalTimer:
		_GlobalTimer = GameState_GlobalTimer.new()
		GlobalTimerCreated.emit()
		WorldGlobals._level.add_child(_GlobalTimer)
	
	WorldGlobals._level.handle_begin_play()

func end_play():
	
	_state = STATE_ENDED_PLAYING
	
	if is_instance_valid(_GlobalTimer):
		SetGameStatValue(LevelFinishTimeStat, _GlobalTimer.TimeSeconds)
		_GlobalTimer.queue_free()
		_GlobalTimer = null
		GlobalTimerDestroyed.emit()
	
	WorldGlobals._level.handle_end_play()

func InitNewLocalPlayer() -> PlayerController:
	
	var NewLocalPlayer = _GameModeData.PlayerControllerScene.instantiate() as PlayerController
	WorldGlobals._level.add_child(NewLocalPlayer)
	return NewLocalPlayer

#func GetNewCreatureModifierNames(InCreature: Creature) -> Array[StringName]:
#	return []

#func InitCreature(InCreature: Creature):
#	pass

#func GetDefaultCreatureLevel() -> int:
#	return 0

func GetDebugStatsFileNamePostfix() -> String:
	return _GameModeData.UniqueName

##
## Game Stats
##
const LevelFinishTimeStat: StringName = &"LevelFinishTime"

var GameStatsDictionary: Dictionary[StringName, Variant]

func GetGameStatValue(InStat: StringName) -> Variant:
	return GameStatsDictionary.get(InStat, 0)

func SetGameStatValue(InStat: StringName, InValue: Variant) -> void:
	GameStatsDictionary[InStat] = InValue

func ResetGameStatValue(InStat: StringName) -> void:
	GameStatsDictionary.erase(InStat)

##
## Leaderboards
##
var PlayerScore: int = 0:
	set(InScore):
		PlayerScore = InScore
		PlayerScoreChanged.emit()

signal PlayerScoreChanged()

func LoadPlayerScore() -> void:
	pass
	#if Bridge.leaderboards.type != Bridge.LeaderboardType.NOT_AVAILABLE:
		#Bridge.leaderboards.get_entries("levelscore")

func OnLeaderboardPlayerEntryLoaded(InData) -> void:
	print("GameState OnLeaderboardPlayerEntryLoaded(), ", InData)
	PlayerScore = InData["score"]

func AddPlayerScore(InScore: int) -> void:
	
	PlayerScore += InScore
	
	#if Bridge.leaderboards.type != Bridge.LeaderboardType.NOT_AVAILABLE:
	#	Bridge.leaderboards.set_score("levelscore", PlayerScore)
