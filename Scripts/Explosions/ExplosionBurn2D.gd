extends Sprite2D
class_name ExplosionBurn2D

static func Spawn(InPosition: Vector2, InScene: PackedScene, InRadius: float, InParent: Node = WorldGlobals._level) -> ExplosionBurn2D:
	
	assert(InScene)
	
	var NewExplosionBurn := InScene.instantiate() as ExplosionBurn2D
	NewExplosionBurn.position = InPosition.snapped(Vector2(1.0, 1.0))
	NewExplosionBurn.Radius = InRadius
	InParent.add_child.call_deferred(NewExplosionBurn)
	return NewExplosionBurn

@export_category("Sprite")
@export var _SpriteTextureArray: Array[Texture2D] = [
	preload("res://addons/GodotCommons-Core/Assets/Explosions/Burn001a.png"),
	preload("res://addons/GodotCommons-Core/Assets/Explosions/Burn001b.png"),
	preload("res://addons/GodotCommons-Core/Assets/Explosions/Burn001c.png"),
	preload("res://addons/GodotCommons-Core/Assets/Explosions/Burn001d.png")
]
@export var _SpriteRadiusScaleMul: float = 0.025
@export var _SpriteAlphaMinMax: Vector2 = Vector2(0.5, 0.7)

var Radius: float = 0.0

func _ready():
	
	texture = _SpriteTextureArray.pick_random()
	
	var SpriteScale := Radius * _SpriteRadiusScaleMul
	scale = Vector2(SpriteScale, SpriteScale)
	
	modulate.a = randf_range(_SpriteAlphaMinMax.x, _SpriteAlphaMinMax.y)

#func _enter_tree():
#	WorldGlobals._level._OptimizationManager.RegisterExplosionBurn(self)

#func _exit_tree():
#	WorldGlobals._level._OptimizationManager.UnRegisterExplosionBurn(self)
