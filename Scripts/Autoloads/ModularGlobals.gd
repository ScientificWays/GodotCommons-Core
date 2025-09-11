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

func TryGetFrom(InOwner: Node, InModularNodeScript: Script) -> Node:
	var Data := GetOrCreateModularNodeData(InModularNodeScript)
	return InOwner.get_meta(Data.TryGetFromMeta) if is_instance_valid(InOwner) and InOwner.has_meta(Data.TryGetFromMeta) else null

func InitModularNode(InNode: Node, InOwner: Node = InNode.get_parent()) -> void:
	var Data := GetOrCreateModularNodeData(InNode.get_script())
	InOwner.set_meta(Data.TryGetFromMeta, InNode)

func DeInitModularNode(InNode: Node, InOwner: Node = InNode.get_parent()) -> void:
	var Data := GetOrCreateModularNodeData(InNode.get_script())
	InOwner.remove_meta(Data.TryGetFromMeta)
