extends Node

var Pools: Dictionary = {}

func _ready() -> void:
	#LoadShaderMaterials()
	pass

func UtilGetOrCreate(InKeyArray: Array, InInitCallable: Callable) -> Variant:
	
	if not Pools.has(InKeyArray[0]):
		Pools[InKeyArray[0]] = {}
	var SubPool = Pools[InKeyArray[0]]
	
	for SampleIndex: int in range(1, InKeyArray.size() - 1):
		
		var SampleKey = InKeyArray[SampleIndex]
		if not SubPool.has(SampleKey):
			SubPool[SampleKey] = {}
		SubPool = SubPool[SampleKey]
	
	var FinalKey = InKeyArray.back()
	if not SubPool.has(FinalKey):
		SubPool[FinalKey] = InInitCallable.call(InKeyArray)
	#else:
	#	print("Getting ", SubPool[FinalKey], " from Pool")
	return SubPool[FinalKey]

## Shaders
#var CacheShaderMaterialPaths: Array[String] = [
#	"res://addons/GodotCommons-Core/Assets/Tiles/Grass/DirtGrassFloor001a_Material.tres",
#	"res://addons/GodotCommons-Core/Assets/Tiles/Grass/DirtGrassWall001a_Material.tres",
#	"res://addons/GodotCommons-Core/Assets/Tiles/Grass/StoneGrassFloor001a_Material.tres",
#	"res://addons/GodotCommons-Core/Assets/Tiles/Grass/StoneGrassWall001a_Material.tres",
#]

#func LoadShaderMaterials():
#	
#	for SamplePath: String in CacheShaderMaterialPaths:
#		if not ResourceLoader.has_cached(SamplePath):
#			ResourceLoader.load(SamplePath)

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
func GetOrCreatePPMWithRadius(InBasePPM: ParticleProcessMaterial, InRadius: float) -> ParticleProcessMaterial:
	return UtilGetOrCreate([ InBasePPM, InRadius ], UtilInitPPMWithRadius)

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

func GetOrCreateOutlineMaterial(InColor: Color) -> ShaderMaterial:
	return UtilGetOrCreate([ OutlineMaterialBase, InColor ], UtilInitOutlineMaterial)

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
		WorldGlobals._Level.add_child(SampleBank)
		SoundBankByLabelDictionary[InCurrentKeyArray[0]] = SampleBank
	SoundManager._event_table[SampleBank.label]["events"] = SoundManager._create_events(SampleBank.events)
	return SampleBank
