extends Resource
class_name GameModeData

@export_category("Info")
@export var unique_name: StringName
@export var PreviewTexture: Texture2D

func init_new_game_state(in_game_seed: int, InArgs: Dictionary) -> GameState:
	assert(false, "init_new_game_state() is not implemented!")
	return null

@export_category("Player")
@export var PlayerControllerScene: PackedScene

@export_category("Transition")
@export var TransitionScenePath: String
