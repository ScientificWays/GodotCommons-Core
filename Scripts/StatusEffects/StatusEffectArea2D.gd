extends Area2D
class_name StatusEffectArea2D

static func spawn(in_global_position: Vector2, in_scene: PackedScene, in_level: int, in_instigator: Node) -> StatusEffectArea2D:
	
	assert(in_scene)
	
	var out_area := in_scene.instantiate() as StatusEffectArea2D
	out_area._level = in_level
	out_area._instigator = in_instigator
	out_area.set_position(in_global_position)
	
	WorldGlobals._level.add_child.call_deferred(out_area)
	return out_area

@export_category("Compontents")
@export var particles_pivot: ParticlesPivot

@export_category("Expire")
@export var auto_expire_duration_base: float = 5.0
@export var auto_expire_duration_per_level_gain: float = 0.0

func get_auto_expire_duration() -> float:
	return auto_expire_duration_base + auto_expire_duration_per_level_gain + _level

@export_category("Effect")
@export var status_effect_data: StatusEffectData
@export var status_effect_duration: float = 4.0
@export var status_effect_reapply_tick: float = 1.0

var _level: int = 0
var _instigator: Node:
	set(in_instigator):
		
		if _instigator:
			_instigator.tree_exited.disconnect(_on_instigator_exited_tree)
		
		_instigator = in_instigator
		
		if _instigator:
			_instigator.tree_exited.connect(_on_instigator_exited_tree)

var auto_expire_timer: Timer
var reapply_timer: Timer

signal applied(in_target: Node2D)

func _ready():
	
	assert(particles_pivot)
	
	var auto_expire_duration := get_auto_expire_duration()
	if auto_expire_duration > 0.0:
		auto_expire_timer = GameGlobals.spawn_one_shot_timer_for(self, _on_auto_expire_timer_timeout, auto_expire_duration)
	
	if status_effect_reapply_tick > 0.0:
		reapply_timer = GameGlobals.spawn_regular_timer_for(self, _on_reapply_timer_timeout, status_effect_reapply_tick, false)

func _on_target_entered(in_target: Node2D):
	try_apply_effect_to(in_target)

func _on_auto_expire_timer_timeout():
	particles_pivot.DetachAndRemoveAll()
	queue_free()

func _on_reapply_timer_timeout():
	var OverlappingBodies := get_overlapping_bodies()
	for TargetOverlappingBody: Node2D in OverlappingBodies:
		try_apply_effect_to(TargetOverlappingBody)

func try_apply_effect_to(in_target: Node2D):
	
	var target_receiver := StatusEffectReceiver.try_get_from(in_target)
	if target_receiver:
		if target_receiver.try_apply_status_effect(status_effect_data, self, _instigator, _level, status_effect_duration) != StatusEffectInstance.INVALID_HANDLE:
			applied.emit(target_receiver)

func _on_instigator_exited_tree():
	_instigator = null
