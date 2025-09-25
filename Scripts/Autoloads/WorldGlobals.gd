extends Node

signal TransitionAreaEnterBegin(InTransitionArea: LevelTransitionArea2D)
signal TransitionAreaEnterFinished(InTransitionArea: LevelTransitionArea2D)

var _Level: LevelBase2D
var _GameState: GameState

func _enter_tree() -> void:
	if _GameState:
		_GameState.OnNewSceneLoaded()

func LoadSceneByPath(InPath: String) -> void:
	
	if _Level:
		_Level.EndPlay()
	
	Bridge.platform.send_message(Bridge.PlatformMessage.IN_GAME_LOADING_STARTED)
	
	if get_tree().change_scene_to_file(InPath) == OK:
		await get_tree().scene_changed
	Bridge.platform.send_message(Bridge.PlatformMessage.IN_GAME_LOADING_STOPPED)

func LoadSceneByPacked(InPacked: PackedScene) -> void:
	
	if _Level:
		_Level.EndPlay()
	
	Bridge.platform.send_message(Bridge.PlatformMessage.IN_GAME_LOADING_STARTED)
	
	if get_tree().change_scene_to_packed(InPacked) == OK:
		await get_tree().scene_changed
	Bridge.platform.send_message(Bridge.PlatformMessage.IN_GAME_LOADING_STOPPED)

var PendingScenePath: StringName:
	set(InPath):
		PendingScenePath = InPath
		PendingScenePathChanged.emit()
signal PendingScenePathChanged()

func LoadPendingScene() -> void:
	
	var Path := PendingScenePath
	PendingScenePath = StringName()
	
	LoadSceneByPath(Path)

func StartNewGame(InGameMode: GameModeData, InGameSeed: int, InArgs: Array = []) -> void:
	
	print("Starting new game...")
	_GameState = GameState.new(InGameMode, InGameSeed, InArgs)
	
	#SaveGlobals.ClearRunSaveData()
	
	_GameState.GameStartedFromMainMenu = true
	_GameState.HandleStartNewGame()

func ContinueGameFromSaveData() -> void:
	
	print("Continuing game from save data...")
	
	## Will call GameStateBase.CreateNew
	#SaveGlobals.ApplyRunSaveData_Game()
	
	_GameState.GameStartedFromMainMenu = true
	_GameState.HandleContinueGameFromSaveData()

signal PreReturnToMainMenu()

func ReturnToMainMenu(InSavePersistentData: bool) -> void:
	
	print("Returning to MainMenu...")
	
	PreReturnToMainMenu.emit()
	GameGlobals.RemoveAllPauseSources()
	
	#if InSavePersistentData:
	#	SaveGlobals.SavePersistentSaveData(false)
	
	_GameState = null
	#LoadScene(_MainMenuScenePath)

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
