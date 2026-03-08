extends Area2D
class_name RelativeTeleport2D

@export_category("Position")
@export var relative_position: Vector2 = Vector2(256.0, 0.0)
@export_range(0.0, 360.0) var relative_rotation_degress: float = 0.0

@export_category("Camera")
@export var reset_camera: bool = false

@export_category("Fade")
@export var fade_in: float = 0.0
@export var fade_out: float = 0.0

func _ready() -> void:
	area_entered.connect(_on_target_entered)
	body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	handle_target_teleport.call_deferred(in_target)

func handle_target_teleport(in_target: Node2D) -> void:
	
	var target_player := PlayerController.try_get_from(in_target)
	if target_player:
		await target_player.trigger_fade_in(fade_in)
	
	if in_target is Pawn2D:
		in_target.teleport_to(in_target.global_position + relative_position, deg_to_rad(relative_rotation_degress), reset_camera)
	else:
		in_target.translate(relative_position)
		in_target.rotate(deg_to_rad(relative_rotation_degress))
	
	if target_player:
		await target_player.trigger_fade_out(fade_out)
