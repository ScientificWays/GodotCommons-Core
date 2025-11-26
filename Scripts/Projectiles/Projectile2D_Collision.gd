extends CollisionShape2D
class_name Projectile2D_Collision

const monitor_hits_start_delay_meta: StringName = &"monitor_hits_start_delay"
const receive_explosions_delay_meta: StringName = &"receive_explosions_delay"

@export_category("Owner")
@export var _owner: Projectile2D
@export var owner_damage_area: Area2D

func _ready() -> void:
	
	assert(_owner)
	
	var size_mul := _owner.data.get_size_mul(_owner._level)
	var scaled_size_mul := size_mul * _owner._power
	
	shape = ResourceGlobals.get_or_create_scaled_shape(shape, scaled_size_mul, 0.0)
	position *= scaled_size_mul
	
	var monitor_hits_start_delay := get_meta(monitor_hits_start_delay_meta, 0.0) as float
	if monitor_hits_start_delay > 0.0:
		
		if owner_damage_area:
			owner_damage_area.monitoring = false
			GameGlobals.spawn_one_shot_timer_for(self, func():
				if is_instance_valid(owner_damage_area):
					owner_damage_area.monitoring = true
			, monitor_hits_start_delay)
		
		GameGlobals.delayed_collision_activate(_owner, _on_projectile_body_hit, monitor_hits_start_delay, self)
	else:
		_owner.body_entered.connect(_on_projectile_body_hit)
		
		if owner_damage_area:
			owner_damage_area.area_entered.connect(_on_damage_area_target_entered)
			owner_damage_area.body_entered.connect(_on_damage_area_target_entered)
	
	var receive_explosions_delay := get_meta(receive_explosions_delay_meta, 0.0) as float
	if receive_explosions_delay > 0.0 and _owner.collision_layer & GameGlobals_Class.collision_layer_explosion_receiver:
		_owner.collision_layer = GameGlobals_Class.remove_mask(_owner.collision_layer, GameGlobals_Class.collision_layer_explosion_receiver)
		GameGlobals.SpawnOneShotTimerFor(_owner, func(): _owner.collision_layer = GameGlobals_Class.remove_mask(_owner.collision_layer, GameGlobals_Class.collision_layer_explosion_receiver), 0.2)
	
	if _owner.data.should_damage_on_hit or _owner.data.should_remove_on_hit:
		assert(_owner.contact_monitor and _owner.max_contacts_reported > 0)

func _on_projectile_body_hit(in_target: Node) -> void:
	
	var hit_speed_squared := _owner.linear_velocity.length_squared() + _owner.angular_velocity * _owner.angular_velocity * 150.0
	if _owner.data.hit_speed_threshold > 0.0 and (hit_speed_squared < _owner.data.hit_speed_threshold * _owner.data.hit_speed_threshold):
		return
	
	var hit_speed := sqrt(hit_speed_squared)
	if _owner.data.hit_sound_event:
		AudioGlobals.try_play_sound_varied_at_global_position(_owner.data.sound_bank_label, _owner.data.hit_sound_event, _owner.global_position, _owner.data.get_hit_sound_pitch_mul(hit_speed), _owner.data.get_hit_sound_volume_db(hit_speed))
	
	if _owner.data.should_damage_on_hit:
		apply_impact_damage_to(in_target)
	
	if _owner.data.should_remove_on_hit:
		_owner.handle_remove_from_scene(Projectile2D.RemoveReason.Hit)

func _on_damage_area_target_entered(in_target: Node) -> void:
	apply_impact_damage_to(in_target)

func apply_impact_damage_to(in_target: Node) -> void:
	
	var target_receiver := DamageReceiver.try_get_from(in_target)
	if target_receiver:
		
		var instigator_receiver := DamageReceiver.try_get_from(_owner._instigator)
		if target_receiver != instigator_receiver:
			
			var target_damage := _owner.data.get_hit_damage(_owner._level)
			target_receiver.try_receive_damage(self, _owner._instigator, target_damage, DamageReceiver.DamageType_RangedHit, false)
