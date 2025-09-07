extends AnimatedSprite2D
class_name Explosion2D_Sprite

@export_category("Owner")
@export var OwnerExplosion: Explosion2D

@export_category("Sprite")
@export var _SpriteRadiusScaleMul: float = 0.05

func _ready() -> void:
	
	assert(sprite_frames.get_frame_count(animation) > 0)
	var SpriteScale := OwnerExplosion._Radius * _SpriteRadiusScaleMul
	scale = Vector2(SpriteScale, SpriteScale)
	
	#if OS.get_name() != &"Android":
	#	_Sprite.frame_changed.connect(OnExplosionSpriteFrameChanged)
	
	
	play(animation)
