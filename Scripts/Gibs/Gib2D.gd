@tool
extends RigidBody2D
class_name Gib2D

const OPTIMIZATION_GIB_2D_IDENTIFIER: StringName = &"Gib2D"

static func should_spawn(in_gib: Gib2D) -> bool:
	return not in_gib.is_cosmetic or GameGlobals.GibsSetting > GameGlobals.GraphicsOption.Minimal

static func spawn(in_position: Vector2, in_scene: PackedScene, in_parent: Node = WorldGlobals._level) -> Gib2D:
	
	assert(in_scene)
	
	var out_gib := in_scene.instantiate() as Gib2D
	if should_spawn(out_gib):
		out_gib.position = in_position
		in_parent.add_child.call_deferred(out_gib)
		return out_gib
	return null

@export var sprite: Sprite2D
@export var ignite_probability: float = 0.0

@export_category("Optimization")
@export var is_high_priority: bool = false
@export var is_cosmetic: bool = true
@export var should_freeze_on_sleep: bool = true

func _ready():
	
	if Engine.is_editor_hint():
		if not sprite:
			sprite = find_child("*?prite*")
	else:
		if (collision_layer & GameGlobals_Class.collision_layer_gib) == 0:
			push_warning("%s does not have Gib collision_layer!" % self)
		
		assert(sprite)
		sprite.frame = randi_range(0, sprite.hframes * sprite.vframes - 1)
		
		if should_freeze_on_sleep:
			sleeping_state_changed.connect(OnSleepingStateChanged)
		
		OptimizationGlobals.register_managed_node(OPTIMIZATION_GIB_2D_IDENTIFIER, self)

func _enter_tree():
	if not Engine.is_editor_hint():
		#WorldGlobals._level._OptimizationManager.RegisterGib(self)
		pass

func _exit_tree():
	if not Engine.is_editor_hint():
		#WorldGlobals._level._OptimizationManager.UnRegisterGib(self)
		pass

func OnSleepingStateChanged():
	assert(should_freeze_on_sleep)
	set_deferred("freeze", sleeping)

func try_ignite(in_duration: float) -> bool:
	
	if in_duration <= 0.0 or randf() > ignite_probability:
		return false
	
	GameGlobals.ignite_target(self, in_duration)
	return true

func Explosion2D_receive_impulse(in_explosion: Explosion2D, in_impulse: Vector2, in_offset: Vector2) -> bool:
	handle_break(in_impulse)
	return true

func handle_break(in_impulse: Vector2):
	queue_free()
