@tool
extends Area2D
class_name ArenaTrigger2D

@export var _collision_shape: Shape2D:
	set(in_shape):
		
		_collision_shape = in_shape
		
		if is_node_ready():
			$Collision.shape = _collision_shape
@export var camera_limits: Vector2 = Vector2(512.0, 512.0):
	set(in_limits):
		
		camera_limits = in_limits
		
		if is_node_ready():
			$CameraLimits.shape.size = camera_limits
			_update_block_collision()

@export var camera_zoom_mul: float = 0.7
@export_flags_2d_physics var limits_collision: int = GameGlobals_Class.collision_layer_player_block

@export var waves_data: Array[ArenaTrigger2D_WaveData]
@export var spawn_points: Array[Node2D]

var is_active: bool = false:
	set(in_is_active):
		is_active = in_is_active
		_update_block_collision()

var was_finished: bool = false

var current_target: Node

var current_wave_index: int = -1
var current_wave_pawns: Array[Pawn2D]

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not _collision_shape:
			_collision_shape = RectangleShape2D.new()
			_collision_shape.resource_local_to_scene = true
			_collision_shape.size = Vector2(16.0, 512.0)
	else:
		assert(not waves_data.is_empty())
		assert(not spawn_points.is_empty())
	
	$Collision.shape = _collision_shape
	$CameraLimits.shape.size = camera_limits
	_update_block_collision()
	
	area_entered.connect(_on_target_entered)
	body_entered.connect(_on_target_entered)

func _on_target_entered(in_target: Node2D) -> void:
	
	if not is_active and not was_finished:
		
		var target_player := PlayerController.try_get_from(in_target)
		if target_player:
			activate_for_target(target_player)
		else:
			activate_for_target(in_target)
		
		try_spawn_next_wave()

func activate_for_target(in_target: Node) -> void:
	
	assert(not is_active)
	is_active = true
	
	assert(not current_target)
	current_target = in_target
	
	if current_target is PlayerController:
		current_target._camera.set_camera_limits(global_position, camera_limits * 0.5)
		current_target._camera.PendingZoomLerpSpeed *= 0.5
		current_target._camera.PendingZoom *= camera_zoom_mul
		current_target.ControlledPawnChanged.connect(_on_target_player_controlled_pawn_changed)

func deactivate_for_target() -> void:
	
	if current_target is PlayerController:
		current_target._camera.reset_camera_limits()
		current_target._camera.PendingZoomLerpSpeed /= 0.5
		current_target._camera.PendingZoom /= camera_zoom_mul
		current_target.ControlledPawnChanged.disconnect(_on_target_player_controlled_pawn_changed)
	
	is_active = false
	current_target = null

func try_spawn_next_wave() -> bool:
	
	if GameGlobals_Class.ArrayIsValidIndex(waves_data, current_wave_index + 1) and current_wave_pawns.is_empty():
		current_wave_index += 1
		spawn_wave(current_wave_index)
		return true
	finish_waves()
	return false

func pause_waves() -> void:
	
	assert(is_active and current_wave_index > -1)
	current_wave_index -= 1
	
	for sample_pawn: Pawn2D in current_wave_pawns:
		sample_pawn.HealthDamageReceiver.ReceiveLethalDamage.disconnect(_on_pawn_receive_lethal_damage)
		sample_pawn.tree_exited.disconnect(_on_pawn_exited_tree)
	current_wave_pawns.clear()
	
	deactivate_for_target()

func finish_waves() -> void:
	
	was_finished = true
	
	deactivate_for_target()

func spawn_wave(in_index: int) -> void:
	
	assert(current_wave_pawns.is_empty())
	
	var wave_data := waves_data[in_index]
	for sample_scene: PackedScene in wave_data.pawns_array:
		
		var sample_pawn := sample_scene.instantiate() as Pawn2D
		var random_spawn := spawn_points.pick_random() as Node2D
		
		sample_pawn.position = random_spawn.global_position
		add_sibling.call_deferred(sample_pawn)
		
		sample_pawn.HealthDamageReceiver.ReceiveLethalDamage.connect(_on_pawn_receive_lethal_damage.bind(sample_pawn))
		sample_pawn.tree_exited.connect(_on_pawn_exited_tree.bind(sample_pawn))
		current_wave_pawns.append(sample_pawn)

func _on_pawn_receive_lethal_damage(in_source: Node, in_damage: float, in_ignored_immunity_time: bool, in_pawn: Pawn2D) -> void:
	pass

func _on_pawn_exited_tree(in_pawn: Pawn2D) -> void:
	
	if in_pawn.is_queued_for_deletion():
		handle_wave_pawn_defeated(in_pawn)

func handle_wave_pawn_defeated(in_pawn: Pawn2D) -> void:
	
	assert(current_wave_pawns.has(in_pawn))
	
	current_wave_pawns.erase(in_pawn)
	
	if current_wave_pawns.is_empty():
		try_spawn_next_wave()

func _on_target_player_controlled_pawn_changed() -> void:
	pause_waves()

##
## Block
##
var _block_static_body: StaticBody2D

func _update_block_collision() -> void:
	
	if _block_static_body:
		_block_static_body.queue_free()
		_block_static_body = null
	
	if not is_active or not is_node_ready():
		return
	
	_block_static_body = StaticBody2D.new()
	_block_static_body.collision_layer = limits_collision
	_block_static_body.collision_mask = 0
	add_child.call_deferred(_block_static_body)
	
	var right_wall := CollisionShape2D.new()
	right_wall.shape = RectangleShape2D.new()
	right_wall.shape.size = Vector2(16.0, camera_limits.y)
	right_wall.position = Vector2(-camera_limits.x * 0.5 - 8.0, 0.0)
	_block_static_body.add_child(right_wall)
	
	var left_wall := CollisionShape2D.new()
	left_wall.shape = RectangleShape2D.new()
	left_wall.shape.size = Vector2(16.0, camera_limits.y)
	left_wall.position = Vector2(camera_limits.x * 0.5 + 8.0, 0.0)
	_block_static_body.add_child(left_wall)
	
	var top_wall := CollisionShape2D.new()
	top_wall.shape = RectangleShape2D.new()
	top_wall.shape.size = Vector2(camera_limits.x + 32.0, 16.0)
	top_wall.position = Vector2(0.0, camera_limits.y * 0.5 + 8.0)
	_block_static_body.add_child(top_wall)
	
	var bottom_wall := CollisionShape2D.new()
	bottom_wall.shape = RectangleShape2D.new()
	bottom_wall.shape.size = Vector2(camera_limits.x + 32.0, 16.0)
	bottom_wall.position = Vector2(0.0, -camera_limits.y * 0.5 - 8.0)
	_block_static_body.add_child(bottom_wall)
