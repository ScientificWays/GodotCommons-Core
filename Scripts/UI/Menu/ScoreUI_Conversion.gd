@tool
extends Control
class_name ScoreUI_Conversion

@export_category("Components")
@export var TargetImage: TextureRect:
	set(InImage):
		TargetImage = InImage
		UpdateAppearance()

@export var TargetLabel: VHSLabel

@export_category("Appearance")
@export var image_texture: Texture2D:
	set(InTexture):
		image_texture = InTexture
		UpdateAppearance()

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
			TargetLabel.label_text = UIGlobals.FormatTimeString(conversion_num_left)
		else:
			TargetLabel.label_text = String.num_int64(conversion_num_left)

signal Converted(InScore: float)
signal ConversionFinished()

func _ready() -> void:
	
	if not Engine.is_editor_hint():
		var _GameState := WorldGlobals._GameState
		conversion_num_left = _GameState.GetGameStatValue(stat_type)
	
	UpdateAppearance()

func UpdateAppearance() -> void:
	if TargetImage:
		TargetImage.texture = image_texture

func HandleAnimatedSequence() -> void:
	
	var _GameState := WorldGlobals._GameState
	conversion_num_left = _GameState.GetGameStatValue(stat_type)
	
	if conversion_num_left > 0:
		
		assert(not coversion_timer)
		coversion_timer = GameGlobals.SpawnRegularTimerFor(self, OnConvertTimerTimeout, 1.0 / conversion_speed)
		
		await ConversionFinished
	
	_GameState.ResetGameStatValue(stat_type)

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
