@tool
extends CanvasLayer
class_name MainMenuUI

@export_category("Options")
@export var campaigns_option: Button
@export var challenges_option: Button
@export var settings_option: Button
@export var extras_option: Button
@export var quit_option: Button

@export_category("Tabs")
@export var tabs: TabContainer
@export var campaigns_tab_index: int = 0
@export var challenges_tab_index: int = 1
@export var settings_tab_index: int = 2
@export var extras_tab_index: int = 3

@export_category("Links")
@export var telegram_link: LinkUI
@export var vk_link: LinkUI

func _ready() -> void:
	
	if Engine.is_editor_hint():
		return
	
	assert(campaigns_option)
	assert(challenges_option)
	assert(settings_option)
	assert(extras_option)
	assert(quit_option)
	
	assert(telegram_link)
	assert(vk_link)
	
	campaigns_option.pressed.connect(_on_tab_option_pressed.bind(campaigns_tab_index))
	challenges_option.pressed.connect(_on_tab_option_pressed.bind(challenges_tab_index))
	settings_option.pressed.connect(_on_tab_option_pressed.bind(settings_tab_index))
	extras_option.pressed.connect(_on_tab_option_pressed.bind(extras_tab_index))
	
	assert(tabs)
	
	tabs.current_tab = -1
	
	#if PlatformGlobals_Class.IsWeb():
	#	quit_option.queue_free()
	#else:
	quit_option.pressed.connect(_on_quit_option_pressed)

func _on_tab_option_pressed(in_index: int) -> void:
	tabs.current_tab = in_index if (tabs.current_tab != in_index) else -1

func _on_quit_option_pressed() -> void:
	UIGlobals.confirm_ui.toggle("QUIT_PROMPT", _handle_confirm_quit)

func _handle_confirm_quit() -> void:
	get_tree().quit()
