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

func util_get_or_create(InKeyArray: Array, InInitCallable: Callable) -> Variant:
	
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
func get_or_create_scaled_shape(in_out_shape: Shape2D, in_mul: float, in_additive: float) -> Shape2D:
	assert(in_out_shape)
	return util_get_or_create([ in_out_shape, in_mul, in_additive ], util_init_scaled_shape)

func util_init_scaled_shape(in_current_key_array: Array) -> Shape2D:
	
	var out_shape := in_current_key_array[0] as Shape2D
	var mul := in_current_key_array[1] as float
	var additive := in_current_key_array[2] as float
	
	if mul != 1.0 or additive != 0.0:
		out_shape = out_shape.duplicate()
		util_scale_shape(out_shape, mul, additive)
	return out_shape

func util_scale_shape(in_out_shape: Shape2D, in_mul: float, in_additive: float) -> void:
	
	if in_out_shape is CapsuleShape2D:
		in_out_shape.height = in_out_shape.height * in_mul + in_additive
		in_out_shape.radius = in_out_shape.radius * in_mul + in_additive
	elif in_out_shape is CircleShape2D:
		in_out_shape.radius = in_out_shape.radius * in_mul + in_additive
	elif in_out_shape is RectangleShape2D:
		in_out_shape.size = in_out_shape.size * in_mul + Vector2(in_additive, in_additive)
	else:
		assert(false)

## Particles
func GetOrCreatePPMWithRadius(InBasePPM: ParticleProcessMaterial, in_radius: float) -> ParticleProcessMaterial:
	return util_get_or_create([ InBasePPM, in_radius ], UtilInitPPMWithRadius)

func UtilInitPPMWithRadius(in_current_key_array: Array) -> ParticleProcessMaterial:
	var OutPPM = in_current_key_array[0].duplicate() as ParticleProcessMaterial
	OutPPM.emission_sphere_radius = in_current_key_array[1]
	return OutPPM

## Emissive
var EmissiveMaterialBase: ShaderMaterial = preload("res://addons/GodotCommons-Core/Assets/Common/EmissiveMaterial.tres")

func GetOrCreateEmissiveMaterial(InMask: Texture2D, in_mul: float) -> ShaderMaterial:
	return util_get_or_create([ EmissiveMaterialBase, InMask, in_mul ], UtilInitEmissiveMaterial)

func UtilInitEmissiveMaterial(in_current_key_array: Array) -> ShaderMaterial:
	var NewMaterial := in_current_key_array[0].duplicate() as ShaderMaterial
	NewMaterial.set_shader_parameter(&"Mask", in_current_key_array[1])
	NewMaterial.set_shader_parameter(&"Mul", in_current_key_array[2])
	return NewMaterial

## Outline
var OutlineMaterialBase: ShaderMaterial = preload("res://addons/GodotCommons-Core/Assets/Common/OutlineMaterial.tres")

func GetOrCreateOutlineMaterial(in_color: Color) -> ShaderMaterial:
	return util_get_or_create([ OutlineMaterialBase, in_color ], UtilInitOutlineMaterial)

func UtilInitOutlineMaterial(in_current_key_array: Array) -> ShaderMaterial:
	
	var NewMaterial := in_current_key_array[0].duplicate() as ShaderMaterial
	var NewMaterialColor := in_current_key_array[1] as Color
	NewMaterial.set_shader_parameter(&"Color", NewMaterialColor)
	NewMaterial.set_shader_parameter(&"AlphaMul", NewMaterialColor.a)
	return NewMaterial

## SoundBanks
var SoundBankByLabelDictionary: Dictionary

func get_or_create_sound_bank_and_append_event(InLabel: String, InData: SoundEventResource) -> SoundBank:
	return util_get_or_create([ InLabel, InData ], UtilInitSoundBankWithEvent)

func UtilInitSoundBankWithEvent(in_current_key_array: Array) -> SoundBank:
	
	var SampleBank: SoundBank = null
	
	if SoundBankByLabelDictionary.has(in_current_key_array[0]):
		SampleBank = SoundBankByLabelDictionary.get(in_current_key_array[0])
		SampleBank.events.append(in_current_key_array[1])
	else:
		SampleBank = SoundBank.new()
		SampleBank.label = in_current_key_array[0]
		SampleBank.events = [in_current_key_array[1]]
		SampleBank.tree_exited.connect(UtilDeInitSoundBank.bind(SampleBank))
		WorldGlobals._level.add_child(SampleBank)
		SoundBankByLabelDictionary[in_current_key_array[0]] = SampleBank
	SoundManager._event_table[SampleBank.label]["events"] = SoundManager._create_events(SampleBank.events)
	return SampleBank

func UtilDeInitSoundBank(InSoundBank: SoundBank) -> void:
	SoundBankByLabelDictionary.erase(InSoundBank.label)
	InSoundBank.queue_free()

## MusicBanks
var MusicBankByLabelDictionary: Dictionary

func GetOrCreateMusicBankAndAppendEvent(InLabel: String, InData: MusicTrackResource) -> MusicBank:
	return util_get_or_create([ InLabel, InData ], UtilInitMusicBankWithEvent)

func UtilInitMusicBankWithEvent(in_current_key_array: Array) -> MusicBank:
	
	var SampleBank: MusicBank = null
	
	if MusicBankByLabelDictionary.has(in_current_key_array[0]):
		SampleBank = MusicBankByLabelDictionary.get(in_current_key_array[0])
		SampleBank.tracks.append(in_current_key_array[1])
	else:
		SampleBank = MusicBank.new()
		SampleBank.label = in_current_key_array[0]
		SampleBank.tracks = [in_current_key_array[1]]
		SampleBank.tree_exited.connect(UtilDeInitMusicBank.bind(SampleBank))
		WorldGlobals.add_child(SampleBank)
		MusicBankByLabelDictionary[in_current_key_array[0]] = SampleBank
	MusicManager._music_table[SampleBank.label]["tracks"] = MusicManager._create_tracks(SampleBank.tracks)
	return SampleBank

func UtilDeInitMusicBank(InMusicBank: MusicBank) -> void:
	MusicBankByLabelDictionary.erase(InMusicBank.label)
	InMusicBank.queue_free()
