@tool
extends Control
class_name VHSFX

@export var target: Control:
	set(InTarget):
		target = InTarget
		set_process(target and toggle)

@export var scale_speed: float = 6.0
@export var scale_offset: float = 0.02
@export var toggle: bool = true:
	set(InToggle):
		toggle = InToggle
		set_process(target and toggle)

var time: float

func _ready() -> void:
	
	if target:
		target.pivot_offset = target.size * 0.5
	set_process(target and toggle)
	
	visibility_changed.connect(OnVisibilityChanged)
	OnVisibilityChanged()

func OnVisibilityChanged() -> void:
	
	if visible:
		$AnimationPlayer.play(&"Show")

func _process(InDelta: float) -> void:
	
	time += InDelta
	
	var new_scale := 1.0 + sin(time * scale_speed) * scale_offset
	target.scale = Vector2(new_scale, new_scale)
	
	target.position = -target.pivot_offset
	target.position.y += sin(time * 1.5) * 2.0
	
	target.rotation = sin(time * 1.5) * 0.02
	
	if randf() > 0.99:
		target.modulate.a = 0.0
	else:
		target.modulate.a = 0.9 + randf() * 0.1
