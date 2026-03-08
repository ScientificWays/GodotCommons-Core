extends Area2D
class_name FallTriggerArea2D

@export var default_sequence_scene: PackedScene = preload("res://addons/GodotCommons-Core/Scenes/Triggers/FallTriggerDefaultSequence.tscn")

func _ready() -> void:
	area_entered.connect(_on_target_entered)
	body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	try_trigger_target_fall(in_target)

func try_trigger_target_fall(in_target: Node2D) -> bool:
	
	assert(in_target)
	
	var target_sequence := FallTriggerTile_Sequence.try_get_from(in_target)
	if not is_instance_valid(target_sequence):
		target_sequence = default_sequence_scene.instantiate()
		in_target.add_child(target_sequence)
	
	target_sequence.try_trigger_sequence(self)
	return true
