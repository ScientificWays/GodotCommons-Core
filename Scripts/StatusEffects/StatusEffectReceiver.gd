extends Node
class_name StatusEffectReceiver

static func try_get_from(in_node: Node) -> StatusEffectReceiver:
	return ModularGlobals.try_get_from(in_node, StatusEffectReceiver)

@export_category("Attributes")
@export var attribute_set: AttributeSet

signal instance_applied(in_instance: StatusEffectInstance)
signal instance_removed(in_instance: StatusEffectInstance)
signal post_recalc_attributes()

var _instance_array: Array[StatusEffectInstance]

func _ready() -> void:
	pass

func _enter_tree():
	ModularGlobals.init_modular_node(self)

func _exit_tree():
	ModularGlobals.deinit_modular_node(self)

func _process(in_delta: float):
	_process_status_effects(in_delta)

func _process_status_effects(in_delta: float):
	for sample_instance: StatusEffectInstance in _instance_array:
		sample_instance.HandleTick(in_delta)

func get_status_effect_handle(in_data: StatusEffectData) -> int:
	for sample_instance: StatusEffectInstance in _instance_array:
		if sample_instance.data == in_data:
			return sample_instance._Handle
	return StatusEffectInstance.INVALID_HANDLE

func try_apply_status_effect(in_data: StatusEffectData, in_source: Node2D, in_instigator: Node, in_level: int, in_duration: float = -1.0) -> int:
	
	if not in_data.can_stack:
		
		for sample_instance: StatusEffectInstance in _instance_array:
			
			if sample_instance.data == in_data:
				
				sample_instance.source = in_source
				sample_instance.instigator = in_instigator
				sample_instance.level = in_level
				
				if in_data.should_extend_duration_on_reapply:
					sample_instance.expire_time_left = maxf(sample_instance.expire_time_left, in_duration)
				
				return sample_instance.handle
	
	var new_instance := StatusEffectInstance.new(self, in_source, in_instigator, in_data, in_level, in_duration)
	_instance_array.append(new_instance)
	new_instance._on_applied()
	return new_instance.handle

func try_remove_status_effect_by_handle(in_handle: int) -> bool:
	for sample_index: int in range(_instance_array.size()):
		var sample_instance := _instance_array[sample_index]
		if sample_instance.handle == in_handle:
			_instance_array.remove_at(sample_index)
			sample_instance._on_removed()
			return true
	return false

## Does not use GetStatusEffectHandle() because
## it would require run through for loop twice
## Removes only the first occurence of the effect
func TryRemoveStatusEffectByData(in_data: StatusEffectData) -> bool:
	for sample_index: int in range(_instance_array.size()):
		var sample_instance := _instance_array[sample_index]
		if sample_instance.data == in_data:
			_instance_array.remove_at(sample_index)
			sample_instance._on_removed()
			return true
	return false

func recalc_attributes() -> void:
	
	attribute_set.reset_all()
	
	for sample_instance: StatusEffectInstance in _instance_array:
		sample_instance._on_recalc_attributes()
	
	post_recalc_attributes.emit()
