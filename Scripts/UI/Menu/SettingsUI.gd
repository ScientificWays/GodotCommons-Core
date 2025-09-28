extends Control
class_name SettingsUI

@export_category("Sliders")
@export var game_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var default_camera_zoom_slider: HSlider

func _ready() -> void:
	
	assert(game_volume_slider)
	assert(music_volume_slider)
	
	game_volume_slider.value_changed.connect(on_game_volume_slider_value_changed)
	music_volume_slider.value_changed.connect(on_music_volume_slider_value_changed)
	default_camera_zoom_slider.value_changed.connect(on_default_camera_zoom_slider_value_changed)
	
	AudioGlobals.game_volume_linear_changed.connect(on_game_volume_linear_changed)
	AudioGlobals.music_volume_linear_changed.connect(on_music_volume_linear_changed)
	PlayerGlobals.default_camera_zoom_changed.connect(on_default_camera_zoom_changed)
	
	on_game_volume_linear_changed()
	on_music_volume_linear_changed()
	on_default_camera_zoom_changed()

func on_game_volume_slider_value_changed(in_value: float) -> void:
	AudioGlobals.game_volume_linear = in_value

func on_music_volume_slider_value_changed(in_value: float) -> void:
	AudioGlobals.music_volume_linear = in_value

func on_default_camera_zoom_slider_value_changed(in_value: float) -> void:
	PlayerGlobals.default_camera_zoom = in_value

func on_game_volume_linear_changed() -> void:
	game_volume_slider.set_value_no_signal(AudioGlobals.game_volume_linear)

func on_music_volume_linear_changed() -> void:
	music_volume_slider.set_value_no_signal(AudioGlobals.music_volume_linear)

func on_default_camera_zoom_changed() -> void:
	default_camera_zoom_slider.set_value_no_signal(PlayerGlobals.default_camera_zoom)
