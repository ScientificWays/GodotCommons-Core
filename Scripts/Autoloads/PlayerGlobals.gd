extends Node

var player_array: Array[PlayerController]

func _ready() -> void:
	pass

##
## Respawn
##
func restart_all_players(in_initial_restart: bool) -> void:
	for sample_player: PlayerController in player_array:
		sample_player.restart(in_initial_restart)

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
	return player_array[0].GetCurrentCameraRect() ## TODO: Add this method

func ResetAllPlayersZoom() -> void:
	for sample_player: PlayerController in player_array:
		sample_player._camera.ResetZoom()

##
## Fade
##
func StartFadeInForAllPlayers(ToColor: Color, InDuration: float) -> void:
	for SamplePlayer: PlayerController in player_array:
		SamplePlayer._GameUI.StartFadeIn(ToColor, InDuration)

func StartFadeOutForAllPlayers(FromColor: Color, InDuration: float) -> void:
	for SamplePlayer: PlayerController in player_array:
		SamplePlayer._GameUI.StartFadeOut(FromColor, InDuration)

func StopFadeForAllPlayers(InDuration: float) -> void:
	for SamplePlayer: PlayerController in player_array:
		SamplePlayer._GameUI.StopFade(InDuration)
