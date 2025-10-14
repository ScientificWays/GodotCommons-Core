extends Node2D
class_name GibsTemplate2D

static func Spawn(in_position: Vector2, InTemplateScene: PackedScene, in_impulse: Vector2, InCanIgnite: bool, InGibsNumMul: float = 1.0, InParent: Node = WorldGlobals._level) -> GibsTemplate2D:
	
	assert(InTemplateScene)
	
	var OutGibs := InTemplateScene.instantiate() as GibsTemplate2D
	OutGibs._Impulse = in_impulse
	OutGibs._CanIgnite = InCanIgnite
	OutGibs._GibsNumMul = InGibsNumMul
	OutGibs.position = in_position
	
	assert(InParent)
	InParent.add_child.call_deferred(OutGibs)
	return OutGibs

@export_category("Gibs")
@export var SpawnGibsNumMinMax: Vector2i = Vector2i(1, 2)
@export var SpawnGibsSceneArray: Array[PackedScene]
@export var GibsIgniteProbability: float = 0.0
@export var GibsSpawnRadiusInnerOuter: Vector2 = Vector2(0.0, 8.0)

func GetRandomGibSpawnOffset() -> Vector2:
	return Vector2.from_angle(randf_range(-PI, PI)) *  randf_range(GibsSpawnRadiusInnerOuter.x, GibsSpawnRadiusInnerOuter.y)

@export_category("Particles")
@export var ParticlesScene: PackedScene
@export var ParticlesMinMax: Vector2i = Vector2i(0, 2)

@export_category("Impulse")
enum ImpulseType
{
	None = 0,
	Radial = 1
}

@export_enum("None:0", "Radial:1") var InitialImpulseType: int = 0
@export var InitialImpulseAngleMinMax: Vector2 = Vector2(-0.5, 0.5)
@export var InitialImpulseMinMax: Vector2 = Vector2(25.0, 50.0)
@export var InitialTorqueImpulseMinMax: Vector2 = Vector2(-1.5, 1.5)

var _Impulse: Vector2
var _CanIgnite: bool
var _GibsNumMul: float

func _ready() -> void:
	
	for SampleChild: Node in get_children():
		
		var SampleGib := SampleChild as Gib2D
		if is_instance_valid(SampleGib):
			
			if InitGib(SampleGib):
				SampleGib.reparent(get_parent(), true)
			else:
				SampleGib.queue_free()
	
	var GibsNum := roundi(float(randi_range(SpawnGibsNumMinMax.x, SpawnGibsNumMinMax.y)) * _GibsNumMul)
	
	for SampleIndex: int in range(GibsNum):
		
		var SampleGibScene := SpawnGibsSceneArray.pick_random() as PackedScene
		var SamplePosition := position + GetRandomGibSpawnOffset()
		var SampleGib := Gib2D.Spawn(SamplePosition, SampleGibScene, get_parent())
		InitGib(SampleGib)

func InitGib(InGib: Gib2D) -> bool:
	
	## In case of "minimal gibs" settings
	if not is_instance_valid(InGib):
		return false
	
	if not Gib2D.ShouldSpawn(InGib):
		return false
	
	ApplyInitialImpulseTo(InGib)
	
	var SampleGibImpulse := _Impulse * Vector2(randf_range(0.75, 1.25), randf_range(0.75, 1.25))
	InGib.apply_impulse(SampleGibImpulse)
	InGib.apply_torque(randf_range(-0.1, 0.1))
	
	if _CanIgnite and GibsIgniteProbability > 0.0 and randf() < GibsIgniteProbability:
		GameGlobals.Ignite.call_deferred(InGib, randf_range(5.0, 10.0), 2.0, 2)
	
	if ParticlesScene:
		var SampleParticlesNum := randi_range(ParticlesMinMax.x, ParticlesMinMax.y)
		if SampleParticlesNum > 0:
			var SampleParticles := ParticlesScene.instantiate() as ParticleSystem2D
			#SampleParticles.InitAsOneShot(Vector2.ZERO, SampleParticlesNum, 4.0, InGib)
			SampleParticles.InitAsOneShot(Vector2.ZERO, 0, 4.0, InGib)
			SampleParticles.EmitParticlesWithVelocity(SampleParticlesNum, SampleGibImpulse * 0.5)
	
	return true

func ApplyInitialImpulseTo(InGib: Gib2D) -> void:
	
	if InitialImpulseType == ImpulseType.Radial:
		var SampleImpulseAngle := InGib.global_position.angle() + randf_range(InitialImpulseAngleMinMax.x, InitialImpulseAngleMinMax.y)
		var SampleImpulse := Vector2.from_angle(SampleImpulseAngle) * randf_range(InitialImpulseMinMax.x, InitialImpulseMinMax.y)
		InGib.apply_impulse(SampleImpulse)
		InGib.apply_torque_impulse(randf_range(InitialTorqueImpulseMinMax.x, InitialTorqueImpulseMinMax.y))
