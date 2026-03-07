@abstract
extends Node
class_name AnimMontagePlayer

func _ready() -> void:
	pass

@export_category("State")
var is_playing_montage: bool = false

@abstract
func play_montage(in_name: StringName, in_custom_speed: float = 1.0, in_from_end: bool = false, in_should_reset_on_finish: bool = true) -> void

@abstract
func cancel_montage(in_specific_animation_name: StringName = &"") -> void

func _handle_montage_reset():
	is_playing_montage = false
