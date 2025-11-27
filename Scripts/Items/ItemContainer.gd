@abstract
extends Node
class_name ItemContainer

static func get_all_containers_in_owner(in_owner: Node) -> Array[ItemContainer]:
	
	var out_array: Array[ItemContainer] = []
	
	for sample_child: Node in in_owner.get_children():
		if sample_child is ItemContainer:
			out_array.append(sample_child)
	return out_array

var _items_num_dictionary: Dictionary[ItemData, int]
@export var _slots_num_max: int = 100

signal items_changed()
signal item_added(in_item_data: ItemData, in_added_num: int)
signal item_removed(in_item_data: ItemData, in_removed_num: int)

func _ready() -> void:
	pass

func _enter_tree():
	ModularGlobals.init_modular_node(self)

func _exit_tree():
	ModularGlobals.deinit_modular_node(self)

func get_items_dictionary_string() -> String:
	var paths_dictionary := {}
	for sample_item_data: ItemData in _items_num_dictionary.keys():
		paths_dictionary[sample_item_data.resource_path] = _items_num_dictionary[sample_item_data]
	return JSON.stringify(paths_dictionary)

func set_items_from_dictionary_string(in_dictionary_string: String) -> void:
	var parsed_dictionary := JSON.parse_string(in_dictionary_string) as Dictionary
	for sample_path: String in parsed_dictionary.keys():
		set_item_num(load(sample_path), parsed_dictionary[sample_path])

func get_items_num(in_item_data: ItemData) -> int:
	return _items_num_dictionary.get(in_item_data, 0)

func get_slots_num_occupied() -> int:
	return _items_num_dictionary.size()

func get_slots_num_max() -> int:
	return _slots_num_max

func get_items_array() -> Array[ItemData]:
	return _items_num_dictionary.keys()

func set_item_num(in_item_data: ItemData, in_set_num: int) -> void:
	
	var delta := in_set_num - get_items_num(in_item_data)
	if delta > 0:
		try_add_item(in_item_data, delta)
	elif delta < 0:
		try_remove_item(in_item_data, -delta)

func can_add_item(in_item_data: ItemData, in_add_num: int = 1) -> bool:
	
	var items_num := get_items_num(in_item_data)
	
	if items_num == 0:
		return get_slots_num_occupied() < get_slots_num_max()
	else:
		if in_item_data.max_stack > 0:
			return (items_num + in_add_num) <= in_item_data.max_stack
		else:
			return true

func try_add_item(in_item_data: ItemData, in_add_num: int = 1) -> bool:
	
	if not can_add_item(in_item_data, in_add_num):
		return false
	
	_handle_add_item(in_item_data, in_add_num)
	return true

func _handle_add_item(in_item_data: ItemData, in_add_num: int) -> void:
	
	var prev_num := get_items_num(in_item_data)
	_items_num_dictionary[in_item_data] = prev_num + in_add_num
	
	item_added.emit(in_item_data, in_add_num)
	items_changed.emit()

func can_remove_item(in_item_data: ItemData, in_remove_num: int = 1) -> bool:
	return _items_num_dictionary.get(in_item_data, 0) >= in_remove_num

func try_remove_item(in_item_data: ItemData, in_remove_num: int = 1) -> bool:
	
	if not can_remove_item(in_item_data, in_remove_num):
		return false
	
	_handle_remove_item(in_item_data, in_remove_num)
	return true

func _handle_remove_item(in_item_data: ItemData, in_remove_num: int) -> void:
	
	var prev_num := get_items_num(in_item_data)
	
	if prev_num <= in_remove_num:
		_items_num_dictionary.erase(in_item_data)
	else:
		_items_num_dictionary[in_item_data] = prev_num - in_remove_num
	
	item_removed.emit(in_item_data, in_remove_num)
	items_changed.emit()

func remove_all_items() -> void:
	for sample_data: ItemData in _items_num_dictionary.keys():
		try_remove_item(sample_data, _items_num_dictionary[sample_data])
