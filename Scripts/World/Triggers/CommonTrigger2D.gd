@tool
extends Area2D
class_name CommonTrigger2D

signal triggered()
signal triggered_verbose(in_trigger: CommonTrigger2D, in_source: Node2D)

@export_category("Collision")
@export var collision: CollisionShape2D:
	set(in_collision):
		collision = in_collision
		if collision and collision_shape:
			collision.shape = collision_shape

@export var collision_shape: Shape2D:
	set(in_shape):
		collision_shape = in_shape
		if collision:
			collision.shape = collision_shape

@export_category("Trigger")
@export var is_enabled: bool = true
@export var cooldown: float = -1.0

var cooldown_timer: Timer

func _ready() -> void:
	
	if Engine.is_editor_hint():
		
		if not collision:
			collision = find_child("*ollision*")
		
		if collision:
			
			collision.debug_color = Color(Color.ORANGE, 0.25)
			
			if not collision.shape:
				collision_shape = RectangleShape2D.new()
				collision_shape.size = Vector2(32.0, 32.0)
				collision_shape.resource_local_to_scene = true
	else:
		area_entered.connect(_on_target_entered)
		body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	trigger(in_target)

func trigger(in_source: Node2D = null) -> bool:
	
	if not can_trigger():
		return false
	
	triggered.emit()
	triggered_verbose.emit(self, in_source)
	
	start_cooldown()
	return true

func can_trigger() -> bool:
	return is_enabled and ((not cooldown_timer) or cooldown_timer.is_stopped())

func enable() -> void:
	is_enabled = true

func disable() -> void:
	is_enabled = false

func start_cooldown() -> void:
	
	if cooldown < 0.0:
		
		queue_free()
		
	elif cooldown > 0.0:
		
		cooldown_timer = GameGlobals.spawn_one_shot_timer_for(self, finish_cooldown, cooldown)
	else:
		pass

func finish_cooldown() -> void:
	cooldown_timer = null
