@tool
extends LevelHint2D
class_name ItemSpawner2D

const init_item_method_name: StringName = &"ItemSpawner2D_init_item"

@export_category("Pawn")
@export var weighted_variants: Dictionary[PackedScene, float]
@export var deferred_spawn: bool = true

signal spawned()
signal spawned_verbose(in_item: ItemPickUp2D)

func _ready() -> void:
	super()

func try_spawn() -> bool:
	
	if weighted_variants.is_empty():
		return false
	
	var item_scenes := weighted_variants.keys()
	var item_weights := weighted_variants.values()
	var sample_index := GameGlobals.array_get_random_index_weighted(item_weights)
	
	var sample_scene := item_scenes[sample_index] as PackedScene
	if not sample_scene:
		return false
	
	var new_item := sample_scene.instantiate() as ItemPickUp2D
	assert(new_item)
	
	if not new_item:
		return false
	
	new_item.position = position
	if new_item.has_method(init_item_method_name):
		new_item.call(init_item_method_name, self, new_item)
	
	if deferred_spawn:
		add_sibling.call_deferred(new_item)
	else:
		add_sibling(new_item)
	
	spawned.emit()
	spawned_verbose.emit(new_item)
	return true
