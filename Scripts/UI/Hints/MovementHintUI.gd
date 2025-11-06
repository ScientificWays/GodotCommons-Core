extends Control
class_name MovementHintUI

const HintFinishedMeta: StringName = &"MovementHintUI_Finished"

@export_category("Owner")
var owner_hud: HUDUI

@export_category("Components")
@export var VHSControl: VHSFX

@export_category("Textures")
@export var KeysTextureRect: TextureRect
@export var UpTexture: Texture2D
@export var DownTexture: Texture2D
@export var RightTexture: Texture2D
@export var LeftTexture: Texture2D
@export var NoneTexture: Texture2D

@export_category("Visiblity")
@export var lerp_visible: bool = true
@export var lerp_visible_speed: float = 4.0
@export var highlight_animation_player: AnimationPlayer

signal finished()

var display_time_left: float = 0.0:
	set(InTime):
		
		display_time_left = InTime
		
		if is_node_ready() and not Engine.is_editor_hint():
			
			Update()
			
			if display_time_left <= 0.0:
				HandleFinished()

func _ready() -> void:
	
	if GameGlobals.get_meta(HintFinishedMeta, false) \
	or not PlatformGlobals_Class.IsPC(true):
		queue_free()
		return
	
	owner_hud = get_parent().get_parent()
	
	assert(owner_hud)
	assert(KeysTextureRect)
	
	assert(highlight_animation_player)
	
	SetInstantLerpVisible(lerp_visible)
	Update()

func _process(in_delta: float) -> void:
	
	if lerp_visible:
		modulate.a = minf(modulate.a + lerp_visible_speed * in_delta, 1.0)
	else:
		modulate.a = maxf(modulate.a - lerp_visible_speed * in_delta, 0.0)
	
	if display_time_left <= 0.0:
		return
	
	var movement_input := owner_hud.owner_player_controller.movement_input
	
	if movement_input.is_zero_approx():
		KeysTextureRect.texture = NoneTexture
		KeysTextureRect.self_modulate.a = 0.5
		return
	
	if movement_input.x > 0.0:
		KeysTextureRect.texture = RightTexture
	elif movement_input.x < 0.0:
		KeysTextureRect.texture = LeftTexture
	elif movement_input.y > 0.0:
		KeysTextureRect.texture = DownTexture
	elif movement_input.y < 0.0:
		KeysTextureRect.texture = UpTexture
	
	KeysTextureRect.self_modulate.a = 1.0
	display_time_left -= in_delta

func Update():
	
	var prev_lerp_visible := lerp_visible
	lerp_visible = (display_time_left > 0.0)
	
	if lerp_visible != prev_lerp_visible:
		highlight_animation_player.play(&"highlight")
	
	VHSControl.lerp_visible = lerp_visible

func SetInstantLerpVisible(InLerpVisible: bool) -> void:
	
	lerp_visible = InLerpVisible
	VHSControl.SetInstantLerpVisible(InLerpVisible)
	
	if lerp_visible:
		modulate.a = 1.0
	else:
		modulate.a = 0.0

func HandleFinished():
	
	assert(not Engine.is_editor_hint())
	
	GameGlobals.set_meta(HintFinishedMeta, true)
	finished.emit()
