@tool
extends LevelHint2D
class_name ItemPoolSpawner2D

const init_pick_up_method_name: StringName = &"ItemPoolSpawner2D_init_pick_up"

@export_category("Pool")
@export var pool_data: ItemPoolData
@export var remove_item_from_pool_after_spawn: bool = true
@export var async_item_scene_loading: bool = true
@export var deferred_spawn: bool = true

signal init_pick_up(in_pick_up: ItemPickUp2D)

signal spawned()
signal spawned_verbose(in_pick_up: ItemPickUp2D)

func _ready() -> void:
	
	if Engine.is_editor_hint():
		pass
	else:
		assert(pool_data)
	
	super()

func try_spawn() -> Node:
	
	var sample_scene := await pool_data.get_random_scene(async_item_scene_loading, remove_item_from_pool_after_spawn)
	if not sample_scene:
		return null
	
	var new_pick_up := sample_scene.instantiate() as ItemPickUp2D
	assert(new_pick_up)
	
	if not new_pick_up:
		return null
	
	new_pick_up.position = position
	
	if new_pick_up.has_method(init_pick_up_method_name):
		new_pick_up.call(init_pick_up_method_name, self)
	
	init_pick_up.emit(new_pick_up)
	
	if deferred_spawn:
		add_sibling.call_deferred(new_pick_up)
	else:
		add_sibling(new_pick_up)
	
	spawned.emit()
	spawned_verbose.emit(new_pick_up)
	return new_pick_up
