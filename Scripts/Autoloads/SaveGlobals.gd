extends Node
class_name SaveGlobals_Class

var LocalDataPath: String = "user://savegame.save"
var LastLevelPathKey: String = "LastLevelPath"

var LocalData: Dictionary

func _ready() -> void:
	
	LoadLocalData()
	
	get_tree().scene_changed.connect(OnSceneChanged)
	WorldGlobals.PendingScenePathChanged.connect(OnPendingScenePathChanged)

func OnSceneChanged() -> void:
	SaveLocalData()

func SaveLocalData() -> void:
	
	var CurrentScene := get_tree().current_scene
	if CurrentScene is LevelBase2D:
		LocalData[LastLevelPathKey] = CurrentScene.scene_file_path
	
	var NewFile = FileAccess.open(LocalDataPath, FileAccess.WRITE)
	NewFile.store_var(LocalData)
	NewFile.close()

func LoadLocalData() -> void:
	
	if not FileAccess.file_exists(LocalDataPath):
		return
	
	var LoadedFile = FileAccess.open(LocalDataPath, FileAccess.READ)
	LocalData = LoadedFile.get_var()
	LoadedFile.close()

func IsLastLevelFromSaveDataValid() -> bool:
	var LastLevelPath := GetLastLevelFromSaveData()
	return ResourceLoader.exists(LastLevelPath, "PackedScene")

func GetLastLevelFromSaveData() -> String:
	return LocalData.get(LastLevelPathKey, "")

func OnPendingScenePathChanged() -> void:
	
	if ResourceLoader.exists(WorldGlobals.PendingScenePath):
		LocalData[LastLevelPathKey] = WorldGlobals.PendingScenePath
