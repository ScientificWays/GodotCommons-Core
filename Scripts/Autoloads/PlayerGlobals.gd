extends Node

var PlayerArray: Array[PlayerController]

const DefaultCameraZoom_Const: Vector2 = Vector2(3.6, 3.6)
const ShopCameraZoom_Const: Vector2 = Vector2(5.4, 5.4)
const DeathCameraZoom_Const: Vector2 = Vector2(5.4, 5.4)
signal ZoomOverridesChanged()

signal MoodChanged(InPlayer: PlayerController)

func _ready() -> void:
	pass

func _exit_tree() -> void:
	RemoveDefaultCameraZoomOverride()
	RemoveShopCameraZoomOverride()
	RemoveDeathCameraZoomOverride()

##
## Respawn
##
func RespawnAllPlayers() -> void:
	for SampelPlayer: PlayerController in PlayerArray:
		SampelPlayer.Restart()

##
## Camera
##
func GetLevelPlayerCurrentCameraRect() -> Rect2:
	return PlayerArray[0].GetCurrentCameraRect() ## TODO: Add this method

func GetDefaultCameraZoom() -> Vector2:
	return get_meta(&"DefaultCameraZoom", DefaultCameraZoom_Const)

func GetShopCameraZoom() -> Vector2:
	return get_meta(&"ShopCameraZoom", ShopCameraZoom_Const)

func GetDeathCameraZoom() -> Vector2:
	return get_meta(&"DeathCameraZoom", DeathCameraZoom_Const)

func SetDefaultCameraZoomOverride(InZoom: Vector2) -> void:
	set_meta(&"DefaultCameraZoom", InZoom)
	ZoomOverridesChanged.emit()

func SetShopCameraZoomOverride(InZoom: Vector2) -> void:
	set_meta(&"ShopCameraZoom", InZoom)
	ZoomOverridesChanged.emit()

func SetDeathCameraZoomOverride(InZoom: Vector2) -> void:
	set_meta(&"DeathCameraZoom", InZoom)
	ZoomOverridesChanged.emit()

func RemoveDefaultCameraZoomOverride() -> void:
	remove_meta(&"DefaultCameraZoom")
	ZoomOverridesChanged.emit()

func RemoveShopCameraZoomOverride() -> void:
	remove_meta(&"ShopCameraZoom")
	ZoomOverridesChanged.emit()

func RemoveDeathCameraZoomOverride() -> void:
	remove_meta(&"DeathCameraZoom")
	ZoomOverridesChanged.emit()

func ResetAllPlayersZoom() -> void:
	for SampelPlayer: PlayerController in PlayerArray:
		SampelPlayer._Camera.ResetZoom()

##
## Fade
##
func StartFadeInForAllPlayers(ToColor: Color, InDuration: float) -> void:
	for SamplePlayer: PlayerController in PlayerArray:
		SamplePlayer._GameUI.StartFadeIn(ToColor, InDuration)

func StartFadeOutForAllPlayers(FromColor: Color, InDuration: float) -> void:
	for SamplePlayer: PlayerController in PlayerArray:
		SamplePlayer._GameUI.StartFadeOut(FromColor, InDuration)

func StopFadeForAllPlayers(InDuration: float) -> void:
	for SamplePlayer: PlayerController in PlayerArray:
		SamplePlayer._GameUI.StopFade(InDuration)
