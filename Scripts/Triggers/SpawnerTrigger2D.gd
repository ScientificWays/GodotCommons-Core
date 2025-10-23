@tool
extends Area2D
class_name SpawnerTrigger2D

@export_category("Points")
@export var spawn_points: Array[Node2D]

@export_category("Animations")
@export var animation_player: AnimationPlayer:
	get():
		if not animation_player:
			return find_child("*nimation*layer*")
		return animation_player

@export var animation_name: StringName = &"trigger"

@export_category("Pawns")
@export var pool_size: float = 5.0
@export var pawns: Array[PackedScene]
@export var pawns_weights: Array[float]
@export var wave_size_min: float = 1.0
@export var wave_size_max: float = 2.0
@export var delay_min: float = 3.0
@export var delay_max: float = 5.0
@export var initial_delay_mul: float = 0.4

var is_active: bool = false
var delay_timer: Timer
var pool_left: float = 0.0

func _ready() -> void:
	
	if Engine.is_editor_hint():
		pass
	else:
		assert(not spawn_points.is_empty())
		
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

func deactivate() -> void:
	
	if not is_active:
		return
	
	stop_delay_timer()
	is_active = false

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
	
	spawn_wave()
	
	if pool_left > 0.0:
		trigger_delay_timer(false)
	else:
		deactivate()

func spawn_wave() -> void:
	
	if animation_player:
		animation_player.play(animation_name)
	
	var wave_size := randf_range(wave_size_min, wave_size_max)
	while wave_size > 0.0 and pool_left > 0.0:
		
		var sample_pawn_scene := pawns[GameGlobals_Class.ArrayGetRandomIndexWeighted(pawns_weights)]
		var sample_pawn := sample_pawn_scene.instantiate() as Pawn2D
		
		init_wave_pawn(sample_pawn)
		
		var sample_spawn := spawn_points.pick_random() as Node2D
		sample_pawn.position = sample_spawn.position
		sample_spawn.add_sibling(sample_pawn)
		
		wave_size -= sample_pawn.SpawnValue
		pool_left -= sample_pawn.SpawnValue

func init_wave_pawn(in_pawn: Pawn2D) -> void:
	pass
