extends Area2D

@export var relative_position: Vector2 = Vector2(256.0, 0.0)
@export_range(0.0, 360.0) var relative_rotation_degress: float = 0.0
@export var reset_camera: bool = false

func _ready() -> void:
	area_entered.connect(_on_target_entered)
	body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	
	if in_target is Pawn2D:
		in_target.teleport_to(in_target.global_position + relative_position, deg_to_rad(relative_rotation_degress), reset_camera)
	else:
		in_target.translate(relative_position)
		in_target.rotate(deg_to_rad(relative_rotation_degress))
