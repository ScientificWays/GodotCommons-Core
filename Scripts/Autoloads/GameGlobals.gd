extends Node
class_name GameGlobals_Class

@export var ShakeSource2DScene: PackedScene = preload("res://addons/GodotCommons-Core/Scenes/Shake/ShakeSource2D.tscn")

signal pre_explosion_impact(in_explosionImpact: Explosion2D_Impact)
signal post_explosion_apply_impulse(in_explosionImpact: Explosion2D_Impact, in_target: Node2D, in_impulse: Vector2, in_offset: Vector2)

signal PostBarrelRamImpact(InBarrelRoll: BarrelPawn2D_Roll)

signal RequestMiniGameBegin(InMiniGameScene: PackedScene)
signal RequestMiniGameFinish(InForced: bool)

var GetCanvasColorCallable: Callable
func GetCanvasColor() -> Color:
	return GetCanvasColorCallable.call()
signal RequestSetCanvasColor(InColor: Color)

enum GraphicsOption
{
	Minimal,
	Low,
	Average,
	High,
	Ultra
}

signal GibsSettingChanged()
var GibsSetting: GraphicsOption = GraphicsOption.Average if OS.has_feature("mobile") else GraphicsOption.High:
	set(InOption):
		GibsSetting = InOption
		GibsSettingChanged.emit()

var _custom_logger: CustomLogger

func _ready():
	
	_custom_logger = CustomLogger.new()
	
	#DebugMenu.style = DebugMenu.Style.VISIBLE_DETAILED
	#if OS.get_name() == &"Windows":
		#get_window().content_scale_size = Vector2i(1280, 1280) * 2
		#get_window().content_scale_factor = 4.0
		#get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		#Engine.max_fps = 120
	
	#SaveGlobals.SettingsProfile_PhysicsTickRateChanged_ConnectAndTryEmit(OnPhysicsTickRateSettingChanged)

##
## Physics
##
const collision_layer_player: int = 1
const collision_layer_creature: int = 2
const collision_layer_projectile: int = 4
const collision_layer_world: int = 8
const collision_layer_item: int = 16
const collision_layer_item_pull: int = 32
const collision_layer_navigation_block: int = 64
const collision_layer_player_block: int = 128
const collision_layer_explosion_receiver: int = 4096

##
## Timers
##
func spawn_one_shot_timer_for(in_owner: Node, in_callable: Callable, in_delay: float, in_auto_remove: bool = true, in_autostart: bool = true) -> Timer:
	
	if in_delay > 0.0:
		
		var out_timer = Timer.new()
		out_timer.autostart = in_autostart
		out_timer.one_shot = true
		out_timer.timeout.connect(in_callable)
		
		if in_auto_remove:
			out_timer.timeout.connect(out_timer.queue_free)
		
		out_timer.wait_time = in_delay
		in_owner.add_child(out_timer)
		return out_timer
	in_callable.call()
	return null

func spawn_regular_timer_for(in_owner: Node, in_callable: Callable, in_delay: float, in_autostart: bool = true) -> Timer:
	
	assert(in_delay > 0.0)
	var out_timer = Timer.new()
	out_timer.autostart = in_autostart
	out_timer.one_shot = false
	out_timer.timeout.connect(in_callable)
	out_timer.wait_time = in_delay
	in_owner.add_child(out_timer)
	return out_timer

func spawn_await_timer(in_owner: Node, in_delay: float) -> Timer:
	
	assert(in_delay > 0.0)
	var out_timer = Timer.new()
	out_timer.autostart = true
	out_timer.one_shot = false
	out_timer.wait_time = in_delay
	in_owner.add_child(out_timer)
	return out_timer

func delayed_collision_activate(InRigidBody: RigidBody2D, InBodyEnteredCallable: Callable, in_delay: float, InTimerParent: Node):
	
	if in_delay > 0.0:
		GameGlobals.spawn_one_shot_timer_for(InTimerParent, func():
			InRigidBody.body_entered.connect(InBodyEnteredCallable)
			for SampleBody: Node2D in InRigidBody.get_colliding_bodies():
				#print(SampleBody)
				InBodyEnteredCallable.call(SampleBody),
			in_delay)
	else:
		InRigidBody.body_entered.connect(InBodyEnteredCallable)

func calc_radial_impulse_with_offset_for_target(in_target: Node2D, in_origin: Vector2, in_max_impulse: float, in_radius: float, in_impact_ease: float = 1.0) -> Vector4:
	
	var ImpulseOffset := Vector2(0.0, 0.0)
	var ImpulsePosition := Vector2.INF
	
	var TargetImpulsePoints := ImpulsePoints2D.try_get_from(in_target)
	if TargetImpulsePoints:
		
		var ImpulseLocalPosition := TargetImpulsePoints.GetLocalImpulsePosition(in_origin)
		ImpulsePosition = in_target.to_global(ImpulseLocalPosition)
		ImpulseOffset = ImpulseLocalPosition.rotated(in_target.global_rotation)
	else:
		ImpulsePosition = in_target.global_position
	
	var ImpulseVector := ImpulsePosition - in_origin
	var ImpulseDistance := ImpulseVector.length()
	var ImpulseDirection := ImpulseVector / ImpulseDistance
	
	var TargetDistance := ImpulseDistance - in_target.get_meta(DamageReceiver.BoundsRadiusMeta, 4.0) as float
	
	var FinalImpulseAmplitude := in_max_impulse
	if in_radius > 0.0:
		FinalImpulseAmplitude *= (1.0 - ease(clampf(TargetDistance / in_radius, 0.0, 1.0), in_impact_ease))
	
	var OutImpulse := ImpulseDirection * FinalImpulseAmplitude
	return Vector4(OutImpulse.x, OutImpulse.y, ImpulseOffset.x, ImpulseOffset.y)

##
## Arrays
##
static func ArrayIsValidIndex(InArray: Array, InIndex: int) -> bool:
	return InIndex >= 0 and InIndex < InArray.size()

static func ArrayClampIndex(InArray: Array, InIndex: int) -> int:
	return clampi(InIndex, 0, InArray.size() - 1)

static func ArrayRemoveDuplicates(InArray: Array):
	var UniqueElementsDictionary = {}
	for SampleElement in InArray:
		UniqueElementsDictionary[SampleElement] = true
	InArray.assign(UniqueElementsDictionary.keys())

static func ArrayGetRandomIndexWeighted(InWeightArray: Array[float], InRandomFraction: float = randf()) -> int:
	
	var WeightSum: float = 0.0
	
	for SampleWeight: float in InWeightArray:
		WeightSum += SampleWeight
	var WeightThreshold := InRandomFraction * WeightSum
	WeightSum = 0.0
	
	for SampleIndex: int in range(InWeightArray.size()):
		WeightSum += InWeightArray[SampleIndex]
		if WeightSum >= WeightThreshold:
			return SampleIndex
	
	if InRandomFraction > 1.0 or InRandomFraction < 0.0:
		OS.alert("ArrayGetRandomIndexWeighted() bad InRandomFraction \"%s!\"" % InRandomFraction)
	if InWeightArray.is_empty():
		OS.alert("ArrayGetRandomIndexWeighted() InWeightArray is empty!")
	assert(false)
	return -1

static func ArrayFilterParallel(InCheckArray: Array, InParallelArray: Array, OutCheckArray: Array, OutParallelArray: Array, InPredicate: Callable):
	
	for SampleIndex: int in range(InCheckArray.size()):
		
		var SampleData = InCheckArray[SampleIndex]
		if InPredicate.call(SampleData):
			OutCheckArray.append(SampleData)
			OutParallelArray.append(InParallelArray[SampleIndex])

static func ArrayIntersects(InArrayA: Array, InArrayB: Array) -> bool:
	
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
static func get_one_bits_num(in_integer: int, in_acc: int = 0) -> int:
	return get_one_bits_num(in_integer / 2, in_acc + (in_integer % 2)) if in_integer > 0 else in_acc

static func add_mask(in_a: int, in_b: int) -> int:
	return in_a | in_b

static func remove_mask(in_a: int, in_b: int) -> int:
	return in_a & (~in_b)

##
## Random
##
func RandRangeVector2(InVector: Vector2) -> float:
	return randf_range(InVector.x, InVector.y)

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
signal pause_sources_changed()

func AddPauseSource(in_node: Node):
	if not PauseSources.has(in_node):
		PauseSources.append(in_node)
		in_node.tree_exiting.connect(RemovePauseSource.bind(in_node))
		OnPauseSourcesChanged()

func RemovePauseSource(in_node: Node):
	if PauseSources.has(in_node):
		PauseSources.erase(in_node)
		in_node.tree_exiting.disconnect(RemovePauseSource)
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
	
	if not is_inside_tree():
		await tree_entered
	
	if PauseSources.is_empty():
		get_tree().paused = false
	else:
		get_tree().paused = true
	pause_sources_changed.emit()

func OnPhysicsTickRateSettingChanged(in_value: int):
	if in_value < 30 or in_value > 120:
		push_error("Invalid PhysicsTickRate setting %s!" % [ in_value ])
	else:
		Engine.physics_ticks_per_second = in_value

func AppendToObjectMetaArray(InObject: Object, in_name: StringName, InElement: Variant, InDefaultArray: Array = []):
	var MetaArray: Array = InObject.get_meta(in_name, InDefaultArray)
	MetaArray.append(InElement)
	InObject.set_meta(in_name, MetaArray)

##
## Status Effects
##
var status_effect_handle_counter: int = StatusEffectInstance.INVALID_HANDLE

func generate_new_status_effect_handle() -> int:
	status_effect_handle_counter += 1
	return status_effect_handle_counter

##
## Ignite
##
var ignite_small_scene_path: String = "res://addons/GodotCommons-Core/Scenes/Particles/Fire/Fire001_GPU.tscn"
var ignite_small_scene_path_web: String = "res://addons/GodotCommons-Core/Scenes/Particles/Fire/Fire001_CPU.tscn"

@onready var ignite_small_scene: PackedScene = load(ignite_small_scene_path_web if PlatformGlobals_Class.IsWeb() else ignite_small_scene_path)

func ignite_target(in_target: Node2D, in_duration: float) -> void:
	
	var new_ignite = ignite_small_scene.instantiate()
	
	var pivot := ParticlesPivot.new()
	pivot.add_child(new_ignite)
	spawn_one_shot_timer_for(pivot, pivot.detach_and_remove_all, in_duration)
	
	in_target.add_child(pivot)
	in_target.tree_exited.connect(func():
		if in_target.is_queued_for_deletion():
			pivot.detach_and_remove_all()
	)
