extends Marker2D
class_name ParticlesPivot

var _ExpireTimer: Timer

var _ParticlesArray: Array[GPUParticles2D]

signal Expired()

func _ready():
	for SampleChild: Node in get_children():
		var SampleParticles := SampleChild as GPUParticles2D
		if SampleParticles:
			AttachNew(SampleParticles)

func RegisterParticles(InParticles: GPUParticles2D):
	
	if InParticles.get_parent():
		InParticles.reparent(self)
	else:
		add_child(InParticles)
	
	if not _ParticlesArray.has(InParticles):
		_ParticlesArray.append(InParticles)
		InParticles.tree_exited.connect(UtilUnRegisterParticles.bind(InParticles))

func UtilUnRegisterParticles(InParticles: GPUParticles2D):
	_ParticlesArray.erase(InParticles)

func AttachNew(InParticles: GPUParticles2D):
	RegisterParticles(InParticles)

func detach_and_remove_all():
	
	if not _ParticlesArray.is_empty():
		
		var MaxLifetime: float = 0.0
		for SampleParticles in _ParticlesArray:
			MaxLifetime = maxf(UtilStopParticlesWithChildren(SampleParticles), MaxLifetime)
		assert(MaxLifetime > 0.0)
		
		if MaxLifetime > 0.0:
			
			reparent(WorldGlobals._level)
			reset_physics_interpolation()
			
			var SelfRemoveTimer := Timer.new()
			SelfRemoveTimer.one_shot = true
			SelfRemoveTimer.autostart = true
			SelfRemoveTimer.wait_time = MaxLifetime
			SelfRemoveTimer.timeout.connect(queue_free)
			add_child(SelfRemoveTimer)
		else:
			queue_free()

func DetachAndRemoveSpecific(InParticles: GPUParticles2D):
	
	if _ParticlesArray.has(InParticles):
		var MaxLifetime := UtilStopParticlesWithChildren(InParticles)
		#get_tree().create_timer(MaxLifetime).timeout.connect(func(): if is_instance_valid(InParticles): InParticles.queue_free())
		get_tree().create_timer(MaxLifetime, false).timeout.connect(DetachAndRemoveSpecificCallback.bind(InParticles))

func DetachAndRemoveSpecificCallback(InParticles: GPUParticles2D):
	if is_instance_valid(InParticles):
		InParticles.queue_free()

func UtilStopParticlesWithChildren(InParticles: GPUParticles2D) -> float:
	
	InParticles.one_shot = true
	InParticles.emitting = false
	var OutMaxLifetime = InParticles.lifetime
	for SampleChild: Node in InParticles.get_children():
		if SampleChild is GPUParticles2D:
			SampleChild.one_shot = true
			SampleChild.emitting = false
			OutMaxLifetime = maxf(SampleChild.lifetime, OutMaxLifetime)
	return OutMaxLifetime

func SetExpireTime(InTime: float):
	
	if not _ExpireTimer:
		_ExpireTimer = Timer.new()
		_ExpireTimer.timeout.connect(OnExpireTimerExpired)
		_ExpireTimer.autostart = true
		_ExpireTimer.one_shot = true
		_ExpireTimer.wait_time = InTime
		add_child(_ExpireTimer)

func OnExpireTimerExpired():
	detach_and_remove_all()
	Expired.emit()

func _exit_tree():
	pass
	#print_orphan_nodes.call_deferred()
