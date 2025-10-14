extends Projectile2D
class_name BombProjectile2D

const bomblet_meta: StringName = &"Bomblet"

@export_category("Owner")
@export var beep_light: PointLight2D
@export var beep_animation_player: AnimationPlayer

var await_for_throw_impulse: bool = false
signal throw_impulse_applied()

var detonate_delay: float = 0.0
signal detonate(in_is_timer_detonate: bool)

var _detonate_timer: Timer
var _beep_timer: Timer

func _ready() -> void:
	
	if await_for_throw_impulse:
		await throw_impulse_applied
	
	if detonate_delay > 0.0:
		
		_detonate_timer = GameGlobals.spawn_one_shot_timer_for(self, _on_detonate_timer_timeout, detonate_delay)
		beep_light.visible = false
		
		if detonate_delay > data.detonate_beep_time:
			_beep_timer = GameGlobals.spawn_regular_timer_for(self, _on_beep_timer_timeout, detonate_delay - data.detonate_beep_time)
		else:
			_on_beep_timer_timeout()
			#var BeepPassedTime := _DetonateBeepTime - detonate_delay
			#beep_animation_player.advance(BeepPassedTime / _DetonateBeepTime)

##
## Detonate
##
func _on_detonate_timer_timeout():
	_handle_detonate(true)

func _handle_detonate(in_is_timer_detonate: bool):
	
	if not is_node_ready():
		OS.alert("Trying to detonate bomb before node is ready!")
	
	detonate.emit(in_is_timer_detonate)
	
	if is_instance_valid(self):
		
		if data.detonate_sound_event and data.should_play_detonate_sound(in_is_timer_detonate):
			AudioGlobals.try_play_sound_varied_at_global_position(data.sound_bank_label, data.detonate_sound_event, global_position, data.get_detonate_sound_pitch_mul(in_is_timer_detonate), data.get_detonate_sound_volume_db(in_is_timer_detonate))
		
		spawn_explosion_at(global_position)
		handle_remove_from_scene(RemoveReason.Detonate)

var explosion_damage_receiver_callable_array: Array[Callable] = []

func spawn_explosion_at(in_global_position: Vector2) -> Explosion2D:
	var out_explosion := Explosion2D.spawn(in_global_position, data.explosion_data, _level, data.get_explosion_radius(_level), data.get_explosion_damage(_level), data.get_explosion_impulse(_level), _instigator) as Explosion2D
	#out_explosion.OverlayDataArray = ExplosionOverlayDataArray
	out_explosion.damage_receiver_callable_array.append_array(explosion_damage_receiver_callable_array)
	return out_explosion

##
## Beep
##
func _on_beep_timer_timeout():
	
	beep_light.visible = true
	beep_animation_player.play(&"Beep", -1.0, 2.0 / data.detonate_beep_time)

func PlayBeepSound():
	
	if get_meta(&"DisableBeepSound", false):
		return
	AudioGlobals.try_play_sound_at_global_position(data.sound_bank_label, data.beep_sound_event, global_position)

##
## Throw
##
var applied_throw_direction: Vector2
var applied_throw_scale: float

func GetThrowImpulseFromThrowVector(in_throw_vector: Vector2) -> Vector2:
	return in_throw_vector * data.throw_bomb_impulse_scale * mass

func apply_throw_impulse(in_throw_vector: Vector2):
	
	assert(await_for_throw_impulse)
	
	if data.throw_bomb_impulse_scale > 0.0:
		var impulse := GetThrowImpulseFromThrowVector(in_throw_vector)
		apply_central_impulse(impulse)
	
	if not data.throw_angle_min_max.is_zero_approx():
		rotation += deg_to_rad(randf_range(data.throw_angle_min_max.x, data.throw_angle_min_max.y))
		set_angular_velocity(randf_range(data.throw_angular_velocity_min_max.x, data.throw_angular_velocity_min_max.y))
	
	var throw_vector_length := in_throw_vector.length()
	applied_throw_direction = in_throw_vector / throw_vector_length
	applied_throw_scale = throw_vector_length * 0.002
	#print(applied_throw_scale)
	
	if data.detonate_delay_curve:
		detonate_delay = data.detonate_delay_curve.sample_baked(applied_throw_scale)
		#print(detonate_delay)
	
	if data.throw_sound_event:
		AudioGlobals.try_play_sound_varied_at_global_position(data.sound_bank_label, data.throw_sound_event, global_position, data.get_throw_sound_pitch_mul(applied_throw_scale), data.get_throw_sound_volume_db(applied_throw_scale))
	
	throw_impulse_applied.emit()
