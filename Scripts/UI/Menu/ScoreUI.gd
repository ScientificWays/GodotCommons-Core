extends Control
class_name ScoreUI

@export_category("Stats")
@export var ExperienceConversion: ScoreUI_Conversion
@export var TimeConversion: ScoreUI_Conversion

@export_category("Score")
@export var ScoreLabel: VHSLabel

var visual_prev_score: int = 0
var visual_add_score: float = 0.0:
	set(in_score):
		visual_add_score = in_score
		ScoreLabel.label_text = "%d + %d" % [ visual_prev_score, ceili(visual_add_score) ]

func _ready() -> void:
	ExperienceConversion.Converted.connect(on_stat_converted)
	TimeConversion.Converted.connect(on_stat_converted)

func handle_animated_sequence() -> void:
	
	visual_prev_score = WorldGlobals._game_state.current_score
	visual_add_score = 0.0
	
	var final_add_score := ExperienceConversion.get_final_add_score()
	final_add_score += TimeConversion.get_final_add_score()
	
	await WorldGlobals._game_state.add_score(ceili(final_add_score))
	
	await get_tree().create_timer(0.25).timeout
	await ExperienceConversion.handle_animated_sequence()
	
	await get_tree().create_timer(0.25).timeout
	await TimeConversion.handle_animated_sequence()

func on_stat_converted(in_score: float) -> void:
	visual_add_score += in_score
