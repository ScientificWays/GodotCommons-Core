extends PointLight2D
class_name OptimizableLight

@export var optimize_on_web_mobile: bool = true
@export var light_energy_to_alpha_curve: Curve = preload("res://addons/GodotCommons-Core/Assets/Lights/LightEnergyToAlpha.tres")
@export var sprite_light_material: Material = preload("res://addons/GodotCommons-Core/Assets/Lights/SpriteLightMaterial.tres")

var _SpriteLight: Sprite2D

func _ready():
	if optimize_on_web_mobile and GameGlobals.IsMobile() and GameGlobals.IsWeb():
		EnableSpriteLight()

func EnableSpriteLight():
	
	enabled = false
	
	assert(not _SpriteLight)
	_SpriteLight = Sprite2D.new()
	_SpriteLight.texture = texture
	_SpriteLight.offset = offset
	_SpriteLight.scale = Vector2(texture_scale, texture_scale)
	_SpriteLight.modulate = color
	#_SpriteLight.modulate.h -= 0.08
	_SpriteLight.modulate.a = light_energy_to_alpha_curve.sample_baked(energy)
	_SpriteLight.z_index = 10
	_SpriteLight.z_as_relative = false
	_SpriteLight.material = sprite_light_material
	add_child(_SpriteLight)

func DisableSpriteLight():
	
	assert(_SpriteLight)
	_SpriteLight.queue_free()
	_SpriteLight = null
	
	enabled = true
