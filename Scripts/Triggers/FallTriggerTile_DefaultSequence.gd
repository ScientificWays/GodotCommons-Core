extends FallTriggerTile_Sequence

@export var _alpha: float = 0.0:
	set(in_alpha):
		
		var delta := in_alpha - _alpha
		_alpha = in_alpha
		
		## ~30.0 degress
		fall_target.rotate(delta * 0.5)
		
		fall_target.scale = initial_scale.lerp(Vector2(0.2, 0.2), _alpha)
		fall_target.modulate.a = lerpf(initial_modulate.a, 0.0, _alpha)

var initial_scale: Vector2
var initial_modulate: Color

func try_trigger_sequence(in_source: Node) -> bool:
	
	if not super(in_source):
		return false
	
	initial_scale = fall_target.scale
	initial_modulate = fall_target.modulate
	return true
