@tool
extends CanvasLayer
class_name HUDUI

static func try_get_from(in_node: Node) -> HUDUI:
	return ModularGlobals.try_get_from(in_node, HUDUI)

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

@export_category("Healthbar")
@export var healthbar_container: Container
@export var healthbar_scene: PackedScene

@export_category("Joystick")
@export var virtual_joystick: VirtualJoystick

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not owner_player_controller:
			owner_player_controller = find_parent("*layer*ontroller") as PlayerController
		if not fade_color_rect:
			fade_color_rect = find_child("*ade*olor*") as ColorRect
		if not fade_animation_player and fade_color_rect:
			fade_animation_player = fade_color_rect.find_child("*nimation*") as AnimationPlayer
		if not healthbar_container:
			healthbar_container = find_child("*ealth?ar*") as Container
		if not virtual_joystick:
			virtual_joystick = find_child("*irtual*oystick*") as VirtualJoystick
	else:
		assert(owner_player_controller)
		assert(TransitionBackground)
		assert(pause_button)
		assert(fade_animation_player)
		
		WorldGlobals.change_level_transition_begin.connect(_on_change_level_transition_begin)
		TransitionBackground.FadeOut()
		
		pause_button.pressed.connect(_on_pause_button_pressed)
		
		owner_player_controller.fade_in_trigger.connect(_on_owner_fade_in_triggered)
		owner_player_controller.fade_out_trigger.connect(_on_owner_fade_out_triggered)
		
		PawnGlobals.init_pawn_healthbar.connect(_handle_init_pawn_healthbar)

func _enter_tree():
	if not Engine.is_editor_hint():
		ModularGlobals.init_modular_node(self)
		ModularGlobals.init_modular_node(self, owner_player_controller)

func _exit_tree():
	if not Engine.is_editor_hint():
		ModularGlobals.deinit_modular_node(self)
		ModularGlobals.deinit_modular_node(self, owner_player_controller)

func _on_change_level_transition_begin(in_change_level: ChangeLevel) -> void:
	TransitionBackground.FadeIn(in_change_level.transtioin_delay)

func _on_pause_button_pressed() -> void:
	UIGlobals.pause_menu_ui.toggle()

func _on_owner_fade_in_triggered(in_duration: float, in_color: Color, in_blend: float) -> void:
	fade_color_rect.color = in_color
	fade_animation_player.play(fade_in_animation_name, in_blend, 1.0 / in_duration)

func _on_owner_fade_out_triggered(in_duration: float, in_color: Color, in_blend: float) -> void:
	fade_color_rect.color = in_color
	fade_animation_player.play(fade_out_animation_name, in_blend, 1.0 / in_duration)

func _handle_init_pawn_healthbar(in_pawn: Pawn2D) -> void:
	
	assert(healthbar_scene)
	
	var new_healthbar := healthbar_scene.instantiate() as HUDUI_Healthbar
	new_healthbar.target_pawn = in_pawn
	
	healthbar_container.add_child(new_healthbar)
