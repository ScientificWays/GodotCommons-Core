extends Area2D
class_name Projectile2D_Homing

@export_category("Owner")
@export var owner_projectile: Projectile2D
@export var ignore_owner_mass: bool = true

@export_category("Targeting")
@export var ignore_instigator: bool = true

@export_category("Torque")
@export var homing_torque_mul_base: float = 1.0
@export var homing_torque_mul_per_level_gain: float = 0.1

const homing_torque_magnitude_base: float = 50.0

func get_homing_torque_mul() -> float:
	return homing_torque_mul_base + homing_torque_mul_per_level_gain * owner_projectile._level

func calc_torque_magnitude() -> float:
	
	var out_magnitude := homing_torque_magnitude_base * get_homing_torque_mul()
	if ignore_owner_mass:
		out_magnitude *= owner_projectile.mass
	return out_magnitude

var current_homing_target: Node2D = null

func _ready() -> void:
	
	assert(owner_projectile)
	
	area_entered.connect(_on_homing_target_entered)
	body_entered.connect(_on_homing_target_entered)
	area_exited.connect(_on_homing_target_exited)
	body_exited.connect(_on_homing_target_exited)

func _physics_process(in_delta: float) -> void:
	
	if not is_instance_valid(current_homing_target):
		return
	
	var homing_angle := owner_projectile.global_position.angle_to_point(current_homing_target.global_position)
	var projectile_angle := owner_projectile.global_rotation
	owner_projectile.apply_torque(angle_difference(projectile_angle, homing_angle) * calc_torque_magnitude())

func _on_homing_target_entered(in_target: Node2D) -> void:
	
	if ignore_instigator and in_target == owner_projectile._instigator:
		return
	
	current_homing_target = in_target

func _on_homing_target_exited(in_target: Node2D) -> void:
	if in_target == current_homing_target:
		current_homing_target = null
