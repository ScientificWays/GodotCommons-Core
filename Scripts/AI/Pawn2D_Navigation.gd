extends NavigationAgent2D
class_name Pawn2D_Navigation

static func try_get_from(in_node: Node) -> Pawn2D_Navigation:
	return ModularGlobals.try_get_from(in_node, Pawn2D_Navigation)

@export_category("Owner")
@export var owner_pawn: Pawn2D
@export var owner_movement: Pawn2D_CharacterMovement

@export_category("Jump")
@export var jump_on_vertical_path: bool = false
@export var jump_vertical_y_threshold: float = -0.8

var target_node: Node2D:
	set(in_node):
		target_node = in_node
		if target_node:
			assert(target_node != owner_pawn)
			target_position = target_node.global_position
		else:
			target_position = owner_pawn.global_position

func _ready() -> void:
	
	assert(owner_pawn)
	assert(owner_movement)
	
	target_reached.connect(_on_target_reached)
	velocity_computed.connect(_on_avoidance_velocity_computed)

func _enter_tree() -> void:
	ModularGlobals.init_modular_node(self)

func _exit_tree() -> void:
	ModularGlobals.deinit_modular_node(self)

func _physics_process(in_delta: float) -> void:
	
	if target_node:
		target_position = target_node.global_position
	
	if owner_movement.move_speed == 0.0 or disable_movement_counter > 0:
		velocity = Vector2.ZERO
	elif is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_position := get_next_path_position()
		var move_direction := owner_movement.owner_body.global_position.direction_to(next_path_position)
		
		if jump_on_vertical_path:
			if move_direction.y < jump_vertical_y_threshold:
				owner_movement.apply_jump_input()
		
		velocity = move_direction * owner_movement.move_speed
	
	if not avoidance_enabled:
		owner_movement.set_movement_velocity(velocity, true)

func _on_target_reached() -> void:
	pass

func _on_avoidance_velocity_computed(in_safe_velocity: Vector2) -> void:
	owner_movement.set_movement_velocity(in_safe_velocity, true)

var disable_movement_counter: int = 0

func increment_disable_movement(in_for_duration: float = 0.0) -> void:
	
	disable_movement_counter += 1
	
	if in_for_duration > 0.0:
		GameGlobals.spawn_one_shot_timer_for(self, decrement_disable_movement, in_for_duration)

func decrement_disable_movement() -> void:
	disable_movement_counter -= 1
