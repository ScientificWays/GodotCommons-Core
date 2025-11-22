extends Marker2D
class_name Projectile2D_Homing

@export_category("Owner")
@export var owner_projectile: Projectile2D
@export var ignore_owner_mass: bool = true

@export_category("Force")
@export var homing_force_mul_base: float = 1.0
@export var homing_force_mul_per_level_gain: float = 0.1

const homing_force_magnitude_base: float = 500.0

func get_homing_force_mul() -> float:
	return homing_force_mul_base + homing_force_mul_per_level_gain * owner_projectile._level

func calc_force_magnitude() -> float:
	
	var out_magnitude := homing_force_magnitude_base * get_homing_force_mul()
	if ignore_owner_mass:
		out_magnitude *= owner_projectile.mass
	return out_magnitude

var current_homing_target: Node2D = null

func _ready() -> void:
	
	assert(owner_projectile)
	
	owner_projectile.body_entered.connect(_on_owner_target_entered)
	owner_projectile.body_exited.connect(_on_owner_target_exited)

func _physics_process(in_delta: float) -> void:
	
	if not is_instance_valid(current_homing_target):
		return
	
	var homing_direction := owner_projectile.global_position.direction_to(current_homing_target.global_position)
	var homing_force := homing_direction * calc_force_magnitude()
	owner_projectile.apply_force(homing_force, global_position - owner_projectile.global_position)

func _on_owner_target_entered(in_target: Node2D) -> void:
	current_homing_target = in_target

func _on_owner_target_exited(in_target: Node2D) -> void:
	if in_target == current_homing_target:
		current_homing_target = null
