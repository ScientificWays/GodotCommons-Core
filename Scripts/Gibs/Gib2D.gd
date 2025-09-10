extends RigidBody2D
class_name Gib2D

static func ShouldSpawn(InGib: Gib2D) -> bool:
	return not InGib.IsCosmetic or GameGlobals.GibsSetting > GameGlobals.GraphicsOption.Minimal

static func Spawn(InPosition: Vector2, InScene: PackedScene, InParent: Node = WorldGlobals._Level) -> Gib2D:
	
	assert(InScene)
	
	var NewGib := WorldGlobals.GibScene.instantiate() as Gib2D
	if ShouldSpawn(NewGib):
		NewGib.position = InPosition
		InParent.add_child.call_deferred(NewGib)
		return NewGib
	return null

@export_category("Optimization")
@export var IsHighPriority: bool = false
@export var IsCosmetic: bool = true
@export var ShouldFreezeOnSleep: bool = true

func _ready():
	
	if ShouldFreezeOnSleep:
		sleeping_state_changed.connect(OnSleepingStateChanged)

func _enter_tree():
	if not Engine.is_editor_hint():
		#WorldGlobals._Level._OptimizationManager.RegisterGib(self)
		pass

func _exit_tree():
	if not Engine.is_editor_hint():
		#WorldGlobals._Level._OptimizationManager.UnRegisterGib(self)
		pass

func OnSleepingStateChanged():
	assert(ShouldFreezeOnSleep)
	set_deferred("freeze", sleeping)

func Break():
	queue_free()
