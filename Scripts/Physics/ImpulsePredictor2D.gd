extends Node
class_name ImpulsePredictor2D

@export var OutputLine: Line2D

@export var step: float = 1.0 / 30.0
@export var gravity: Vector2 = Vector2.ZERO
@export var max_time: float = 1.0
@export var max_bounces: int = 3

var TargetBody: RigidBody2D
var ImpulseVector: Vector2
var CachedBodyDamp: float

signal SimulationFinished()

func _ready():
	assert(OutputLine)

func GetLastPoint() -> Vector2:
	return OutputLine.get_point_position(OutputLine.get_point_count() - 1)

func QueueSimulation(InTargetBody: RigidBody2D, in_impulseVector: Vector2):
	
	TargetBody = InTargetBody
	ImpulseVector = in_impulseVector
	
	if not InTargetBody.is_node_ready():
		await InTargetBody.ready
	
	CachedBodyDamp = WorldGlobals.calc_body_combined_linear_damp(TargetBody)
	
	if not get_tree().physics_frame.is_connected(QueueSimulation_Process):
		get_tree().physics_frame.connect(QueueSimulation_Process, Object.CONNECT_ONE_SHOT)

func QueueSimulation_Process():
	
	var OutPoints := CalcMovementPoints()
	OutputLine.points = OutPoints
	SimulationFinished.emit()

func Reset(InResetLine: bool = true):
	
	if InResetLine:
		OutputLine.clear_points()
	
	if get_tree().physics_frame.is_connected(QueueSimulation_Process):
		get_tree().physics_frame.disconnect(QueueSimulation_Process)

func CalcMovementPoints() -> PackedVector2Array:
	
	var pos := TargetBody.global_position
	var ret: PackedVector2Array = [ pos ]
	
	var ImpulseVectorLength := ImpulseVector.length()
	if ImpulseVectorLength < 0.001:
		return ret
	
	var ImpulseDirection := ImpulseVector / ImpulseVectorLength
	var v := TargetBody.linear_velocity + ImpulseVector
	
	var bounces := 0
	var t := 0.0
	
	var rid := TargetBody.get_rid()
	
	var mat: PhysicsMaterial = TargetBody.physics_material_override
	var bounce := mat.bounce if mat else 0.1
	var friction := mat.friction if mat else 0.25
	
	while t < max_time and bounces <= max_bounces and v.length() > 5.0:
		
		var next_v := v + gravity * step
		next_v *= clampf(1.0 - CachedBodyDamp * step, 0.0, 1.0)
		
		var next_pos := pos + v * step + 0.5 * gravity * step * step
		var motion := next_pos - pos
		
		var params := PhysicsTestMotionParameters2D.new()
		params.from = Transform2D(0.0, pos)
		params.motion = motion
		params.margin = 0.1
		
		var result := PhysicsTestMotionResult2D.new()
		var collided := PhysicsServer2D.body_test_motion(rid, params, result)
		
		if collided:
			pos += motion * result.get_collision_safe_fraction()
			ret.push_back(pos)
			
			var n := result.get_collision_normal()
			# отражение скорости
			v = v - (1.0 + bounce) * v.dot(n) * n
			# примитивное трение
			var vn := v.dot(n) * n
			var vt := v - vn
			vt *= max(0.0, 1.0 - 0.2 * friction)
			v = vt + vn
			
			bounces += 1
			t += step
		else:
			pos = next_pos
			v = next_v
			ret.push_back(pos)
			t += step
	return ret
