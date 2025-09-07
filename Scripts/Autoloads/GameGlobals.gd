extends Node
class_name GameGlobals_Class

@export var ShakeSource2DScene: PackedScene = preload("res://addons/GodotCommons-Core/Scenes/Shake/ShakeSource2D.tscn")

signal PreExplosionImpact(InExplosionImpact: Explosion2D_Impact)
signal PostExplosionApplyImpulse(InExplosionImpact: Explosion2D_Impact, InTarget: Node2D, InImpulse: Vector2, InOffset: Vector2)

signal PostBarrelRamImpact(InBarrelRoll: BarrelPawn2D_Roll)

signal RequestMiniGameBegin(InMiniGameScene: PackedScene)
signal RequestMiniGameFinish(InForced: bool)

var GetCanvasColorCallable: Callable
func GetCanvasColor() -> Color:
	return GetCanvasColorCallable.call()
signal RequestSetCanvasColor(InColor: Color)

func _ready():
	
	#DebugMenu.style = DebugMenu.Style.VISIBLE_DETAILED
	#if OS.get_name() == &"Windows":
		#get_window().content_scale_size = Vector2i(1280, 1280) * 2
		#get_window().content_scale_factor = 4.0
		#get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		#Engine.max_fps = 120
	
	#SaveGlobals.SettingsProfile_PhysicsTickRateChanged_ConnectAndTryEmit(OnPhysicsTickRateSettingChanged)
	pass

func SpawnOneShotTimerFor(InOwner: Node, InCallable: Callable, InDelay: float, InAutoRemove: bool = true, InAutostart: bool = true) -> Timer:
	
	if InDelay > 0.0:
		
		var NewTimer = Timer.new()
		NewTimer.autostart = InAutostart
		NewTimer.one_shot = true
		NewTimer.timeout.connect(InCallable)
		
		if InAutoRemove:
			NewTimer.timeout.connect(NewTimer.queue_free)
		
		NewTimer.wait_time = InDelay
		InOwner.add_child(NewTimer)
		return NewTimer
	InCallable.call()
	return null

func SpawnRegularTimerFor(InOwner: Node, InCallable: Callable, InDelay: float, InAutostart: bool = true) -> Timer:
	
	assert(InDelay > 0.0)
	var NewTimer = Timer.new()
	NewTimer.autostart = InAutostart
	NewTimer.one_shot = false
	NewTimer.timeout.connect(InCallable)
	NewTimer.wait_time = InDelay
	InOwner.add_child(NewTimer)
	return NewTimer

func DelayedCollisionActivate(InRigidBody: RigidBody2D, InBodyEnteredCallable: Callable, InDelay: float, InTimerParent: Node):
	
	if InDelay > 0.0:
		GameGlobals.SpawnOneShotTimerFor(InTimerParent, func():
			InRigidBody.body_entered.connect(InBodyEnteredCallable)
			for SampleBody: Node2D in InRigidBody.get_colliding_bodies():
				#print(SampleBody)
				InBodyEnteredCallable.call(SampleBody),
			InDelay)
	else:
		InRigidBody.body_entered.connect(InBodyEnteredCallable)

func CalcRadialImpulseWithOffsetForTarget(InTarget: Node2D, InOrigin: Vector2, InMaxImpulse: float, InRadius: float, InImpactEase: float) -> Vector4:
	
	var ImpulseOffset := Vector2(0.0, 0.0)
	var ImpulsePosition := Vector2.INF
	
	var TargetImpulsePoints := ImpulsePoints2D.TryGetFrom(InTarget)
	if TargetImpulsePoints:
		
		var ImpulseLocalPosition := TargetImpulsePoints.GetLocalImpulsePosition(InOrigin)
		ImpulsePosition = InTarget.to_global(ImpulseLocalPosition)
		ImpulseOffset = ImpulseLocalPosition.rotated(InTarget.global_rotation)
	else:
		ImpulsePosition = InTarget.global_position
	
	var ImpulseVector := ImpulsePosition - InOrigin
	var ImpulseDistance := ImpulseVector.length()
	var ImpulseDirection := ImpulseVector / ImpulseDistance
	
	var TargetDistance := ImpulseDistance - InTarget.get_meta(DamageReceiver.BoundsRadiusMeta, 4.0) as float
	var DistanceMul := (1.0 - ease(clampf(TargetDistance / InRadius, 0.0, 1.0), InImpactEase))
	var FinalImpulseAmplitude := InMaxImpulse * DistanceMul
	
	var OutImpulse := ImpulseDirection * FinalImpulseAmplitude
	return Vector4(OutImpulse.x, OutImpulse.y, ImpulseOffset.x, ImpulseOffset.y)

##
## Arrays
##
func ArrayIsValidIndex(InArray: Array, InIndex: int) -> bool:
	return InIndex >= 0 and InIndex < InArray.size()

static func ArrayClampIndex(InArray: Array, InIndex: int) -> int:
	return clampi(InIndex, 0, InArray.size() - 1)

func ArrayRemoveDuplicates(InArray: Array):
	var UniqueElementsDictionary = {}
	for SampleElement in InArray:
		UniqueElementsDictionary[SampleElement] = true
	InArray.assign(UniqueElementsDictionary.keys())

func ArrayGetRandomIndexWeighted(InWeightArray: Array[float], InRandomFraction: float = randf()) -> int:
	
	var WeightSum: float = 0.0
	
	for SampleWeight: float in InWeightArray:
		WeightSum += SampleWeight
	var WeightThreshold := InRandomFraction * WeightSum
	WeightSum = 0.0
	
	for SampleIndex: int in range(InWeightArray.size()):
		WeightSum += InWeightArray[SampleIndex]
		if WeightSum >= WeightThreshold:
			return SampleIndex
	
	if InRandomFraction > 1.0 or InRandomFraction < 0.0 or true:
		OS.alert("ArrayGetRandomIndexWeighted() bad InRandomFraction \"%s!\"" % InRandomFraction)
	if InWeightArray.is_empty():
		OS.alert("ArrayGetRandomIndexWeighted() InWeightArray is empty!")
	assert(false)
	return -1

func ArrayFilterParallel(InCheckArray: Array, InParallelArray: Array, OutCheckArray: Array, OutParallelArray: Array, InPredicate: Callable):
	
	for SampleIndex: int in range(InCheckArray.size()):
		
		var SampleData = InCheckArray[SampleIndex]
		if InPredicate.call(SampleData):
			OutCheckArray.append(SampleData)
			OutParallelArray.append(InParallelArray[SampleIndex])

func ArrayIntersects(InArrayA: Array, InArrayB: Array) -> bool:
	
	var DictionaryA = {}
	for SampleElementA in InArrayA:
		DictionaryA[SampleElementA] = true
	
	for SampleElementB in InArrayB:
		if DictionaryA.has(SampleElementB):
			return true
	return false

##
## Bits
##
func GetOneBitsNum(InInteger: int, InAcc: int = 0) -> int:
	return GetOneBitsNum(InInteger / 2, InAcc + (InInteger % 2)) if InInteger > 0 else InAcc

##
## Random
##
func RandRangeVector2i(InVector: Vector2i) -> int:
	return randi_range(InVector.x, InVector.y)

##
## Callables
##
func CallAllCancellable(InArray: Array[Callable], InArguments: Array = []) -> bool:
	for SampleCallable: Callable in InArray:
		if SampleCallable.callv(InArguments):
			return true
	return false

##
## Pause 
##
var PauseSources: Array[Node] = []

func AddPauseSource(InNode: Node):
	if not PauseSources.has(InNode):
		PauseSources.append(InNode)
		InNode.tree_exiting.connect(RemovePauseSource.bind(InNode))
		OnPauseSourcesChanged()

func RemovePauseSource(InNode: Node):
	if PauseSources.has(InNode):
		PauseSources.erase(InNode)
		InNode.tree_exiting.disconnect(RemovePauseSource)
		OnPauseSourcesChanged()

func RemoveAllPauseSources():
	for SampleSource: Node in PauseSources.duplicate():
		RemovePauseSource(SampleSource)

func OnPauseSourcesChanged():
	
	var ValidPauseSources: Array[Node] = []
	
	for SampleSource: Node in PauseSources:
		if is_instance_valid(SampleSource):
			ValidPauseSources.append(SampleSource)
	
	PauseSources.clear()
	PauseSources = ValidPauseSources
	
	if PauseSources.is_empty():
		get_tree().paused = false
	else:
		get_tree().paused = true

func OnPhysicsTickRateSettingChanged(InValue: int):
	if InValue < 30 or InValue > 120:
		push_error("Invalid PhysicsTickRate setting %s!" % [ InValue ])
	else:
		Engine.physics_ticks_per_second = InValue

func AppendToObjectMetaArray(InObject: Object, InName: StringName, InElement: Variant, InDefaultArray: Array = []):
	var MetaArray: Array = InObject.get_meta(InName, InDefaultArray)
	MetaArray.append(InElement)
	InObject.set_meta(InName, MetaArray)

static func GetAllFilePathsIn(InPath: String) -> Array[String]:  
	var OutPaths: Array[String] = []  
	var DirectoryStream = DirAccess.open(InPath)  
	DirectoryStream.list_dir_begin()  
	var NextFileName = DirectoryStream.get_next()  
	while not NextFileName.is_empty():  
		var SampleFilePath = InPath + "/" + NextFileName  
		if DirectoryStream.current_is_dir():  
			OutPaths += GetAllFilePathsIn(SampleFilePath)  
		else:  
			OutPaths.append(SampleFilePath)  
		NextFileName = DirectoryStream.get_next()  
	return OutPaths
