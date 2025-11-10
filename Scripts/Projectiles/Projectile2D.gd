@tool
extends RigidBody2D
class_name Projectile2D

static func spawn(in_transform: Transform2D, in_data: ProjectileData2D, in_level: int, in_instigator: Node, in_parent: Node = WorldGlobals._level._y_sorted) -> Projectile2D:
	
	assert(in_data)
	assert(in_data.scene)
	
	assert(in_level >= 0)
	
	var out_projectile := in_data.scene.instantiate() as Projectile2D
	out_projectile.data = in_data
	out_projectile._level = in_level
	out_projectile._instigator = in_instigator
	out_projectile.transform = in_transform
	in_parent.add_child.call_deferred(out_projectile)
	return out_projectile

@export_category("Sprite")
@export var sprite: AnimatedSprite2D
@export var allow_different_sprite_z_index: bool = false

var data: ProjectileData2D

##
## Instigator
##
var _instigator: Node:
	set(in_instigator):
		
		if _instigator:
			_instigator.tree_exited.disconnect(_on_instigator_tree_exited)
		
		_instigator = in_instigator
		
		if _instigator:
			_instigator.tree_exited.connect(_on_instigator_tree_exited)

func _on_instigator_tree_exited():
	_instigator = null

var _level: int = 0
var _power: float = 1.0

var loop_sound_instance: PooledAudioStreamPlayer2D

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not sprite:
			sprite = find_child("*?prite*")
		if sprite and not allow_different_sprite_z_index:
			sprite.z_index = GameGlobals_Class.PROJECTILE_2D_SPRITE_DEFAULT_Z_INDEX
			sprite.z_as_relative = false
	else:
		var size_mul := data.get_size_mul(_level)
		size_mul *= _power
		
		mass *= data.get_mass_mul(_level) * pow(size_mul, data.size_mul_mass_scale_factor)
		
		if _instigator is PhysicsBody2D:
			add_collision_exception_with(_instigator)
			GameGlobals.spawn_one_shot_timer_for(self, func():
				if is_instance_valid(_instigator):
					self.remove_collision_exception_with(_instigator), 1.0)
		
		if data.spawn_sound_event:
			AudioGlobals.try_play_sound_varied_at_global_position(data.sound_bank_label, data.spawn_sound_event, global_position, data.get_spawn_sound_pitch_mul(), data.get_spawn_sound_volume_db())
		
		if data.loop_sound_event:
			loop_sound_instance = AudioGlobals.try_play_sound_on_node_at_global_position(data.sound_bank_label, data.loop_sound_event, self)
		
		if data.max_lifetime > 0.0:
			set_lifetime(data.max_lifetime)

##
## Lifetime
##
var _lifetime_timer: Timer

func set_lifetime(in_lifetime: float):
	
	if _lifetime_timer:
		_lifetime_timer.queue_free()
		_lifetime_timer = null
	
	if in_lifetime > 0.0:
		_lifetime_timer = GameGlobals.spawn_one_shot_timer_for(self, _on_lifetime_timer_timeout, in_lifetime)
	else:
		_on_lifetime_timer_timeout.call_deferred()

func _on_lifetime_timer_timeout():
	handle_remove_from_scene(RemoveReason.Lifetime)

##
## Remove
##
enum RemoveReason
{
	Default = 0,
	Hit = 1,
	Damage = 2,
	Lifetime = 3,
	Detonate = 4
}
signal pre_removed_from_scene(in_reason: RemoveReason)

func handle_remove_from_scene(in_reason: RemoveReason):
	
	pre_removed_from_scene.emit(in_reason)
	
	if loop_sound_instance:
		loop_sound_instance.release(false)
	
	queue_free()
