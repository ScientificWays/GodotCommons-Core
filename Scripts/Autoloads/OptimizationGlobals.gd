extends Node

class NodesManageData:
	
	var limit: int = 40
	var instance_ids: Array[int]
	
	func _get_free_index() -> int:
		for sample_index: int in range(instance_ids.size()):
			if not is_instance_id_valid(instance_ids[sample_index]):
				return sample_index
		return -1
	
	func _append_instance_id(in_instance_id: int) -> void:
		
		if instance_ids.size() == limit:
			var first_instance_id := instance_ids.pop_front()
			if is_instance_id_valid(first_instance_id):
				var first_node := instance_from_id(first_instance_id) as Node2D
				first_node.queue_free()
		
		assert(not instance_ids.has(in_instance_id))
		instance_ids.append(in_instance_id)
		for sample_index: int in range(instance_ids.size()):
			var sample_id := instance_ids[sample_index]
			if is_instance_id_valid(sample_id):
				var sample_node := instance_from_id(sample_id) as Node2D
				sample_node.modulate.a = ease(float(sample_index + 1) / float(instance_ids.size()), 0.2)
	
	func register_node(in_node: Node2D) -> void:
		
		var instance_id := in_node.get_instance_id()
		
		var free_index := _get_free_index()
		if free_index > -1:
			instance_ids[free_index] = instance_id
		else:
			_append_instance_id(instance_id)

var managed_nodes_dictionary: Dictionary[StringName, NodesManageData]

func _ready() -> void:
	get_tree().scene_changed.connect(_on_tree_scene_changed)

func _on_tree_scene_changed() -> void:
	reset_all_managed_nodes()

func register_managed_node(in_identifier: StringName, in_node: Node2D) -> void:
	
	if not managed_nodes_dictionary.has(in_identifier):
		managed_nodes_dictionary[in_identifier] = NodesManageData.new()
	
	var managed_nodes := managed_nodes_dictionary[in_identifier]
	managed_nodes.register_node(in_node)

func reset_all_managed_nodes() -> void:
	print("OptimizationGlobals.reset_all_managed_nodes()")
	managed_nodes_dictionary.clear()
