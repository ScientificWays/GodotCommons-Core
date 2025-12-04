@tool
extends AnimatedSprite2D
class_name Pawn2D_Sprite

static func try_get_from(in_node: Node) -> Pawn2D_Sprite:
	return ModularGlobals.try_get_from(in_node, Pawn2D_Sprite)

@export_category("Owner")
@export var owner_pawn: Pawn2D
@export var status_effect_particles_radius: float = 16.0
@export var direction_flip_targets: Array[Node2D]
@export var animation_data: AnimationData2D

var particles_pivot: ParticlesPivot

var current_animation_type: AnimationData2D.Type = AnimationData2D.Type.Idle
var current_look_direction: AnimationData2D.LookDirection = AnimationData2D.LookDirection.Forward

var current_move_direction: AnimationData2D.Direction = AnimationData2D.Direction.None:
	set(in_direction):
		
		if current_move_direction != in_direction:
			
			current_move_direction = in_direction
			
			if animation_data.use_horizontal_direction_flip:
				
				if current_move_direction == AnimationData2D.Direction.Left:
					flip_h = true
				elif current_move_direction == AnimationData2D.Direction.Right:
					flip_h = false
			
			for sample_flip_target: Node2D in direction_flip_targets:
				
				if flip_h:
					sample_flip_target.position.x = -absf(sample_flip_target.position.x)
					sample_flip_target.scale.x = -absf(sample_flip_target.scale.x)
				else:
					sample_flip_target.position.x = absf(sample_flip_target.position.x)
					sample_flip_target.scale.x = absf(sample_flip_target.scale.x)

func get_current_forward_direction() -> Vector2: return animation_data.calc_look_direction_vector(self)
func get_current_back_direction() -> Vector2: return -animation_data.calc_look_direction_vector(self)

func is_idle_animation_type() -> bool: return current_animation_type == AnimationData2D.Type.Idle
func is_idle_to_move_animation_type() -> bool: return current_animation_type == AnimationData2D.Type.IdleToMove
func is_move_animation_type() -> bool: return current_animation_type == AnimationData2D.Type.Move
func is_move_to_idle_animation_type() -> bool: return current_animation_type == AnimationData2D.Type.MoveToIdle
func is_override_animation_type() -> bool: return current_animation_type == AnimationData2D.Type.Override

var linear_speed: float = 0.0
var linear_velocity: Vector2 = Vector2.ZERO:
	set(in_velocity):
		
		if not linear_velocity.is_equal_approx(in_velocity):
			
			linear_velocity = in_velocity
			linear_speed = linear_velocity.length()
			assert(not is_nan(linear_speed))
			
			if not is_instance_valid(look_at_target):
				current_move_direction = animation_data.calc_move_direction(self)
			
			if is_updating_velocity_based_animations:
				update_velocity_based_animations()

@export var can_update_velocity_based_animations: bool = true
var is_updating_velocity_based_animations: bool = true

@export var move_animation_base_speed: float = 25.0

@export var z_index_offset: int = 0
@export var allow_different_z_index: bool = false

signal look_at_target_changed()

var look_at_target: Node2D:
	set(in_target):
		if look_at_target:
			look_at_target.tree_exited.disconnect(_on_look_at_target_tree_exited)
		look_at_target = in_target
		if look_at_target:
			look_at_target.tree_exited.connect(_on_look_at_target_tree_exited)
		look_at_target_changed.emit()

func _on_look_at_target_tree_exited():
	look_at_target = null

var status_effect_modulate_array: Array[Color] = []

func _ready():
	
	if Engine.is_editor_hint():
		if not owner_pawn:
			owner_pawn = get_parent() as Pawn2D
		if not animation_data:
			animation_data = AnimationData2D.new()
		if not allow_different_z_index:
			z_index = GameGlobals_Class.PAWN_2D_SPRITE_DEFAULT_Z_INDEX + z_index_offset
			z_as_relative = false
	else:
		assert(owner_pawn)
		
		owner_pawn.died.connect(_on_owner_pawn_died)
		
		particles_pivot = ParticlesPivot.new()
		add_child(particles_pivot)
		
		scale *= owner_pawn.get_size_scale()

func _enter_tree():
	
	if Engine.is_editor_hint():
		pass
	else:
		ModularGlobals.init_modular_node(self)

func _exit_tree():
	
	if Engine.is_editor_hint():
		pass
	else:
		ModularGlobals.deinit_modular_node(self)

func _process(in_delta: float):
	
	if is_instance_valid(look_at_target):
		current_move_direction = animation_data.GetNewDirectionForLookAtTarget(self)

func update_velocity_based_animations():
	
	if linear_speed > 2.0:
		
		if is_move_animation_type():
			UpdateMoveAnimationSpeed()
		else:
			HandleSwitchToMoveAnimation()
	elif linear_speed < 1.0:
		if not is_idle_animation_type():
			HandleSwitchToIdleAnimation()

func HandleSwitchToMoveAnimation():
	
	if animation_data.UseIdleToMoveTransition:
		
		if is_idle_animation_type():
			PlayIdleToMoveAnimation()
			
		elif is_move_to_idle_animation_type():
			
			var MoveToIdleFrame = frame
			var MoveToIdleFrameNum = sprite_frames.get_frame_count(animation_data.GetMoveToIdleAnimationName(self))
			
			PlayIdleToMoveAnimation()
			frame = MoveToIdleFrameNum - 1 - MoveToIdleFrame
		else:
			UpdateMoveAnimationSpeed()
	else:
		UpdateMoveAnimationSpeed()

func UpdateMoveAnimationSpeed():
	PlayMoveAnimation(linear_speed / move_animation_base_speed)

func HandleSwitchToIdleAnimation():
	
	if animation_data.UseMoveToIdleTransition:
		
		if is_move_animation_type():
			PlayMoveToIdleAnimation()
		
		elif is_idle_to_move_animation_type():
			
			var IdleToMoveFrame = frame
			var IdleToMoveFrameNum = sprite_frames.get_frame_count(animation_data.GetIdleToMoveAnimationName(self))
			
			PlayMoveToIdleAnimation()
			frame = IdleToMoveFrameNum - 1 - IdleToMoveFrame
		else:
			PlayIdleAnimation()
	else:
		PlayIdleAnimation()

func PlayIdleAnimation():
	current_animation_type = AnimationData2D.Type.Idle
	play(animation_data.GetIdleAnimationName(self))

func PlayIdleToMoveAnimation():
	play_override_animation(animation_data.GetIdleToMoveAnimationName(self), 1.0, false, true, true, AnimationData2D.Type.IdleToMove)

func PlayMoveAnimation(InSpeed: float):
	current_animation_type = AnimationData2D.Type.Move
	play(animation_data.GetMoveAnimationName(self), InSpeed)

func PlayMoveToIdleAnimation():
	play_override_animation(animation_data.GetMoveToIdleAnimationName(self), 1.0, false, true, true, AnimationData2D.Type.MoveToIdle)

func try_play_death_animation() -> bool:
	if animation_data.UseDeathAnimation:
		play_override_animation(animation_data.GetDeathAnimationName(self), 1.0, false, true, false, AnimationData2D.Type.Death)
		return true
	return false

func play_override_animation(in_name: StringName, InCustomSpeed: float = 1.0, InFromEnd: bool = false, InShouldResetOnFinish: bool = true, in_keep_update_velocity_based_animations: bool = false, in_type: AnimationData2D.Type = AnimationData2D.Type.Override):
	
	assert(sprite_frames.has_animation(in_name))
	
	is_updating_velocity_based_animations = can_update_velocity_based_animations and in_keep_update_velocity_based_animations
	
	current_animation_type = in_type
	play(in_name, InCustomSpeed, InFromEnd)
	
	if InShouldResetOnFinish:
		if not animation_finished.is_connected(_HandleOverrideAnimationReset):
			animation_finished.connect(_HandleOverrideAnimationReset, Object.CONNECT_ONE_SHOT)
	else:
		if animation_finished.is_connected(_HandleOverrideAnimationReset):
			animation_finished.disconnect(_HandleOverrideAnimationReset)

func CancelOverrideAnimation(in_name: StringName = &""):
	
	assert(sprite_frames.has_animation(in_name))
	
	if animation == in_name or is_override_animation_type():
		stop()

func _HandleOverrideAnimationReset():
	
	is_updating_velocity_based_animations = can_update_velocity_based_animations
	
	if is_updating_velocity_based_animations:
		update_velocity_based_animations()
	else:
		PlayIdleAnimation()

func _on_owner_pawn_died(in_immediately: bool) -> void:
	if not in_immediately:
		try_remove_with_animation()

func try_remove_with_animation(in_custom_animation_name: StringName = StringName()) -> bool:
	
	if in_custom_animation_name:
		play_override_animation(in_custom_animation_name)
	else:
		if not try_play_death_animation():
			return false
	
	reparent(WorldGlobals._level._y_sorted)
	animation_finished.connect(handle_remove, Object.CONNECT_ONE_SHOT)
	return true

func handle_remove():
	particles_pivot.detach_and_remove_all()
	queue_free()
