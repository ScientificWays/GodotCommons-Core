extends PointLight2D
class_name Explosion2D_Light

@export_category("Owner")
@export var OwnerExplosion: Explosion2D
@export var OwnerSprite: Explosion2D_Sprite

@export_category("Radius")
@export var _RadiusScaleMul: float = 0.025
@export var _RadiusEnergyMul: float = 0.15

func _ready() -> void:
	
	assert(OwnerExplosion)
	
	assert(_RadiusEnergyMul > 0.0 and _RadiusScaleMul > 0.0)
	texture_scale = OwnerExplosion._Radius * _RadiusScaleMul
	energy = OwnerExplosion._Radius * _RadiusEnergyMul
	
	if OwnerSprite:
		OwnerSprite.frame_changed.connect(OnExplosionSpriteFrameChanged)
		OnExplosionSpriteFrameChanged()

func OnExplosionSpriteFrameChanged():
	
	var FrameNum := OwnerSprite.sprite_frames.get_frame_count(OwnerSprite.animation)
	var AnimationProgress := float(OwnerSprite.frame + 1) / float(FrameNum)
	energy = OwnerExplosion._Radius * _RadiusEnergyMul * sqrt(1.0 - AnimationProgress)
