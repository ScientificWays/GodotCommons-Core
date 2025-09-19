extends Control
class_name ScoreUI

@export_category("Stats")
@export var ExperienceConversion: ScoreUI_Conversion
@export var TimeConversion: ScoreUI_Conversion

@export_category("Score")
@export var ScoreLabel: VHSLabel

func _ready() -> void:
	ExperienceConversion.Converted.connect(OnStatConverted)
	TimeConversion.Converted.connect(OnStatConverted)

func HandleAnimatedSequence() -> void:
	
	CumulatedPlayerScore = 0.0
	
	await get_tree().create_timer(1.0).timeout
	await ExperienceConversion.HandleAnimatedSequence()
	
	await get_tree().create_timer(1.0).timeout
	await TimeConversion.HandleAnimatedSequence()
	
	var _GameState := WorldGlobals._GameState
	_GameState.AddPlayerScore(ceili(CumulatedPlayerScore))

var CumulatedPlayerScore: float = 0.0:
	set(InScore):
		CumulatedPlayerScore = InScore
		ScoreLabel.label_text = String.num_int64(CumulatedPlayerScore)

func OnStatConverted(InScore: float) -> void:
	CumulatedPlayerScore += InScore
