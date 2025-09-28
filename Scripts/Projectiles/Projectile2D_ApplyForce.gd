extends Node
class_name Projectile2D_ApplyForce

@export_category("Owner")
@export var OwnerProjectile: Projectile2D

@export_category("Initial")
@export var InitialImpulseMul: float = 0.25

@export_category("Constant")
@export var ConstantLocalOffset: Vector2 = Vector2.ZERO
@export_range(-360.0, 360.0) var ConstantLocalAngleDegrees: float = 0.0
@export var ConstantMagnitudeMul: float = 1.0
@export var ConstantMagnitudeMul_PerLevelGain: float = 0.0
@export var ApplyConstantAsVelocity: bool = false

func GetConstantMagnitudeMul() -> float:
	return ConstantMagnitudeMul + ConstantMagnitudeMul_PerLevelGain * OwnerProjectile._level

@export_category("Pattern")
@export var PatternDirectionCurve: Curve2D = null
@export var PatternDirectionInLocalSpace: bool = true
@export var PatternMagnitudeMul: float = 1.0
@export var PatternMagnitudeMul_PerLevelGain: float = 0.0
@export var PatternLoopSpeed: float = 1.0
@export var ApplyPatternAsVelocity: bool = false

func GetPatternMagnitudeMul() -> float:
	return PatternMagnitudeMul + PatternMagnitudeMul_PerLevelGain * OwnerProjectile._level

var ForceOffsetNode: Marker2D = null
var ForcePatternDelta: float = 0.0

static func GetForceFromMul(InMul: float) -> float:
	return 100.0 * InMul

func _ready() -> void:
	
	assert(OwnerProjectile)
	
	ForceOffsetNode = Marker2D.new()
	ForceOffsetNode.transform = Transform2D(deg_to_rad(ConstantLocalAngleDegrees), ConstantLocalOffset)
	OwnerProjectile.add_child(ForceOffsetNode)
	
	if InitialImpulseMul > 0.0:
		var Direction := Vector2.from_angle(ForceOffsetNode.global_rotation)
		var InitialImpulse := Direction * GetForceFromMul(GetConstantMagnitudeMul()) * InitialImpulseMul
		OwnerProjectile.apply_impulse(InitialImpulse, ForceOffsetNode.global_position)

func _physics_process(InDelta: float) -> void:
	
	var NewVelocity := Vector2.ZERO
	var ApplyForce := Vector2.ZERO
	
	var ShouldUpdateVelocity := false
	var ShouldUpdateForce := false
	
	var ProjectileRotation := ForceOffsetNode.global_rotation
	var ConstantDirection := Vector2.from_angle(ProjectileRotation)
	var ConstantValue = ConstantDirection * GetForceFromMul(GetConstantMagnitudeMul())
	
	if ApplyConstantAsVelocity:
		NewVelocity += ConstantValue
		ShouldUpdateVelocity = true
	else:
		ApplyForce += ConstantValue
		ShouldUpdateForce = true
	
	if PatternDirectionCurve:
		
		var PatternDirection := PatternDirectionCurve.samplef(ForcePatternDelta)
		if PatternDirectionInLocalSpace:
			PatternDirection = PatternDirection.rotated(ProjectileRotation)
		
		var PatternValue := PatternDirection * GetForceFromMul(GetPatternMagnitudeMul())
		
		if ApplyPatternAsVelocity:
			NewVelocity += PatternValue
			ShouldUpdateVelocity = true
		else:
			ApplyForce += PatternValue
			ShouldUpdateForce = true
		
		ForcePatternDelta = fmod(ForcePatternDelta + get_physics_process_delta_time() * PatternLoopSpeed, float(PatternDirectionCurve.point_count - 1))
	
	if ShouldUpdateVelocity:
		OwnerProjectile.linear_velocity = NewVelocity
	if ShouldUpdateForce:
		OwnerProjectile.apply_force(ApplyForce, ForceOffsetNode.global_position - OwnerProjectile.global_position)
