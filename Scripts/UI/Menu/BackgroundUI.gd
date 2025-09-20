extends TextureRect
class_name BackgroundUI

@export_category("Initialize")
@export var EnabledFromStart: bool = false

@export_category("Components")
@export var PulseAP: AnimationPlayer
@export var FadeAP: AnimationPlayer

var gradient_texture: GradientTexture1D

@export var pulse_alpha: float = 0.0:
	set(InAlpha):
		
		pulse_alpha = InAlpha
		
		if gradient_texture:
			gradient_texture.gradient.offsets[1] = 0.25 + 0.5 * pulse_alpha
		#gradient_texture.gradient.colors[1].v = 0.4 + 0.2 * pulse_alpha

func _ready() -> void:
	
	if EnabledFromStart:
		FadeIn(0.0)

func _enter_tree() -> void:
	UIGlobals.BackgroundTextureOverrideChanged.connect(OnTextureOverrideChanged)
	OnTextureOverrideChanged()

func _exit_tree() -> void:
	UIGlobals.BackgroundTextureOverrideChanged.disconnect(OnTextureOverrideChanged)

func OnTextureOverrideChanged() -> void:
	
	if UIGlobals.BackgroundTextureOverride:
		texture = UIGlobals.BackgroundTextureOverride
		gradient_texture = texture as GradientTexture1D

func FadeIn(InDuration: float = 1.0) -> void:
	
	if InDuration > 0.0:
		FadeAP.play(&"FadeIn", InDuration * 0.5, 1.0 / InDuration)
	else:
		FadeAP.play(&"FadeIn")
		FadeAP.advance(100.0)

func FadeOut(InDuration: float = 1.0) -> void:
	
	if InDuration > 0.0:
		FadeAP.play(&"FadeOut", InDuration * 0.5, 1.0 / InDuration)
	else:
		FadeAP.play(&"FadeOut")
		FadeAP.advance(100.0)
