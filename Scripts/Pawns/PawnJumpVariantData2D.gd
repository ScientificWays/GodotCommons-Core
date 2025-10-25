extends Resource
class_name PawnJumpVariantData2D

@export_category("Animation")
@export var animation_name: StringName = &"Jump"
@export var should_reset_animation_on_finish: bool = true
@export var start_frame: int = 0
@export var end_frame: int = 1
@export var z_index_additive: int = 2

@export_category("Launch")
@export var impulse: float = 100.0
@export var launch_velocity_damp: float = 3.0
@export var ignore_mass: bool = true
@export_flags_2d_physics var launch_collision_layer: int = GameGlobals_Class.collision_layer_explosion_receiver
@export_flags_2d_physics var launch_collision_mask: int = 0

@export_category("Land")
@export var land_explosion_data: ExplosionData2D
@export var land_explosion_radius: float = 32.0
@export var land_explosion_radius_per_level_gain: float = 2.0
@export var land_explosion_damage: float = 32.0
@export var land_explosion_damage_per_level_gain: float = 8.0
@export var land_explosion_impulse: float = 100.0
@export var land_explosion_impulse_per_level_gain: float = 20.0
@export var land_owner_status_effect: StatusEffectData
@export var land_owner_status_effect_duration: float = 2.0

func get_land_explosion_radius(in_level: int) -> float:
	return land_explosion_radius + land_explosion_radius_per_level_gain * in_level

func get_land_explosion_damage(in_level: int) -> float:
	return land_explosion_damage + land_explosion_damage_per_level_gain * in_level

func get_land_explosion_impulse(in_level: int) -> float:
	return land_explosion_impulse + land_explosion_impulse_per_level_gain * in_level
