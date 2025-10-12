extends GPUParticles2D
class_name ParticleSystem2D

func _ready():
	pass

func InitAsOneShot(InPosition: Vector2, InParticlesNum: int, InLifetime: float, InParent: Node = WorldGlobals._level):
	
	if InParticlesNum > 0:
		emitting = true
		one_shot = true
		amount = InParticlesNum
		lifetime = InLifetime
	else:
		emitting = false
	
	var LifetimeTimer := Timer.new()
	LifetimeTimer.timeout.connect(OnLifetimeTimerTimeout)
	LifetimeTimer.autostart = true
	LifetimeTimer.one_shot = true
	LifetimeTimer.wait_time = InLifetime
	add_child(LifetimeTimer)
	
	position = InPosition
	InParent.add_child(self)

func OverrideRadius(in_radius: float):
	
	var BasePPM := process_material as ParticleProcessMaterial
	if in_radius != BasePPM.emission_sphere_radius:
		process_material = ResourceGlobals.GetOrCreatePPMWithRadius(BasePPM, in_radius)
		#process_material = BasePPM.duplicate()
		#process_material.emission_sphere_radius = in_radius
	
	for SampleChild: Node in get_children():
		var SampleParticles := SampleChild as GPUParticles2D
		if SampleParticles:
			var SampleBasePPM := SampleParticles.process_material as ParticleProcessMaterial
			if in_radius != SampleBasePPM.emission_sphere_radius:
				SampleParticles.process_material = ResourceGlobals.GetOrCreatePPMWithRadius(SampleBasePPM, in_radius)
				#SampleParticles.process_material = SampleBasePPM.duplicate()
				#SampleParticles.process_material.emission_sphere_radius = in_radius

func EmitParticlesWithVelocity(InParticlesNum: int, InVelocity: Vector2):
	
	if ProjectSettings.get_setting_with_override(&"rendering/renderer/rendering_method") == &"gl_compatibility":
		print(self, " EmitParticlesWithVelocity() cancelled due to gl_compatibility renderer")
		return
	
	var Flags := EMIT_FLAG_VELOCITY
	
	for SampleIndex: int in range(InParticlesNum):
		emit_particle(global_transform, InVelocity, Color.BLACK, Color.BLACK, Flags)

func OnLifetimeTimerTimeout():
	queue_free()
