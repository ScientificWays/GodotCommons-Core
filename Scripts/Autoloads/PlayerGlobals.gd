extends Node

var PlayerArray: Array[PlayerController]

func _ready() -> void:
	pass

##
## Respawn
##
func RespawnAllPlayers() -> void:
	for SampelPlayer: PlayerController in PlayerArray:
		SampelPlayer.Restart()

##
## Camera
##
var default_camera_zoom: float = 3.6:
	set(in_zoom):
		default_camera_zoom = in_zoom
		handle_default_camera_zoom_changed()
signal default_camera_zoom_changed()

func handle_default_camera_zoom_changed():
	default_camera_zoom_changed.emit()

func GetLevelPlayerCurrentCameraRect() -> Rect2:
	return PlayerArray[0].GetCurrentCameraRect() ## TODO: Add this method

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
