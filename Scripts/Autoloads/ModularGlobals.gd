extends Node
class_name ModularGlobals_Class

class ModularNodeData:
	
	var try_get_from_meta: StringName
	
	func _init(in_script: Script):
		
		try_get_from_meta = in_script.get_global_name()
		
		if try_get_from_meta.is_empty():
			try_get_from_meta = in_script.get_base_script().get_global_name()
		assert(not try_get_from_meta.is_empty())

var modular_node_data_dictionary: Dictionary[Script, ModularNodeData]

func get_or_create_modular_node_data(in_script: Script) -> ModularNodeData:
	
	if not modular_node_data_dictionary.has(in_script):
		modular_node_data_dictionary[in_script] = ModularNodeData.new(in_script)
	return modular_node_data_dictionary[in_script]

func try_get_from(in_owner: Node, in_modular_node_script: Script) -> Node:
	var data := get_or_create_modular_node_data(in_modular_node_script)
	return in_owner.get_meta(data.try_get_from_meta) if is_instance_valid(in_owner) and in_owner.has_meta(data.try_get_from_meta) else null

func init_modular_node(in_node: Node, in_script: Script = in_node.get_script(), in_owner = in_node.get_parent()) -> void:
	var data := get_or_create_modular_node_data(in_script)
	if is_instance_valid(in_owner): in_owner.set_meta(data.try_get_from_meta, in_node)

func deinit_modular_node(in_node: Node, in_script: Script = in_node.get_script(), in_owner = in_node.get_parent()) -> void:
	var data := get_or_create_modular_node_data(in_script)
	if is_instance_valid(in_owner): in_owner.remove_meta(data.try_get_from_meta)
