extends Projectile2D
class_name BombProjectile2D

const StockReplenishBaseTimeMul: float = 2.5
const StockReplenishBaseMax: int = 4

const BombletMeta: StringName = &"Bomblet"

@export_category("Owner")
@export var BeepLight: PointLight2D
@export var BeepAnimationPlayer: AnimationPlayer

@export_category("Audio")
@export var BeepSoundEvent: SoundEventResource = preload("res://addons/GodotCommons-Core/Assets/Audio/Events/Projectiles/Bombs/Beep001.tres")
@export var ThrowSoundEvent: SoundEventResource = preload("res://addons/GodotCommons-Core/Assets/Audio/Events/Projectiles/Throw001.tres")
@export var DetonateSoundEvent: SoundEventResource

func GetThrowSoundPitchMul() -> float:
	return maxf(ThrowSoundEvent.pitch - 0.4 + AppliedThrowVectorScale * 0.8, 0.5) * randf_range(0.9, 1.1)

func GetThrowSoundVolumeDb() -> float:
	return minf(ThrowSoundEvent.volume - 12.0 + AppliedThrowVectorScale * 32.0, 0.0)

func ShouldPlayDetonateSound(FromTimer: bool) -> bool:
	return true

func GetDetonateSoundPitchMul(FromTimer: bool) -> float:
	return DetonateSoundEvent.pitch * randf_range(0.9, 1.1)

func GetDetonateSoundVolumeDb(FromTimer: bool) -> float:
	return DetonateSoundEvent.volume

@export_category("Throw")
@export var _ThrowPlayerImpulseScale: float = -0.1
@export var _ThrowBombImpulseScale: float = 6.5
@export var _ThrowAngularVelocityMinMax: Vector2 = Vector2(-10.0, 10.0)
@export var _ThrowAngleMinMax: Vector2 = Vector2(-5.0, 5.0)

@export_category("Detonate")
@export var _ShouldDetonateOnHit: bool = false
@export var _ShouldDetonateOnReceiveDamage: bool = false
@export var _DetonateDelayCurve: Curve = preload("res://Assets/Projectiles/DefaultBomb_DetonateCurve.tres")
@export var _DetonateBeepTime: float = 0.4

@export_category("Explosion")
@export var _ExplosionScene: PackedScene = preload("res://addons/GodotCommons-Core/Scenes/Explosions/Explosion001.tscn")
@export var _ExplosionRadiusMul: float = 1.0
@export var _ExplosionRadiusMul_PerLevelGain: float = 0.0
@export var _ExplosionDamageMul: float = 1.0
@export var _ExplosionDamageMul_PerLevelGain: float = 0.0
@export var _ExplosionImpulseMul: float = 1.0
@export var _ExplosionImpulseMul_PerLevelSqrtGain: float = 0.0
@export var _ExternalExplosionImpulseMul: float = 1.0

func GetExplosionRadiusMul() -> float:
	return _ExplosionRadiusMul + _ExplosionRadiusMul_PerLevelGain * _level

func GetExplosionDamageMul() -> float:
	return _ExplosionDamageMul + _ExplosionDamageMul_PerLevelGain * _level

func GetExplosionImpulseMul() -> float:
	return _ExplosionImpulseMul + _ExplosionImpulseMul_PerLevelSqrtGain * sqrt(_level)

func GetExplosionRadius() -> float:
	return Explosion2D.BaseRadius * GetExplosionRadiusMul()

func GetExplosionDamage() -> float:
	return Explosion2D.BaseDamage * GetExplosionDamageMul()

func GetExplosionImpulse() -> float:
	return Explosion2D.BaseImpulse * GetExplosionImpulseMul()

@export_category("Stock")
@export var StockColor: Color = Color.GRAY
@export var _StockReplenishTimeMul: float = 1.0
@export var _StockReplenishTimeMul_PerLevelSqrtGain: float = 0.0
@export var _StockMaxMul: float = 1.0
@export var _StockMaxMul_PerLevelGain: float = 0.0

func GetStockReplenishTimeMul(InLevel: int) -> float:
	return _StockReplenishTimeMul + _StockReplenishTimeMul_PerLevelSqrtGain * sqrt(float(InLevel))

func GetStockMaxMul(InLevel: int) -> float:
	return _StockMaxMul + _StockMaxMul_PerLevelGain * InLevel

func GetStockReplenishTime(InLevel: int) -> float:
	return StockReplenishBaseTimeMul * GetStockReplenishTimeMul(InLevel)

func GetStockMax(InLevel: int) -> int:
	return maxi(roundi(float(StockReplenishBaseMax) * GetStockMaxMul(InLevel)), 1)

@export_category("Avoidance")
@export var _AvoidanceRadius: float = 6.0

var AwaitForThrowImpulse: bool = false
signal ThrowImpulseApplied()

var DetonateDelay: float = 0.0
signal Detonate(FromTimer: bool)

var _DetonateTimer: Timer
var _BeepTimer: Timer

func _ready() -> void:
	
	if AwaitForThrowImpulse:
		await ThrowImpulseApplied
	
	if DetonateDelay > 0.0:
		
		_DetonateTimer = GameGlobals.SpawnOneShotTimerFor(self, OnDetonateTimerTimeout, DetonateDelay)
		BeepLight.visible = false
		
		if DetonateDelay > _DetonateBeepTime:
			_BeepTimer = GameGlobals.SpawnRegularTimerFor(self, OnBeepTimerTimeout, DetonateDelay - _DetonateBeepTime)
		else:
			OnBeepTimerTimeout()
			#var BeepPassedTime := _DetonateBeepTime - DetonateDelay
			#BeepAnimationPlayer.advance(BeepPassedTime / _DetonateBeepTime)

##
## Detonate
##
func OnDetonateTimerTimeout():
	HandleDetonate(true)

func HandleDetonate(FromTimer: bool):
	
	if not is_node_ready():
		OS.alert("Trying to detonate bomb before node is ready!")
	
	Detonate.emit(FromTimer)
	
	if is_instance_valid(self):
		
		if DetonateSoundEvent and ShouldPlayDetonateSound(FromTimer):
			ResourceGlobals.GetOrCreateSoundBankAndAppendEvent("Bomb", DetonateSoundEvent)
			SoundManager.play_at_position_varied("Bomb", DetonateSoundEvent.name, global_position, GetDetonateSoundPitchMul(FromTimer), GetDetonateSoundVolumeDb(FromTimer))
		
		SpawnExplosionAt(global_position)
		HandleRemoveFromScene(RemoveReason.Detonate)

var ExplosionDamageReceiverCallableArray: Array[Callable] = []

func SpawnExplosionAt(InGlobalPosition: Vector2) -> Explosion2D:
	var OutExplosion := Explosion2D.Spawn(InGlobalPosition, _ExplosionScene, _level, GetExplosionRadius(), GetExplosionDamage(), GetExplosionImpulse(), _Instigator) as Explosion2D
	#OutExplosion.OverlayDataArray = ExplosionOverlayDataArray
	OutExplosion.DamageReceiverCallableArray.append_array(ExplosionDamageReceiverCallableArray)
	return OutExplosion

##
## Beep
##
func OnBeepTimerTimeout():
	
	BeepLight.visible = true
	BeepAnimationPlayer.play(&"Beep", -1.0, 2.0 / _DetonateBeepTime)

func PlayBeepSound():
	
	if get_meta(&"DisableBeepSound", false):
		return
	AudioGlobals.TryPlaySound_AtGlobalPosition(SoundBankLabel, BeepSoundEvent, global_position)

##
## Throw
##
var AppliedThrowVectorDirection: Vector2
var AppliedThrowVectorScale: float

func GetThrowImpulseFromThrowVector(InThrowVector: Vector2) -> Vector2:
	
	var OutImpulse = InThrowVector
	
	if _ThrowBombImpulseScale > 0.0:
		OutImpulse *= _ThrowBombImpulseScale * mass
	return OutImpulse

func ApplyThrowImpulse(InThrowVector: Vector2):
	
	assert(AwaitForThrowImpulse)
	
	var Impulse := GetThrowImpulseFromThrowVector(InThrowVector)
	apply_central_impulse(Impulse)
	
	rotation += deg_to_rad(randf_range(_ThrowAngleMinMax.x, _ThrowAngleMinMax.y))
	set_angular_velocity(randf_range(_ThrowAngularVelocityMinMax.x, _ThrowAngularVelocityMinMax.y))
	
	var ThrowVectorLength := InThrowVector.length()
	AppliedThrowVectorDirection = InThrowVector / ThrowVectorLength
	AppliedThrowVectorScale = ThrowVectorLength * 0.002
	#print(AppliedThrowVectorScale)
	
	if _DetonateDelayCurve:
		DetonateDelay = _DetonateDelayCurve.sample_baked(AppliedThrowVectorScale)
		#print(DetonateDelay)
	
	if ThrowSoundEvent:
		AudioGlobals.TryPlaySoundVaried_AtGlobalPosition(SoundBankLabel, ThrowSoundEvent, global_position, GetThrowSoundPitchMul(), GetThrowSoundVolumeDb())
	
	ThrowImpulseApplied.emit()
