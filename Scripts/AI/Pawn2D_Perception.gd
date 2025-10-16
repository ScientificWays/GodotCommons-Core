extends Area2D
class_name Pawn2D_Perception

static func try_get_from(in_node: Node) -> Pawn2D_Perception:
	return ModularGlobals.try_get_from(in_node, Pawn2D_Perception)

@export_category("Sight")
@export var sort_sight_targets: bool = false
@export var see_only_pawns: bool = true

var _sort_sight_targets_timer: Timer
var sight_targets: Array[Node2D]
var sight_targets_sorted: Array[Node2D]

signal sight_targets_changed()

func _ready() -> void:
	
	area_entered.connect(_on_target_entered)
	body_entered.connect(_on_target_entered)
	
	area_exited.connect(_on_target_exited)
	body_exited.connect(_on_target_exited)
	
	_sort_sight_targets_timer = GameGlobals.spawn_regular_timer_for(self, _sort_sight_targets_timer_timeout, 1.0)

func _enter_tree():
	ModularGlobals.init_modular_node(self)

func _exit_tree():
	ModularGlobals.deinit_modular_node(self)

func _on_target_entered(in_target: Node2D) -> void:
	
	if see_only_pawns and (not in_target is Pawn2D):
		return
	
	assert(not sight_targets.has(in_target))
	
	sight_targets.append(in_target)
	sight_targets_changed.emit()

func _on_target_exited(in_target: Node2D) -> void:
	
	if see_only_pawns and (not in_target is Pawn2D):
		return
	
	assert(sight_targets.has(in_target))
	
	sight_targets.erase(in_target)
	sight_targets_changed.emit()

func _sort_sight_targets_timer_timeout() -> void:
	
	if sort_sight_targets:
		pass ## TODO: Sort
	else:
		sight_targets_sorted = sight_targets

func get_relevant_sight_target() -> Node2D:
	return null if sight_targets_sorted.is_empty() else sight_targets_sorted[0]

func is_valid_target(in_target: Node2D) -> bool:
	return sight_targets_sorted.has(in_target)
