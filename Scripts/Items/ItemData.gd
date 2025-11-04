extends Resource
class_name ItemData

@export_category("Info")
@export var display_data: ResourceDisplayData
@export var quality: int = 0

@export_category("Item Container")
@export var target_container_script: Script
@export var use_controller_container: bool = true
@export var max_stack: int = -1

@export_category("Shop")
@export var shop_cost: int = 100
@export var shop_cost_item_data: ItemData

func can_pick_up(in_target: Node) -> bool:
	
	if not is_instance_valid(in_target):
		return false
	
	var target_player := PlayerController.try_get_from(in_target)
	
	#if shop_cost_item_data:
	#	var cost_item_container := ModularGlobals.try_get_from(target_player, shop_cost_item_data.target_container_script) as ItemContainer
	#	if cost_item_container and cost_item_container.can_remove_item(shop_cost_item_data, shop_cost):
	#		pass
	#	else:
	#		return false
	
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
	
	#if shop_cost_item_data:
	#	var cost_item_container := ModularGlobals.try_get_from(in_target, shop_cost_item_data.target_container_script) as ItemContainer
	#	var cost_applied := cost_item_container.try_remove_item(shop_cost_item_data, shop_cost)
	
	var target_container := ModularGlobals.try_get_from(in_target, target_container_script) as ItemContainer
	target_container._handle_add_item(self, 1)
