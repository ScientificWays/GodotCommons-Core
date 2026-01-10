@tool
extends Area2D

@export_category("Collision")
@export var collision_width: float = 16.0:
	set(in_width):
		collision_width = in_width
		_update_bounds()
@export var collision_offset: float = 1.0:
	set(in_offset):
		collision_offset = in_offset
		_update_bounds()

@onready var left: CollisionShape2D = $Left
@onready var right: CollisionShape2D = $Right
@onready var top: CollisionShape2D = $Top
@onready var down: CollisionShape2D = $Down

var _owner_camera: PlayerCamera2D

func _ready() -> void:
	
	_owner_camera = get_parent() as PlayerCamera2D
	_owner_camera.zoom_changed.connect(_on_owner_camera_zoom_changed)
	
	if Engine.is_editor_hint():
		set_physics_process(false)
	else:
		pass
	
	_on_viewport_size_changed()

func _physics_process(in_delta: float) -> void:
	global_position = _owner_camera.get_screen_center_position()

func _enter_tree() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _exit_tree() -> void:
	get_viewport().size_changed.disconnect(_on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
	_update_bounds()

func _on_owner_camera_zoom_changed() -> void:
	#print("_on_owner_camera_zoom_changed")
	_update_bounds()

func _update_bounds() -> void:
	
	if not is_node_ready():
		pass
	
	var bounds_size := get_viewport_rect().size
	
	if _owner_camera:
		bounds_size /= _owner_camera.zoom
	
	(left.shape as RectangleShape2D).size = Vector2(collision_width, bounds_size.y * collision_offset + collision_width)
	(right.shape as RectangleShape2D).size = Vector2(collision_width, bounds_size.y * collision_offset + collision_width)
	(top.shape as RectangleShape2D).size = Vector2(bounds_size.x * collision_offset + collision_width, collision_width)
	(down.shape as RectangleShape2D).size = Vector2(bounds_size.x * collision_offset + collision_width, collision_width)
	
	var position_mul := collision_offset * 0.5
	left.position = Vector2(-bounds_size.x * position_mul, 0.0)
	right.position = Vector2(bounds_size.x * position_mul, 0.0)
	top.position = Vector2(0.0, -bounds_size.y * position_mul)
	down.position = Vector2(0.0, bounds_size.y * position_mul)
