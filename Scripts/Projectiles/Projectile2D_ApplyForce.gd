extends Marker2D
class_name Projectile2D_ApplyForce

@export_category("Owner")
@export var owner_projectile: Projectile2D
@export var ignore_owner_mass: bool = true

@export_category("Initial")
@export var InitialImpulseMul: float = 0.25

@export_category("Constant")
@export var ConstantMagnitudeMul: float = 1.0
@export var ConstantMagnitudeMul_PerLevelGain: float = 0.0
@export var constant_magnitude_mul_power_factor: float = -0.5
@export var ApplyConstantAsVelocity: bool = false

func get_constant_magnitude_mul() -> float:
	return (ConstantMagnitudeMul + ConstantMagnitudeMul_PerLevelGain * owner_projectile._level) * pow(owner_projectile._power, constant_magnitude_mul_power_factor)

func calc_constant_magnitude() -> float:
	var out_magnitude := 100.0 * get_constant_magnitude_mul()
	if ignore_owner_mass: out_magnitude *= owner_projectile.mass
	return out_magnitude

@export_category("Pattern")
@export var PatternDirectionCurve: Curve2D = null
@export var PatternDirectionInLocalSpace: bool = true
@export var PatternMagnitudeMul: float = 1.0
@export var PatternMagnitudeMul_PerLevelGain: float = 0.0
@export var pattern_magnitude_mul_power_factor: float = -0.5
@export var PatternLoopSpeed: float = 1.0
@export var ApplyPatternAsVelocity: bool = false

func get_pattern_magnitude_mul() -> float:
	return (PatternMagnitudeMul + PatternMagnitudeMul_PerLevelGain * owner_projectile._level) * pow(owner_projectile._power, pattern_magnitude_mul_power_factor)

func calc_pattern_magnitude() -> float:
	var out_magnitude := 100.0 * get_pattern_magnitude_mul()
	if ignore_owner_mass: out_magnitude *= owner_projectile.mass
	return out_magnitude

func _ready() -> void:
	
	assert(owner_projectile)
	
	cached_constant_magnitude = calc_constant_magnitude()
	cached_pattern_magnitude = calc_pattern_magnitude()
	
	if InitialImpulseMul > 0.0:
		var Direction := Vector2.from_angle(global_rotation)
		var InitialImpulse := Direction * cached_constant_magnitude * InitialImpulseMul
		owner_projectile.apply_impulse(InitialImpulse, global_position)

var cached_constant_magnitude: float = 0.0
var cached_pattern_magnitude: float = 0.0
var ForcePatternDelta: float = 0.0

func _physics_process(in_delta: float) -> void:
	
	var NewVelocity := Vector2.ZERO
	var ApplyForce := Vector2.ZERO
	
	var ShouldUpdateVelocity := false
	var ShouldUpdateForce := false
	
	var ProjectileRotation := global_rotation
	var ConstantDirection := Vector2.from_angle(ProjectileRotation)
	var ConstantValue := ConstantDirection * cached_constant_magnitude
	
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
		
		var PatternValue := PatternDirection * cached_pattern_magnitude
		
		if ApplyPatternAsVelocity:
			NewVelocity += PatternValue
			ShouldUpdateVelocity = true
		else:
			ApplyForce += PatternValue
			ShouldUpdateForce = true
		
		ForcePatternDelta = fmod(ForcePatternDelta + in_delta * PatternLoopSpeed, float(PatternDirectionCurve.point_count - 1))
	
	if ShouldUpdateVelocity:
		owner_projectile.linear_velocity = NewVelocity
	if ShouldUpdateForce:
		owner_projectile.apply_force(ApplyForce, global_position - owner_projectile.global_position)
