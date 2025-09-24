@tool
extends EditorPlugin

func _enter_tree():
	
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

func _exit_tree():
	
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
