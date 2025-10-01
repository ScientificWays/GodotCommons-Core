extends Control
class_name ScoreUI

@export_category("Stats")
@export var ExperienceConversion: ScoreUI_Conversion
@export var TimeConversion: ScoreUI_Conversion

@export_category("Score")
@export var ScoreLabel: VHSLabel

var prev_score: int = 0
var add_score: float = 0.0:
	set(InScore):
		add_score = InScore
		ScoreLabel.label_text = "%d + %d" % [ prev_score, add_score ]

func _ready() -> void:
	ExperienceConversion.Converted.connect(OnStatConverted)
	TimeConversion.Converted.connect(OnStatConverted)

func handle_animated_sequence() -> void:
	
	prev_score = WorldGlobals._game_state.current_score
	add_score = 0.0
	
	await get_tree().create_timer(0.5).timeout
	await ExperienceConversion.handle_animated_sequence()
	
	await get_tree().create_timer(0.5).timeout
	await TimeConversion.handle_animated_sequence()
	
	await WorldGlobals._game_state.add_score(ceili(add_score))

func OnStatConverted(InScore: float) -> void:
	add_score += InScore
