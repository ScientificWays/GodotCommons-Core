@tool
extends AnimatedSprite2D
class_name Pawn2D_Sprite

static func try_get_from(in_node: Node) -> Pawn2D_Sprite:
	return ModularGlobals.try_get_from(in_node, Pawn2D_Sprite)

var _ParticlesPivot: ParticlesPivot

@export_category("Owner")
@export var owner_pawn: Pawn2D

@export var animation_data: AnimationData2D = null:
	set(InData):
		
		animation_data = InData
		
		if animation_data and not Engine.is_editor_hint():
			if not is_node_ready():
				await ready
			animation_data.init_sprite(self)

@export var StatusEffectParticlesRadius: float = 16.0

var _AnimationType: AnimationData2D.Type = AnimationData2D.Type.Idle
var _Direction: AnimationData2D.Direction = AnimationData2D.Direction.None:
	set(InDirection):
		
		if _Direction != InDirection:
			
			_Direction = InDirection
			
			if animation_data.UseHorizontalDirectionFlip:
				flip_h = _Direction == AnimationData2D.Direction.Left

func IsIdleAnimationType() -> bool:
	return _AnimationType == AnimationData2D.Type.Idle

func IsIdleToMoveAnimationType() -> bool:
	return _AnimationType == AnimationData2D.Type.IdleToMove

func IsMoveAnimationType() -> bool:
	return _AnimationType == AnimationData2D.Type.Move

func IsMoveToIdleAnimationType() -> bool:
	return _AnimationType == AnimationData2D.Type.MoveToIdle

func IsOverrideAnimationType() -> bool:
	return _AnimationType == AnimationData2D.Type.Override

var LinearSpeed: float = 0.0
var linear_velocity: Vector2 = Vector2.ZERO:
	set(in_velocity):
		
		if not linear_velocity.is_equal_approx(in_velocity):
			
			linear_velocity = in_velocity
			LinearSpeed = linear_velocity.length()
			assert(not is_nan(LinearSpeed))
			
			if not is_instance_valid(LookAtTarget):
				_Direction = animation_data.GetNewDirectionForVelocity(self)
			
			if ShouldUpdateVelocityBasedAnimations:
				UpdateVelocityBasedAnimations()

var ShouldUpdateVelocityBasedAnimations: bool = true
@export var move_animation_base_speed: float = 25.0

@export var z_index_offset: int = 0
@export var allow_different_z_index: bool = false

signal LookAtTargetChanged()

var LookAtTarget: Node2D:
	set(in_target):
		if LookAtTarget:
			LookAtTarget.tree_exited.disconnect(OnLookAtTargetTreeExited)
		LookAtTarget = in_target
		if LookAtTarget:
			LookAtTarget.tree_exited.connect(OnLookAtTargetTreeExited)
		LookAtTargetChanged.emit()

func OnLookAtTargetTreeExited():
	LookAtTarget = null

var StatusEffectModulateArray: Array[Color] = []

func _ready():
	
	if Engine.is_editor_hint():
		if not owner_pawn:
			owner_pawn = get_parent() as Pawn2D
		if not allow_different_z_index:
			z_index = GameGlobals_Class.PAWN_2D_SPRITE_DEFAULT_Z_INDEX + z_index_offset
			z_as_relative = false
	else:
		assert(owner_pawn)
		
		owner_pawn.died.connect(_on_owner_pawn_died)
		
		_ParticlesPivot = ParticlesPivot.new()
		add_child(_ParticlesPivot)
		
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
	
	if is_instance_valid(LookAtTarget):
		_Direction = animation_data.GetNewDirectionForLookAtTarget(self)

func UpdateVelocityBasedAnimations():
	
	if LinearSpeed > 2.0:
		
		if IsMoveAnimationType():
			UpdateMoveAnimationSpeed()
		else:
			HandleSwitchToMoveAnimation()
	elif LinearSpeed < 1.0:
		if not IsIdleAnimationType():
			HandleSwitchToIdleAnimation()

func HandleSwitchToMoveAnimation():
	
	if animation_data.UseIdleToMoveTransition:
		
		if IsIdleAnimationType():
			PlayIdleToMoveAnimation()
			
		elif IsMoveToIdleAnimationType():
			
			var MoveToIdleFrame = frame
			var MoveToIdleFrameNum = sprite_frames.get_frame_count(animation_data.GetMoveToIdleAnimationName(self))
			
			PlayIdleToMoveAnimation()
			frame = MoveToIdleFrameNum - 1 - MoveToIdleFrame
		else:
			UpdateMoveAnimationSpeed()
	else:
		UpdateMoveAnimationSpeed()

func UpdateMoveAnimationSpeed():
	PlayMoveAnimation(LinearSpeed / move_animation_base_speed)

func HandleSwitchToIdleAnimation():
	
	if animation_data.UseMoveToIdleTransition:
		
		if IsMoveAnimationType():
			PlayMoveToIdleAnimation()
		
		elif IsIdleToMoveAnimationType():
			
			var IdleToMoveFrame = frame
			var IdleToMoveFrameNum = sprite_frames.get_frame_count(animation_data.GetIdleToMoveAnimationName(self))
			
			PlayMoveToIdleAnimation()
			frame = IdleToMoveFrameNum - 1 - IdleToMoveFrame
		else:
			PlayIdleAnimation()
	else:
		PlayIdleAnimation()

func PlayIdleAnimation():
	_AnimationType = AnimationData2D.Type.Idle
	play(animation_data.GetIdleAnimationName(self))

func PlayIdleToMoveAnimation():
	play_override_animation(animation_data.GetIdleToMoveAnimationName(self), 1.0, false, true, true, AnimationData2D.Type.IdleToMove)

func PlayMoveAnimation(InSpeed: float):
	_AnimationType = AnimationData2D.Type.Move
	play(animation_data.GetMoveAnimationName(self), InSpeed)

func PlayMoveToIdleAnimation():
	play_override_animation(animation_data.GetMoveToIdleAnimationName(self), 1.0, false, true, true, AnimationData2D.Type.MoveToIdle)

func try_play_death_animation() -> bool:
	if animation_data.UseDeathAnimation:
		play_override_animation(animation_data.GetDeathAnimationName(self), 1.0, false, true, false, AnimationData2D.Type.Death)
		return true
	return false

func play_override_animation(in_name: StringName, InCustomSpeed: float = 1.0, InFromEnd: bool = false, InShouldResetOnFinish: bool = true, InKeepUpdateVelocityBasedAnimations: bool = false, InType: AnimationData2D.Type = AnimationData2D.Type.Override):
	
	assert(sprite_frames.has_animation(in_name))
	
	ShouldUpdateVelocityBasedAnimations = animation_data.CanUpdateVelocityBasedAnimations and InKeepUpdateVelocityBasedAnimations
	
	_AnimationType = InType
	play(in_name, InCustomSpeed, InFromEnd)
	
	if InShouldResetOnFinish:
		if not animation_finished.is_connected(_HandleOverrideAnimationReset):
			animation_finished.connect(_HandleOverrideAnimationReset, Object.CONNECT_ONE_SHOT)
	else:
		if animation_finished.is_connected(_HandleOverrideAnimationReset):
			animation_finished.disconnect(_HandleOverrideAnimationReset)

func CancelOverrideAnimation(in_name: StringName = &""):
	
	assert(sprite_frames.has_animation(in_name))
	
	if animation == in_name or IsOverrideAnimationType():
		stop()

func _HandleOverrideAnimationReset():
	
	ShouldUpdateVelocityBasedAnimations = animation_data.CanUpdateVelocityBasedAnimations
	
	if ShouldUpdateVelocityBasedAnimations:
		UpdateVelocityBasedAnimations()
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
	_ParticlesPivot.detach_and_remove_all()
	queue_free()
