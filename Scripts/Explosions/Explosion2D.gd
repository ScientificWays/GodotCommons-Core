extends Area2D
class_name Explosion2D

const base_radius: float = 64.0
const base_damage: float = 50.0
const base_impulse: float = 200.0

static func spawn(in_global_position: Vector2, in_data: ExplosionData2D, in_level: int, in_radius: float, in_max_damage: float, in_max_impulse: float, in_instigator: Node, in_delay: float = 0.0) -> Explosion2D:
	
	assert(in_data)
	assert(in_data.scene)
	
	assert(not is_nan(in_max_damage))
	assert(not is_nan(in_max_impulse))
	
	var out_exlosion := in_data.scene.instantiate() as Explosion2D
	out_exlosion.data = in_data
	out_exlosion._level = in_level
	out_exlosion._radius = in_radius
	out_exlosion._max_damage = in_max_damage
	out_exlosion._max_impulse = in_max_impulse
	out_exlosion._instigator = in_instigator
	out_exlosion.set_position(in_global_position)
	
	if in_delay > 0.0:
		GameGlobals.spawn_one_shot_timer_for(WorldGlobals._level, WorldGlobals._level.add_child.bind(out_exlosion), in_delay)
	else:
		WorldGlobals._level.add_child.call_deferred(out_exlosion)
	return out_exlosion

var data: ExplosionData2D

var _instigator: Node
var _level: int = 0

var should_ignore_instigator: bool = false

var _radius: float = base_radius
var _max_damage: float = base_damage
var _max_impulse: float = base_impulse

var damage_receiver_callable_array: Array[Callable]

func _ready():
	reset_physics_interpolation()
