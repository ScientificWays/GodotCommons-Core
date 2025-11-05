extends Node2D
class_name DamageNumberUI

@export_category("Label")
@export var label: VHSLabel

@export_category("Material")
@export var shader_material_split_amount_parameter: StringName = &"split_amount"

@export_category("Animations")
@export var animation_player: AnimationPlayer
@export var pop_up_animation_name: StringName = &"pop_up"

var damage: float

func _ready() -> void:
	
	var impact_value: float = 0.0
	impact_value = 0.05 + damage * 0.005
	
	var sample_scale := 0.5 + impact_value * 0.4
	if damage < 15.0:
		sample_scale *= lerpf(0.5, 1.0, damage / 15.0)
	
	## Display some extra digits and trim the rest
	var decimals_num := 0
	if damage < 1.0:
		
		if damage < 0.1:
			decimals_num = 2
			damage = ceilf(damage * 100.0) * 0.01
		else:
			decimals_num = 1
			damage = ceilf(damage * 10.0) * 0.1
	else:
		damage = ceilf(damage)
	
	label.label_text = "-" + String.num(damage, decimals_num)
	label.scale *= sample_scale
	
	var clamped_impact_value := clampf(impact_value, 0.0, 1.0)
	modulate = Color(1.0, 1.0 - clamped_impact_value, 1.0 - clamped_impact_value)
	
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	
	var duration := lerpf(2.0, 4.0, clamped_impact_value)
	animation_player.play(pop_up_animation_name, -1.0, 1.0 / duration)

func _on_animation_player_animation_finished(in_animation_name: StringName) -> void:
	
	if in_animation_name == pop_up_animation_name:
		queue_free()
