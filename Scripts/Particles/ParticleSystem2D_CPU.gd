extends CPUParticles2D
class_name ParticleSystem2D_CPU

func _ready():
	pass

func InitAsOneShot(in_position: Vector2, InParticlesNum: int, InLifetime: float, in_parent: Node = WorldGlobals._level):
	
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
	
	position = in_position
	in_parent.add_child(self)

func OnLifetimeTimerTimeout():
	queue_free()
