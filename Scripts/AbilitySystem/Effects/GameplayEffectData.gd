extends Resource
class_name StatusEffectData

@export var tick_time: float = -1.0
@export var first_tick_time: float = -1.0
@export var attrbiute_modifier_data_array: Array[AttributeModifierData]

## If true, more than one instance if this Data can be applied
@export var can_stack: bool = false
@export var should_extend_duration_on_reapply: bool = true

@export var particles_scene: PackedScene
@export var creature_sprite_modulate: Color = Color.WHITE

func _on_applied(in_instance: StatusEffectInstance) -> void:
	pass

func _on_removed(in_instance: StatusEffectInstance) -> void:
	pass

func _on_tick(in_instance: StatusEffectInstance) -> void:
	pass

func _on_recalc_attributes(in_instance: StatusEffectInstance) -> void:
	pass

func _on_owner_tree_exiting(in_instance: StatusEffectInstance) -> void:
	pass
