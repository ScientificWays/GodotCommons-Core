extends RefCounted
class_name GameState

var _GameModeData: GameModeData
var GameSeed: int = 0
var GameArgs: Array = []

func _init(InGameMode: GameModeData, InGameSeed: int, InGameArgs: Array):
	
	assert(not is_instance_valid(WorldGlobals._GameState))
	WorldGlobals._GameState = self
	
	_GameModeData = InGameMode
	GameSeed = InGameSeed
	GameArgs = InGameArgs

const State_Unknown: int = -1
const State_BeganPlaying: int = 0
const State_EndedPlaying: int = 1

var _State: int = State_Unknown
var GameStartedFromMainMenu: bool = false

var ShouldCreateGlobalTimer: bool = true
var _GlobalTimer: GameState_GlobalTimer
const GlobalTimer_OverrideTimeMeta: StringName = &"GlobalTimer_OverrideTime"

var BeginPlayOnLevelReady: bool = true

var OwnedArtifactDictionary: Dictionary = {}
var FoundArtifactDictionary: Dictionary = {}
var SpawnedArtifactDictionary: Dictionary = {}

func OnNewSceneLoaded():
	OwnedArtifactDictionary = {}
	FoundArtifactDictionary = {}
	SpawnedArtifactDictionary = {}

func HandleStartNewGame():
	assert(false, "HandleStartNewGame() is not implemented!")

func HandleContinueGameFromSaveData():
	assert(false, "HandleContinueGameFromSaveData() is not implemented!")

func HandleLevelReady(InLevel: LevelBase2D):
	
	InitNewLocalPlayer()
	
	assert(not _GlobalTimer)
	if ShouldCreateGlobalTimer:
		_GlobalTimer = GameState_GlobalTimer.new()
		InLevel.add_child(_GlobalTimer)
	
	if BeginPlayOnLevelReady:
		InLevel.BeginPlay()

func HandleBeginPlay(InLevel: LevelBase2D):
	
	_State = State_BeganPlaying

func HandleEndPlay(InLevel: LevelBase2D):
	
	_State = State_EndedPlaying
	
	if is_instance_valid(_GlobalTimer):
		_GlobalTimer.queue_free()
		_GlobalTimer = null

func InitNewLocalPlayer() -> PlayerController:
	
	var NewLocalPlayer = _GameModeData.PlayerControllerScene.instantiate() as PlayerController
	WorldGlobals._Level.add_child(NewLocalPlayer)
	return NewLocalPlayer

func InitPlayer(InPlayer: PlayerController):
	pass

#func InitCreatureManager(InManager: CreatureManager):
#	pass

#func GetNewCreatureModifierNames(InCreature: Creature) -> Array[StringName]:
#	return []

#func InitCreature(InCreature: Creature):
#	pass

#func GetDefaultCreatureLevel() -> int:
#	return 0

func GetDebugStatsFileNamePostfix() -> String:
	return _GameModeData.UniqueName
