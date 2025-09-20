@tool
extends Control
class_name VHSFX

@export var target: Control:
	set(InTarget):
		target = InTarget
		Update()

@export var scale_speed: float = 6.0
@export var scale_offset: float = 0.02

@export var rotation_speed: float = 1.5
@export var rotation_offset: float = 0.02

@export var toggle: bool = true:
	set(InToggle):
		toggle = InToggle
		Update()

@export var position_offset: Vector2 = Vector2(0.0, 0.0):
	set(InOffset):
		position_offset = InOffset
		Update()

@export var lerp_visible: bool = true:
	set(InVisible):
		lerp_visible = InVisible
		Update.call_deferred()

@export var lerp_visible_speed: float = 4.0

var time: float

func _ready() -> void:
	Update.call_deferred()

func _notification(InCode: int) -> void:
	
	if InCode == NOTIFICATION_EDITOR_PRE_SAVE:
		Update()
	elif InCode == NOTIFICATION_TRANSLATION_CHANGED:
		Update()

func _process(InDelta: float) -> void:
	
	if lerp_visible:
		modulate.a = minf(modulate.a + lerp_visible_speed * InDelta, 1.0)
	else:
		modulate.a = maxf(modulate.a - lerp_visible_speed * InDelta, 0.0)
	
	time += InDelta
	
	var new_scale := 1.0 + sin(time * scale_speed) * scale_offset
	target.scale = Vector2(new_scale, new_scale)
	
	var position_target := GetPositionTarget()
	position_target.position = position_offset - position_target.pivot_offset + pivot_offset
	position_target.position.y += sin(time * 1.5) * 2.0
	
	target.rotation = sin(time * rotation_speed) * rotation_offset
	
	if randf() > 0.99:
		target.modulate.a = 0.0
	else:
		target.modulate.a = 0.9 + randf() * 0.1

func GetPositionTarget() -> Control:
	return target

func Update() -> void:
	
	if target:
		target.pivot_offset = target.size * 0.5
	set_process(target and toggle)

func SetInstantLerpVisible(InLerpVisible: bool) -> void:
	
	lerp_visible = InLerpVisible
	
	if lerp_visible:
		modulate.a = 1.0
	else:
		modulate.a = 0.0
