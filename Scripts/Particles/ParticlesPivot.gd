extends Marker2D
class_name ParticlesPivot

@export var detach_all_on_tree_exited: bool = true

var _ParticlesArray: Array[Node2D]
var expire_timer: Timer

signal expired()

func _ready():
	
	for SampleChild: Node in get_children():
		var SampleParticles := SampleChild as Node2D
		if SampleParticles:
			AttachNew(SampleParticles)
	
	tree_exited.connect(_on_tree_exited)

func _on_tree_exited() -> void:
	if detach_all_on_tree_exited:
		detach_and_remove_all()

func RegisterParticles(in_particles: Node2D):
	
	if in_particles.get_parent():
		in_particles.reparent(self)
	else:
		add_child(in_particles)
	
	if not _ParticlesArray.has(in_particles):
		_ParticlesArray.append(in_particles)
		in_particles.tree_exited.connect(UtilUnRegisterParticles.bind(in_particles))

func UtilUnRegisterParticles(in_particles: Node2D):
	_ParticlesArray.erase(in_particles)

func AttachNew(in_particles: Node2D):
	RegisterParticles(in_particles)

var was_all_detached: bool = false

func detach_and_remove_all() -> void:
	
	if was_all_detached:
		return
	
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
	was_all_detached = true

func DetachAndRemoveSpecific(in_particles: Node2D):
	
	if _ParticlesArray.has(in_particles):
		var MaxLifetime := UtilStopParticlesWithChildren(in_particles)
		get_tree().create_timer(MaxLifetime, false).timeout.connect(DetachAndRemoveSpecificCallback.bind(in_particles))

func DetachAndRemoveSpecificCallback(in_particles: Node2D):
	if is_instance_valid(in_particles):
		in_particles.queue_free()

func UtilStopParticlesWithChildren(in_particles: Node2D) -> float:
	
	in_particles.one_shot = true
	in_particles.emitting = false
	var OutMaxLifetime = in_particles.lifetime
	for SampleChild: Node in in_particles.get_children():
		if SampleChild is GPUParticles2D:
			SampleChild.one_shot = true
			SampleChild.emitting = false
			OutMaxLifetime = maxf(SampleChild.lifetime, OutMaxLifetime)
		elif SampleChild is CPUParticles2D:
			SampleChild.one_shot = true
			SampleChild.emitting = false
			OutMaxLifetime = maxf(SampleChild.lifetime, OutMaxLifetime)
	return OutMaxLifetime

func set_expire_time(in_time: float):
	
	if not expire_timer:
		expire_timer = Timer.new()
		expire_timer.timeout.connect(OnExpireTimerExpired)
		expire_timer.autostart = true
		expire_timer.one_shot = true
		add_child.call_deferred(expire_timer)
	
	if expire_timer.is_node_ready():
		expire_timer.start(in_time)
	else:
		expire_timer.wait_time = in_time

func OnExpireTimerExpired():
	detach_and_remove_all()
	expired.emit()

func _exit_tree():
	pass
	#print_orphan_nodes.call_deferred()
