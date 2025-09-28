extends Resource
class_name GameModeData

@export_category("Info")
@export var UniqueName: StringName
@export var PreviewTexture: Texture2D

func init_new_game_state(InGameSeed: int, InArgs: Array) -> GameState:
	assert(false, "init_new_game_state() is not implemented!")
	return null

@export_category("Player")
@export var PlayerControllerScene: PackedScene

@export_category("Transition")
@export var TransitionScenePath: String
