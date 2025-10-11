@abstract
extends Node
class_name ItemContainer

var _item_array: Array[ItemData]

func _ready() -> void:
	pass

func _enter_tree():
	ModularGlobals.init_modular_node(self)

func _exit_tree():
	ModularGlobals.deinit_modular_node(self)

func can_add_item(in_item_data: ItemData) -> bool:
	return true

func try_add_item(in_item_data: ItemData) -> bool:
	
	if not can_add_item(in_item_data):
		return false
	
	_handle_add_item(in_item_data)
	return true

func _handle_add_item(in_item_data: ItemData) -> void:
	pass
