@tool
extends LevelHint2D
class_name SceneSpawner2D

const init_instance_method_name: StringName = &"SceneSpawner2D_init_instance"

@export_category("Scenes")
@export var weighted_variants: Dictionary[PackedScene, float]
@export var spawn_on_ready: bool = false
@export var deferred_spawn: bool = true

signal spawned()
signal spawned_verbose(in_instance: Node)

func _ready() -> void:
	
	super()
	
	if Engine.is_editor_hint():
		pass
	else:
		if spawn_on_ready:
			try_spawn()

func try_spawn() -> Node:
	
	if weighted_variants.is_empty():
		return null
	
	var scenes := weighted_variants.keys()
	var weights := weighted_variants.values()
	var sample_index := GameGlobals.array_get_random_index_weighted(weights)
	
	var sample_scene := scenes[sample_index] as PackedScene
	if not sample_scene:
		return null
	
	var new_instance := sample_scene.instantiate() as Pawn2D
	assert(new_instance)
	
	if not new_instance:
		return null
	
	new_instance.position = position
	if new_instance.has_method(init_instance_method_name):
		new_instance.call(init_instance_method_name, self)
	
	if deferred_spawn:
		add_sibling.call_deferred(new_instance)
	else:
		add_sibling(new_instance)
	
	spawned.emit()
	spawned_verbose.emit(new_instance)
	return new_instance
