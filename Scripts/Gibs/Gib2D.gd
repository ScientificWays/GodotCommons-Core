@tool
extends RigidBody2D
class_name Gib2D

static func ShouldSpawn(InGib: Gib2D) -> bool:
	return not InGib.IsCosmetic or GameGlobals.GibsSetting > GameGlobals.GraphicsOption.Minimal

static func Spawn(in_position: Vector2, InScene: PackedScene, InParent: Node = WorldGlobals._level) -> Gib2D:
	
	assert(InScene)
	
	var NewGib := WorldGlobals.GibScene.instantiate() as Gib2D
	if ShouldSpawn(NewGib):
		NewGib.position = in_position
		InParent.add_child.call_deferred(NewGib)
		return NewGib
	return null

@export var sprite: Sprite2D
@export var ignite_probability: float = 0.0

@export_category("Optimization")
@export var IsHighPriority: bool = false
@export var IsCosmetic: bool = true
@export var ShouldFreezeOnSleep: bool = true

func _ready():
	
	if Engine.is_editor_hint():
		pass
	else:
		
		assert(sprite)
		
		sprite.frame = randi_range(0, sprite.hframes * sprite.vframes - 1)
		
		if ShouldFreezeOnSleep:
			sleeping_state_changed.connect(OnSleepingStateChanged)

func _enter_tree():
	if not Engine.is_editor_hint():
		#WorldGlobals._level._OptimizationManager.RegisterGib(self)
		pass

func _exit_tree():
	if not Engine.is_editor_hint():
		#WorldGlobals._level._OptimizationManager.UnRegisterGib(self)
		pass

func OnSleepingStateChanged():
	assert(ShouldFreezeOnSleep)
	set_deferred("freeze", sleeping)

func try_ignite(in_duration: float) -> bool:
	
	if randf() > ignite_probability:
		return false
	
	GameGlobals.ignite_target(self, in_duration)
	return true

func Break():
	queue_free()
