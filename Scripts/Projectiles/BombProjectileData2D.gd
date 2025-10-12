@tool
extends ProjectileData2D
class_name BombProjectileData2D

@export_category("Combine")
@export var combine_priority: int = 0
#@export var combine_custom_sprite_frames: Dictionary[BombProjectileData2D, SpriteFrames]

var combined_modifiers: Array[ItemContainer_BombModifiers]

func get_original_modifier() -> ItemContainer_BombModifiers:
	return combined_modifiers[0]

@export_category("Audio")
@export var beep_sound_event: SoundEventResource:
	get:
		if beep_sound_event:
			return beep_sound_event
		return load("res://addons/GodotCommons-Core/Assets/Audio/Events/Projectiles/Bombs/Beep001.tres")

@export var throw_sound_event: SoundEventResource:
	get:
		if throw_sound_event:
			return throw_sound_event
		return load("res://addons/GodotCommons-Core/Assets/Audio/Events/Projectiles/Throw001.tres")

@export var detonate_sound_event: SoundEventResource

func get_throw_sound_pitch_mul(in_throw_scale: float) -> float:
	return maxf(throw_sound_event.pitch - 0.4 + in_throw_scale * 0.8, 0.5) * randf_range(0.9, 1.1)

func get_throw_sound_volume_db(in_throw_scale: float) -> float:
	return minf(throw_sound_event.volume - 12.0 + in_throw_scale * 32.0, 0.0)

func should_play_detonate_sound(in_is_timer_detonate: bool) -> bool:
	return true

func get_detonate_sound_pitch_mul(in_is_timer_detonate: bool) -> float:
	return detonate_sound_event.pitch * randf_range(0.9, 1.1)

func get_detonate_sound_volume_db(in_is_timer_detonate: bool) -> float:
	return detonate_sound_event.volume

@export_category("Throw")
@export var throw_player_impulse_scale: float = -0.1
@export var throw_bomb_impulse_scale: float = 6.5
@export var throw_angle_min_max: Vector2 = Vector2(-5.0, 5.0)
@export var throw_angular_velocity_min_max: Vector2 = Vector2(-10.0, 10.0)

@export_category("Detonate")
@export var should_detonate_on_hit: bool = false
@export var should_detonate_on_receive_damage: bool = false
@export var detonate_delay_curve: Curve:
	get:
		if detonate_delay_curve:
			return detonate_delay_curve
		return load("res://Assets/Projectiles/Bombs/DefaultBomb_DetonateCurve.tres")

@export var detonate_beep_time: float = 0.4

@export_category("Explosion")
@export var explosion_data: ExplosionData2D:
	get:
		if explosion_data:
			return explosion_data
		return load("res://Assets/Explosions/Default001.tres")

@export var explosion_radius_mul: float = 1.0
@export var explosion_radius_mul_per_level_gain: float = 0.0
@export var explosion_damage_mul: float = 1.0
@export var explosion_damage_mul_per_level_gain: float = 0.0
@export var explosion_impulse_mul: float = 1.0
@export var explosion_impulse_mul_per_level_sqrt_gain: float = 0.0
@export var external_explosion_impulseMul: float = 1.0

func get_explosion_radius_mul(in_level: int) -> float:
	return explosion_radius_mul + explosion_radius_mul_per_level_gain * in_level

func get_explosion_damage_mul(in_level: int) -> float:
	return explosion_damage_mul + explosion_damage_mul_per_level_gain * in_level

func get_explosion_impulse_mul(in_level: int) -> float:
	return explosion_impulse_mul + explosion_impulse_mul_per_level_sqrt_gain * sqrt(in_level)

func get_explosion_radius(in_level: int) -> float:
	return Explosion2D.base_radius * get_explosion_radius_mul(in_level)

func get_explosion_damage(in_level: int) -> float:
	return Explosion2D.base_damage * get_explosion_impulse_mul(in_level)

func get_explosion_impulse(in_level: int) -> float:
	return Explosion2D.base_impulse * get_explosion_impulse_mul(in_level)

@export_category("Stock")
@export var stock_color: Color = Color.GRAY
@export var stock_replenish_time_mul: float = 1.0
@export var stock_replenish_time_mul_per_level_sqrt_gain: float = 0.0
@export var stock_max_mul: float = 1.0
@export var stock_max_mul_per_level_gain: float = 0.0

func get_stock_replenish_time_mul(in_level: int) -> float:
	return stock_replenish_time_mul + stock_replenish_time_mul_per_level_sqrt_gain * sqrt(float(in_level))

func get_stock_max_mul(in_level: int) -> float:
	return stock_max_mul + stock_max_mul_per_level_gain * in_level

func get_stock_replenish_time(in_level: int) -> float:
	return BarrelPawn2D_Stock.replenish_base_time_mul * get_stock_replenish_time_mul(in_level)

func get_stock_max(in_level: int) -> int:
	return maxi(roundi(float(BarrelPawn2D_Stock.replenish_base_max) * get_stock_max_mul(in_level)), 1)

@export_category("Avoidance")
@export var avoidance_radius: float = 6.0
