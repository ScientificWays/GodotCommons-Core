@tool
extends Area2D
class_name Debris2D

@export var sprite: Node2D

@export var break_gibs: Array[PackedScene] = [
	preload("res://Scenes/Env/Gibs/Stone/StoneGib001.tscn")
]
@export var break_gibs_num_min_max: Vector2i = Vector2i(1, 2)
@export var break_stages_num: int = 0
@export var break_stages_animation_name: StringName = &"Break"
@export var remove_on_last_break_stage: bool = true

@export var apply_past_last_break_stage_effects: bool = true
@export var past_last_break_stage_darkening: float = 0.2
@export var past_last_break_stage_shrinking_speed: float = 0.1

var break_current_stage: int = 0

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not sprite:
			sprite = find_child("*?prite*")
	else:
		assert(sprite)
		
		if sprite is Sprite2D:
			sprite.frame = randi_range(0, sprite.hframes * sprite.vframes - 1)
		elif sprite is AnimatedSprite2D:
			pass
		
		break_current_stage = -1
	
	area_entered.connect(_on_target_entered)
	body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	pass

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	handle_break(in_impulse, true)
	return true

func handle_break(in_impulse: Vector2, in_try_ignite: bool) -> void:
	
	if break_current_stage > break_stages_num:
		if apply_past_last_break_stage_effects:
			modulate = modulate.darkened(past_last_break_stage_darkening)
			sprite.scale = sprite.scale.lerp(Vector2(0.5, 0.5), past_last_break_stage_shrinking_speed)
		return
	
	break_current_stage += 1
	
	spawn_break_gibs(in_impulse, in_try_ignite)
	
	if break_current_stage == break_stages_num:
		
		if remove_on_last_break_stage:
			queue_free()
		#else:
		#	monitorable = false
	else:
		if sprite is AnimatedSprite2D:
			sprite.animation = break_stages_animation_name
			sprite.frame = break_current_stage
			sprite.pause()

func spawn_break_gibs(in_impulse: Vector2, in_try_ignite: bool) -> void:
	
	assert(not break_gibs.is_empty())
	
	var impulse_magnitude := in_impulse.length()
	
	for sample_index: int in range(randi_range(break_gibs_num_min_max.x, break_gibs_num_min_max.y)):
		
		var sample_gib := break_gibs.pick_random().instantiate() as Gib2D
		sample_gib.position = position
		sample_gib.rotation = randf_range(-PI, PI)
		add_sibling.call_deferred(sample_gib)
		
		sample_gib.ready.connect(func():
			sample_gib.apply_central_impulse(in_impulse.rotated(randf_range(-0.2, 0.2)) * randf_range(0.5, 1.5))
			sample_gib.apply_torque_impulse(randf_range(-PI, PI))
		, Object.CONNECT_DEFERRED)
		
		if in_try_ignite:
			sample_gib.try_ignite(impulse_magnitude * randf_range(0.04, 0.08))
