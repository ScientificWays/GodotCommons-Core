@tool
extends CanvasLayer
class_name HUDUI

@export_category("Owner")
@export var owner_player_controller: PlayerController

@export_category("Transition")
@export var TransitionBackground: BackgroundUI

@export_category("Pause")
@export var pause_button: Button

@export_category("Fade")
@export var fade_color_rect: ColorRect
@export var fade_animation_player: AnimationPlayer

@export var fade_in_animation_name: StringName = &"fade_in"
@export var fade_out_animation_name: StringName = &"fade_out"

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not owner_player_controller:
			owner_player_controller = find_parent("*layer*ontroller")
		if not fade_color_rect:
			fade_color_rect = find_child("*ade*olor*")
		if not fade_animation_player and fade_color_rect:
			fade_animation_player = fade_color_rect.find_child("*nimation*")
	else:
		assert(owner_player_controller)
		assert(TransitionBackground)
		assert(pause_button)
		assert(fade_animation_player)
		
		WorldGlobals.TransitionAreaEnterBegin.connect(OnWorldTransitionAreaEnterBegin)
		TransitionBackground.FadeOut()
		
		pause_button.pressed.connect(_on_pause_button_pressed)
		
		owner_player_controller.fade_in_trigger.connect(_on_owner_fade_in_triggered)
		owner_player_controller.fade_out_trigger.connect(_on_owner_fade_out_triggered)

func OnWorldTransitionAreaEnterBegin(InTransitionArea: LevelTransitionArea2D) -> void:
	TransitionBackground.FadeIn(InTransitionArea.TransitionDelay)

func _on_pause_button_pressed() -> void:
	UIGlobals.pause_menu_ui.toggle()

func _on_owner_fade_in_triggered(in_duration: float, in_color: Color, in_blend: float) -> void:
	fade_color_rect.color = in_color
	fade_animation_player.play(fade_in_animation_name, in_blend, 1.0 / in_duration)

func _on_owner_fade_out_triggered(in_duration: float, in_color: Color, in_blend: float) -> void:
	fade_color_rect.color = in_color
	fade_animation_player.play(fade_out_animation_name, in_blend, 1.0 / in_duration)
