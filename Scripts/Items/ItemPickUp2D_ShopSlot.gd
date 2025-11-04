extends Area2D
class_name ItemPickUp2D_ShopSlot

@export_category("Components")
@export var attribute_set: AttributeSet
@export var damage_receiver: DamageReceiver

@export_category("Cost")
@export var cost_control: Control
@export var cost_label: VHSLabel
@export var cost_image: TextureRect

@export_category("Cage")
@export var cage_body: StaticBody2D
@export var cage_health: float = 80.0
@export var remove_on_disable_cage: bool = true

var owner_pick_up: ItemPickUp2D

func _ready() -> void:
	
	damage_receiver.set_max_health(cage_health)
	damage_receiver.set_health(cage_health)
	damage_receiver.receive_damage_lethal.connect(_on_receive_damage_lethal)
	
	owner_pick_up.pick_up_success.connect(_handle_pick_up_success)
	
	disable_cage(true)
	
	_update_cost()

func _enter_tree() -> void:
	
	owner_pick_up = get_parent()
	assert(owner_pick_up)
	
	cage_body.add_collision_exception_with(owner_pick_up)
	owner_pick_up.freeze_counter += 1
	
	owner_pick_up.can_pick_up_extra_checks.append(check_cost_for_target)

func _exit_tree() -> void:
	
	if is_cage_enabled():
		disable_cage()
	
	cage_body.remove_collision_exception_with(owner_pick_up)
	owner_pick_up.freeze_counter -= 1
	
	owner_pick_up.can_pick_up_extra_checks.erase(check_cost_for_target)

func _update_cost() -> void:
	
	var item_data := owner_pick_up.item_data
	cost_label.label_text = String.num_int64(item_data.shop_cost)
	
	var shop_cost_item_data := item_data.shop_cost_item_data
	assert(shop_cost_item_data)
	cost_image.texture = shop_cost_item_data.display_data.get_image()

func check_cost_for_target(in_target: Node) -> bool:
	
	var target_player := PlayerController.try_get_from(in_target)
	
	var item_data := owner_pick_up.item_data
	var shop_cost_item_data := item_data.shop_cost_item_data
	assert(shop_cost_item_data)
	
	var target_container_script := item_data.target_container_script
	var cost_item_container := ModularGlobals.try_get_from(target_player, shop_cost_item_data.target_container_script) as ItemContainer
	return cost_item_container and cost_item_container.can_remove_item(shop_cost_item_data, item_data.shop_cost)

func _handle_pick_up_success(in_target: Node) -> void:
	
	var target_player := PlayerController.try_get_from(in_target)
	
	var item_data := owner_pick_up.item_data
	var shop_cost_item_data := item_data.shop_cost_item_data
	assert(shop_cost_item_data)
	
	var cost_item_container := ModularGlobals.try_get_from(target_player, shop_cost_item_data.target_container_script) as ItemContainer
	var cost_applied := cost_item_container.try_remove_item(shop_cost_item_data, item_data.shop_cost)
	assert(cost_applied)

func is_cage_enabled() -> bool:
	return cage_body.visible

func enable_cage(in_silent: bool = false) -> void:
	
	assert(in_silent or not is_cage_enabled())
	
	cage_body.visible = true
	cage_body.process_mode = Node.PROCESS_MODE_INHERIT
	damage_receiver.ignore_damage = false
	
	if not in_silent:
		owner_pick_up.block_pick_up_counter += 1
		
		if remove_on_disable_cage:
			cost_control.visible = false

func disable_cage(in_silent: bool = false) -> void:
	
	assert(in_silent or is_cage_enabled())
	
	cage_body.visible = false
	cage_body.process_mode = Node.PROCESS_MODE_DISABLED
	damage_receiver.ignore_damage = true
	
	if not in_silent:
		
		owner_pick_up.block_pick_up_counter -= 1
		
		if remove_on_disable_cage:
			queue_free()
		else:
			cost_control.visible = true

func _on_receive_damage_lethal(in_source: Node, in_damage: float, in_ignored_immunity_time: bool) -> void:
	disable_cage()
