extends Node

@export var _MainMenuScenePath: NodePath = "res://World/Levels/MainMenu/MainMenu.tscn"
@export var _StageScenePath: NodePath = "res://World/Levels/Stage/Stage.tscn"
@export var _PrologueScenePath: NodePath = "res://World/Levels/Prologue/Prologue.tscn"

signal StageFinished()

var _Level: LevelBase2D
var _GameState: GameState

func _enter_tree():
	if _GameState:
		_GameState.OnNewSceneLoaded()

func LoadScene(InPath: NodePath):
	get_tree().change_scene_to_file(InPath)

func StartNewGame(InGameMode: GameModeData, InGameSeed: int, InArgs: Array = []):
	
	print("Starting new game...")
	_GameState = GameState.new(InGameMode, InGameSeed, InArgs)
	
	#SaveGlobals.ClearRunSaveData()
	
	_GameState.GameStartedFromMainMenu = true
	_GameState.HandleStartNewGame()

func ContinueGameFromSaveData():
	
	print("Continuing game from save data...")
	
	## Will call GameStateBase.CreateNew
	#SaveGlobals.ApplyRunSaveData_Game()
	
	_GameState.GameStartedFromMainMenu = true
	_GameState.HandleContinueGameFromSaveData()

signal PreReturnToMainMenu()

func ReturnToMainMenu(InSavePersistentData: bool):
	
	print("Returning to MainMenu...")
	
	PreReturnToMainMenu.emit()
	GameGlobals.RemoveAllPauseSources()
	
	#if InSavePersistentData:
	#	SaveGlobals.SavePersistentSaveData(false)
	
	_GameState = null
	LoadScene(_MainMenuScenePath)

func CalcBodyCombinedLinearDamp(InBody: RigidBody2D) -> float:
	
	assert(ProjectSettings.has_setting("physics/2d/default_linear_damp"))
	var default_damp := ProjectSettings.get_setting("physics/2d/default_linear_damp")
	
	var body_damp := InBody.linear_damp
	
	match InBody.linear_damp_mode:
		RigidBody2D.DAMP_MODE_REPLACE:
			return body_damp
		RigidBody2D.DAMP_MODE_COMBINE:
			return default_damp + body_damp
		_:
			return default_damp
