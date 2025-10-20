extends Area2D
class_name ShakeSource2D

static func spawn(in_position: Vector2, in_radius: float, InMaxOffset: Vector2 = Vector2(2.0, 2.0), InMaxRotation: float = 0.004, InDecaySpeed: float = 0.4, in_parent: Node = WorldGlobals._level) -> ShakeSource2D:
	
	var NewShakeSource := GameGlobals.ShakeSource2DScene.instantiate() as ShakeSource2D
	NewShakeSource.position = in_position
	NewShakeSource.ready.connect(NewShakeSource.Init.bind(in_radius, InMaxOffset, InMaxRotation, InDecaySpeed), Object.CONNECT_ONE_SHOT)
	in_parent.add_child.call_deferred(NewShakeSource)
	return NewShakeSource
 
@onready var _Collision: CollisionShape2D = $Collision

@export var _DistanceMulCurve: Curve = preload("res://addons/GodotCommons-Core/Assets/Shake/ShakeDistanceMulCurve.tres")

var MaxDistanceSquared: float = 64.0 * 64.0
var MaxOffset: Vector2 = Vector2(10.0, 10.0)
var MaxRotation: float = 0.01

var DecayAlpha: float = 1.0
var DecaySpeed: float = 1.0

func _ready():
	pass

func _physics_process(in_delta: float):
	
	var TargetOffset := MaxOffset * DecayAlpha
	var TargetRotation := MaxRotation * DecayAlpha
	
	TargetOffset = Vector2(
		randf_range(-TargetOffset.x, TargetOffset.x),
		randf_range(-TargetOffset.y, TargetOffset.y),
	)
	TargetRotation = randf_range(-TargetRotation, TargetRotation)
	
	var SourceGlobalPosition := global_position
	var TargetArray := get_overlapping_areas()
	
	for SampleTarget: Area2D in TargetArray:
		
		var _ShakeReceiver := SampleTarget as ShakeReceiver2D
		if not _ShakeReceiver:
			continue
		
		var SampleCamera := _ShakeReceiver._camera
		if SampleCamera:
			var TargetGlobalPosition := SampleTarget.global_position
			var DistanceMul := _DistanceMulCurve.sample_baked(TargetGlobalPosition.distance_squared_to(SourceGlobalPosition) / MaxDistanceSquared)
			#print("Shake source DistanceMul: ", DistanceMul)
			if DistanceMul > 0.0:
				SampleCamera.PendingOffset += TargetOffset * DistanceMul
				SampleCamera.PendingRotation += TargetRotation * DistanceMul
	
	DecayAlpha -= in_delta * DecaySpeed
	if DecayAlpha < 0.0:
		queue_free()

func Init(in_radius: float, InMaxOffset: Vector2, InMaxRotation: float, InDecaySpeed: float):
	
	assert(is_node_ready())
	
	var _CircleShape := _Collision.shape as CircleShape2D
	_CircleShape.radius = in_radius
	MaxDistanceSquared = in_radius * in_radius
	
	MaxOffset = InMaxOffset
	MaxRotation = InMaxRotation
	
	DecaySpeed = InDecaySpeed
	DecayAlpha = 1.0
