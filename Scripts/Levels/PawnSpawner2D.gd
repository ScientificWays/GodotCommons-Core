@tool
extends LevelHint2D
class_name PawnSpawner2D

const init_pawn_method_name: StringName = &"PawnSpawner2D_init_pawn"

@export_category("Pawn")
@export var weighted_variants: Dictionary[PackedScene, float]
@export var deferred_spawn: bool = true

signal spawned()
signal spawned_verbose(in_pawn: Pawn2D)

func _ready() -> void:
	super()

func try_spawn() -> bool:
	
	if weighted_variants.is_empty():
		return false
	
	var pawn_scenes := weighted_variants.keys()
	var pawn_weights := weighted_variants.values()
	var sample_index := GameGlobals.ArrayGetRandomIndexWeighted(pawn_weights)
	
	var sample_scene := pawn_scenes[sample_index] as PackedScene
	if not sample_scene:
		return false
	
	var new_pawn := sample_scene.instantiate() as Pawn2D
	if not new_pawn:
		return false
	
	new_pawn.position = position
	if new_pawn.has_method(init_pawn_method_name):
		new_pawn.call(init_pawn_method_name, self, new_pawn)
	
	if deferred_spawn:
		add_sibling.call_deferred(new_pawn)
	else:
		add_sibling(new_pawn)
	
	spawned.emit()
	spawned_verbose.emit(new_pawn)
	return true
