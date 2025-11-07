@tool
extends Area2D
class_name SpawnerTrigger2D

@export_category("Points")
@export var spawn_points: Array[Node2D]

@export_category("Animations")
@export var animation_player: AnimationPlayer
@export var animation_name: StringName = &"trigger"

@export_category("Pawns")
@export var pool_size: float = 5.0
@export var wave_data: PawnWaveData2D
@export var delay_min: float = 3.0
@export var delay_max: float = 5.0
@export var initial_delay_mul: float = 0.4

var is_active: bool = false
var delay_timer: Timer

signal pool_depleted()
var pool_left: float = 0.0:
	set(in_left):
		
		pool_left = in_left
		
		if pool_left <= 0.0:
			pool_depleted.emit()

signal activated()
signal deactivated()

func _ready() -> void:
	
	if Engine.is_editor_hint():
		
		if spawn_points.is_empty():
			var valid_points: Array[Node2D] = []
			for sample_child: Node in find_children("*pawn*"):
				if sample_child is Node2D: valid_points.append(sample_child)
			spawn_points = valid_points
		
		if not animation_player:
			animation_player = find_child("*nimation*layer*")
	else:
		if spawn_points.is_empty():
			spawn_points.append(self)
		
		pool_left = pool_size
		
		area_entered.connect(_on_target_entered)
		body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	activate()

func _on_target_exited(in_target: Node2D) -> void:
	
	if has_overlapping_areas() or has_overlapping_bodies():
		pass
	else:
		deactivate()

func activate() -> void:
	
	if is_active or pool_left <= 0.0:
		return
	
	trigger_delay_timer(true)
	is_active = true
	
	activated.emit()

func deactivate() -> void:
	
	if not is_active:
		return
	
	stop_delay_timer()
	is_active = false
	
	deactivated.emit()

func trigger_delay_timer(in_initial: bool) -> void:
	
	if not delay_timer:
		delay_timer = GameGlobals.spawn_regular_timer_for(self, _on_delay_timer_timeout, 1.0, false)
	
	var delay := randf_range(delay_min, delay_max)
	if in_initial:
		delay *= initial_delay_mul
	
	delay_timer.start(delay)

func stop_delay_timer() -> void:
	
	if delay_timer:
		delay_timer.stop()

func _on_delay_timer_timeout() -> void:
	
	try_spawn_wave()
	
	if pool_left > 0.0:
		trigger_delay_timer(false)
	else:
		deactivate()

func try_spawn_wave() -> float:
	
	var out_spawned_size := wave_data.try_spawn_wave(init_wave_pawn, pool_left)
	pool_left -= out_spawned_size
	
	if out_spawned_size > 0.0 and animation_player:
		animation_player.play(animation_name)
	return out_spawned_size

func init_wave_pawn(in_pawn: Pawn2D) -> void:
	
	var sample_spawn := spawn_points.pick_random() as Node2D
	in_pawn.position = sample_spawn.global_position
	WorldGlobals._level._y_sorted.add_child.call_deferred(in_pawn)
