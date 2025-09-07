extends Node
class_name ModularGlobals_Class

class ModularNodeData:
	
	var TryGetFromMeta: StringName
	
	func _init(InScript: Script):
		TryGetFromMeta = InScript.get_global_name()

var ModularNodeDataDictionary: Dictionary[Script, ModularNodeData]

func GetOrCreateModularNodeData(InScript: Script) -> ModularNodeData:
	
	if not ModularNodeDataDictionary.has(InScript):
		ModularNodeDataDictionary[InScript] = ModularNodeData.new(InScript)
	return ModularNodeDataDictionary[InScript]

func TryGetFrom(InOwnerNode: Node, InModularNodeScript: Script) -> Node:
	var Data := GetOrCreateModularNodeData(InModularNodeScript)
	return InOwnerNode.get_meta(Data.TryGetFromMeta) if is_instance_valid(InOwnerNode) and InOwnerNode.has_meta(Data.TryGetFromMeta) else null

func InitModularNode(InNode: Node) -> void:
	var Data := GetOrCreateModularNodeData(InNode.get_script())
	InNode.get_parent().set_meta(Data.TryGetFromMeta, InNode)

func DeInitModularNode(InNode: Node) -> void:
	var Data := GetOrCreateModularNodeData(InNode.get_script())
	InNode.get_parent().remove_meta(Data.TryGetFromMeta)
