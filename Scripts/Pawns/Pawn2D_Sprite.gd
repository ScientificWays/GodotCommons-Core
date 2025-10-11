extends AnimatedSprite2D
class_name Pawn2D_Sprite

var _ParticlesPivot: ParticlesPivot

@export var _AnimationData: AnimationData2D = null:
	set(InData):
		
		_AnimationData = InData
		
		if _AnimationData:
			_AnimationData.Init(self)

@export var StatusEffectParticlesRadius: float = 16.0
@export var AlwaysLookAtRelevantTarget: bool = false

var _AnimationType: AnimationData2D.Type = AnimationData2D.Type.Idle
var _Direction: AnimationData2D.Direction = AnimationData2D.Direction.None:
	set(InDirection):
		
		if _Direction != InDirection:
			
			_Direction = InDirection
			
			if _AnimationData.UseHorizontalDirectionFlip:
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
var LinearVelocity: Vector2 = Vector2.ZERO:
	set(InVelocity):
		
		if not LinearVelocity.is_equal_approx(InVelocity):
			
			LinearVelocity = InVelocity
			LinearSpeed = LinearVelocity.length()
			assert(not is_nan(LinearSpeed))
			
			if not is_instance_valid(LookAtTarget):
				_Direction = _AnimationData.GetNewDirectionForVelocity(self)
			
			if ShouldUpdateVelocityBasedAnimations:
				UpdateVelocityBasedAnimations()

var ShouldUpdateVelocityBasedAnimations: bool = true
var MoveAnimationBaseSpeed: float = 25.0

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
	_ParticlesPivot = ParticlesPivot.new()
	add_child(_ParticlesPivot)

func _process(InDelta: float):
	
	if is_instance_valid(LookAtTarget):
		_Direction = _AnimationData.GetNewDirectionForLookAtTarget(self)

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
	
	if _AnimationData.UseIdleToMoveTransition:
		
		if IsIdleAnimationType():
			PlayIdleToMoveAnimation()
			
		elif IsMoveToIdleAnimationType():
			
			var MoveToIdleFrame = frame
			var MoveToIdleFrameNum = sprite_frames.get_frame_count(_AnimationData.GetMoveToIdleAnimationName(self))
			
			PlayIdleToMoveAnimation()
			frame = MoveToIdleFrameNum - 1 - MoveToIdleFrame
		else:
			UpdateMoveAnimationSpeed()
	else:
		UpdateMoveAnimationSpeed()

func UpdateMoveAnimationSpeed():
	PlayMoveAnimation(LinearSpeed / MoveAnimationBaseSpeed)

func HandleSwitchToIdleAnimation():
	
	if _AnimationData.UseMoveToIdleTransition:
		
		if IsMoveAnimationType():
			PlayMoveToIdleAnimation()
		
		elif IsIdleToMoveAnimationType():
			
			var IdleToMoveFrame = frame
			var IdleToMoveFrameNum = sprite_frames.get_frame_count(_AnimationData.GetIdleToMoveAnimationName(self))
			
			PlayMoveToIdleAnimation()
			frame = IdleToMoveFrameNum - 1 - IdleToMoveFrame
		else:
			PlayIdleAnimation()
	else:
		PlayIdleAnimation()

func PlayIdleAnimation():
	_AnimationType = AnimationData2D.Type.Idle
	play(_AnimationData.GetIdleAnimationName(self))

func PlayIdleToMoveAnimation():
	PlayOverrideAnimation(_AnimationData.GetIdleToMoveAnimationName(self), 1.0, false, true, true, AnimationData2D.Type.IdleToMove)

func PlayMoveAnimation(InSpeed: float):
	_AnimationType = AnimationData2D.Type.Move
	play(_AnimationData.GetMoveAnimationName(self), InSpeed)

func PlayMoveToIdleAnimation():
	PlayOverrideAnimation(_AnimationData.GetMoveToIdleAnimationName(self), 1.0, false, true, true, AnimationData2D.Type.MoveToIdle)

func TryPlayDeathAnimation() -> bool:
	if _AnimationData.UseDeathAnimation:
		PlayOverrideAnimation(_AnimationData.GetDeathAnimationName(self), 1.0, false, true, false, AnimationData2D.Type.Death)
		return true
	return false

func PlayOverrideAnimation(InName: StringName, InCustomSpeed: float = 1.0, InFromEnd: bool = false, InShouldResetOnFinish: bool = true, InKeepUpdateVelocityBasedAnimations: bool = false, InType: AnimationData2D.Type = AnimationData2D.Type.Override):
	
	assert(sprite_frames.has_animation(InName))
	
	ShouldUpdateVelocityBasedAnimations = _AnimationData.CanUpdateVelocityBasedAnimations and InKeepUpdateVelocityBasedAnimations
	
	_AnimationType = InType
	play(InName, InCustomSpeed, InFromEnd)
	
	if InShouldResetOnFinish:
		if not animation_finished.is_connected(_HandleOverrideAnimationReset):
			animation_finished.connect(_HandleOverrideAnimationReset, Object.CONNECT_ONE_SHOT)
	else:
		if animation_finished.is_connected(_HandleOverrideAnimationReset):
			animation_finished.disconnect(_HandleOverrideAnimationReset)

func CancelOverrideAnimation(InName: StringName = &""):
	
	assert(sprite_frames.has_animation(InName))
	
	if animation == InName or IsOverrideAnimationType():
		stop()

func _HandleOverrideAnimationReset():
	
	ShouldUpdateVelocityBasedAnimations = _AnimationData.CanUpdateVelocityBasedAnimations
	
	if ShouldUpdateVelocityBasedAnimations:
		UpdateVelocityBasedAnimations()
	else:
		PlayIdleAnimation()

func TryRemoveWithDeathAnimation() -> bool:
	
	if TryPlayDeathAnimation():
		reparent(WorldGlobals._level._YSorted)
		animation_finished.connect(HandleRemove, Object.CONNECT_ONE_SHOT)
		return true
	return false

func HandleRemove():
	_ParticlesPivot.DetachAndRemoveAll()
	queue_free()
