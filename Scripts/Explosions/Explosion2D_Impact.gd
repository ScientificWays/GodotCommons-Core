extends CollisionShape2D
class_name Explosion2D_Impact

const default_impact_ease: float = 2.0

const ReceiveImpulseMethodName: StringName = &"Explosion2D_receive_impulse"
const ReceiveDamageMethod: StringName = &"Explosion2D_receive_damage"

@export_category("Owner")
@export var owner_explosion: Explosion2D
@export var owner_sprite: Explosion2D_Sprite

var should_ignore_instigator: bool = false

func _ready() -> void:
	
	assert(owner_explosion)
	
	var base_radius := shape.radius as float
	var RadiusMul := owner_explosion._radius / base_radius;
	shape = ResourceGlobals.GetOrCreateScaledShape(shape, RadiusMul, 0.0)
	
	if owner_explosion.data.impact_sound_event:
		var PitchMul := maxf(1.8 - sqrt(owner_explosion._radius) * 0.1, 0.5)
		var VolumeDb := -15.0 + owner_explosion._radius * 0.15
		AudioGlobals.try_play_sound_varied_at_global_position(owner_explosion.data.sound_bank_label, owner_explosion.data.impact_sound_event, global_position, PitchMul, VolumeDb)
	
	if owner_explosion.data.impact_delay > 0.0:
		GameGlobals.spawn_one_shot_timer_for(self, HandleImpact, owner_explosion.data.impact_delay)
	else:
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		if is_instance_valid(self): ## May be better to check this
			HandleImpact()

func HandleImpact():
	
	GameGlobals.pre_explosion_impact.emit(self)
	
	var ImpactImmediateTargets := owner_explosion.get_overlapping_bodies() + owner_explosion.get_overlapping_areas()
	for SampleTarget: Node2D in ImpactImmediateTargets:
		TryApplyImpact(SampleTarget)
	
	var GlobalPosition := global_position
	
	if owner_explosion.data.shake_strength_scale > 0.0:
		var ShakeMaxOffsetValue := owner_explosion._max_impulse * 0.008 * owner_explosion.data.shake_strength_scale
		var ShakeMaxOffset := Vector2(ShakeMaxOffsetValue, ShakeMaxOffsetValue)
		var ShakeMaxRotation := owner_explosion._max_impulse * 0.00015 * owner_explosion.data.shake_strength_scale
		ShakeSource2D.Spawn(GlobalPosition, owner_explosion._radius * owner_explosion.data.shake_radius_scale, ShakeMaxOffset, ShakeMaxRotation, 2.5)
	
	if owner_explosion.data.should_create_smoke_particles:
		
		var smoke_particles = owner_explosion.data.get_smoke_particles_scene().instantiate()
		smoke_particles.InitAsOneShot(GlobalPosition, randi_range(2, 6), 5.0)
		smoke_particles.modulate = owner_explosion.data.smoke_particles_modulate
	
	if owner_explosion.data.should_create_burn:
		
		if WorldGlobals._level.has_available_tile_floor_extent_at(GlobalPosition, 2):
			ExplosionBurn2D.Spawn(GlobalPosition, owner_explosion.data.burn_scene, owner_explosion._radius)
		elif WorldGlobals._level.has_available_tile_floor_extent_at(GlobalPosition, 1):
			var snapped_position = WorldGlobals._level.snap_position_to_tile_floor(GlobalPosition)
			ExplosionBurn2D.Spawn(snapped_position, owner_explosion.data.burn_scene, owner_explosion._radius * 0.5)
	
	#if _Data.ImpactSoundEvent:
	#	var VolumeDb := -12.0 + _radius * 0.1
	#	SoundManager.play_at_position_varied("Explosion", _Data.ImpactSoundEvent.name, GlobalPosition, randf_range(0.9, 1.1), VolumeDb)
	HandlePostImpact()

var AffectedTargetsDictionary: Dictionary = {}

func TryApplyImpact(in_target: Node2D) -> void:
	
	if AffectedTargetsDictionary.has(in_target):
		printerr("Target ", in_target, " was already affected by an explosion! Skipping.")
		return
	AffectedTargetsDictionary[in_target] = true
	
	if should_ignore_instigator and in_target == owner_explosion._instigator:
		return
	
	TryApplyImpulseTo(in_target)
	TryApplyDamageTo(in_target)

func TryApplyImpulseTo(in_target: Node2D) -> void:
	
	assert(not is_nan(owner_explosion._max_impulse))
	if owner_explosion._max_impulse <= 0.0:
		return
	
	var HasReceiveMethod := in_target.has_method(ReceiveImpulseMethodName)
	if HasReceiveMethod or (in_target is RigidBody2D):
		
		var TargetImpulseWithOffset := GameGlobals.calc_radial_impulse_with_offset_for_target(in_target, owner_explosion.global_position, owner_explosion._max_impulse, owner_explosion._radius, default_impact_ease)
		var TargetImpulse := Vector2(TargetImpulseWithOffset.x, TargetImpulseWithOffset.y)
		var ImpulseOffset := Vector2(TargetImpulseWithOffset.z, TargetImpulseWithOffset.w)
		
		if HasReceiveMethod and in_target.call(ReceiveImpulseMethodName, owner_explosion, TargetImpulse, ImpulseOffset):
			pass
		elif in_target is RigidBody2D:
			in_target.apply_impulse(TargetImpulse, ImpulseOffset)
		GameGlobals.post_explosion_apply_impulse.emit(self, in_target, TargetImpulse, ImpulseOffset)

func TryApplyDamageTo(in_target: Node) -> void:
	
	if not owner_explosion.data.should_apply_damage or owner_explosion._max_damage <= 0.0:
		return
	
	var TargetReceiver := DamageReceiver.try_get_from(in_target)
	if TargetReceiver:
		
		var TargetDistance := in_target.global_position.distance_to(global_position) - TargetReceiver.get_meta(DamageReceiver.BoundsRadiusMeta, 4.0) as float
		var DistanceMul: float = 1.0 - ease(minf(TargetDistance / owner_explosion._radius, 1.0), default_impact_ease)
		
		if DistanceMul > 0.0:
			TargetReceiver.TryReceiveDamage(self, owner_explosion._instigator, owner_explosion._max_damage * DistanceMul, owner_explosion.data.damage_type, false)
		GameGlobals.CallAllCancellable(owner_explosion.damage_receiver_callable_array, [ self, TargetReceiver, DistanceMul ])

func HandlePostImpact():
	
	if owner_sprite.visible and owner_sprite.is_playing():
		await owner_sprite.animation_finished
	else:
		await get_tree().create_timer(0.1).timeout
	
	owner_explosion.queue_free()
