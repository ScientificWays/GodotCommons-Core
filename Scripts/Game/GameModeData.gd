extends Resource
class_name GameModeData

@export_category("Info")
@export var UniqueName: StringName
@export var PreviewTexture: Texture2D

func InitNewGameState(InGameSeed: int, InArgs: Array) -> GameState:
	assert(false, "InitNewGameState() is not implemented!")
	return null

#@export_category("Item pools")
#@export var UpgradeablePool: ItemPoolData = preload("res://Inventory/Items/Content/Pools/UpgradeablePool.tres")
#@export var ShopPool: ItemPoolData = preload("res://Inventory/Items/Content/Pools/ShopPool.tres")
#@export var SecretPool: ItemPoolData = preload("res://Inventory/Items/Content/Pools/SecretPool.tres")
#@export var BossPool: ItemPoolData = preload("res://Inventory/Items/Content/Pools/BossPool.tres")
#@export var TreasurePool_Default: ItemPoolData = preload("res://Inventory/Items/Content/Pools/TreasurePool_Default.tres")
#@export var TreasurePool_Active: ItemPoolData = preload("res://Inventory/Items/Content/Pools/TreasurePool_Active.tres")
#@export var TreasurePool_Passive: ItemPoolData = preload("res://Inventory/Items/Content/Pools/TreasurePool_Passive.tres")
#@export var TreasurePool_BombType: ItemPoolData = preload("res://Inventory/Items/Content/Pools/TreasurePool_BombType.tres")

@export_category("Player")
@export var PlayerControllerScene: PackedScene

@export_category("Saves")
@export var ShouldSaveRunData: bool = false

#func UpdateRunSaveData(InRunSaveData: RunSaveData):
#	pass

#func ApplyRunSaveData(InRunSaveData: RunSaveData):
#	
#	var GlobalTimeSeconds := InRunSaveData.GetGlobalTimeSeconds()
#	if is_instance_valid(WorldGlobals._GameState._GlobalTimer):
#		WorldGlobals._GameState._GlobalTimer.TimeSeconds = GlobalTimeSeconds

@export_category("Transition")
@export var TransitionScenePath: String
