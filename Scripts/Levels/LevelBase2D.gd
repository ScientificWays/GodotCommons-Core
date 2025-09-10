extends Node2D
class_name LevelBase2D

@export_category("Game Mode")
@export var DefaultGameMode: GameModeData
@export var DefaultGameModeArgs: Array

@export_category("Players")
@export var DefaultPlayerSpawn: Node2D
@export var RespawnAllPlayersOnBeginPlay: bool = true

#const ForceMoodMeta: StringName = &"ForceMood"

const WorldBankLabel: String = "World"
#const MusicBankLabel: String = "Music"

var _YSorted: Node2D

@export var _CanvasModulate: CanvasModulate

var _GameState: GameState

#signal CreatureSpawned(InCreature: Creature)
#signal BossCreatureSpawned(InCreature: Creature)

#signal CreatureDied(InCreature: Creature)
#signal BossCreatureDied(InCreature: Creature)

#signal StageBossDefeated(InBossCreature: Creature)
#signal ChapterBossDefeated(InBossCreature: Creature)

#signal CreatureRelevantDetectedTargetChanged(InCreature: Creature, InOldTarget: Node2D, InNewTarget: Node2D)

func _ready():
	
	_YSorted = Node2D.new()
	_YSorted.y_sort_enabled = true
	add_child(_YSorted)
	move_child(_YSorted, 0)
	
	PrepareGameStateAndSaveData()
	_GameState.HandleLevelReady(self)

func _enter_tree():
	WorldGlobals._Level = self

func _exit_tree():
	WorldGlobals._Level = null
	EndPlay()

func PrepareGameStateAndSaveData():
	
	if WorldGlobals._GameState and WorldGlobals._GameState.GameStartedFromMainMenu:
		
		#if WorldGlobals._GameState._GameMode.ShouldSaveRunData:
		#	assert(SaveGlobals._PersistentSaveData)
		#	SaveGlobals.SaveRunData.call_deferred()
		pass
	else:
		
		#if not SaveGlobals._PersistentSaveData:
		#	if SaveGlobals.TryLoadPersistentSaveData() == ERR_FILE_CANT_OPEN:
		#		SaveGlobals.CurrentSaveSlot = "Debug"
		
		if not WorldGlobals._GameState:
			
			#if not SaveGlobals._RunSaveData and SaveGlobals.TryLoadRunSaveData():
				
				## Will create GameState and init GameMode internally
			#	SaveGlobals.ApplyRunSaveData_Game()
			#else:
				var NewGameSeed := 2729052680
				#var NewGameSeed := randi()
				
				assert(DefaultGameMode)
				WorldGlobals._GameState = DefaultGameMode.InitNewGameState(NewGameSeed, DefaultGameModeArgs)
	assert(WorldGlobals._GameState)
	_GameState = WorldGlobals._GameState

func BeginPlay():
	
	_GameState.HandleBeginPlay(self)
	
	if RespawnAllPlayersOnBeginPlay:
		PlayerGlobals.RespawnAllPlayers()
	
	#_LevelTileMap.UpdateUnbreakableCells()
	#_LevelTileMap.InitNavigation()

func EndPlay():
	
	_GameState.HandleEndPlay(self)
	
	if MusicManager._is_playing_music():
		MusicManager.stop(1.0)

func GetPlayerSpawnPosition(InPlayer: PlayerController) -> Vector2:
	return DefaultPlayerSpawn.global_position if DefaultPlayerSpawn else Vector2.ZERO
