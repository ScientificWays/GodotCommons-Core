@tool
extends Control
class_name VHSFX

@export var animation_player: AnimationPlayer
@export var show_animation: StringName = &"Show"

@export var target: Control:
	set(InTarget):
		target = InTarget
		Update()

@export var scale_speed: float = 6.0
@export var scale_offset: float = 0.02
@export var toggle: bool = true:
	set(InToggle):
		toggle = InToggle
		Update()

@export var position_offset: Vector2 = Vector2(0.0, 0.0):
	set(InOffset):
		position_offset = InOffset
		Update()

var time: float

func _ready() -> void:
	
	visibility_changed.connect(OnVisibilityChanged)
	OnVisibilityChanged()

func _process(InDelta: float) -> void:
	
	time += InDelta
	
	var new_scale := 1.0 + sin(time * scale_speed) * scale_offset
	target.scale = Vector2(new_scale, new_scale)
	
	var position_target := GetPositionTarget()
	position_target.position = target.size * position_offset - target.pivot_offset
	position_target.position.y += sin(time * 1.5) * 2.0
	
	target.rotation = sin(time * 1.5) * 0.02
	
	if randf() > 0.99:
		target.modulate.a = 0.0
	else:
		target.modulate.a = 0.9 + randf() * 0.1

func GetPositionTarget() -> Control:
	return target

func OnVisibilityChanged() -> void:
	
	if visible and animation_player:
		animation_player.play(show_animation)

func Update() -> void:
	
	if target:
		target.pivot_offset = target.size * 0.5
	set_process(target and toggle)
	
