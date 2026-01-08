@tool
extends Area2D
class_name Pawn2D_Perception

static func try_get_from(in_node: Node) -> Pawn2D_Perception:
	return ModularGlobals.try_get_from(in_node, Pawn2D_Perception)

@export_category("Sight")
@export var sight_collision: CollisionShape2D
@export var sort_sight_targets: bool = false
@export var see_only_pawns: bool = true
@export var on_sight_shape_size_mul: float = 2.0

var _sort_sight_targets_timer: Timer
var sight_targets: Array[Node2D]
var sight_targets_sorted: Array[Node2D]

signal sight_targets_changed()

var default_sight_shape: Shape2D

func _ready() -> void:
	
	if Engine.is_editor_hint():
		pass
	else:
		area_entered.connect(_on_target_entered)
		body_entered.connect(_on_target_entered)
		
		area_exited.connect(_on_target_exited)
		body_exited.connect(_on_target_exited)
		
		_sort_sight_targets_timer = GameGlobals.spawn_regular_timer_for(self, _sort_sight_targets, 1.0)
		
		assert(sight_collision)
		assert(sight_collision.shape)
		default_sight_shape = sight_collision.shape
		
		sight_targets_changed.connect(_sort_sight_targets)
		
		sight_targets_changed.connect(_update_sight_collision_shape, Object.CONNECT_DEFERRED)
		_update_sight_collision_shape.call_deferred()

func _enter_tree():
	
	if Engine.is_editor_hint():
		if get_tree().edited_scene_root is LevelBase2D:
			visible = false
	else:
		ModularGlobals.init_modular_node(self)

func _exit_tree():
	
	if Engine.is_editor_hint():
		pass
	else:
		ModularGlobals.deinit_modular_node(self)

func _on_target_entered(in_target: Node2D) -> void:
	
	if see_only_pawns and (not in_target is Pawn2D):
		return
	
	force_add_sight_target(in_target)

func _on_target_exited(in_target: Node2D) -> void:
	
	if see_only_pawns and (not in_target is Pawn2D):
		return
	
	force_remove_sight_target(in_target)

func has_sight_target(in_target: Node2D) -> bool:
	return sight_targets.has(in_target)

func force_add_sight_target(in_target: Node2D) -> void:
	
	if has_sight_target(in_target):
		return
	
	in_target.tree_exited.connect(force_remove_sight_target.bind(in_target))
	
	sight_targets.append(in_target)
	sight_targets_changed.emit()

func force_remove_sight_target(in_target: Node2D) -> void:
	
	if not has_sight_target(in_target):
		return
	
	in_target.tree_exited.disconnect(force_remove_sight_target.bind(in_target))
	
	sight_targets.erase(in_target)
	sight_targets_changed.emit()

func _update_sight_collision_shape() -> void:
	
	if sight_targets_sorted.is_empty():
		sight_collision.shape = default_sight_shape
	else:
		sight_collision.shape = ResourceGlobals.get_or_create_scaled_shape(default_sight_shape, on_sight_shape_size_mul, 0.0)

func _sort_sight_targets() -> void:
	
	if sort_sight_targets:
		pass ## TODO: Sort
	else:
		sight_targets_sorted = sight_targets

func get_relevant_sight_target() -> Node2D:
	return null if sight_targets_sorted.is_empty() else sight_targets_sorted[0]

func is_valid_target(in_target: Node2D) -> bool:
	return sight_targets_sorted.has(in_target)
