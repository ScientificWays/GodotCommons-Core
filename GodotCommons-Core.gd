@tool
extends EditorPlugin

func _enter_tree():
	
	add_autoload_singleton("PlatformGlobals", "Scripts/Autoloads/PlatformGlobals.gd")
	add_autoload_singleton("ResourceGlobals", "Scripts/Autoloads/ResourceGlobals.gd")
	add_autoload_singleton("ModularGlobals", "Scripts/Autoloads/ModularGlobals.gd")
	add_autoload_singleton("GameGlobals", "Scripts/Autoloads/GameGlobals.gd")
	add_autoload_singleton("WorldGlobals", "Scripts/Autoloads/WorldGlobals.gd")
	add_autoload_singleton("TileGlobals", "Scripts/Autoloads/TileGlobals.gd")
	add_autoload_singleton("PawnGlobals", "Scripts/Autoloads/PawnGlobals.gd")
	add_autoload_singleton("PlayerGlobals", "Scripts/Autoloads/PlayerGlobals.gd")
	add_autoload_singleton("UIGlobals", "Scripts/Autoloads/UIGlobals.gd")
	add_autoload_singleton("AudioGlobals", "Scripts/Autoloads/AudioGlobals.gd")
	add_autoload_singleton("SaveGlobals", "Scripts/Autoloads/SaveGlobals.gd")
	add_autoload_singleton("OptimizationGlobals", "Scripts/Autoloads/OptimizationGlobals.gd")
	
	add_project_setting(
		GodotCommonsCore_Settings.MAIN_MENU_LEVEL_SETTING_NAME,
		GodotCommonsCore_Settings.MAIN_MENU_LEVEL_SETTING_DEFAULT,
		TYPE_STRING)
	
	add_project_setting(
		GodotCommonsCore_Settings.PAUSE_MENU_UI_SETTING_NAME,
		GodotCommonsCore_Settings.PAUSE_MENU_UI_SETTING_DEFAULT,
		TYPE_STRING)
	
	add_project_setting(
		GodotCommonsCore_Settings.CONFIRM_UI_SETTING_NAME,
		GodotCommonsCore_Settings.CONFIRM_UI_SETTING_DEFAULT,
		TYPE_STRING)
	
	
	add_project_setting(
		GodotCommonsCore_Settings.YANDEX_METRICS_COUNTER_SETTING_NAME,
		GodotCommonsCore_Settings.YANDEX_METRICS_COUNTER_SETTING_DEFAULT,
		TYPE_INT)

func _exit_tree():
	
	remove_autoload_singleton("PlatformGlobals")
	remove_autoload_singleton("ResourceGlobals")
	remove_autoload_singleton("ModularGlobals")
	remove_autoload_singleton("GameGlobals")
	remove_autoload_singleton("WorldGlobals")
	remove_autoload_singleton("TileGlobals")
	remove_autoload_singleton("PawnGlobals")
	remove_autoload_singleton("PlayerGlobals")
	remove_autoload_singleton("UIGlobals")
	remove_autoload_singleton("AudioGlobals")
	remove_autoload_singleton("SaveGlobals")
	remove_autoload_singleton("OptimizationGlobals")

func add_project_setting(in_name: String, in_default: Variant, in_type: int, in_hint: int = PROPERTY_HINT_NONE, in_hint_string: String = ""):
	
	if ProjectSettings.has_setting(in_name): 
		return
	
	ProjectSettings.set_setting(in_name, in_default)
	
	ProjectSettings.add_property_info({
		"name": in_name,
		"type": in_type,
		"hint": in_hint,
		"hint_string": in_hint_string,
	})
	
	var error: int = ProjectSettings.save()
	if error: 
		push_error("GodotCommons-Core: encountered error %d when saving project settings." % error)
