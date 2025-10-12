@tool
extends Control
class_name ScoreUI_Conversion

@export_category("Components")
@export var TargetImage: TextureRect:
	set(InImage):
		TargetImage = InImage
		_update_appearance()

@export var TargetLabel: VHSLabel

@export_category("Appearance")
@export var image_texture: Texture2D:
	set(InTexture):
		image_texture = InTexture
		_update_appearance()

@export_category("Stat")
@export var stat_type: String = GameState.LevelFinishTimeStat
@export var format_as_time_string: bool = true
@export var stat_to_score_ratio: float = 1.0
@export var conversion_speed: float = 10.0
@export var conversion_speed_increase: float = 1.0

var coversion_timer: Timer

var conversion_num_left: int = 0:
	set(InNum):
		
		conversion_num_left = InNum
		
		if format_as_time_string:
			TargetLabel.label_text = UIGlobals.format_time_seconds(conversion_num_left)
		else:
			TargetLabel.label_text = String.num_int64(conversion_num_left)

signal Converted(InScore: float)
signal ConversionFinished()

func _ready() -> void:
	
	if not Engine.is_editor_hint():
		var _game_state := WorldGlobals._game_state
		conversion_num_left = _game_state.GetGameStatValue(stat_type)
	
	_update_appearance.call_deferred()

func _update_appearance() -> void:
	
	if not is_node_ready():
		return
	
	if TargetImage:
		TargetImage.texture = image_texture
	
	if Engine.is_editor_hint():
		return
	
	conversion_num_left = conversion_num_left

func get_final_add_score() -> Variant:
	return WorldGlobals._game_state.GetGameStatValue(stat_type) * stat_to_score_ratio

func handle_animated_sequence() -> void:
	
	var _game_state := WorldGlobals._game_state
	conversion_num_left = _game_state.GetGameStatValue(stat_type)
	
	if conversion_num_left > 0:
		
		assert(not coversion_timer)
		coversion_timer = GameGlobals.spawn_regular_timer_for(self, OnConvertTimerTimeout, 1.0 / conversion_speed)
		
		await ConversionFinished
	
	_game_state.ResetGameStatValue(stat_type)

func OnConvertTimerTimeout() -> void:
	
	conversion_num_left -= 1
	Converted.emit(stat_to_score_ratio)
	
	conversion_speed += conversion_speed_increase
	coversion_timer.wait_time = 1.0 / conversion_speed
	
	if conversion_num_left <= 0:
		
		coversion_timer.stop()
		coversion_timer.queue_free()
		coversion_timer = null
		
		ConversionFinished.emit()
