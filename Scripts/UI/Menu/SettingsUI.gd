extends Control
class_name SettingsUI

@export_category("Sliders")
@export var game_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var default_camera_zoom_slider: HSlider

@export_category("Options")
@export var translation_option: OptionButton
@export var translation_option_locale_array: Array[String] = [
	"ru",
	"en",
	"tr",
	"es",
]

@export_category("Buttons")
@export var reset_button: Button

func _ready() -> void:
	
	assert(game_volume_slider)
	assert(music_volume_slider)
	assert(default_camera_zoom_slider)
	assert(translation_option)
	
	game_volume_slider.value_changed.connect(on_game_volume_slider_value_changed)
	music_volume_slider.value_changed.connect(on_music_volume_slider_value_changed)
	default_camera_zoom_slider.value_changed.connect(on_default_camera_zoom_slider_value_changed)
	translation_option.item_selected.connect(on_translation_option_item_selected)
	reset_button.pressed.connect(on_reset_button_pressed)
	
	AudioGlobals.game_volume_linear_changed.connect(on_game_volume_linear_changed)
	AudioGlobals.music_volume_linear_changed.connect(on_music_volume_linear_changed)
	PlayerGlobals.default_camera_zoom_changed.connect(on_default_camera_zoom_changed)
	
	on_game_volume_linear_changed()
	on_music_volume_linear_changed()
	on_default_camera_zoom_changed()
	on_translation_changed()
	
	reset_button.visible = PlatformGlobals_Class.is_debug()

func _notification(in_what: int) -> void:
	
	if NOTIFICATION_TRANSLATION_CHANGED:
		if is_node_ready():
			on_translation_changed()

func on_game_volume_slider_value_changed(in_value: float) -> void:
	AudioGlobals.game_volume_linear = in_value

func on_music_volume_slider_value_changed(in_value: float) -> void:
	AudioGlobals.music_volume_linear = in_value

func on_default_camera_zoom_slider_value_changed(in_value: float) -> void:
	PlayerGlobals.default_camera_zoom = in_value

func on_translation_option_item_selected(in_index: int) -> void:
	
	assert(in_index >= 0 and in_index < translation_option_locale_array.size())
	var selected_locale := translation_option_locale_array[in_index]
	
	if TranslationServer.get_locale() != selected_locale:
		TranslationServer.set_locale(selected_locale)

func on_game_volume_linear_changed() -> void:
	game_volume_slider.set_value_no_signal(AudioGlobals.game_volume_linear)

func on_music_volume_linear_changed() -> void:
	music_volume_slider.set_value_no_signal(AudioGlobals.music_volume_linear)

func on_default_camera_zoom_changed() -> void:
	default_camera_zoom_slider.set_value_no_signal(PlayerGlobals.default_camera_zoom)

func on_translation_changed() -> void:
	
	if not is_instance_valid(translation_option):
		return
	
	var current_locale := TranslationServer.get_locale().left(2)
	var locale_index := translation_option_locale_array.find(current_locale)
	
	if translation_option.selected != locale_index:
		translation_option.select(locale_index)
	
	if translation_option.selected == -1:
		push_error(self, "on_translation_changed() unknown locale %s!" % current_locale)

func on_reset_button_pressed() -> void:
	SaveGlobals.delete_all_storage_data()
