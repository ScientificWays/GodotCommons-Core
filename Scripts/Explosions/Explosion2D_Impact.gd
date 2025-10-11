extends CollisionShape2D
class_name Explosion2D_Impact

const DefaultImpactEase: float = 2.0

const ReceiveImpulseMethodName: StringName = &"Explosion2D_receive_impulse"
const ReceiveDamageMethod: StringName = &"Explosion2D_receive_damage"

@export_category("Owner")
@export var OwnerExplosion: Explosion2D
@export var OwnerSprite: Explosion2D_Sprite

@export_category("Impact")
@export var _ImpactDelay: float = 0.1
@export var _ShouldImpactTiles: bool = true
@export var _TilesImpactRadiusMul: float = 1.0
@export var _TilesImpactDamageMul: float = 1.0
@export var _ShouldApplyDamage: bool = true
@export var _DamageType: int = DamageReceiver.DamageType_Explosion
@export var _CanIgniteDebris: bool = true
@export var _ImpactSoundEvent: SoundEventResource = preload("res://addons/GodotCommons-Core/Assets/Audio/Events/Explosions/Default001.tres")

@export_category("Smoke")
@export var _ShouldCreateSmokeParticles: bool = true
@export var _smoke_particles_scene: PackedScene = preload("res://addons/GodotCommons-Core/Scenes/Particles/Smoke/Smoke001.tscn")
@export var _smoke_particles_scene_web: PackedScene = preload("res://addons/GodotCommons-Core/Scenes/Particles/Smoke/Smoke001_CPU.tscn")
@export var _SmokeParticlesModulate: Color = Color.WHITE

@export_category("Burn")
@export var _ShouldCreateBurn: bool = true
@export var _BurnScene: PackedScene = preload("res://addons/GodotCommons-Core/Scenes/Explosions/Burn001.tscn")

@export_category("Shake")
@export var _ShakeStrengthScale: float = 1.0
@export var _ShakeRadiusScale: float = 4.0

var _ShouldDestroyTiles: bool = true
var _ShouldIgnoreInstigator: bool = false

func _ready() -> void:
	
	assert(OwnerExplosion)
	
	var BaseRadius := shape.radius as float
	var RadiusMul := OwnerExplosion._Radius / BaseRadius;
	shape = ResourceGlobals.GetOrCreateScaledShape(shape, RadiusMul, 0.0)
	
	if _ImpactSoundEvent:
		var PitchMul := maxf(1.8 - sqrt(OwnerExplosion._Radius) * 0.1, 0.5)
		var VolumeDb := -15.0 + OwnerExplosion._Radius * 0.15
		AudioGlobals.TryPlaySoundVaried_AtGlobalPosition(OwnerExplosion.SoundBankLabel, _ImpactSoundEvent, global_position, PitchMul, VolumeDb)
	
	if _ImpactDelay > 0.0:
		GameGlobals.SpawnOneShotTimerFor(self, HandleImpact, _ImpactDelay)
	else:
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		if is_instance_valid(self): ## May be better to check this
			HandleImpact()

func HandleImpact():
	
	GameGlobals.PreExplosionImpact.emit(self)
	
	var ImpactImmediateTargets := OwnerExplosion.get_overlapping_bodies() + OwnerExplosion.get_overlapping_areas()
	for SampleTarget: Node2D in ImpactImmediateTargets:
		TryApplyImpact(SampleTarget)
	
	var GlobalPosition := global_position
	
	if _ShakeStrengthScale > 0.0:
		var ShakeMaxOffsetValue := OwnerExplosion._MaxImpulse * 0.008 * _ShakeStrengthScale
		var ShakeMaxOffset := Vector2(ShakeMaxOffsetValue, ShakeMaxOffsetValue)
		var ShakeMaxRotation := OwnerExplosion._MaxImpulse * 0.00015 * _ShakeStrengthScale
		ShakeSource2D.Spawn(GlobalPosition, OwnerExplosion._Radius * _ShakeRadiusScale, ShakeMaxOffset, ShakeMaxRotation, 2.5)
	
	if _ShouldCreateSmokeParticles:
		
		var smoke_particles := (_smoke_particles_scene_web.instantiate() as ParticleSystem2D_CPU) \
			if PlatformGlobals.IsWeb() \
			else (_smoke_particles_scene.instantiate() as ParticleSystem2D)
		smoke_particles.InitAsOneShot(GlobalPosition, randi_range(2, 6), 5.0)
		smoke_particles.modulate = _SmokeParticlesModulate
	
	if _ShouldCreateBurn:
		
		if WorldGlobals._level.has_available_tile_floor_extent_at(GlobalPosition, 2):
			ExplosionBurn2D.Spawn(GlobalPosition, _BurnScene, OwnerExplosion._Radius)
		elif WorldGlobals._level.has_available_tile_floor_extent_at(GlobalPosition, 1):
			var snapped_position = WorldGlobals._level.snap_position_to_tile_floor(GlobalPosition)
			ExplosionBurn2D.Spawn(snapped_position, _BurnScene, OwnerExplosion._Radius * 0.5)
	
	#if _Data.ImpactSoundEvent:
	#	var VolumeDb := -12.0 + _Radius * 0.1
	#	SoundManager.play_at_position_varied("Explosion", _Data.ImpactSoundEvent.name, GlobalPosition, randf_range(0.9, 1.1), VolumeDb)
	HandlePostImpact()

var AffectedTargetsDictionary: Dictionary = {}

func TryApplyImpact(in_target: Node2D) -> void:
	
	if AffectedTargetsDictionary.has(in_target):
		printerr("Target ", in_target, " was already affected by an explosion! Skipping.")
		return
	AffectedTargetsDictionary[in_target] = true
	
	if _ShouldIgnoreInstigator and in_target == OwnerExplosion._Instigator:
		return
	
	TryApplyImpulseTo(in_target)
	TryApplyDamageTo(in_target)

func TryApplyImpulseTo(in_target: Node2D) -> void:
	
	assert(not is_nan(OwnerExplosion._MaxImpulse))
	if OwnerExplosion._MaxImpulse <= 0.0:
		return
	
	var HasReceiveMethod := in_target.has_method(ReceiveImpulseMethodName)
	if HasReceiveMethod or (in_target is RigidBody2D):
		
		var TargetImpulseWithOffset := GameGlobals.calc_radial_impulse_with_offset_for_target(in_target, OwnerExplosion.global_position, OwnerExplosion._MaxImpulse, OwnerExplosion._Radius, DefaultImpactEase)
		var TargetImpulse := Vector2(TargetImpulseWithOffset.x, TargetImpulseWithOffset.y)
		var ImpulseOffset := Vector2(TargetImpulseWithOffset.z, TargetImpulseWithOffset.w)
		
		if HasReceiveMethod and in_target.call(ReceiveImpulseMethodName, OwnerExplosion, TargetImpulse, ImpulseOffset):
			pass
		elif in_target is RigidBody2D:
			in_target.apply_impulse(TargetImpulse, ImpulseOffset)
		GameGlobals.post_explosion_apply_impulse.emit(self, in_target, TargetImpulse, ImpulseOffset)

func TryApplyDamageTo(in_target: Node) -> void:
	
	if not _ShouldApplyDamage or OwnerExplosion._MaxDamage <= 0.0:
		return
	
	var TargetReceiver := DamageReceiver.try_get_from(in_target)
	if TargetReceiver:
		
		var TargetDistance := in_target.global_position.distance_to(global_position) - TargetReceiver.get_meta(DamageReceiver.BoundsRadiusMeta, 4.0) as float
		var DistanceMul: float = 1.0 - ease(minf(TargetDistance / OwnerExplosion._Radius, 1.0), DefaultImpactEase)
		
		if DistanceMul > 0.0:
			TargetReceiver.TryReceiveDamage(self, OwnerExplosion._Instigator, OwnerExplosion._MaxDamage * DistanceMul, _DamageType, false)
		GameGlobals.CallAllCancellable(OwnerExplosion.DamageReceiverCallableArray, [ self, TargetReceiver, DistanceMul ])

func HandlePostImpact():
	
	if OwnerSprite.visible and OwnerSprite.is_playing():
		await OwnerSprite.animation_finished
	else:
		await get_tree().create_timer(0.1).timeout
	
	OwnerExplosion.queue_free()
