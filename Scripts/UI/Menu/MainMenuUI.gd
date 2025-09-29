@tool
extends CanvasLayer
class_name MainMenuUI

@export_category("Options")
@export var campaigns_option: Button
@export var challenges_option: Button
@export var settings_option: Button
@export var quit_option: Button

@export_category("Tabs")
@export var tabs: TabContainer
@export var campaigns_tab_index: int = 0
@export var challenges_tab_index: int = 1
@export var settings_tab_index: int = 2

func _ready() -> void:
	
	assert(campaigns_option)
	assert(challenges_option)
	assert(settings_option)
	assert(quit_option)
	
	if Engine.is_editor_hint():
		return
	
	campaigns_option.pressed.connect(_on_campaigns_option_pressed)
	challenges_option.pressed.connect(_on_challenges_option_pressed)
	settings_option.pressed.connect(_on_settings_option_pressed)
	
	assert(tabs)
	
	tabs.current_tab = -1
	
	#if GameGlobals_Class.IsWeb():
	#	quit_option.queue_free()
	#else:
	quit_option.pressed.connect(_on_quit_option_pressed)

func _on_campaigns_option_pressed() -> void:
	tabs.current_tab = campaigns_tab_index if (tabs.current_tab != campaigns_tab_index) else -1

func _on_challenges_option_pressed() -> void:
	tabs.current_tab = challenges_tab_index if (tabs.current_tab != challenges_tab_index) else -1

func _on_settings_option_pressed() -> void:
	tabs.current_tab = settings_tab_index if (tabs.current_tab != settings_tab_index) else -1

func _on_quit_option_pressed() -> void:
	UIGlobals.confirm_ui.toggle("QUIT_PROMPT", _handle_confirm_quit)

func _handle_confirm_quit() -> void:
	SaveGlobals.save_local_data(true)
	get_tree().quit()
