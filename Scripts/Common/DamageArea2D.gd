extends Area2D
class_name DamageArea2D

const ReceiveImpulseMethodName: StringName = &"DamageArea2D_receive_impulse"

@export_category("Owner")
@export var owner_body: Node2D
@export var owner_movement: Pawn2D_CharacterMovement
@export var owner_perception: Pawn2D_Perception

@export_category("Damage")
@export var damage: float = 10.0
@export_flags("MeleeHit", "RangedHit", "Explosion", "Fire", "Poison", "Impact", "Fall") var damage_type: int = DamageReceiver.DamageType_MeleeHit
@export var damage_cooldown_time: float = 1.0
@export var damage_initial_delay: float = 0.5:
	set(in_time):
		damage_initial_delay = in_time
		if damage_initial_delay > 0.0:
			if not body_entered.is_connected(_handle_damage_initial_delay):
				body_entered.connect(_handle_damage_initial_delay)
		else:
			if body_entered.is_connected(_handle_damage_initial_delay):
				body_entered.disconnect(_handle_damage_initial_delay)

@export var damage_to_impulse_mul: float = 5.0

@export var use_individual_cooldowns: bool = false:
	set(in_use):
		use_individual_cooldowns = in_use
		if use_individual_cooldowns:
			process_cooldowns_callable = process_cooldowns_individual
		else:
			process_cooldowns_callable = process_cooldowns_common

func _ready() -> void:
	
	damage_initial_delay = damage_initial_delay
	
	if owner_movement:
		owner_movement.bounce.connect(_on_owner_movement_bounce)

var process_cooldowns_callable: Callable = process_cooldowns_common

func _physics_process(in_delta: float) -> void:
	process_cooldowns_callable.call(in_delta)

func enable() -> void:
	set_deferred("monitoring", true)
	set_physics_process(true)

func disable() -> void:
	set_deferred("monitoring", false)
	set_physics_process(false)

func is_valid_target(in_target: Node2D) -> bool:
	return not owner_perception or owner_perception.is_valid_target(in_target)

func _handle_damage_initial_delay(in_target: Node2D) -> void:
	
	var valid_targets_num := 0
	for sample_target: Node2D in get_overlapping_bodies():
		if is_valid_target(sample_target):
			valid_targets_num += 1
			if valid_targets_num > 1:
				return
	
	if valid_targets_num == 1:
		if use_individual_cooldowns:
			individual_cooldown_time_dictionary[in_target] = maxf(individual_cooldown_time_dictionary.get(in_target, 0.0), damage_initial_delay)
		else:
			common_cooldown_time_left = maxf(common_cooldown_time_left, damage_initial_delay)

var common_cooldown_time_left: float = 0.0

func process_cooldowns_common(in_delta: float) -> void:
	
	common_cooldown_time_left -= in_delta
	
	if common_cooldown_time_left > 0.0:
		pass
	else:
		var implact_applied = false
		
		for sample_target: Node2D in get_overlapping_bodies():
			if is_valid_target(sample_target):
				apply_impact_to(sample_target)
				implact_applied = true
		
		if implact_applied:
			common_cooldown_time_left = damage_cooldown_time

var individual_cooldown_time_dictionary: Dictionary[Node2D, float] = {}

func process_cooldowns_individual(in_delta: float) -> void:
	
	for sample_target: Node2D in get_overlapping_bodies():
		
		if individual_cooldown_time_dictionary.get(sample_target, 0.0) > 0.0:
			continue
		
		if not is_valid_target(sample_target):
			continue
		
		apply_impact_to(sample_target)
	
	for sample_target: Node2D in individual_cooldown_time_dictionary.keys():
		
		if is_instance_valid(sample_target):
			
			individual_cooldown_time_dictionary[sample_target] -= in_delta
			
			if individual_cooldown_time_dictionary[sample_target] > 0.0:
				individual_cooldown_time_dictionary.erase(sample_target)
		else:
			individual_cooldown_time_dictionary.erase(sample_target)

signal post_apply_impact_to(in_target: Node2D)

func apply_impact_to(in_target: Node2D) -> void:
	apply_damage_to(in_target)
	apply_impulse_to(in_target)
	post_apply_impact_to.emit(in_target)

func _on_owner_movement_bounce(in_bounce_collision: KinematicCollision2D) -> void:
	
	var collider_target := in_bounce_collision.get_collider() as Node2D
	
	var current_time := Time.get_unix_time_from_system()
	if use_individual_cooldowns:
		if individual_cooldown_time_dictionary.get(collider_target, 0.0) > 0.0:
			return
	else:
		if common_cooldown_time_left > 0.0:
			return
	
	if is_valid_target(collider_target):
		
		apply_impact_to(collider_target)
		
		if use_individual_cooldowns:
			common_cooldown_time_left = damage_cooldown_time
		else:
			individual_cooldown_time_dictionary[collider_target] = common_cooldown_time_left

func apply_impulse_to(in_target: Node2D):
	
	if damage_to_impulse_mul <= 0.0:
		return
	
	var has_receive_method := in_target.has_method(ReceiveImpulseMethodName)
	if not has_receive_method and (not in_target is RigidBody2D):
		return
	
	var max_impulse := damage * randfn(damage_to_impulse_mul, damage_to_impulse_mul * 0.5)
	
	var target_impulse_with_offset := GameGlobals.calc_radial_impulse_with_offset_for_target(in_target, owner_body.global_position, max_impulse, 0.0)
	var target_impulse := Vector2(target_impulse_with_offset.x, target_impulse_with_offset.y)
	var impulse_offset := Vector2(target_impulse_with_offset.z, target_impulse_with_offset.w)
	
	if has_receive_method and in_target.call(ReceiveImpulseMethodName, self, target_impulse, impulse_offset):
		pass
	elif in_target is RigidBody2D:
		in_target.apply_impulse(target_impulse, impulse_offset)

func apply_damage_to(in_target: Node2D):
	var target_receiver := DamageReceiver.try_get_from(in_target)
	if target_receiver:
		target_receiver.try_receive_damage(self, owner_body, damage, damage_type, false)
