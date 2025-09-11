extends Control
class_name MovementHintUI

const HintFinishedMeta: StringName = &"MovementHintUI_Finished"

@export_category("Owner")
@export var OwnerHUD: HUDUI

@export_category("Components")
@export var VHSControl: VHSFX

@export_category("Textures")
@export var KeysTextureRect: TextureRect
@export var UpTexture: Texture2D
@export var DownTexture: Texture2D
@export var RightTexture: Texture2D
@export var LeftTexture: Texture2D
@export var NoneTexture: Texture2D

signal Finished()

var display_time_left: float = 0.0:
	set(InTime):
		
		display_time_left = InTime
		
		if is_node_ready() and not Engine.is_editor_hint():
			
			Update()
			
			if display_time_left <= 0.0:
				HandleFinished()

func _ready() -> void:
	
	if GameGlobals.get_meta(HintFinishedMeta, false):
		queue_free()
		return
	
	assert(OwnerHUD)
	assert(KeysTextureRect)
	
	visibility_changed.connect(OnVisibilityChanged)
	OnVisibilityChanged()
	
	Update()

func _process(InDelta: float) -> void:
	
	var movement_input := OwnerHUD.OwnerPlayerController.MovementInput
	
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
	display_time_left -= InDelta

func OnVisibilityChanged() -> void:
	set_process(visible)

func Update():
	visible = display_time_left > 0.0

func HandleFinished():
	
	assert(not Engine.is_editor_hint())
	
	GameGlobals.set_meta(HintFinishedMeta, true)
	Finished.emit()
	
	VHSControl.lerp_visible = false
	
	GameGlobals.SpawnOneShotTimerFor(self, queue_free, 0.5)
