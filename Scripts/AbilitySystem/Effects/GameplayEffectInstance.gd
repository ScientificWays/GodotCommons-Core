extends RefCounted
class_name StatusEffectInstance

const INVALID_HANDLE: int = -1

var owner: StatusEffectReceiver:
	set(in_owner):
		if owner: owner.tree_exiting.disconnect(_on_owner_tree_exiting)
		owner = in_owner
		if owner: owner.tree_exiting.connect(_on_owner_tree_exiting)

var source: Node2D:
	set(InSource):
		if source: source.tree_exiting.disconnect(_on_source_tree_exiting)
		source = InSource
		if source: source.tree_exiting.connect(_on_source_tree_exiting)

var instigator: Node:
	set(InInstigator):
		if instigator: instigator.tree_exiting.disconnect(_on_instigator_tree_exiting)
		instigator = InInstigator
		if instigator: instigator.tree_exiting.connect(_on_instigator_tree_exiting)

var data: StatusEffectData
var level: int
var expire_time_left: float
var tick_time_left: float
var handle: int
var particles: GPUParticles2D
var is_tick_muted: bool

func _init(in_owner: StatusEffectReceiver, in_source: Node2D, in_instigator: Node, in_data: StatusEffectData, in_level: int, in_duration: float) -> void:
	
	owner = in_owner
	source = in_source
	instigator = in_instigator
	data = in_data
	level = in_level
	expire_time_left = in_duration
	
	if data.FirstTickTime > 0.0:
		tick_time_left = data.FirstTickTime
	else:
		tick_time_left = data.TickTime
	
	handle = GameGlobals.generate_new_status_effect_handle()

func _on_applied() -> void:
	
	if is_instance_valid(owner._CreatureSprite):
		owner._CreatureSprite.ApplyStatusEffectVisuals(self)
	
	data._on_applied(self)
	owner.recalc_attributes()
	owner.instance_applied.emit(self)

func _on_removed() -> void:
	
	if is_instance_valid(owner._CreatureSprite):
		owner._CreatureSprite.RemoveStatusEffectVisuals(self)
	
	data._on_removed(self)
	owner.recalc_attributes()
	owner.instance_removed.emit(self)
	#free()

func _on_process(InDelta: float) -> void:
	
	if expire_time_left > 0.0:
		expire_time_left -= InDelta
		if expire_time_left > 0.0:
			pass
		else:
			owner.TryRemoveStatusEffectByHandle.call_deferred(handle)
		
	if tick_time_left > 0.0 and not is_tick_muted:
		tick_time_left -= InDelta
		if tick_time_left > 0.0:
			pass
		else:
			data._OnTick(self)
			tick_time_left += data.TickTime

func _on_recalc_attributes() -> void:
	
	for sample_modifier_data: AttributeModifierData in data.AttrbiuteModifierDataArray:
		
		var sample_attribute := owner.attribute_set.get_or_init_attribute(sample_modifier_data.attribute_name)
		
		## Accumulate effects to current value
		## base_value is used in recalc_attributes()
		var new_value := sample_attribute.current_value
		
		match sample_modifier_data._OperationType:
			AttributeModifierData.OperationType.Add:
				new_value += sample_modifier_data.GetMagnitude(level)
			AttributeModifierData.OperationType.Multiply:
				new_value *= sample_modifier_data.GetMagnitude(level)
		sample_attribute.current_value = new_value
	data._on_recalc_attributes(self)

func _on_owner_tree_exiting() -> void:
	data._on_owner_tree_exiting(self)
	#free()

func _on_source_tree_exiting() -> void:
	source = null

func _on_instigator_tree_exiting() -> void:
	instigator = null
