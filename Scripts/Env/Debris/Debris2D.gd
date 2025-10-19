@tool
extends Area2D
class_name Debris2D

@export var sprite: Sprite2D
@export var break_gibs: Array[PackedScene] = [
	preload("res://Scenes/Env/Gibs/Stone/StoneGib001.tscn")
]
@export var break_gibs_num_min_max: Vector2i = Vector2i(1, 2)

func _ready() -> void:
	
	if Engine.is_editor_hint():
		pass
	else:
		sprite.frame = randi_range(0, sprite.hframes * sprite.vframes - 1)
	
	area_entered.connect(_on_target_entered)
	body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	pass

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	handle_break(in_impulse, true)
	return true

func handle_break(in_impulse: Vector2, in_try_ignite: bool) -> void:
	
	assert(not break_gibs.is_empty())
	
	var impulse_magnitude := in_impulse.length()
	
	for sample_index: int in range(randi_range(break_gibs_num_min_max.x, break_gibs_num_min_max.y)):
		
		var sample_gib := break_gibs.pick_random().instantiate() as Gib2D
		sample_gib.position = position
		sample_gib.rotation = randf_range(-PI, PI)
		add_sibling.call_deferred(sample_gib)
		
		sample_gib.ready.connect(func():
			sample_gib.apply_central_impulse(in_impulse.rotated(randf_range(-0.2, 0.2)) * randf_range(0.5, 1.0))
			sample_gib.apply_torque_impulse(randf_range(-PI, PI))
		, Object.CONNECT_DEFERRED)
		
		if in_try_ignite:
			sample_gib.try_ignite(impulse_magnitude * randf_range(0.04, 0.08))
	queue_free()
