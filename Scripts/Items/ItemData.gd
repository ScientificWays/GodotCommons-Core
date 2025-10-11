extends Resource
class_name ItemData

@export_category("Info")
@export var display_data: ResourceDisplayData
@export var quality: int = 0
@export var shop_cost: int = 100

@export_category("Item Container")
@export var target_container_script: Script
@export var use_controller_container: bool = true
@export var max_stack: int = -1

func can_pick_up(in_target: Node) -> bool:
	
	if not is_instance_valid(in_target):
		return false
	
	if target_container_script:
		
		if use_controller_container:
			in_target = PlayerController.try_get_from(in_target)
		
		var target_container := ModularGlobals.try_get_from(in_target, target_container_script)
		if is_instance_valid(target_container):
			return target_container.can_add_item(self)
		else:
			return false
	else:
		return true

func handle_pick_up(in_target: Node) -> void:
	
	assert(target_container_script)
	
	if use_controller_container:
		in_target = PlayerController.try_get_from(in_target)
	
	var target_container := ModularGlobals.try_get_from(in_target, target_container_script) as ItemContainer
	target_container._handle_add_item(self, 1)
