extends Area2D
class_name LevelTransitionArea2D

@export_category("Transition")
@export var change_level: ChangeLevel

func _ready() -> void:
	
	assert(change_level)
	
	area_entered.connect(_on_target_entered)
	body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D):
	change_level.trigger_transition()

func is_enabled() -> bool:
	return monitoring

func enable() -> void:
	monitoring = true

func disable() -> void:
	monitoring = false
