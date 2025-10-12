extends Resource
class_name ProjectileData2D

@export_category("Init")
@export var scene: PackedScene

func custom_init(in_projectile: Projectile2D) -> void:
	pass

@export_category("Sprite")
@export var sprite_frames: SpriteFrames
@export var sprite_scale: Vector2 = Vector2(0.5, 0.5)
@export var sprite_offset: Vector2 = Vector2(0.0, 0.0)
@export var sprite_material: Material = null

@export_category("Physics")
@export var mass_mul: float = 1.0
@export var mass_mul_per_level_gain: float = 0.0

func get_mass_mul(in_level: int) -> float:
	return mass_mul + mass_mul_per_level_gain * in_level

@export_category("Size")
@export var size_mul: float = 1.0
@export var size_mul_per_level_gain: float = 0.0
@export var size_mul_mass_scale_factor: float = 2.0

func get_size_mul(in_level: int) -> float:
	return size_mul + size_mul_per_level_gain * in_level

@export_category("Audio")
@export var sound_bank_label: String = "Projectile"
@export var spawn_sound_event: SoundEventResource
@export var loop_sound_event: SoundEventResource
@export var hit_sound_event: SoundEventResource

func get_spawn_sound_pitch_mul() -> float:
	return spawn_sound_event.pitch * randf_range(0.9, 1.1)

func get_spawn_sound_volume_db() -> float:
	return spawn_sound_event.volume

func get_hit_sound_pitch_mul(in_hit_speed: float) -> float:
	return maxf(hit_sound_event.pitch - 0.5 + in_hit_speed * 0.005, 0.5) * randf_range(0.9, 1.1)

func get_hit_sound_volume_db(in_hit_speed: float) -> float:
	return minf(hit_sound_event.volume - 12.0 + in_hit_speed * 0.025, 0.0)

@export_category("Hits")
@export var hit_speed_threshold: float = 0.0
@export var should_damage_on_hit: bool = false
@export var hit_damage_mul: float = 1.0
@export var hit_damage_mul_per_level_gain: float = 0.0
@export var should_remove_on_hit: bool = true
@export var monitor_hits_start_delay: float = 0.0

func get_hit_damage_mul(in_level: int) -> float:
	return hit_damage_mul + hit_damage_mul_per_level_gain * in_level

@export_category("Lifetime")
@export var max_lifetime: float = -1.0
