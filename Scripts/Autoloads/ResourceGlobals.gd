extends Node

var Pools: Dictionary = {}
#var pending_resources: Array[String]

#signal resource_threaded_load_finished(in_path: String, in_status: ResourceLoader.ThreadLoadStatus)

#func _ready() -> void:
#	process_mode = Node.PROCESS_MODE_ALWAYS

#func _process(in_delta: float) -> void:
#	
#	for sample_pending: String in pending_resources:
#		
#		var sample_status := ResourceLoader.load_threaded_get_status(sample_pending)
#		if sample_status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
#			resource_threaded_load_finished.emit(sample_pending, sample_status)
#			pending_resources.erase(sample_pending)
#			break

func UtilGetOrCreate(InKeyArray: Array, InInitCallable: Callable) -> Variant:
	
	if not Pools.has(InKeyArray[0]) or not is_instance_valid(Pools[InKeyArray[0]]):
		Pools[InKeyArray[0]] = {}
	var SubPool = Pools[InKeyArray[0]]
	
	for SampleIndex: int in range(1, InKeyArray.size() - 1):
		
		var SampleKey = InKeyArray[SampleIndex]
		if not SubPool.has(SampleKey) or not is_instance_valid(SubPool[SampleKey]):
			SubPool[SampleKey] = {}
		SubPool = SubPool[SampleKey]
	
	var FinalKey = InKeyArray.back()
	if not SubPool.has(FinalKey):
		SubPool[FinalKey] = InInitCallable.call(InKeyArray)
	#else:
	#	print("Getting ", SubPool[FinalKey], " from Pool")
	return SubPool[FinalKey]

## Loading
#func force_get_resource(in_path: String) -> Resource:
#	return ResourceLoader.load_threaded_get(in_path)

## Shapes
func GetOrCreateScaledShape(InShape: Shape2D, InMul: float, InAdditive: float) -> Shape2D:
	assert(InShape)
	return UtilGetOrCreate([ InShape, InMul, InAdditive ], UtilInitScaledShape)

func UtilInitScaledShape(InCurrentKeyArray: Array) -> Shape2D:
	
	var OutShape := InCurrentKeyArray[0] as Shape2D
	var Mul := InCurrentKeyArray[1] as float
	var Additive := InCurrentKeyArray[2] as float
	
	if Mul != 1.0 or Additive != 0.0:
		
		OutShape = OutShape.duplicate()
		if OutShape is CapsuleShape2D:
			OutShape.height = OutShape.height * Mul + Additive
			OutShape.radius = OutShape.radius * Mul + Additive
		elif OutShape is CircleShape2D:
			OutShape.radius = OutShape.radius * Mul + Additive
		elif OutShape is RectangleShape2D:
			OutShape.size = OutShape.size * Mul + Vector2(Additive, Additive)
		else:
			assert(false)
	return OutShape

## Particles
func GetOrCreatePPMWithRadius(InBasePPM: ParticleProcessMaterial, in_radius: float) -> ParticleProcessMaterial:
	return UtilGetOrCreate([ InBasePPM, in_radius ], UtilInitPPMWithRadius)

func UtilInitPPMWithRadius(InCurrentKeyArray: Array) -> ParticleProcessMaterial:
	var OutPPM = InCurrentKeyArray[0].duplicate() as ParticleProcessMaterial
	OutPPM.emission_sphere_radius = InCurrentKeyArray[1]
	return OutPPM

## Emissive
var EmissiveMaterialBase: ShaderMaterial = preload("res://addons/GodotCommons-Core/Assets/Common/EmissiveMaterial.tres")

func GetOrCreateEmissiveMaterial(InMask: Texture2D, InMul: float) -> ShaderMaterial:
	return UtilGetOrCreate([ EmissiveMaterialBase, InMask, InMul ], UtilInitEmissiveMaterial)

func UtilInitEmissiveMaterial(InCurrentKeyArray: Array) -> ShaderMaterial:
	var NewMaterial := InCurrentKeyArray[0].duplicate() as ShaderMaterial
	NewMaterial.set_shader_parameter(&"Mask", InCurrentKeyArray[1])
	NewMaterial.set_shader_parameter(&"Mul", InCurrentKeyArray[2])
	return NewMaterial

## Outline
var OutlineMaterialBase: ShaderMaterial = preload("res://addons/GodotCommons-Core/Assets/Common/OutlineMaterial.tres")

func GetOrCreateOutlineMaterial(in_color: Color) -> ShaderMaterial:
	return UtilGetOrCreate([ OutlineMaterialBase, in_color ], UtilInitOutlineMaterial)

func UtilInitOutlineMaterial(InCurrentKeyArray: Array) -> ShaderMaterial:
	
	var NewMaterial := InCurrentKeyArray[0].duplicate() as ShaderMaterial
	var NewMaterialColor := InCurrentKeyArray[1] as Color
	NewMaterial.set_shader_parameter(&"Color", NewMaterialColor)
	NewMaterial.set_shader_parameter(&"AlphaMul", NewMaterialColor.a)
	return NewMaterial

## SoundBanks
var SoundBankByLabelDictionary: Dictionary

func GetOrCreateSoundBankAndAppendEvent(InLabel: String, InData: SoundEventResource) -> SoundBank:
	return UtilGetOrCreate([ InLabel, InData ], UtilInitSoundBankWithEvent)

func UtilInitSoundBankWithEvent(InCurrentKeyArray: Array) -> SoundBank:
	
	var SampleBank: SoundBank = null
	
	if SoundBankByLabelDictionary.has(InCurrentKeyArray[0]):
		SampleBank = SoundBankByLabelDictionary.get(InCurrentKeyArray[0])
		SampleBank.events.append(InCurrentKeyArray[1])
	else:
		SampleBank = SoundBank.new()
		SampleBank.label = InCurrentKeyArray[0]
		SampleBank.events = [InCurrentKeyArray[1]]
		SampleBank.tree_exited.connect(UtilDeInitSoundBank.bind(SampleBank))
		WorldGlobals._level.add_child(SampleBank)
		SoundBankByLabelDictionary[InCurrentKeyArray[0]] = SampleBank
	SoundManager._event_table[SampleBank.label]["events"] = SoundManager._create_events(SampleBank.events)
	return SampleBank

func UtilDeInitSoundBank(InSoundBank: SoundBank) -> void:
	SoundBankByLabelDictionary.erase(InSoundBank.label)
	InSoundBank.queue_free()

## MusicBanks
var MusicBankByLabelDictionary: Dictionary

func GetOrCreateMusicBankAndAppendEvent(InLabel: String, InData: MusicTrackResource) -> MusicBank:
	return UtilGetOrCreate([ InLabel, InData ], UtilInitMusicBankWithEvent)

func UtilInitMusicBankWithEvent(InCurrentKeyArray: Array) -> MusicBank:
	
	var SampleBank: MusicBank = null
	
	if MusicBankByLabelDictionary.has(InCurrentKeyArray[0]):
		SampleBank = MusicBankByLabelDictionary.get(InCurrentKeyArray[0])
		SampleBank.tracks.append(InCurrentKeyArray[1])
	else:
		SampleBank = MusicBank.new()
		SampleBank.label = InCurrentKeyArray[0]
		SampleBank.tracks = [InCurrentKeyArray[1]]
		SampleBank.tree_exited.connect(UtilDeInitMusicBank.bind(SampleBank))
		WorldGlobals.add_child(SampleBank)
		MusicBankByLabelDictionary[InCurrentKeyArray[0]] = SampleBank
	MusicManager._music_table[SampleBank.label]["tracks"] = MusicManager._create_tracks(SampleBank.tracks)
	return SampleBank

func UtilDeInitMusicBank(InMusicBank: MusicBank) -> void:
	MusicBankByLabelDictionary.erase(InMusicBank.label)
	InMusicBank.queue_free()
